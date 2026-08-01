---
title: "Linux PAM"
date: "2026-08-01"
toc: true
---




## 简述

PAM（Pluggable Authentication Modules，可插拔认证模块）。


应用程序无需自己实现密码认证流程，PAM 为应用程序提供了统一的认证 API，且 PAM 能单独配置认证方式（密码、指纹、LDAP 等）。


## 配置文件

```bash{ bar="路径:/etc/pam.d/服务名" }
管理组类型   控制标志   模块路径   [模块参数...]
```

### 管理组类型

{{< table thead=false min-width="160,120" >}}
| 类型 | 说明 | 典型用途 |
|:-----|:-----|:---------|
| `auth` | 认证管理 | 验证用户身份（如密码、指纹识别） |
| `account` | 账户管理 | 检查账户是否过期、是否允许访问等 |
| `password` | 密码管理 | 修改密码时的操作和限制 |
| `session` | 会话管理 | 登录 / 注销时的操作（如挂载目录、记录日志） |
{{< /table >}}



### 控制标志

用于控制 PAM 栈中模块的执行流程。

{{< table thead=false min-width="160" >}}
|  | |
|:--|:--|
| `required` | 若成功继续执行；若失败，继续执行，但最终返回失败。 |
| `requisite` | 若成功继续执行；若失败，立即终止并返回失败。 |
| `sufficient` | 若成功且之前无 `required` 模块失败，立即终止并返回成功；若失败，继续执行。 |
| `optional` | 若同模块类型中有其它非 `optional` 标志的模块，那么 `optional` 模块的成败不影响最终结果，除非唯一模块。 |
| `include` | 将被包含文件的同类型模块插入到当前位置，相当于复制粘贴。 |
| `substack` | 将被包含文件的同类型模块作为一个整体，相当于函数调用。 |
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


### 模块路径

