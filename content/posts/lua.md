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
无须声明即可使用
当使用未经初始化的全局变量时，得到的结果是 nil
当把 nil 赋值给全局变量时，lua 会回收该全局变量
```

类型和值：

```text
Lua 语言是一种动态类型语言，在这种语言中没有类型定义，每个值都带有其自身的类型信息
Lua 语言中有 8 种基本类型：
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


独立解释器：

不需要显式地调用 Lua 语言解释器也可以直接运行Lua 脚本

```lua
#!/usr/bin/lua
```

或

```lua
#!/usr/bin/env lua
```


命令行参数：

```lua
#!/usr/bin/lua
print("arg[0] = " .. arg[0])
print("arg[1] = " .. arg[1])
print("arg[2] = " .. arg[2])
```

```bash-session
$ ./test.lua hello world
arg[0] = ./test.lua
arg[1] = hello
arg[2] = world
```



## 数值

整型值和浮点型值的类型都是"number"

```bash-session
> type(3)
number
> type(3.0)
number
```

区分整型值和浮点型值

```bash-session
> math.type(3)
integer
> math.type(3.0)
float
```

支持以 `0x` 开头的十六进制常量，包括浮点数

```bash-session
> 0xff
255
> 0x0.5
0.3125
```

算术运算：

Lua 5.3 引入了新的除法，称为 `floor` 除法的新算术运算符 `//`

`floor` 除法会对得到的商向负无穷取整，从而保证结果是一个整数

```bash-session
> 9 // 2
4
> -9 // 2
-5
```

关系运算

返回结果都是 Boolean 类型

```text
<    >    <=    >=    ==    ~=
                      等于  不等于
```

数学库

Lua 语言提供了标准数学库 math

随机数发⽣器 math.random
取整函数 

```text
math.abs(x)                 绝对值 math.abs(-3) -> 3
math.acos(x)                反余弦 math.acos(1) -> 0.0
math.asin(x)                反正弦 math.asin(1) -> 1.570796...
math.atan(y [, x])          反正切；给 x 时相当于 atan2(y, x)；math.atan(1) -> pi/4
math.ceil(x)                向上取整 math.ceil(3.2) -> 4
math.cos(x)                 余弦 math.cos(0) -> 1.0
math.deg(x)                 弧度转角度 math.deg(math.pi) -> 180.0
math.exp(x)                 自然指数 e^x，math.exp(1) -> 2.718...
math.floor(x)               向下取整 math.floor(3.8) -> 3
math.fmod(x, y)             取余，余数符号随 x，math.fmod(-5, 3) -> -2.0
math.log(x [, base])        对数；省略 base 为自然对数，math.log(100, 10) -> 2.0
math.max(x, ...)            返回最大值，math.max(1, 5, 3) -> 5
math.min(x, ...)            返回最小值，math.min(1, 5, 3) -> 1
math.modf(x)                返回整数部分和小数部分，math.modf(3.7) -> 3.0, 0.7
math.rad(x)                 角度转弧度，math.rad(180) -> pi
math.random([m [, n]])      随机数：无参返回 [0,1) 浮点；random(n) 返回 [1,n]；random(m,n) 返回 [m,n]，math.random(1, 6)
math.randomseed([x [, y]])  设置随机种子；5.4 无参时自动生成并返回种子分量，math.randomseed(123)
math.sin(x)                 正弦，math.sin(math.pi/2) -> 1.0
math.sqrt(x)                平方根，math.sqrt(9) -> 3.0
math.tan(x)                 正切，math.tan(math.pi/4) -> 1.0
math.tointeger(x)           尝试转成整数，不能转返回 nil，math.tointeger(3.0) -> 3
math.type(x)                返回 "integer"、"float" 或 nil，math.type(3) -> "integer"
math.ult(m, n)              按无符号整数比较 m < n，math.ult(0, -1) -> true
math.huge                   无穷大，math.huge > 1e308 -> true
math.pi                     圆周率 π，3.1415926535898
math.maxinteger             最大整数值，通常 64 位下为 9223372036854775807
math.mininteger             最小整数值，通常 64 位下为 -9223372036854775808
```


表示范围：skip

算术运算符

```text
+   加法        数值相加，3 + 2 → 5
-   减法/负号   二元为相减，一元为取负，5 - 2 → 3；-x
*   乘法        数值相乘，3 * 4 → 12
/   浮点除法    结果总是浮点数，7 / 2 → 3.5
//  整除        向下取整的除法，7 // 2 → 3；-7 // 2 → -4
%   取模        余数，结果符号与除数一致，7 % 3 → 1；-5 % 3 → 1
^   幂          乘方，右结合，2 ^ 3 → 8
```

位运算符

```text
&	按位与	两个整数逐位与	5 & 3 → 1
|	按位或	两个整数逐位或
~	按位异或（二元）	两个整数逐位异或	5 ~ 3 → 6
~	按位取反（一元）	对整数逐位取反	~0 → -1
<<	左移	左移指定位数	1 << 3 → 8
>>	右移	逻辑右移	8 >> 2 → 2
```

逻辑运算符

```text
and    or    not
```

其他运算符

```text
..	字符串连接	连接两个字符串或数字，右结合	"a" .. "b" → "ab"
#	长度	返回字符串字节数或表的序列长度	#"abc" → 3；#{1,2,3} → 3
=	赋值符号	用于赋值语句，不是表达式运算符	x = 10
```

