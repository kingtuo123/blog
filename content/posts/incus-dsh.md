---
title: "Incus 运行 DSH"
date: "2026-11-03"
toc: true
draft: true
---



## 检查


```bash-session
$ mkdir -p ~/Incus/dsh
```



## Profile

```bash-session
$ incus profile create dsh
$ incus profile edit dsh
```

```yaml{ copy=true }
config:
  boot.autostart: "true"
  boot.autorestart: "false"
  raw.idmap: both 1000 1000
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
              ln -sf /mnt/wayland-1 /run/user/$(id -u)/wayland-1
          fi
          dbus-update-activation-environment --systemd --all
      - path: /usr/local/bin/dsh-web
        permissions: '0755'
        content: |
          #!/bin/bash
          if [[ "$(pgrep dsh-web | wc -l)" -gt 2 ]]; then
              echo "dsh-web is already running"
              exit 0
          fi
          pid=$(ss -tlnp | grep 3080 | grep -Po '(?<=pid=)[0-9]+')
          if [[ -n "${pid}" ]]; then
              kill -9 ${pid}
          fi
          coproc dsh {
              dsh web --no-open
          }
          read line <&"${dsh[0]}"
          url=$(echo "${line}" | grep -o 'http://.*token=.*')
          if [[ -z "${url}" ]];then
              echo "failed to get url"
              exit 1
          fi
          echo ${url}
          chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --disable-features=WaylandWpColorManagerV1 --force-color-profile=srgb --app="${url}"
          kill -9 ${dsh_PID} &> /dev/null
          pid=$(ss -tlnp | grep 3080 | grep -Po '(?<=pid=)[0-9]+')
          if [[ -n "${pid}" ]]; then
              kill -9 ${pid}
          fi
    runcmd:
      - ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
      - echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
      - echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
      - locale-gen
      - echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
      - sed -i 's/^#DisableSandbox/DisableSandbox/' /etc/pacman.conf
      - touch /etc/systemd/do-not-udevadm-trigger-on-update
      - pacman -Syu --noconfirm base-devel pciutils mesa-utils pipewire-audio ttf-dejavu wqy-microhei noto-fonts-cjk foot bash-completion
      - pacman -Scc --noconfirm
      - loginctl enable-linger arch
devices:
  root:
    path: /
    pool: default
    type: disk
  dsh:
    source: /home/king/Incus/dsh
    path: /home/arch
    type: disk
  fonts:
    source: /home/king/.fonts
    path: /home/arch/.fonts
    readonly: true
    type: disk
  eth0:
    name: eth0
    network: incusbr-1000
    type: nic
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

### 测试

```bash-session
$ incus exec dsh -- machinectl shell arch@.host /bin/bash -l -c '/home/arch/dsh-web'
```

### 说明

`sed -i 's/^#DisableSandbox/DisableSandbox/' /etc/pacman.conf`

> 全局禁用 Pacman 在下载文件时使用的沙盒机制。沙盒功能需要内核 `CONFIG_SECURITY_LANDLOCK` 支持

`loginctl enable-linger arch`：

`machinectl shell arch@`

> enable-linger 确保用户级 systemd 服务在无登录时存活，machinectl shell 则帮你获得一个正确的用户登录会话

`touch /etc/systemd/do-not-udevadm-trigger-on-update`

> 禁止 systemd 软件包在更新时自动触发 udevadm trigger

## DSH


```
pacman -S --noconfirm nodejs npm git
pacman -S --noconfirm firefox lxappearance gnome-themes-extra
pacman -S --noconfirm pnpm
npm config set registry https://registry.npmmirror.com
npm config set allow-scripts=@deepseek-ai/dsh-subprocess-local,koffi,node-pty,@google/genai,protobufjs --location=user
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

/etc/systemd/system/auto-sysupgrade.service

```
[Unit]
Description=Automatic system upgrade
[Service]
Type=oneshot
ExecStart=/usr/bin/pacman -Syu --noconfirm
ExecStart=/usr/bin/sync
IOSchedulingClass=idle
```

/etc/systemd/system/auto-sysupgrade.timer

```
[Unit]
Description=Run automatic system upgrade 10min after boot, at most once per day
[Timer]
OnBootSec=10min
OnUnitActiveSec=24h
[Install]
WantedBy=timers.target
```



```
systemctl enable auto-sysupgrade.timer
```

更新：

```
pacman -Syu --noconfirm
npm install -g @deepseek-ai/dsh
```
