---
title: "Incus 运行 DSH"
date: "2026-11-03"
toc: true
draft: true
---


内核需启用 `Landlock`

## Profile

```bash-session
$ incus profile create dsh
$ incus profile edit dsh
```

```yaml{ copy=true }
config:
  boot.autostart: "true"
  boot.autorestart: "false"
  cloud-init.vendor-data: |
    #cloud-config
    ssh_genkeytypes: []
    write_files:
      - path: /etc/profile.d/gui.sh
        permissions: '0755'
        content: |
          export LANG=en_US.UTF-8
          export LC_ALL=en_US.UTF-8
          export WAYLAND_DISPLAY=wayland-1
          export PIPEWIRE_REMOTE=unix:/mnt/pipewire-0
          export PULSE_SERVER=unix:/mnt/pulse-native
          if [[ -e /mnt/wayland-1 && ! -e /run/user/$(id -u)/wayland-1 ]]; then
              mkdir -p /run/user/$(id -u)
              ln -sf /mnt/wayland-1 /run/user/$(id -u)/wayland-1
          fi
          dbus-update-activation-environment --systemd --all
    runcmd:
      - ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
      - echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
      - echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
      - locale-gen
      - echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
      - sed -i 's/^#DisableSandbox/DisableSandbox/' /etc/pacman.conf
      - touch /etc/systemd/do-not-udevadm-trigger-on-update
      - pacman -Syu --noconfirm base-devel pciutils mesa-utils pipewire-audio ttf-dejavu wqy-microhei foot bash-completion
      - pacman -Scc --noconfirm
      - loginctl enable-linger arch
devices:
  eth0:
    name: eth0
    network: incusbr-1000
    type: nic
  root:
    path: /
    pool: default
    type: disk
  gpu:
    type: gpu
  wayland-socket:
    connect: unix:/run/user/1000/wayland-1
    listen: unix:/mnt/wayland-1
    type: proxy
    bind: instance
    mode: "0700"
    uid: "1000"
    gid: "1000"
    security.gid: "1000"
    security.uid: "1000"
  pipewire-0:
    connect: unix:/run/user/1000/pipewire-0
    listen: unix:/mnt/pipewire-0
    type: proxy
    bind: instance
    mode: "0700"
    uid: "1000"
    gid: "1000"
    security.gid: "1000"
    security.uid: "1000"
  pulse-native:
    connect: unix:/run/user/1000/pulse/native
    listen: unix:/mnt/pulse-native
    type: proxy
    bind: instance
    mode: "0700"
    uid: "1000"
    gid: "1000"
    security.gid: "1000"
    security.uid: "1000"
```


创建容器：

```bash-session
$ incus launch images:archlinux/cloud dsh -p dsh
```

查看 cloud-init 日志：

```bash-session
$ incus exec dsh -- tail -fn +1 /var/log/cloud-init-output.log
$ incus exec dsh -- tail -fn +1 /var/log/cloud-init.log
```

查看 cloud-init 运行状态：

```bash-session
$ incus exec dsh -- cloud-init status --long
```



## DSH


```
pacman -S --noconfirm nodejs npm git
pacman -S --noconfirm firefox
pacman -S --noconfirm pnpm
npm config set registry https://registry.npmmirror.com
npm install -g @deepseek-ai/dsh
dsh plugin --profile web add dsh-network-mode
dsh web --no-open

```


```bash-session
$ machinectl shell arch@.host
$ machinectl shell arch@.host /usr/bin/whoami
```


## nginx

```
pacman -S --noconfirm nginx
systemctl enable nginx
systemctl start nginx
```


```bash-session
$ vim /etc/nginx/nginx.conf
```

```nginx
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
events {
    worker_connections 1024;
}
http {
    server {
        listen 8080;
        location / {
	   proxy_pass http://127.0.0.1:3080;
	   proxy_set_header Host 127.0.0.1:3080;
	   proxy_set_header Origin http://127.0.0.1:3080;
	   proxy_set_header X-Real-IP $remote_addr;
	   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	   proxy_http_version 1.1;
	   proxy_set_header Upgrade $http_upgrade;
	   proxy_set_header Connection "upgrade";
        }
    }
}
```


```bash-session
$ mkdir -p /etc/nginx/ssl
$ openssl req -x509 -nodes -days 825 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/dsh.key \
  -out /etc/nginx/ssl/dsh.crt \
  -subj "/CN=192.168.20.130" \
  -addext "subjectAltName=IP:192.168.20.130"
$ chmod 600 /etc/nginx/ssl/dsh.key
```



## chromium


```
chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --disable-features=WaylandWpColorManagerV1 --force-color-profile=srgb --app="https://你的目标网址.com"
```


## openssh

```
sudo pacman -S openssh
systemctl enable sshd
ssh-keygen -N "" -t ed25519 -f ~/.ssh/dsh_ed25519
```


## 定期更新系统