```bash-session{ height=30 }
$ ls -1 /usr/lib64/security
{{< text fg="green" >}}pam_access.so           {{< /text >}} - 基于 /etc/security/access.conf 等文件，按用户名、来源 IP/主机、终端等条件允许或拒绝登录。
{{< text fg="green" >}}pam_canonicalize_user.so{{< /text >}} - 将用户名规范化（如去除域名后缀、统一大小写或解析别名），确保后续模块收到标准格式用户名。
{{< text fg="green" >}}pam_cap.so              {{< /text >}} - 在认证过程中为进程设置或继承 Linux capabilities（细粒度权限），实现无需 setuid 授予特定特权。
{{< text fg="green" >}}pam_cgfs.so             {{< /text >}} - 在用户登录时为其创建或挂载 cgroup 文件系统层级，常用于容器环境（如 LXC/LXD）。
{{< text fg="green" >}}pam_debug.so            {{< /text >}} - 调试模块，将 PAM 调用参数和返回结果记录到日志，用于排查认证流程问题。
{{< text fg="green" >}}pam_deny.so             {{< /text >}} - 无条件拒绝访问，常用于测试或作为“默认拒绝”的后备模块。
{{< text fg="green" >}}pam_echo.so             {{< /text >}} - 在认证过程中向用户打印指定文本信息（如提示、警告）。
{{< text fg="green" >}}pam_elogind.so          {{< /text >}} - 集成 elogind（独立的登录/会话管理器），跟踪用户会话、席位（seat）和运行时目录。
{{< text fg="green" >}}pam_env.so              {{< /text >}} - 根据 /etc/security/pam_env.conf 等配置，为用户会话设置或修改环境变量。
{{< text fg="green" >}}pam_exec.so             {{< /text >}} - 调用外部命令或脚本，将其执行结果作为认证/会话管理的一部分。
{{< text fg="green" >}}pam_faildelay.so        {{< /text >}} - 设置认证失败后的强制延迟时间，用于减缓暴力破解。
{{< text fg="green" >}}pam_faillock.so         {{< /text >}} - 记录连续认证失败次数，在达到阈值后锁定账户（失败锁定）。
{{< text fg="green" >}}pam_filter.so           {{< /text >}} - 在 PAM 对话流中插入外部过滤器程序，对输入输出进行转换或过滤（极少使用）。
{{< text fg="green" >}}pam_ftp.so              {{< /text >}} - 为 FTP 服务提供匿名用户认证支持，允许无需真实系统账户的 FTP 访问。
{{< text fg="green" >}}pam_group.so            {{< /text >}} - 根据 /etc/security/group.conf 的规则，在登录时动态授予用户额外的附属组权限。
{{< text fg="green" >}}pam_issue.so            {{< /text >}} - 在显示登录提示前，输出 /etc/issue 文件的内容。
{{< text fg="green" >}}pam_keyinit.so          {{< /text >}} - 在登录时初始化或链接内核会话密钥环（session keyring）。
{{< text fg="green" >}}pam_lastlog.so          {{< /text >}} - 记录用户本次登录信息，并在登录时显示其上一次的登录时间/来源。
{{< text fg="green" >}}pam_limits.so           {{< /text >}} - 根据 /etc/security/limits.conf 设置用户的系统资源限制（如最大进程数、打开文件数、内存等）。
{{< text fg="green" >}}pam_listfile.so         {{< /text >}} - 根据指定文本文件中的列表（用户、组、终端等）允许或拒绝访问。
{{< text fg="green" >}}pam_localuser.so        {{< /text >}} - 检查用户是否存在于本地 /etc/passwd 中，常用于跳过 LDAP 等远程认证流程。
{{< text fg="green" >}}pam_loginuid.so         {{< /text >}} - 设置内核审计子系统的 loginuid，以便追踪用户会话生命周期内的所有进程。
{{< text fg="green" >}}pam_mail.so             {{< /text >}} - 检查用户邮箱（如 /var/mail/$USER），在登录时提示是否有新邮件。
{{< text fg="green" >}}pam_mkhomedir.so        {{< /text >}} - 若用户主目录不存在，则自动创建（通常从 /etc/skel 复制配置文件）。
{{< text fg="green" >}}pam_motd.so             {{< /text >}} - 登录成功后显示“今日消息”（/etc/motd 及相关目录中的内容）。
{{< text fg="green" >}}pam_namespace.so        {{< /text >}} - 实现目录多实例化（Polyinstantiation），为用户会话创建隔离的私有命名空间（如独立的 /tmp、/var/tmp 视图）。
{{< text fg="green" >}}pam_nologin.so          {{< /text >}} - 检查 /etc/nologin 文件是否存在，若存在则拒绝非 root 用户登录（用于系统维护）。
{{< text fg="green" >}}pam_openrc.so           {{< /text >}} - 与 OpenRC 初始化系统集成，在用户登录/注销时触发相关服务或设置运行时环境。
{{< text fg="green" >}}pam_passwdqc.so         {{< /text >}} - 密码质量检查器，强制要求密码满足复杂度、长度和多样性策略。
{{< text fg="green" >}}pam_permit.so           {{< /text >}} - 无条件允许访问，常用于测试或作为“默认允许”的后备模块。
{{< text fg="green" >}}pam_pwhistory.so        {{< /text >}} - 维护密码历史数据库，防止用户重复使用近期已用过的密码。
{{< text fg="green" >}}pam_rhosts.so           {{< /text >}} - 基于 ~/.rhosts 和 /etc/hosts.equiv 进行认证（传统 Berkeley r-commands 风格，安全性差，已不推荐使用）。
{{< text fg="green" >}}pam_rootok.so           {{< /text >}} - 若当前用户 UID 为 0（root），则无条件返回成功。
{{< text fg="green" >}}pam_securetty.so        {{< /text >}} - 限制 root 用户只能通过 /etc/securetty 中列出的“安全终端”登录。
{{< text fg="green" >}}pam_setquota.so         {{< /text >}} - 在登录时为用户设置磁盘配额限制。
{{< text fg="green" >}}pam_shells.so           {{< /text >}} - 检查用户登录 shell 是否存在于 /etc/shells 列表中，若不在则拒绝登录。
{{< text fg="green" >}}pam_stress.so           {{< /text >}} - 压力测试模块，用于对 PAM 框架本身进行压力测试和返回码模拟。
{{< text fg="green" >}}pam_succeed_if.so       {{< /text >}} - 根据 UID、GID、用户名、shell 等条件进行判断，实现 PAM 配置中的条件分支控制。
{{< text fg="green" >}}pam_time.so             {{< /text >}} - 基于 /etc/security/time.conf 按时间段限制用户登录（如仅允许工作时间访问）。
{{< text fg="green" >}}pam_timestamp.so        {{< /text >}} - 为终端认证提供时间戳缓存（类似 sudo 的 timestamp_timeout），短时间内免重复输入密码。
{{< text fg="green" >}}pam_umask.so            {{< /text >}} - 设置用户会话的文件创建掩码（umask）。
{{< text fg="green" >}}pam_unix.so             {{< /text >}} - 传统 Unix 认证核心模块，通过 /etc/passwd、/etc/shadow 进行密码验证、账户管理和密码修改。
{{< text fg="green" >}}pam_userdb.so           {{< /text >}} - 使用 Berkeley DB 格式的数据库文件（而非系统 passwd）进行用户名/密码认证。
{{< text fg="green" >}}pam_usertype.so         {{< /text >}} - 根据 UID 范围判断用户类型（如普通用户、系统用户），并据此返回成功或失败。
{{< text fg="green" >}}pam_warn.so             {{< /text >}} - 将认证尝试信息记录到 syslog（通常作为堆叠模块用于审计和告警）。
{{< text fg="green" >}}pam_wheel.so            {{< /text >}} - 检查用户是否属于 wheel 组，常用于限制 su 到 root 的权限。
{{< text fg="green" >}}pam_xauth.so            {{< /text >}} - 在用户切换身份（如 su、sudo）时，安全地传递 X11 认证 cookie，保证图形会话不中断。
```


