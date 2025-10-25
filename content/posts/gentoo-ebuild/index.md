---
title: "Gentoo ebuild"
date: "2024-07-29"
toc: true
---



## 概述

### 什么是 ebuild

ebuild 是在特殊环境中执行的 bash 脚本

### ebuild 文件命名

```makefile
libfoo-1.2.5b_pre5-r2.ebuild
libfoo     : 包名  
-1.2.5b    : 版本号  
_pre5      : 后缀 
-r2        : 修订号，-r2 表示第二个修订版
```

<div class="table-container w-110">

|后缀    |说明                |
|:-------|:-------------------|
|`_alpha`|软件开发最初期的版本|
|`_beta` |测试版              |
|`_pre`  |预发布              |
|`_rc`   |候选发布            |
|`_p`    |补丁发布            |
|无后缀  |正常发布            |

</div>


### ebuild 示例

ebuild 模板路径：`/var/db/repos/gentoo/skel.ebuild`

ebuild 中缩进必须使用 `tab`，且每行开头和末尾不要留空格


```bash
# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Ebuild API 的第八个版本，它定义了 ebuild（Gentoo 的软件包构建脚本）的语法、变量和行为规范
EAPI=8

# eclass 是 ebuild 的共享代码库，类似于其他编程语言中的类或模块
# 用于在多个 ebuild 之间共享通用功能和逻辑
inherit autotools

# 变量 
DESCRIPTION="This is a sample skeleton ebuild file"
HOMEPAGE="https://foo.example.org/"
SRC_URI="ftp://foo.example.org/${P}.tar.gz"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 x86"
IUSE="gnome +gtk"

# 依赖
RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

# 函数
src_configure() {
    ./configure --prefix=${EPREFIX}/usr
}

src_compile() {
    emake
}

src_install() {
    emake DESTDIR="${D}" install
}
```




## 变量

