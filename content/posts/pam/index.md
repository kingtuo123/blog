---
title: "Linux PAM"
date: "2026-07-29"
draft: true
---




## 简述

PAM（Pluggable Authentication Modules，可插拔认证模块）。


应用程序无需自己实现密码认证流程，PAM 为应用程序提供了统一的认证 API，且 PAM 能单独配置认证方式（密码、指纹、LDAP 等）。


## 模块类型

{{< table thead=false min-width="160,120" >}}
| 类型 | 说明 | 典型用途 |
|:-----|:-----|:---------|
| **auth** | 认证管理 | 验证用户身份（如密码、指纹识别） |
| **account** | 账户管理 | 检查账户是否过期、是否允许访问等 |
| **password** | 密码管理 | 修改密码时的操作和限制 |
| **session** | 会话管理 | 登录 / 注销时的操作（如挂载目录、记录日志） |
{{< /table >}}


## 控制标志

{{< table thead=true min-width="160,550" >}}
|  | 成功时 | 失败时 |
|:--|:--|:--|
| `required` | 继续执行 | 继续执行，但最终返回失败 |
| `requisite` | 继续执行 | 立即终止，返回失败 |
| `sufficient` | 此模块成功且之前无 `required` 模块失败，立即终止，返回成功 | 继续执行 |
{{< /table >}}

{{< table thead=false min-width="160" >}}
|  | |
|:--|:--|
| `optional` | 若同模块类型中有其它非 `optional` 标志的模块，那么 `optional` 模块的成败不影响最终结果，除非唯一模块。 |
| `include` | 将被包含文件的内容展开并插入到当前位置，等效于复制粘贴 |
| `substack` | 将被包含文件的内容作为一个整体，隔离作用域 |
| `[返回值=动作]` |高级用法，允许根据模块的返回值决定跳转或动作。|
{{< /table >}}

{{< table thead=true min-width="160,200" >}}
|| 返回值 |  |
|:---|:--|:--|
| | `success` | 模块返回成功 |
| | `new_authtok_reqd` | 成功，但需要更新密码（如密码过期） |
| | `ignore` | 模块主动忽略此结果 |
| | `default` | 匹配任何未明确列出的返回值（相当于通配符） |
{{< /table >}}

{{< table thead=true min-width="160,200" >}}
|| 动作 |  |
|:--|:--|:--|
|| `ignore` | 忽略此结果，模块的成败不计入最终状态 |
|| `bad` | 标记失败，继续执行后续模块 |
|| `die` | 标记失败，立即终止|
|| `ok` | 标记成功，继续执行 |
|| `done` | 标记成功，立即终止，并返回成功 |
|| `reset` | 清除此前所有模块的记忆状态，重新开始（相当于忽略之前的所有成败） |
|| `N` | 跳过接下来 N 个模块 |
{{< /table >}}



## 配置文件

```
模块类型   控制标志   模块路径   [模块参数...]
```





## 实例

### passwd




## 其它

 /sbin/agetty <-- sys-apps/util-linux

每个模块执行后，其成败状态会被记录，影响后续模块是否继续执行


是 Linux/Unix 系统中负责认证（Authentication）、授权（Authorization）、账户管理（Account）和会话管理（Session）的核心框架。


在没有 PAM 的时代，每个需要认证的应用程序（如 login、sshd、su）都必须自己实现密码验证逻辑。如果你想把本地密码认证换成 LDAP 或 Kerberos，就必须修改并重新编译这些程序。


PAM 解决了这个问题：

应用程序只负责调用 PAM API（问："这个用户能登录吗？"）

PAM 根据配置文件决定调用哪些模块来回答这个问题

模块负责具体的认证逻辑（查 /etc/shadow 、问 LDAP 服务器、验证硬件密钥等）


```
应用程序 (sshd/login/sudo)
    ↓
libpam (PAM API 库)
    ↓
/etc/pam.d/服务名 (配置文件)
    ↓
pam_unix.so / pam_ldap.so / pam_faillock.so ... (模块)
    ↓
/etc/shadow / LDAP / Kerberos / 硬件令牌 (实际数据源)
```




## 示例

使用 pam_exec 在登录后执行自定义脚本

假设你想在用户登录时发送一条通知

```
session     optional     pam_exec.so /usr/local/bin/login-notify.sh
```