### 模块参数

可用 man 命令查看：

```bash-session
$ man pam_unix
```



## 相关概念

### PAM 栈

PAM 栈就是针对某个服务的某个管理组类型，按顺序执行的一系列模块队列。

```bash{ bar="/etc/pam.d/system-auth" }
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

上述文件中，对应四个栈，其中所有 `auth` 类型的模块在一个 `auth` 栈中（以此类推），PAM 触发 `auth` 栈时栈中的模块会从上到下依次执行：

```
auth        required    pam_env.so
auth        requisite   pam_faillock.so preauth
auth        [success=1 new_authtok_reqd=1 ignore=ignore default=bad]    pam_unix.so nullok  try_first_pass
auth        [default=die]   pam_faillock.so authfail
auth        optional    pam_cap.so
```

### PAM 架构

```text{ nonebg=true }
应用程序
    ↓
libpam API（/usr/lib64/libpam.so.0） ←  配置文件（/etc/pam.d/服务名）
    ↓
PAM 模块（/usr/lib64/security/pam_*.so）
    ↓
实际数据源（/etc/shadow、LDAP、Kerberos、硬件令牌）
```

#### 应用程序

以 `login` 为例，其调用了 `libpam` 来处理用户登陆：

```bash-session
$ ldd /usr/bin/login | grep libpam
	libpam.so.0 => /usr/lib64/libpam.so.0 (0x00007ffbec9a3000)
	libpam_misc.so.0 => /usr/lib64/libpam_misc.so.0 (0x00007ffbec99d000)