补充说明

```text
Lua 没有 +=、-=、*= 等复合赋值运算符。
Lua 没有 ++、-- 自增自减运算符（-- 是注释符号）。
Lua 没有 ?: 条件运算符，通常用 and / or 模拟。
位运算符仅适用于整数，浮点数会报错；算术运算符中 / 总是产生浮点数，// 产生整数（若操作数都是整数）。
```


## 字符串

可以使⽤长度操作符（length operator）（#）获取字符串的长度：

```bash-session
> #"hello world"
11
> a = "hello world"
> print(#a)
11
```

可以使用连接操作符 `..`（两个点）来进行字符串连接。

```bash-session
> a = "hello"
> b = "world"
> print(a .. b)
helloworld
```

字符串常量：

长字符串/多行字符串

可以使用一对双方括号来声明长字符串/多行字符串常量

```lua
a=[[
say
hello
world
]]
```

强制类型转换

Lua 语言在运行时提供了数值与字符串之间的自动转换。

```bash-session
> print(10 .. 20)
1020
> print("10" + 1)
11
```

如果需要显示地将一个字符串转换成数值，那么可以使用函数 tonumber

调用函数 tostring 可以将数值转换成字符串

字符串标准库

字符串是不可变值，所有 string 库函数都返回新字符串，不会修改原字符串。

```text
string.byte(s [, i [, j]])	返回 s[i] 到 s[j] 的字节值（整数），默认 i=1, j=i	string.byte("ABC", 1, 2) → 65, 66
string.char(...)	将整数转换成对应字符并连接成字符串	string.char(65, 66, 67) → "ABC"
string.dump(function [, strip])	返回函数的二进制表示，可被 load 加载	string.dump(function() return 1 end)
string.find(s, pattern [, init [, plain]])	在 s 中查找模式，返回起始和结束位置；未找到返回 nil	string.find("hello", "ll") → 3, 4
string.format(formatstring, ...)	按格式串格式化并返回新字符串，类似 printf	string.format("%d %s", 10, "x") → "10 x"
string.gmatch(s, pattern)	返回迭代器，用于遍历 s 中所有匹配模式的子串	for w in string.gmatch("a b", "%a+") do print(w) end
string.gsub(s, pattern, repl [, n])	替换匹配模式的部分，返回新字符串和替换次数	string.gsub("hello", "l", "L") → "heLLo", 2
string.len(s)	返回字符串长度（字节数）	string.len("abc") → 3
string.lower(s)	返回转小写后的副本	string.lower("AbC") → "abc"
string.match(s, pattern [, init])	返回第一个匹配模式的捕获或整个匹配；未匹配返回 nil	string.match("hello 123", "%d+") → "123"
string.pack(fmt, v1, ...)	按二进制格式打包并返回二进制字符串	string.pack("i4", 123)
string.packsize(fmt)	返回按格式打包所需的字节数	string.packsize("i4") → 4
string.rep(s, n [, sep])	返回 s 重复 n 次的字符串，可插入分隔符 sep	string.rep("ab", 3, "-") → "ab-ab-ab"
string.reverse(s)	返回字符串反转后的副本	string.reverse("abc") → "cba"
string.sub(s, i [, j])	返回子串 s[i..j]，支持负数索引	string.sub("hello", 2, 4) → "ell"
string.unpack(fmt, s [, pos])	按二进制格式从 s 解包值，返回解包值和下一个位置	local v, pos = string.unpack("i4", s)
string.upper(s)	返回转大写后的副本	string.upper("AbC") → "ABC"
```




## 表

创建 table：

```bash-session
> a = {}
> k = "x"
> a[k] = 10
> a[20] = "great"

> a["x"]
10
> k = 20
> a[k]
great
```

对于一个表而言，当程序中不再有指向它的引用时，垃圾收集器会最终删除这个表并重用其占用的内存。

表索引

数组索引按照惯例是从 1 开始的

对于中间存在空洞（nil值）的列表而言，序列长度操作符 `#` 是不可靠的

多数情况下使用长度操作符是安全的，在确实需要处理存在空洞的列表时，应该将列表的长度显式地保存起来。

```bash-session
> a = {}
> a[1] = "a"
> a[3] = "c"
> {{< text fg="foreground" >}}#a{{< /text >}}
1
```

```bash-session
> a = {"a", "b", "c"}
> a[2] = nil
> {{< text fg="foreground" >}}#a{{< /text >}}
3
```

遍历表：

使用 pairs 迭代器，遍历所有键值，

```lua
t = {11, a=22, c=33, 44}

for k, v in pairs(t) do
    print(k, v)
end
```
输出（键值顺序不定）

```bash-session{ nonebg=true }
1	11
2	44
c	33
a	22
```

使用 ipairs 仅遍历数字键值（数组部分）

```lua
t = {11, a=22, c=33, 44}

for k, v in ipairs(t) do
    print(k, v)
end
```

```bash-session{ nonebg=true }
1	11
2	44
```

需要遍历全部数据（包括字符串键） → 用 pairs

处理数组/列表，且需要保证顺序 → 用 ipairs

数组中有 nil 空洞 → 用 pairs（ipairs 会提前中断）
