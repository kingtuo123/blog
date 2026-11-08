---
title: "Incus 运行 DSH"
date: "2026-11-05"
---





## 准备

工程配置：

```bash-session
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
  security.nesting: "true"
  raw.idmap: both 1000 1000
  cloud-init.vendor-data: |
    #cloud-config
    ssh_genkeytypes: []
    write_files:
      - path: /etc/systemd/system.conf
        permissions: '0644'
        content: |
          [Manager]
          DefaultEnvironment="LANG=en_US.UTF-8"
          DefaultEnvironment="LC_ALL=en_US.UTF-8"
          DefaultEnvironment="WAYLAND_DISPLAY=/mnt/wayland-1"
          DefaultEnvironment="PIPEWIRE_REMOTE=unix:/mnt/pipewire-0"
          DefaultEnvironment="PULSE_SERVER=unix:/mnt/pulse-native"
      - path: /etc/systemd/system/dsh-web.service
        permissions: '0644'
        content: |
          [Unit]
          Description=DSH Web Service
          After=network-online.target systemd-user-sessions.service
          Wants=network-online.target
          [Service]
          Type=simple
          User=arch
          Group=arch
          ExecStart=/usr/bin/dsh web --no-open
          Restart=always
          RestartSec=1s
          Environment="HOME=/home/arch"
          Environment="XDG_RUNTIME_DIR=/run/user/1000"
          Environment="DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
          Environment="PATH=/home/arch/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin"
          [Install]
          WantedBy=multi-user.target
      - path: /usr/local/bin/dsh-web
        permissions: '0755'
        content: |
          #!/bin/bash
          time=$(systemctl show --property=ActiveEnterTimestamp --value dsh-web.service)
          url=$(journalctl -u dsh-web.service --since "${time}" | grep -o 'http://.*token=.*' | tail -n1)
          if [[ "$1" == "url" ]];then
              echo "${url}"
              exit 0
          fi
          if [[ -n "${url}" ]];then
              app="--app=${url}"
          fi
          chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --disable-features=WaylandWpColorManagerV1 --force-color-profile=srgb ${app}
    runcmd:
      - ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
      - echo -e "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen
      - touch /etc/systemd/do-not-udevadm-trigger-on-update
      - echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
      - pacman -Syu --noconfirm
      - pacman -S --noconfirm --needed base-devel pciutils mesa-utils pipewire-audio bash-completion
      - pacman -S --noconfirm --needed openssh git jq uv 7zip unzip zip poppler imagemagick wget ripgrep fd tree bat
      - pacman -S --noconfirm --needed ttf-dejavu wqy-microhei
      - pacman -S --noconfirm --needed nodejs npm pnpm
      - pacman -S --noconfirm --needed chromium foot nwg-look gnome-themes-extra
      - pacman -Scc --noconfirm
      - npm config set registry https://registry.npmmirror.com
      - npm config set allow-scripts=@deepseek-ai/dsh-subprocess-local,koffi,node-pty,@google/genai,protobufjs --location=user
      - npm install -g @deepseek-ai/dsh
      - loginctl enable-linger arch
      - systemctl enable dsh-web.service
      - systemctl enable sshd.service
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
    host_name: dsh
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





## 配置（可选）

设置字体和主题：

```bash-session
$ incus exec dsh -- machinectl shell arch@.host /bin/bash -l -c 'nwg-look'
```

启用鼠标中键粘贴（Chromium 浏览器）：

```bash-session
$ incus exec dsh -- machinectl shell arch@.host /bin/bash -l -c 'gsettings set org.gnome.desktop.interface gtk-enable-primary-paste true'
```

安装 `dsh-market` 插件市场：

```bash-session
$ incus exec dsh -- machinectl shell arch@.host /bin/bash -l -c 'dsh plugin --profile web add dshmarket'
```



## 打开 DSH

### 方法一：从容器内浏览器打开

```bash-session
$ incus exec dsh -- machinectl shell arch@.host /bin/bash -l -c 'dsh-web'
```

### 方法二：从宿主机浏览器打开

需要配置 ssh 转发，创建以下脚本：

```bash-session
$ touch dsh-ssh-forwarding.sh && chmod +x dsh-ssh-forwarding.sh && vim dsh-ssh-forwarding.sh
```

```bash{ bar="dsh-ssh-forwarding.sh" copy=true height=50 }
#!/bin/bash

