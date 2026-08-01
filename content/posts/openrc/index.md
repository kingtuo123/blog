---
title: "OpenRC"
date: "2026-08-02"
draft: true
toc: true
---


## USE 标志


|||
|:--|:--|
|`audit`  |果你的系统安装了 sys-process/audit 且对安全审计有要求（如企业服务器、合规环境），建议启用。普通桌面用户通常不需要。 |
|`bash`   |在服务脚本中启用 bash 的使用|
|`netifrc`|使用传统的 netifrc 网络管理框架。这会在 /etc/init.d/ 中安装 net.lo 等服务，并依赖 /etc/conf.d/net 进行配置。|
|`newnet` |启用 OpenRC 实验性的“新网络”堆栈。这是多年前试图替代 netifrc 的重写项目，但长期处于不成熟/半停滞状态，社区文档和测试极少。|
|`pam`    |添加对 PAM（Pluggable Authentication Modules 可插拔认证模块）的支持
**`audit`**