```


#### Libpam

```bash-session{ height=30 }
$ nm -D --defined-only /usr/lib64/libpam.so.0 | grep pam_ | cut -f1 -d@
0000000000003a50 T pam_acct_mgmt
0000000000003ac0 T pam_authenticate
000000000000ae40 T pam_chauthtok
000000000000afd0 T pam_close_session
0000000000004b20 T pam_end
0000000000004050 T pam_fail_delay
0000000000006000 T pam_get_authtok
0000000000006010 T pam_get_authtok_noverify
0000000000006030 T pam_get_authtok_verify
0000000000003d40 T pam_get_data
0000000000005510 T pam_getenv
0000000000005630 T pam_getenvlist
0000000000008590 T pam_get_item
0000000000008730 T pam_get_user
0000000000003ab0 T pam_modutil_audit_write
00000000000091f0 T pam_modutil_check_user_in_passwd
000000000000a530 T pam_modutil_drop_priv
0000000000009570 T pam_modutil_getgrgid
00000000000097e0 T pam_modutil_getgrnam
0000000000009960 T pam_modutil_getlogin
0000000000009b00 T pam_modutil_getpwnam
0000000000009d70 T pam_modutil_getpwuid
0000000000009fe0 T pam_modutil_getspnam
000000000000a3b0 T pam_modutil_read
000000000000a7b0 T pam_modutil_regain_priv
000000000000aac0 T pam_modutil_sanitize_helper_fds
000000000000ac60 T pam_modutil_search_key
000000000000a2f0 T pam_modutil_user_in_group_nam_gid
000000000000a2b0 T pam_modutil_user_in_group_nam_nam
000000000000a370 T pam_modutil_user_in_group_uid_gid
000000000000a330 T pam_modutil_user_in_group_uid_nam
000000000000a470 T pam_modutil_write
000000000000af70 T pam_open_session
000000000000bfb0 T pam_prompt
00000000000050f0 T pam_putenv
0000000000003b90 T pam_setcred
0000000000003c00 T pam_set_data
0000000000007f40 T pam_set_item
000000000000b510 T pam_start
000000000000b500 T pam_start_confdir
000000000000b520 T pam_strerror
000000000000bc70 T pam_syslog
000000000000bd30 T pam_vprompt
000000000000ba50 T pam_vsyslog
```


#### PAM 模块

一个 PAM 模块通常包含多个类型的服务模块接口，PAM 会根据当前调用的管理组类型来调用模块内部对应的接口。

以 `pam_unix.so` 为例，该模块包含了本地 Unix 账户全家桶服务，以下是 `pam_unix.so` 中的接口函数：

```bash-session
$ nm -D --defined-only /usr/lib64/security/pam_unix.so
0000000000003530 T pam_sm_authenticate     {{< text fg="yellow" >}}auth     类型{{< /text >}}
00000000000037c0 T pam_sm_setcred          {{< text fg="yellow" >}}auth     类型{{< /text >}}
0000000000003270 T pam_sm_acct_mgmt        {{< text fg="yellow" >}}account  类型{{< /text >}}
0000000000003e10 T pam_sm_chauthtok        {{< text fg="yellow" >}}password 类型{{< /text >}}
0000000000004830 T pam_sm_close_session    {{< text fg="yellow" >}}session  类型{{< /text >}}
0000000000004660 T pam_sm_open_session     {{< text fg="yellow" >}}session  类型{{< /text >}}
```

#### Libpam API 对应的 PAM 模块接口函数

当应用程序调用 `pam_*` 函数，`libpam` 会找到配置文件中对应的模块，然后调用该模块内部对应的 `pam_sm_*` 函数（Service Module）。

| 类型 | Libpam  | PAM 模块 | 说明 |
|:--|:--|:--|:--|
| `auth` | `pam_authenticate()` | `pam_sm_authenticate()` | 验证用户身份（核对密码） |
| `auth` | `pam_setcred()` | `pam_sm_setcred()` | 建立/修改/删除用户凭证 |
| `account` | `pam_acct_mgmt()` | `pam_sm_acct_mgmt()` | 账户可用性检查 |
| `password` | `pam_chauthtok()` | `pam_sm_chauthtok()` | 修改认证令牌（修改密码）|
| `session` | `pam_open_session()` | `pam_sm_open_session()` | 打开用户会话 |
| `session` | `pam_close_session()` | `pam_sm_close_session()` | 关闭用户会话 |

> 用户凭证：用户身份通过验证（pam_authenticate 成功）后，系统为该用户建立的一整套权限证明和访问令牌。这些凭证决定了该进程能以什么身份、什么权限、什么网络凭据去访问系统资源。

#### 配置文件

以一个简单的 `/etc/pam.d/login` 配置文件为例：
 
```
auth       required   pam_unix.so
account    required   pam_unix.so
password   required   pam_passwdqc.so config=/etc/passwdqc.conf
password   required   pam_unix.so use_authtok nullok yescrypt
session    required   pam_unix.so
```

```text{ nonebg=true }
login 程序
│
├─ pam_start() → 读取配置文件，按顺序加载模块，建立 auth/account/password/session 栈
│
├─ 验证用户身份 → pam_authenticate() → 遍历 auth 栈 → pam_unix.so :: pam_sm_authenticate()
│
├─ 账户可用性检查 → pam_acct_mgmt() → 遍历 account 栈 → pam_unix.so :: pam_sm_acct_mgmt()
│
├─ 是否需要修密码 → pam_chauthtok() → 遍历 password 栈
│                                              ├─ 检查密码强度 → pam_passwdqc.so :: pam_sm_chauthtok()
│                                              └─ 更改密码 → pam_unix.so :: pam_sm_chauthtok()
│
├─ 建立凭证 → pam_setcred() → 遍历 auth 栈 → pam_unix.so :: pam_sm_setcred()
│
├─ 建立会话 → pam_open_session() → 遍历 session 栈 → pam_unix.so :: pam_sm_open_session()
│
├─ ...
│
├─ 关闭会话 → pam_close_session() →  遍历 session 栈 → pam_unix.so :: pam_sm_close_session()
│
├─ 删除凭证 → pam_setcred() → 遍历 auth 栈 → pam_unix.so :: pam_sm_setcred()
│
└─ pam_end()
```

##### 说明

PAM 配置文件中哪些栈会被遍历执行，取决于应用程序是否调用了 libpam 中对应的 API，
比如上面的 `password` 栈中的模块，当账户可用性检查 `pam_acct_mgmt()` 返回值不等于 `PAM_NEW_AUTHTOK_REQD`，则无须修改密码，
那么 login 程序就不会调用 `pam_chauthtok()`，`password` 栈中的模块也就不会被执行，参考 [login.c](https://github.com/shadow-maint/shadow/blob/855d15a04625818fa28a94e693dd4dc7acfb5af3/src/login.c#L758)。

> 配置文件定义了 “怎么执行”，而应用程序的代码逻辑定义了 “是否执行”。


> 同一 type 的栈内，模块按顺序执行；不同 type 之间的上下相对位置对执行流毫无影响，因为它们被完全不同的 libpam API 调用所触发。





## Gentoo PAM 配置文件

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
  9. 尝试使用上一个模块（passwdqc）传递过来的密码。
 10. 应用 /etc/security/limits.conf （及 limits.d/*.conf）中的资源限制（如最大打开文件数、最大进程数、内存/CPU 限制）。
 11. 加载环境变量。
 12. 记录登录日志、更新 utmp/wtmp/lastlog。
```




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


