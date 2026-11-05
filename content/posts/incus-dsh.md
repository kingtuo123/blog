---
title: "Incus 运行 DeepSeek Harness"
date: "2026-11-05"
---





## 准备

工程配置：

```bash-session{ height=25 }
$ incus project show user-1000
config:
  features.images: "true"
  features.networks: "false"
  features.networks.zones: "true"
  features.profiles: "true"
  features.storage.buckets: "true"
  features.storage.volumes: "true"
  restricted: "true"
  restricted.containers.nesting: allow
  restricted.devices.disk: allow
  restricted.devices.disk.paths: /home/king,/run/user/1000
  restricted.devices.gpu: allow
  restricted.devices.proxy: allow
  restricted.devices.usb: allow
  restricted.idmap.gid: "1000"
  restricted.idmap.uid: "1000"
  restricted.networks.access: incusbr-1000
  restricted.snapshots: allow
```

idmap 配置，参考 [映射本地路径](/posts/incus/#%e6%98%a0%e5%b0%84%e6%9c%ac%e5%9c%b0%e8%b7%af%e5%be%84)：

```bash-session
$ cat /etc/subuid
king:100000:65536
root:1000000:1000000000
root:1000:1
$ cat /etc/subgid
king:100000:65536
root:1000000:1000000000
root:1000:1
```

需要的目录：

```bash-session
$ mkdir -p ~/Incus/dsh/Default
$ mkdir -p ~/.fonts
```






## 创建 profile

```bash-session
$ incus profile create dsh
$ incus profile edit dsh
```

```yaml{ copy=true height=60 }
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
          ulimit -c 0
          if [[ "$(pgrep dsh-web | wc -l)" -gt 2 ]]; then
              echo "dsh-web is already running"
              exit 0
          fi
          pid=$(ss -tlnp | grep 3080 | grep -Po '(?<=pid=)[0-9]+')
          if [[ -n "${pid}" ]]; then
              kill -INT ${pid}
          fi
          coproc dsh {
              dsh web --no-open
          }
          while read line <&"${dsh[0]}"; do
              echo "${line}"
              url=$(echo "${line}" | grep -o 'http://.*token=.*')
              if [[ -n "${url}" ]];then
                  break
              fi
          done
          chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --disable-features=WaylandWpColorManagerV1 --force-color-profile=srgb --app="${url}"
          kill -INT ${dsh_PID} &> /dev/null
          pid=$(ss -tlnp | grep 3080 | grep -Po '(?<=pid=)[0-9]+')
          if [[ -n "${pid}" ]]; then
              kill -INT ${pid}
          fi
    runcmd:
      - loginctl enable-linger arch
      - ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
      - echo -e "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen
      - touch /etc/systemd/do-not-udevadm-trigger-on-update
      - echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
      - pacman -Syu --noconfirm
      - pacman -S --noconfirm --needed base-devel pciutils mesa-utils pipewire-audio bash-completion
      - pacman -S --noconfirm --needed git jq unzip zip poppler imagemagick wget ripgrep fd tree bat
      - pacman -S --noconfirm --needed ttf-dejavu wqy-microhei
      - pacman -S --noconfirm --needed nodejs npm pnpm
      - pacman -S --noconfirm --needed chromium foot lxappearance gnome-themes-extra
      - pacman -Scc --noconfirm
      - npm config set registry https://registry.npmmirror.com
      - npm config set allow-scripts=@deepseek-ai/dsh-subprocess-local,koffi,node-pty,@google/genai,protobufjs --location=user
      - npm install -g @deepseek-ai/dsh
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

{{< notice >}}

说明：

*`loginctl enable-linger arch`* → 确保用户级 systemd 服务在无登录时存活。

*`touch /etc/systemd/do-not-udevadm-trigger-on-update`* → 禁止 systemd 软件包在更新时自动触发 udevadm trigger（会报错）。

{{< /notice >}}





## 创建容器

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

重启容器：

```bash-session
$ incus restart dsh
```





## 配置

设置字体和主题：

```bash-session
$ incus exec dsh -- machinectl shell arch@.host /bin/bash -l -c 'lxappearance'
```

启用鼠标中键粘贴（Chromium 浏览器）：

```bash-session
$ incus exec dsh -- machinectl shell arch@.host /bin/bash -l -c 'gsettings set org.gnome.desktop.interface gtk-enable-primary-paste true'
```




## DSH

安装 `dsh-market` 插件：

```bash-session
$ incus exec dsh -- machinectl shell arch@.host /bin/bash -l -c 'dsh plugin --profile web add dshmarket'
```

浏览器打开 `dsh web`：

```bash-session
$ incus exec dsh -- machinectl shell arch@.host /bin/bash -l -c 'dsh-web'
```





## 更新

```bash-session
$ incus exec dsh -- pacman -Syu --noconfirm
$ incus exec dsh -- npm install -g @deepseek-ai/dsh
```
