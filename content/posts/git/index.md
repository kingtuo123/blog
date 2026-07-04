---
title: "Git 入门"
date: "2026-07-04"
toc: true
draft: true
---








## 配置文件


{{< table border=true thead=false min-width="130,160" >}}
|                 |               |                                         |
|:----------------|:--------------|:----------------------------------------|
|**本地级配置**   |对当前仓库生效 |`.git/config`                            |
|**全局级配置**   |对当前用户生效 |`~/.gitconfig` 或 `~/.config/git/config` |
|**系统级配置**   |对所有用户生效 |`/etc/gitconfig`                         |
{{< /table >}}

> 优先级从高到低为：本地（local）→ 全局（global）→ 系统（system）。





### 设置配置

{{< table thead=false min-width="400" border=true >}}
|                                           |                    |
|:------------------------------------------|:-------------------|
|**全局配置**                               |                    |
|*`git config --global user.name "用户名"`* |设置用户名。        |
|*`git config --global user.email "邮箱"`*  |设置邮箱。          |
|*`git config --global --edit`*             |直接编辑配置文件。  |
{{< /table >}}


> 不写级别默认是 `--local`。




### 查看配置

{{< table thead=false min-width="400" border=true >}}
|                                        |                                            |
|:---------------------------------------|:-------------------------------------------|
|**查看所有配置**                        |                                            |
|*`git config --list`*                   |列出所有配置。                              |
|*`git config --list --show-origin`*     |列出所有配置及其来源的配置文件。            |
|**查看单项配置**                        |                                            |
|*`git config user.name`*                |查看用户名。                                |
|*`git config --show-origin user.email`* |查看邮箱及其来源的配置文件。                |
|**只查看对应级别配置**                  |                                            |
|*`git config --list --local`*           | 查看本地仓库配置，必须在仓库中执行该命令。 |
{{< /table >}}





## 初始化仓库

{{< table thead=false min-width="400" border=true >}}
|                                        |                                            |
|:---------------------------------------|:-------------------------------------------|
|*`git init`*                            |在当前目录初始化。                          |
|*`git init 目录`*                       |以指定目录名初始化                          |
{{< /table >}}























































































































## 工作区

## 暂存区

## 本地仓库

## 远程仓库
