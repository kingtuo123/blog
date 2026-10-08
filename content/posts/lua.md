---
title: "Lua 笔记"
date: "2026-10-08"
toc: true
draft: true
---


参考手册：
[Reference manuals](https://www.lua.org/manual/)


## 基本概念

保留字：

```text
and      break     do        else    elseif
end      false     goto      for     function
if       in        local     nil     not
or       repeat    return    then    true
until    while
```

注释：

```lua
-- 单行注释

--[[
    多行注释
--]]
```

全局变量：

```text
⽆须声明即可使⽤
当使⽤未经初始化的全局变量时，得到的结果是 nil
当把nil赋值给全局变量时，Lua会回收该全局变量
```

类型和值：

```text
Lua语⾔是⼀种动态类型语⾔，在这种语⾔中没有类型定义，每个值都带有其⾃⾝的类型信息。
Lua语⾔中有8种基本类型：
nil（空）、
boolean（布尔）、
number（数值）、
string（ 字 符 串 ） 、
userdata（ ⽤ 户 数 据 ）、
function（ 函 数 ）、
thread（ 线 程 ）
table（表）
```

```bash-session
> type(nil)
nil
> type(true)
boolean
> type(10.4*3)
number
> type("hello world")
string
> type(io.stdin)
userdata
> type(print)
function
> type(type)
function
> type({})
table
> type(type(X))
string
```

> 为什么 `type(type)` 是 `function` 不是 `thread` ？
