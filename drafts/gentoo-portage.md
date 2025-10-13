---
title: "Gentoo portage"
date: "2025-09-22"
toc: true
---


## 仓库目录


## 常用 USE


## 配置目录/文件

> 参考 [/etc/portage](https://wiki.gentoo.org/wiki//etc/portage)

<div class="table-container"> 

|||
|:--|:--|
|[make.conf](#makeconf)|主配置|
|binrepos.conf|二进制仓库配置|
|[package.accept\_keywords](https://wiki.gentoo.org/wiki//etc/portage/package.accept_keywords)|允许为特定软件包安装测试版（~arch） 或其他架构的版本。|


</div>


## 操作符


## make.conf

```
man make.conf
```


## binrepos.conf

[Gentoo Binary Host Quickstart](https://wiki.gentoo.org/wiki/Gentoo_Binary_Host_Quickstart)

/var/cache/binpkgs/ - 存储下载的二进制包

/etc/portage/make.conf - 中的 EMERGE_DEFAULT_OPTS="--getbinpkg" 启用二进制包优先

```
[binhost]
# 当在多个仓库中找到版本相同的包时，优先选择优先级较高的仓库，数值越小优先级越高
priority = 9999
# 二进制源
sync-uri = https://example.com/binhost
```


## package.accept_keywords



```bash
# 对于 gui-wm/sway-9999 的屏蔽是由于未定义任何关键字（masked by: missing keyword），使用 **
gui-wm/sway **
# 对于测试版屏蔽（masked by: ~amd64 keyword）
gui-wm/sway ~amd64
# 指定版本
=gui-wm/sway-1.11 ~amd64
```