dsh_home="${HOME}/Incus/dsh"
ssh_key="${HOME}/.ssh/dsh/dsh_ed25519"

function close() {
    ssh_pid=$(ss -nltp | grep '127.0.0.1:3080' | grep -Po '(?<=pid=)[0-9]+')
    if [[ -n "${ssh_pid}" ]]; then
        echo "关闭 ssh 转发..."
        kill -9 ${ssh_pid}
    fi
    echo "退出..."
    exit 0
}

trap close SIGINT
trap close SIGTERM

function get_ip() {
    dsh_ip=$(incus list dsh -c 4 -f csv,noheader | grep -Po '([0-9]{1,3}\.){3}[0-9]{1,3}' | tail -n1)
    if [[ -n "${dsh_ip}" ]];then
        return 0
    else
        return 1
    fi
}

function get_url() {
    url=$(incus exec dsh -- dsh-web url)
    if [[ -n "${url}" ]]; then
        return 0
    else
        return 1
    fi
}

function key_check() {
    local ret=0
    if [[ ! -e "${ssh_key}" || ! -e "${ssh_key}.pub" ]]; then
        echo "创建密钥..."
        rm -f ${ssh_key} ${ssh_key}.pub
        mkdir -p $(dirname ${ssh_key})
        ssh-keygen -N "" -t ed25519 -f ${ssh_key}
        ret=1
    fi
    if ! grep -q -o -F "$(<${ssh_key}.pub)" ${dsh_home}/.ssh/authorized_keys; then
        echo "容器授权..."
        mkdir -p ${dsh_home}/.ssh
        cat ${ssh_key}.pub >> ${dsh_home}/.ssh/authorized_keys
        ret=1
    fi
    return ${ret}
}

while true; do
    until get_ip; do
        echo "等待容器启动..."
        sleep 5
    done
    until get_url; do
        echo "等待获取地址..."
        sleep 5
    done
    until key_check; do
        echo "等待检查密钥..."
        sleep 0
    done
    echo "开启 ssh 转发..."
    echo "${url}"
    ssh -N -o StrictHostKeyChecking=accept-new -i ${ssh_key} -L 127.0.0.1:3080:127.0.0.1:3080 arch@${dsh_ip}
    sleep 5
done
```

运行脚本，然后在浏览器中打开链接即可：

```bash-session
$ ./dsh-ssh-forwarding.sh
开启 ssh 转发...
http://127.0.0.1:3080/?token=D1pv-zN_fA99WCbAOzgRs_M5HjKco814c_7RPsHQO9w
```

要获取 url，也可执行：

```bash-session
$ incus exec dsh -- dsh-web url
```



## 更新

```bash-session
$ incus exec dsh -- pacman -Syu --noconfirm
$ incus exec dsh -- npm install -g @deepseek-ai/dsh
$ incus exec dsh -- pnpm self-update
```



## 代理

容器内修改：

```bash-session
$ incus exec dsh -- vim /etc/systemd/system.conf
```

```{ bar="/etc/systemd/system.conf" }
DefaultEnvironment="http_proxy=http://192.168.20.120:7890"
DefaultEnvironment="https_proxy=http://192.168.20.120:7890"
DefaultEnvironment="no_proxy=localhost,127.0.0.1"
```

重启或执行以下命令：

```bash-session
$ incus exec dsh -- systemctl daemon-reexec
```

测试：

```bash-session
$ incus exec dsh -- machinectl shell arch@.host /bin/bash -l -c 'curl www.google.com'
```




## 常用插件

```
billion-context
dsh-cost-meter
dsh-everforest
dsh-archive-manager
dsh-net-proxy
```
