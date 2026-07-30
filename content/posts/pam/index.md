---
title: "Linux PAM"
date: "2026-07-29"
draft: true
---




## 简述

PAM（Pluggable Authentication Modules，可插拔认证模块）。


应用程序无需自己实现密码认证流程，PAM 为应用程序提供了统一的认证 API，且 PAM 能单独配置认证方式（密码、指纹、LDAP 等）。


## 配置文件

```bash{ bar="路径:/etc/pam.d/服务名" }
模块类型   控制标志   模块路径   [模块参数...]
```

### 模块类型

{{< table thead=false min-width="160,120" >}}
| 类型 | 说明 | 典型用途 |
|:-----|:-----|:---------|
| `auth` | 认证管理 | 验证用户身份（如密码、指纹识别） |
| `account` | 账户管理 | 检查账户是否过期、是否允许访问等 |
| `password` | 密码管理 | 修改密码时的操作和限制 |
| `session` | 会话管理 | 登录 / 注销时的操作（如挂载目录、记录日志） |
{{< /table >}}


### 控制标志


{{< table thead=false min-width="160" >}}
|  | |
|:--|:--|
| `required` | 若成功继续执行；若失败，继续执行，但最终返回失败。 |
| `requisite` | 若成功继续执行；若失败，立即终止并返回失败。 |
| `sufficient` | 若成功且之前无 `required` 模块失败，立即终止并返回成功；若失败，继续执行。 |
| `optional` | 若同模块类型中有其它非 `optional` 标志的模块，那么 `optional` 模块的成败不影响最终结果，除非唯一模块。 |
| `include` | 将被包含文件的同类型模块插入到当前位置，等效于复制粘贴。 |
| `substack` | 将被包含文件的同类型模块作为一个整体，隔离作用域。 |
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







## 实例

### passwd

```bash{ bar="/etc/pam.d/passwd" linenos=inline }
auth         sufficient  pam_rootok.so
auth         include     system-auth
account      include     system-auth
password     include     system-auth
```

```text{ nonebg=true }
 1. 检查当前用户是否为 root，是 -> 立即返回成功，否 -> 继续执行。
 2. 执行 system-auth 中的 auth     类型模块。
 3. 执行 system-auth 中的 account  类型模块。
 4. 执行 system-auth 中的 password 类型模块。
```

```bash{ bar="/etc/pam.d/system-auth" linenos=inline }
auth        required    pam_env.so
auth        requisite   pam_faillock.so preauth
auth        [success=1 new_authtok_reqd=1 ignore=ignore default=bad]    pam_unix.so nullok  try_first_pass
auth        [default=die]   pam_faillock.so authfail
auth        optional    pam_cap.so
account     required    pam_unix.so
account     required    pam_faillock.so
password    required    pam_passwdqc.so config=/etc/security/passwdqc.conf
password    required    pam_unix.so try_first_pass shadow use_authtok nullok yescrypt
session     required    pam_limits.so
session     required    pam_env.so
session     required    pam_unix.so
```

```text{ nonebg=true }
  1. 设置 PATH、LANG 等环境变量。
  2. 在询问用户密码之前，检查该用户是否已被 faillock 锁定（失败次数超过阈值）。
  3. 验证密码，成功/密码过期/忽略 -> 跳过下一个模块，其它返回值 -> 继续执行。
  4. 立即终止，返回失败。
  5. 设置 Linux Capabilities（进程权能），例如让普通用户程序拥有某些特权。成败不影响认证结果，走到这里说明认证已经成功。
  6. 检查账户是否被禁用、是否过期。
  7. 检查该用户是否已被 faillock 锁定（失败次数超过阈值）。
  8. 检查密码强度，使用 /etc/security/passwdqc.conf 配置文件控制规则（最小长度、是否允许字典单词、字符类要求等）。
  9. 强制使用上一个模块（passwdqc）传递过来的新密码，不再自行交互式询问用户。
 10. 应用 /etc/security/limits.conf （及 limits.d/*.conf）中的资源限制（如最大打开文件数、最大进程数、内存/CPU 限制）。
 11. 加载环境变量。
 12. 记录登录日志、更新 utmp/wtmp/lastlog。
```


> 不同模块类型会调用模块中不同的函数，如上面的 `account     required    pam_unix.so` 和 `session     required    pam_unix.so`
> 两者调用 `pam_unix.so` 中的不同函数，功能自然也不同。


### login

```bash{ bar="/etc/pam.d/login" linenos=inline }
auth        include     system-local-login
account     include     system-local-login
password    include     system-local-login
session     include     system-local-login
```

```bash{ bar="/etc/pam.d/system-local-login" linenos=inline }
auth        include     system-login
account     include     system-login
password    include     system-login
session     include     system-login
```

```bash{ bar="/etc/pam.d/system-login" linenos=inline }
auth        required    pam_nologin.so
auth        include     system-auth
account     required    pam_access.so
account     required    pam_nologin.so
account     required    pam_time.so
account     include     system-auth
password    include     system-auth
session     optional    pam_loginuid.so
session     required    pam_env.so envfile=/etc/profile.env
session     include     system-auth
session     optional    pam_motd.so motd=/etc/motd
session     optional    pam_lastlog.so never showfailed
session     optional    pam_mail.so
-session    optional    pam_elogind.so
-session    optional    pam_openrc.so
```

```text{ nonebg=true }
  1. 若 /etc/nologin 存在（且登录者非 root），直接拒绝。
  2. 执行 system-auth 中的 auth 类型模块。
  3. 来源控制：只允许特定用户从特定终端 / IP 登录，配置文件 /etc/security/access.conf。
  4. 二次确认：再次检查 /etc/nologin，与 auth 阶段双保险。
  5. 时间控制：只允许在特定时段登录，配置文件 /etc/security/time.conf。
  6. 账户检查：执行 system-auth 中的 account 类型模块（账户是否过期、被禁用等）。
  7. 密码修改：执行 system-auth 中的 password 类型模块。
  8. 为当前进程设置内核 loginuid（写入 /proc/self/loginuid ）。
  9. 加载环境变量，envfile=/etc/profile.env 是 Gentoo 特有路径，由 env-update 命令生成，包含 PATH、LDPATH 等系统级变量。
 10. 通用 session 栈，执行 system-auth 中的 session 类型模块。
 11. 显示 /etc/motd 登录成功后提示信息。
 12. 显示上次登录信息。
 13. 检查 /var/mail/用户名，是否有未读邮件。
 14. 在 elogind 进程中注册用户会话，设置 XDG_* 等变量。
 15. OpenRC 会话追踪。通知 OpenRC 有一个用户会话启动，影响关机顺序（确保有用户登录时不贸然关机）。
```

> 前缀 `-` 表示模块不存在也不报错。


```
用户登陆的流程
init -> /etc/inittab -> agetty（控制台） -> login（输入用户名/密码）-> /sbin/login -> PAM 模块 /etc/pam.d/login -> elogind 会话注册 -> 登陆
```



## 其它

man pam_*

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
