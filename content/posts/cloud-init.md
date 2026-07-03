---
title: "Cloud-init"
date: "2026-06-26"
---


## 执行流程

{{< text fg="aqua" bold=true >}}Local{{< /text >}}

探测本地数据源（例如 ConfigDrive，它是一个包含网络配置、主机名、SSH 密钥等元数据的 “虚拟光驱”）。

将数据源中提供的网络配置应用于系统。

-----

{{< text fg="aqua" bold=true >}}Network{{< /text >}}

探测网络数据源。

系统配置（主机名、SSH 等）。

执行 `/etc/cloud/cloud.cfg` 文件中 `cloud_init_modules` 的模块。

-----

{{< text fg="aqua" bold=true >}}Config{{< /text >}}

执行 `/etc/cloud/cloud.cfg` 文件中 `cloud_config_modules` 的模块。

-----

{{< text fg="aqua" bold=true >}}Final{{< /text >}}

执行 `/etc/cloud/cloud.cfg` 文件中 `cloud_final_modules` 的模块。

-----





## 数据源中的数据类型

{{< text fg="aqua" bold=true >}}meta-data{{< /text >}}

实例 ID、主机名、网络信息、SSH 公钥等元数据。

-----

{{< text fg="aqua" bold=true >}}vendor-data{{< /text >}}

预设的默认配置（user-data 可覆盖）。

-----

{{< text fg="aqua" bold=true >}}user-data{{< /text >}}

用户自定义配置（YAML、Shell 脚本等）。

-----






## 配置文件

Debian13 中 `cloud-init/stable 25.1.4` 的默认配置文件：

```cfg{ bar="/etc/cloud/cloud.cfg" height=30 }
# The top level settings are used as module
# and system configuration.
# A set of users which may be applied and/or used by various modules
# when a 'default' entry is found it will reference the 'default_user'
# from the distro configuration specified below
users:
   - default


# If this is set, 'root' will not be able to ssh in and they
# will get a message to login instead as the default $user
disable_root: true

# This will cause the set+update hostname module to not operate (if true)
preserve_hostname: false

apt:
   # This prevents cloud-init from rewriting apt's sources.list file,
   # which has been a source of surprise.
   preserve_sources_list: true

# If you use datasource_list array, keep array items in a single line.
# If you use multi line array, ds-identify script won't read array items.
# Example datasource config
# datasource:
#    Ec2:
#      metadata_urls: [ 'blah.com' ]
#      timeout: 5 # (defaults to 50 seconds)
#      max_wait: 10 # (defaults to 120 seconds)




# The modules that run in the 'init' stage
cloud_init_modules:
 - seed_random
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - disk_setup
 - mounts
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - ca-certs
 - rsyslog
 - users-groups
 - ssh

# The modules that run in the 'config' stage
cloud_config_modules:
 - snap
 - ssh-import-id
 - keyboard
 - locale
 - set-passwords
 - grub-dpkg
 - apt-pipelining
 - apt-configure
 - ntp
 - timezone
 - disable-ec2-metadata
 - runcmd
 - byobu

# The modules that run in the 'final' stage
cloud_final_modules:
 - package-update-upgrade-install
 - fan
 - landscape
 - lxd
 - write-files-deferred
 - puppet
 - chef
 - mcollective
 - salt-minion
 - reset_rmc
 - scripts-vendor
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - install-hotplug
 - phone-home
 - final-message
 - power-state-change

# System and/or distro specific settings
# (not accessible to handlers/transforms)
system_info:
   # This will affect which distro class gets used
   distro: debian
   # Default user name + that default users groups (if added/used)
   default_user:
     name: debian
     lock_passwd: True
     gecos: Debian
     groups: [adm, audio, cdrom, dialout, dip, floppy, plugdev, sudo, video]
     sudo: ["ALL=(ALL) NOPASSWD:ALL"]
     shell: /bin/bash
   # Other config here will be given to the distro class and/or path classes
   paths:
      cloud_dir: /var/lib/cloud/
      templates_dir: /etc/cloud/templates/
   package_mirrors:
     - arches: [default]
       failsafe:
         primary: https://deb.debian.org/debian
         security: https://deb.debian.org/debian-security
   ssh_svcname: ssh
```







## User-Data 格式

### YAML 格式

必须以 `#cloud-config` 开头，可用模块参考 [Module reference](https://docs.cloud-init.io/en/latest/reference/modules.html)。

```yaml
#cloud-config
users:
  - name: king
    uid: 1000
    shell: /usr/bin/bash
timezone: Asia/Shanghai
```

{{< notice class="yellow" >}}
模块按 `/etc/cloud/cloud.cfg` 中的模块列表顺序执行，与 `#cloud-config YAML` 中书写的顺序无关。
{{< /notice >}}

{{< notice class="yellow" >}}
`#cloud-config YAML` 中的模块名称与 `/etc/cloud/cloud.cfg` 中的名称会有差异。

例如 `users` 模块的内部名称为 `cc_users_groups`，则在 `/etc/cloud/cloud.cfg` 中的名称为 `users_groups` 或 `users-groups`（不含 `cc_` 前缀）。

内部名称参考文档 [Module reference](https://docs.cloud-init.io/en/latest/reference/modules.html) 模块的 `Internal name` 部分。
{{< /notice >}}

### SHELL 脚本

必须以 `#!` 开头。

```shell
{{< text fg="gray-1" >}}#!/bin/bash{{< /text >}}
useradd -m -s /usr/bin/bash -u 1000 king
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```