#### 控制台 tty 登陆的大致流程

```{ nonebg=true }
init {{<text fg="gray-0" >}}← 读取 /etc/inittab{{< /text >}}
  ↓
启动 agetty 于 /dev/ttyN {{<text fg="gray-0" >}}← 输入用户名{{< /text >}}
  ↓
agetty 执行 /bin/login <用户名>
  ↓
login 调用 PAM 处理认证事务 {{<text fg="gray-0" >}}← 输入密码{{< /text >}}
  ↓
shell
```






## 示例程序

```c{ bar="myapp.c" height=50 }
#include <stdio.h>
#include <stdlib.h>
#include <security/pam_appl.h>
#include <security/pam_misc.h>

// 自定义对话函数，直接使用 libpam_misc 提供的 misc_conv
static struct pam_conv conv = {
    misc_conv,
    NULL
};

int main(int argc, char *argv[])
{
    pam_handle_t *pamh = NULL;
    const char *user = NULL;
    int ret;

    // 1. 确定用户名（可从命令行参数获取，也可在程序中让用户输入）
    if (argc > 1) {
        user = argv[1];
    } else {
        fprintf(stderr, "Usage: %s <username>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    // 2. 初始化 PAM 会话，"myapp" 对应 /etc/pam.d/myapp 配置文件
    ret = pam_start("myapp", user, &conv, &pamh);
    if (ret != PAM_SUCCESS) {
        fprintf(stderr, "pam_start: %s\n", pam_strerror(pamh, ret));
        exit(EXIT_FAILURE);
    }

    // 3. 进行认证（会调用对话函数要求输入密码）
    ret = pam_authenticate(pamh, 0);
    if (ret != PAM_SUCCESS) {
        fprintf(stderr, "pam_authenticate: %s\n", pam_strerror(pamh, ret));
    } else {
        // 4. 认证通过后检查账户有效性
        ret = pam_acct_mgmt(pamh, 0);
        if (ret != PAM_SUCCESS) {
            fprintf(stderr, "pam_acct_mgmt: %s\n", pam_strerror(pamh, ret));
        } else {
            printf("Authentication successful for user '%s'\n", user);
        }
    }

    // 5. 结束 PAM 会话
    pam_end(pamh, ret);

    return (ret == PAM_SUCCESS) ? EXIT_SUCCESS : EXIT_FAILURE;
}
```

```text{ bar="/etc/pam.d/myapp" }
auth        required    pam_unix.so
account     required    pam_unix.so
```

```bash-session
$ gcc myapp.c -o myapp -lpam -lpam_misc
$ ./myapp king
Password: 
Authentication successful for user 'king'
```