详见 [Variables](https://devmanual.gentoo.org/ebuild-writing/variables/index.html)

### 用户定义的变量

<div class="table-container no-thead w-150">

|用户定义的变量    |说明                                                                          |
|:-----------------|:-----------------------------------------------------------------------------|
|`EAPI`            | EAPI 语法规则版本                                                            |
|`DESCRIPTION`     | 软件包及其用途的简短描述                                                     |
|`HOMEPAGE`        | 软件包官网主页                                                               |
|`SRC_URI`         | 软件包的文件下载地址列表                                                     |
|`LICENSE`         | 软件包许可证                                                                 |
|`SLOT`            | 软件包插槽，用于安装不同版本的同一软件包，如果不使用就声明为 0               |
|`KEYWORDS`        | 软件包可以安装的平台，~keyword 表示软件包没有经过广泛测试                    |
|`IUSE`            | 可用的 use 标志，+use 表示默认启用|
|`REQUIRED_USE`    | USE 标志的配置必须满足的断言列表，才能对此 ebuild 有效|
|`PROPERTIES`      | 以空格分隔的属性列表，支持条件语法|
|`RESTRICT`        | 用于禁用 Portage 的默认行为，参考[man Ebuild](https://devmanual.gentoo.org/eclass-reference/ebuild/) 中 RESTRICT 一节|
|`DEPEND`          | 构建时依赖的库或头文件|
|`BDEPEND`         | 构建时依赖的构建工具  |
|`RDEPEND`         | 运行时依赖的库或头文件|
|`S`               | 解压后源码所在路径，默认 `${WORKDIR}/${P}`|
|`DOCS`            | 使用 `dodoc` 安装的默认 `src_install` 函数的文档文件的数组或以空格分隔的列表|

</div>


### 预定义的只读变量

<div class="table-container no-thead w-150">

|预定义的只读变量|说明|
|:--|:--|
|`P`              | 包名和版本号，如 vim-6.3|
|`PN`             | 包名，如 vim|
|`PV`             | 版本号，如 6.3|
|`PVR`            | 版本号和修订号，如 6.3-r2|
|`PF`             | 完整的软件包名称，即不含 .ebuild 后缀的部分，如 vim-6.3-r2|
|`A`              | 包的所有源文件，即 ebuild 下载的文件|
|`CATEGORY`       | 类目名，如 app-shells|
|`FILESDIR`       | 路径 `${PORTAGE_BUILDDIR}/files`，通常存放小补丁和其他文件|
|`WORKDIR`        | 路径 `${PORTAGE_BUILDDIR}/work`|
|`T`              | 路径 `${PORTAGE_BUILDDIR}/temp`|
|`D`              | 路径 `${PORTAGE_BUILDDIR}/image`|
|`HOME`           | 路径 `${PORTAGE_BUILDDIR}/homedir`|
|`ROOT`           | 要将 `${D}` 下的文件合并到的根目录的绝对路径，通常是系统的根路径 `/`，仅允许在 `pkg_*` 阶段进行|
|`DISTDIR`        | 下载的文件所在路径 `${PORTAGE_BUILDDIR}/distdir`|
|`EPREFIX`        | 偏移安装路径，例如 `--prefix=${EPREFIX}/usr`|
|`ED`             | 偏移临时安装路径 `${D}/${EPREFIX}` |
|`EROOT`          | 偏移根路径 `${ROOT}/${EPREFIX}`|

</div>


<blockquote class="red">

路径变量尾部不以斜杠结尾

</blockquote>

> `PORTAGE_BUILDDIR` 等于 `${PORTAGE_TMPDIR}/portage/${CATEGORY}/${PF}`



### SLOT 插槽

SLOT 是软件包版本的一个槽位，具有不同 SLOT 的同一个软件包可以同时安装，详见 [Slotting](https://devmanual.gentoo.org/general-concepts/slotting/index.html)。

```bash
SLOT="0"      # 默认 slot
SLOT="1"      # 数字 slot
SLOT="2.0"    # 带小数的 slot
SLOT="qt5"    # 字符串 slot
SLOT="0/7.6"  # 带子 slot 的格式
```

SLOT 命名通常与软件包的主要版本号对应，这是 Gentoo 官方建议的规范，而非语法的限制。

同时安装 foo 软件包的不同 SLOT 版本：

```makefile
foo-1.1  -->  SLOT="1"
foo-1.2  -->  SLOT="1"
foo-2.0  -->  SLOT="2"
foo-2.1  -->  SLOT="2"
```

```bash-session
$ emerge -av foo:1  # 安装 foo-1.2 --> SLOT=1 的最新版本 
$ emerge -av foo:2  # 安装 foo-2.1 --> SLOT=2 的最新版本
```

主 SLOT / 子 SLOT ：

```makefile
foo-1.1 ( libfoo.so.5   )  -->  SLOT="1/5"
foo-1.2 ( libfoo.so.6   )  -->  SLOT="1/6"
foo-2.0 ( libfoo-2.so.0 )  -->  SLOT="2/0"
foo-2.1 ( libfoo-2.so.1 )  -->  SLOT="2/1"
```

同一软件包，主 SLOT / 子 SLOT 其中一个不同，就可以同时安装。

子 SLOT 用于更精细的依赖关系控制（ABI 依赖），比如某个软件包依赖 foo 库版本为 libfoo.so.5 （SLOT=1/5），相比 SLOT=1 控制更精细。










### SRC_URI 源

#### 条件性源

使用 `flag? ( )`，多个文件使用空格或换行分隔：

```bash
SRC_URI="https://example.com/files/${P}-core.tar.bz2
	x86?   ( https://example.com/files/${P}/${P}-sse-asm.tar.bz2 )
	ppc?   ( https://example.com/files/${P}/${P}-vmx-asm.tar.bz2 )
	sparc? ( https://example.com/files/${P}/${P}-vis-asm.tar.bz2 )
	doc?   ( https://example.com/files/${P}/${P}-docs.tar.bz2    )"
```

#### 重命名源文件

使用 `-> 新名称` ：

```bash
SRC_URI="https://example.com/files/${PV}.tar.gz -> ${P}.tar.gz"
```

#### 第三方镜像

定义在 `/var/db/repos/gentoo/profiles/thirdpartymirrors` 中：

```
gnu  https://example/mirror1  https://example/mirror2  https://example/mirror3
```

使用 `mirror://镜像名` ，从该镜像获取文件：

```bash
SRC_URI="mirror://gnu/gcc/gcc-12.1.0.tar.xz"
```

`SRC_URI` 中的 `mirror://gnu` 链接会被转换为：

```bash
"https://example/mirror1/gcc/gcc-12.1.0.tar.xz"
```

#### 自动镜像

对于下列值，包管理器会优先在官方镜像站查找 `${P}.tar.gz`，若失败再使用原始地址下载

```bash
SRC_URI="https://gnu/${PN}/${P}.tar.gz"
```

#### 解除限制

在 EAPI 8 中，可以通过在地址前添加 `mirror+` 或 `fetch+` 来使 `SRC_URI` 中的单个项目免于自动镜像和抓取限制（由 ` RESTRICT="mirror" ` 和 ` RESTRICT="fetch" ` 施加）。

```bash
SRC_URI="https://gnu/${PN}/${P}.tar.gz
	     mirror+https://dev.gentoo.org/~larry/distfiles/${P}-addons.tar.gz"
RESTRICT="fetch"
```

如上，Portage 不会下载 `${P}.tar.gz` ，但 `${P}-addons.tar.gz` 文件将会被下载。

#### 大致流程

{{< svg src="src_uri.svg" >}}






### KEYWORDS 关键词

KEYWORDS 决定了软件包可以在哪些架构上使用以及其稳定性状态。


```bash
KEYWORDS="amd64"       # 在 amd64 架构上为稳定版                
KEYWORDS="~amd64"      # 在 amd64 架构上为测试版                
KEYWORDS="-*"          # 在所有架构上都默认被屏蔽，无法安装     
KEYWORDS="-* amd64"    # 只在 amd64 架构上可用，其他架构都被屏蔽
```

不要在 ebuild 中使用 `*` 或 `~*` 特殊关键字。











### REQUIRED_USE

必须满足 REQUIRED_USE 中的这些 USE 条件，此 ebuild 才有效

```bash
REQUIRED_USE="foo? ( !bar )"                   # 若启用了 foo，则 bar 必须禁用
REQUIRED_USE="foo? ( || ( bar baz quux ) )"    # 若启用了 foo，则 bar、baz 和 quux 中至少有一个必须被启用
REQUIRED_USE="^^ ( foo bar baz )"              # foo、bar 和 baz 只能其中一个必须被启用
REQUIRED_USE="|| ( foo bar baz )"              # foo、bar 和 baz 中至少有一个必须被启用
REQUIRED_USE="?? ( foo bar baz )"              # foo、bar 或 baz 中的零个或一个选项被启用，不可同时设置多个
```










### 依赖语法

参考 [Dependencies](https://devmanual.gentoo.org/general-concepts/dependencies/index.html)

#### 版本依赖

```bash
DEPEND=">=app-misc/foo-1.23"    # 大于等于1.23 版本
DEPEND=">app-misc/foo-1.23"     # 大于 1.23 版本
DEPEND="=app-misc/foo-1.23"     # 严格等于 1.23 版本
DEPEND="~app-misc/foo-1.23"     # 等于 1.23 或任何 1.23-r* 版本
```

#### 范围依赖

注意，等号 `=` 是必需的，且星号 `*` 前面没有点：

```bash
DEPEND="=app-misc/foo-2*"       # 指定 2.x 版本，使用 * 后缀
```

#### 阻塞项

当前软件包与 `app-misc/foo` 不能同时安装或文件冲突：

```bash
RDEPEND="!app-misc/foo"         # 弱阻塞，安装并警告
RDEPEND="!!app-misc/foo"        # 强阻塞，安装失败并显示错误
RDEPEND="!<app-misc/foo-1.3"    # 针对特定版本阻塞
```

注意：阻塞符号 `!` 与 `!!` 只在 RDEPEND 中有效


#### 槽位依赖

```bash
DEPEND="=app-misc/foo:="        # 表示任何 slot 都可以接受，slot 或 sub-slot 变更则 rebuild
DEPEND="=app-misc/foo:*"        # 表示任何 slot 都可以接受，忽略 slot 或 sub-slot 变更
DEPEND="=app-misc/foo:5="       # 表示只接受 slot 5，sub-slot 变更则 rebuild
DEPEND="=app-misc/foo:5"        # 表示只接受 slot 5，忽略 sub-slot 变更
DEPEND="=app-misc/foo:5/1"      # 表示只接受 slot 5，sub-slot 1
```

#### 条件依赖

```bash
DEPEND="perl? ( dev-lang/perl )"                     # 仅在 perl  标志启用时依赖 perl
DEPEND="!crypt? ( net-misc/netkit-rsh )"             # 仅在 crypt 标志禁用时依赖 netkit-rsh
DEPEND="|| ( app-misc/foo app-misc/bar )"            # 依赖 foo 或 bar
DEPEND="baz? ( || ( app-misc/foo app-misc/bar ) )"   # 当 baz 标志被设置时，依赖 foo 或 bar
```

#### USE 依赖项构建

```bash
DEPEND="app-misc/foo[bar]"       # foo 必须启用 bar
DEPEND="app-misc/foo[bar,baz]"   # foo 必须同时启用 bar 和 baz
DEPEND="app-misc/foo[-bar,baz]"  # foo 必须禁用 bar 并启用 baz
DEPEND="app-misc/foo[bar(+)]"    # 将不含 bar 标志的 foo 版本视为已启用该标志（不论 foo 有没有 bar 标志都视为已启用）
DEPEND="app-misc/foo[bar(-)]"    # 将不含 bar 标志的 foo 版本视为已禁用该标志（不论 foo 有没有 bar 标志都视为已禁用）
DEPEND="app-misc/foo[bar?]"      # 等同 bar? ( app-misc/foo[bar] )  !bar? ( app-misc/foo )
DEPEND="app-misc/foo[!bar?]"     # 等同 bar? ( app-misc/foo )       !bar? ( app-misc/foo[-bar] )
DEPEND="app-misc/foo[bar=]"      # 等同 bar? ( app-misc/foo[bar] )  !bar? ( app-misc/foo[-bar] )
DEPEND="app-misc/foo[!bar=]"     # 等同 bar? ( app-misc/foo[-bar] ) !bar? ( app-misc/foo[bar] )
```












## USE 条件判断

参考 [USE flag conditional code](https://devmanual.gentoo.org/ebuild-writing/use-conditional-code/index.html)

```bash
if use gtk ; then
if ! use gtk ; then
if use amd64 && use sse2 && ! use debug; then
use gtk && echo "it's and"
use gtk || echo "it's or"
```




## eclass

详见 [Eclass reference](https://devmanual.gentoo.org/eclass-reference/index.html)

eclass 是在 ebuild 之间共享的函数或功能的集合（库），使用 inherit 调用 eclass。

inherit 语句必须位于 ebuild 的顶部（在所有函数之前）：

```bash
EAPI=8
inherit autotools bash-completion-r1 flag-o-matic
```

<blockquote class="red">

编写 ebuild 应使用 portage 和 eclass 提供的函数和命令、及 bash 内置命令，不要使用外部命令。

</blockquote>






## 函数

参考 [Ebuild phase functions](https://devmanual.gentoo.org/ebuild-writing/functions/index.html) 与 [Function reference](https://devmanual.gentoo.org/function-reference/index.html)

ebuild 构建时会按下图顺序调用函数

{{< svg src="func.svg" >}}

<div class="table-container">

|||
|:--|:--|
|[pkg_pretend](https://devmanual.gentoo.org/ebuild-writing/functions/pkg_pretend/index.html)|在依赖计算期间对软件包运行完整性检查，该阶段通常用于检查内核配置|
|[pkg_nofetch](https://devmanual.gentoo.org/ebuild-writing/functions/pkg_nofetch/index.html)|此函数仅针对设置了 `RESTRICT="fetch"` 的软件包触发|
|[pkg_setup](https://devmanual.gentoo.org/ebuild-writing/functions/pkg_setup/index.html)|预构建环境配置和检查，例如检查与设置环境变量|
|[src_unpack](https://devmanual.gentoo.org/ebuild-writing/functions/src_unpack/index.html)|解压源码包，ebuild 提供 unpack 函数自动识别并解压各种格式的包，不要使用 tar 等外部命令|
|[src_prepare](https://devmanual.gentoo.org/ebuild-writing/functions/src_prepare/index.html)|为源码打补丁或其它必要的修改|
|[src_configure](https://devmanual.gentoo.org/ebuild-writing/functions/src_configure/index.html)|配置包，如执行 `./configure` 配置参数|
|[src_compile](https://devmanual.gentoo.org/ebuild-writing/functions/src_compile/index.html)|编译|
|[src_test](https://devmanual.gentoo.org/ebuild-writing/functions/src_test/index.html)|运行预安装测试脚本（如果源码包有测试套件）|
|[src_install](https://devmanual.gentoo.org/ebuild-writing/functions/src_install/index.html)|将文件临时安装到 `${D}` ，即 `${PORTAGE_BUILDDIR}/image` 目录，例如 `emake DESTDIR="${D}" install`|
|[pkg_preinst](https://devmanual.gentoo.org/ebuild-writing/functions/pkg_preinst/index.html)|在 image 目录下的文件合并到 `${ROOT}` 之前调用，例如修改特定的安装文件|
|[pkg_postinst](https://devmanual.gentoo.org/ebuild-writing/functions/pkg_postinst/index.html)|在 image 目录下的文件合并到 `${ROOT}` 之后调用，例如显示安装后的信息性消息或警告|
|[pkg_prerm](https://devmanual.gentoo.org/ebuild-writing/functions/pkg_prerm/index.html)|在软件包 unmerge 前调用，用于清理那些可能妨碍干净卸载的任何文件|
|[pkg_postrm](https://devmanual.gentoo.org/ebuild-writing/functions/pkg_postrm/index.html)|在软件包 unmerge 后调用，用于在软件包卸载后更新符号链接、缓存文件及其他生成的内容|
|[pkg_config](https://devmanual.gentoo.org/ebuild-writing/functions/pkg_config/index.html)|软件包安装后的配置，需要手动调用，例如 mysql 安装后初始化配置 `emerge --config dev-db/mysql`|
|[pkg_info](https://devmanual.gentoo.org/ebuild-writing/functions/pkg_info/index.html)|显示软件包的信息时调用，例如 `emerge --info www-client/firefox`|

</div>

> 个人理解：如果是基于 Autotools 的 tar 包，
> ebuild 按顺序调用这些函数能自动完成解压、编译、安装，无须其它操作。
> 如果你需要在某一阶段做特定的操作或软件包使用 cmake、ninja 等其他构建工具，则需手动编写对应的函数。




### 源文件解压

参考 [src_unpack](https://devmanual.gentoo.org/ebuild-writing/functions/src_unpack/index.html)

大部分压缩格式 `tar/gz/xz/bz/deb/zip` 使用 `unpack` 函数就可以解压：

```bash
src_unpack() {
	unpack ${A}
}
```

对于 rpm 包：

```bash
inherit rpm

src_unpack() {
	rpm_src_unpack ${A}
}
```






### 使用 eapply 打补丁

参考 [Patching with eapply](https://devmanual.gentoo.org/ebuild-writing/functions/src_prepare/eapply/index.html)

基础用法：

```bash
src_prepare() {
	eapply "${FILESDIR}"/${P}-musl.patch
}
```







### 配置软件包

参考 [Configuring a package](https://devmanual.gentoo.org/ebuild-writing/functions/src_configure/configuring/index.html)

`econf` 是 `./configure` 的封装，会自动传递 `--prefix="${EPREFIX}"/usr` 等默认选项。

对于附带由 autoconf 生成的 `configure` 脚本的软件包，使用 `econf` 替代 `./configure` ：

```
src_configure() {
	econf \
		$(use_enable perl) \
		$(use_enable python) \
		$(use_enable ruby)
}
```


`use_enable` 函数用法：

```makefile
语法 : use_enable flag str val
```

根据 `useq flag` 的值输出 `--enable-str=val` 或 `--disable-str` 。若未指定 `str` ，则改用 `flag` 。若未指定 `val` ，则省略赋值部分。











### 错误处理

参考 [Error handling](https://devmanual.gentoo.org/ebuild-writing/error-handling/index.html)

#### die 函数

die 函数应用于指示致命错误并中止构建流程：

```bash
make || die "make failed"    # 打印信息并终止运行
```

####  assert 函数与 PIPESTATUS 

管道命令 `|` 只返回最后一条命令的执行是否错误，简单的条件测试和 `$?` 无法检测最后命令之前的内容是否出错，所以 bash 提供 `PIPESTATUS` 变量供检测。

`assert` 函数会检测 `PIPESTATUS` 变量，报告错误并终止运行：

```bash
bunzip2 "${DISTDIR}/${VIM_RUNTIME_SNAP}" | tar xf
assert
```

####  nonfatal 函数

`nonfatal` 函数会在命令失败时不终止执行，而是返回非零退出状态：

```bash
if ! nonfatal emake check ; then
	...
fi
```







## 创建用户和组

参考 [Users and groups](https://devmanual.gentoo.org/ebuild-writing/users-and-groups/index.html)

创建用户的 ebuild 存放在仓库的 `acct-user` 目录，用户名和包名相同。

创建用户组的 ebuild 存放在仓库的 `acct-group` 目录，组名和包名相同。

ebuild 通过调用 [acct-user.eclass](https://devmanual.gentoo.org/eclass-reference/acct-user.eclass/index.html)
和 [acct-group.eclass](https://devmanual.gentoo.org/eclass-reference/acct-group.eclass/index.html)
创建用户和组，以下是创建 docker 用户组的 ebuild ：

{{< bar str="/var/db/repos/gentoo/acct-group/docker/docker-0-r3.ebuild" >}}

```bash
# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-group

ACCT_GROUP_ID=48
```

{{< bar str="/var/db/repos/gentoo/acct-user/docker_auth/docker_auth-0-r3.ebuild" >}}

```bash
# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="User for docker_auth"
ACCT_USER_ID=345
ACCT_USER_GROUPS=( docker_auth )

acct-user_add_deps
```










## 消息

参考 [Messages](https://devmanual.gentoo.org/ebuild-writing/messages/index.html)

```bash
pkg_postinst() {
    elog "You will need to set up your /etc/foo/foo.conf file before"
    elog "running foo for the first time. For details, please see the"
    elog "foo.conf(5) manual page."
}

```

<div class="table-container no-thead w-100"> 

|         |                                                             |
|:--------|:------------------------------------------------------------|
|`einfo`  |信息类消息，以绿色星号为前缀，不会输出到日志                 |
|`elog`   |信息类消息，以绿色星号为前缀，如果启用了日志记录，则会被记录 |
|`ewarn`  |警告消息，以黄色星号为前缀                                       |
|`eerror` |错误消息，以红色星号为前缀，该函数后面通常跟一个 `die` 函数      |
|`eqawarn`|供 eclass 作者用于通知 ebuild 编写者有关已弃用的功能         |

</div>


























## 临时目录

`PORTAGE_TMPDIR` 目录在 `make.conf` 中设置，当 `PORTAGE_TMPDIR="/tmp"` ，目录结构如下：

```text
${PORTAGE_TMPDIR}/
└── portage
    └── ${CATEGORY}/
        └── ${PF}/
             ├── build-info
             ├── distdir
             ├── files
             ├── work
             └── ...
```


以 `app-shells/zsh` 为例，构建时的临时目录结构如下：

```text
/tmp
└── portage
    └── app-shells
        └── zsh-5.9-r6
            ├── build-info
            │   ├── ...
            │   └── zsh-5.9-r6.ebuild
            ├── distdir
            │   └── zsh-5.9.tar.xz -> /var/cache/distfiles/zsh-5.9.tar.xz
            ├── empty/
            ├── files -> /var/db/repos/gentoo/app-shells/zsh/files
            ├── homedir/
            ├── image
            │   ├── bin
            │   │   ├── zsh
            │   │   └── zsh-5.9
            │   ├── etc
            │   │   └── zsh
            │   └── usr
            │       ├── include
            │       ├── lib64
            │       └── share
            ├── temp
            │   ├── ...
            │   └── build.log
            └── work
                └── zsh-5.9
                    ├── configure
                    ├── Makefile
                    ├── ...
                    └── Src
```

- ebuild 下载的文件存放在 `/var/cache/distfiles` 目录，然后链接到 `distdir` 目录下。
- `src_unpack` 函数解压源文件到 `${WORKDIR}` 目录，即 `work` 目录。
- `src_configure`、`src_compile` 函数工作在 `${S}` = `${WORKDIR}/${P}` 目录，即在 `work/zsh-5.9` 中配置、编译程序。
- `src_install` 函数将文件临时安装到 `${D}`，即 `image` 目录。
- 最后 ebuild 将 `image` 下的文件合并到系统的 `${ROOT}` 路径上，完成安装。








## ebuild 仓库

参考 [Repository format](https://wiki.gentoo.org/wiki/Repository_format)

```text
/var/db/repos                       -----> 仓库默认存放路径
└── gentoo                          -----> 仓库目录
    ├── app-misc                    -----> 类目
    │   └── foo                     -----> 包名
    │       ├── foo-1.2.3.ebuild    -----> ebuild 文件
    │       ├── Manifest            -----> 记录了当前目录下各个文件的校验和
    │       ├── metadata.xml        -----> 记录了软件包的一些描述信息
    │       └── files               -----> 存放 ebuild 构建时额外所需的文件
    │           └── foo-1.2.3.patch
    ├── ...
    ├── metadata
    │   └── layout.conf             -----> 仓库配置文件
    └── profiles
        ├── repo_name               -----> 仓库名称
        ├── package.mask            -----> 屏蔽的包
        └── license_groups
```




### 创建本地仓库

参考 [Creating an ebuild repository](https://wiki.gentoo.org/wiki/Creating_an_ebuild_repository)、[Adding unofficial ebuilds](https://wiki.gentoo.org/wiki/Handbook:AMD64/Portage/CustomTree#Adding_unofficial_ebuilds)

#### 手动创建

创建仓库目录：

```bash-session
# mkdir -p /var/db/repos/localrepo/{metadata,profiles}
# chown -R portage:portage /var/db/repos/localrepo
```

配置仓库名称：

```bash-session
# echo 'localrepo' > /var/db/repos/localrepo/profiles/repo_name
```
定义仓库中配置文件的 EAPI 版本：

```bash-session
# echo '8' > /var/db/repos/localrepo/profiles/eapi
```

配置仓库：

```bash-session
# vim /var/db/repos/localrepo/metadata/layout.conf
```

```bash
# 告诉 portage gentoo 是主仓库
masters = gentoo
# 本地仓库不用自动同步
auto-sync = false
thin-manifests = true
sign-manifests = false
```

添加仓库到 portage：

```bash-session
# vim /etc/portage/repos.conf/localrepo.conf
```

```bash
[localrepo]
location = /var/db/repos/localrepo
```

#### 可选：使用 eselect 创建仓库

需安装 `app-eselect/eselect-repository` 这个模块：

```bash-session
# eselect repository create testrepo
# tree /var/db/repos/testrepo
/var/db/repos/testrepo
├── metadata
│   └── layout.conf
└── profiles
    ├── eapi
    └── repo_name
# cat /etc/portage/repos.conf/eselect-repo.conf
[testrepo]
location = /var/db/repos/testrepo
```




### 添加 ebuild 到本地仓库

```bash-session
# mkdir -p /var/db/repos/localrepo/app-misc/hello
# vim /var/db/repos/localrepo/app-misc/hello/hello-1.0.ebuild
```
```bash
# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="hello world"
HOMEPAGE="https://gitee.com/kingtuo123/gentoo-kt"
SRC_URI="https://gitee.com/kingtuo123/gentoo-kt/releases/download/1.0/hello-1.0.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
```

该程序使用 autotools 构建，且没有依赖项等其他操作，所以无需编写函数。

生成 `hello-1.0.ebuild` 文件的校验和到 `manifest` ：

```bash-session
# ebuild hello-1.0.ebuild manifest
```

> 可选：创建 `metadata.xml`，该文件记录包的一些描述信息，参考 [Package and category metadata.xml](https://devmanual.gentoo.org/ebuild-writing/misc-files/metadata/)

安装运行：

```bash-session
# emerge -av hello::localrepo
# hello
Hello World!
```



### 创建远程仓库

```bash-session
# eselect repository create gentoo-kt
# vim /etc/portage/repos.conf/eselect-repo.conf
[gentoo-kt]
location = /var/db/repos/gentoo-kt
sync-type = git
auto-sync = false
sync-uri = https://gitee.com/kingtuo123/gentoo-kt.git

# mkdir -p /var/db/repos/gentoo-kt/app-misc/hello
# cd /var/db/repos/gentoo-kt/app-misc/hello
# vim hello-1.0.ebuild
# ebuild hello-1.0.ebuild manifest

# cd /var/db/repos/gentoo-kt
# git init
# git config user.name "kingtuo123"
# git config user.email "kingtuo123@foxmail.com"
# git branch -M master
# git remote add origin git@gitee.com:kingtuo123/gentoo-kt.git
# git add -A
# git commit -m "first commit"
# git push -f -u origin master
```

测试：

```bash-session
# rm -rf /var/db/repos/gentoo-kt

# emerge --sync -r gentoo-kt
 >> Syncing repository 'gentoo-kt' into '/var/db/repos/gentoo-kt'...
/usr/bin/git clone --depth 1 https://gitee.com/kingtuo123/gentoo-kt.git .
Cloning into '.'...
remote: Enumerating objects: 12, done.
remote: Counting objects: 100% (12/12), done.
remote: Compressing objects: 100% (7/7), done.
remote: Total 12 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (12/12), done.
=== Sync completed for gentoo-kt

Action: sync for repo: gentoo-kt, returned code = 0

# emerge -av hello::gentoo-kt
# hello
Hello World!
```


## ebuild 调试

指定运行到特定阶段的函数，例如执行 ebuild 到 `src_install` 阶段：

```bash-session
# ebuild hello-1.0.ebuild install
```

注意事项：

- 执行前清空 `/tmp/portage/` 下的临时目录，否则旧文件会导致奇怪的问题
- ebuild 修改后要更新 `manifest` 文件
- 多使用 `elog`、`einfo` 这些消息函数
- 通过 `${PORTAGE_BUILDDIR}/${D}` 即 `image` 下的目录结构及文件，判断是否正确安装




## 遇到的问题

二进制包可能需要在 ebuild 中添加 `RESTRICT="binchecks"` 以跳过某些无意义的检查

参考 [Ebuild](https://devmanual.gentoo.org/eclass-reference/ebuild/) 中 RESTRICT 一节



## 参考链接

- [EBUILD](https://devmanual.gentoo.org/eclass-reference/ebuild/)
- [Ebuild Writing](https://devmanual.gentoo.org/ebuild-writing/index.html)
- [Gentoo Devmanual](https://devmanual.gentoo.org/)
- [How to Create an ebuild on Gentoo](https://terminalroot.com/how-to-create-an-ebuild-on-gentoo/)
- [/etc/portage](https://wiki.gentoo.org/wiki//etc/portage)
- [Binary package guide](https://wiki.gentoo.org/wiki/Binary_package_guide)
