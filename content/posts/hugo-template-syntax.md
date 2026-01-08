---
title: "Hugo 模板语法"
date: "2025-12-26"
toc: true
---





## 基本语法

### 上下文

`.` 代表当前上下文，在 `range/with` 块中会被重新绑定。

在页面模板的顶层，当前上下文与 `Page` 对象绑定，如下调用 `Page` 的 `Title` 方法获取标题：

```go-template
{{ .Title }}  →  Hugo 模板语法
```

`$` 代表根上下文，始终指向模板的顶层上下文，在 `range/with` 块中是不可变的。


### 注释

```go-template
{{/* 注释内容 */}}
```



### 自定义变量

使用 `:=` 初始化变量，使用 `=` 修改已初始化的变量：

```go-template
{{ $name := "Alice" }}
{{ $name = "Bob" }}
```

### 变量作用域

变量在 `if/range/with` 块内为局部变量。


`:=` 在块内无法修改外部变量：

```go-template
{{ $name := "Alice" }}
{{ if true }}
    {{ $name := "Bob" }}
{{ end }}
{{ $name }}
```

```bash-session
Alice
```

`=` 从当前作用域向外查找，可以修改外部变量：

```go-template
{{ $name := "Alice" }}
{{ if true }}
    {{ $name = "Bob" }}
{{ end }}
{{ $name }}
```

```bash-session
Bob
```

> 优先使用 `:=` ，除非明确需要修改外部变量。



### 切片（数组）

```go-template
{{ $arr := slice "a" "b" "c" "d" }}
{{/* 索引访问 */}}
{{ index $arr 0 }}
{{/* 首尾元素 */}}
{{ first 1 $arr }}
{{ last  1 $arr }}
{{/* 数组长度 */}}
{{ len $arr }}
```

### 字典

```go-template
{{ $m := dict "a" 1 "b" 2 }}
{{/* 点号访问 */}}
{{ $m.a }}
{{/* 键值访问 */}}
{{ index $m "b" }}

```


### if 语句

`if` 用于判断表达式，会创建新的作用域，当前上下文 `.` 不变。

```go-template
{{ if false }}
{{ else if true }}
{{ else }}
{{ end }}
```

比较运算符：

```go-template
{{ if eq $num 5 }}    等于     
{{ if ne $num 5 }}    不等于   
{{ if lt $num 5 }}    小于     
{{ if le $num 5 }}    小于等于 
{{ if gt $num 5 }}    大于     
{{ if ge $num 5 }}    大于等于 
```

逻辑运算符：

```go-template
{{ if and (gt $num 5) (lt $num 10) }}
{{ if or  (gt $num 5) (lt $num 10) }}
{{ if not (gt $num 5) (lt $num 10) }}
```

空值判断：

```go-template
{{ if .Param }}
```




### with 语句

`with` 用于判断表达式，会创建新的作用域，并重新绑定 `.` 为当前表达式：

```go-template
<p>当前页面的标题：{{ .Title }}</p>
{{ with .Site }}
    {{/* 当前上下文与 .Site 绑定 */}}
    <p>当前站点的标题：{{ .Title }}</p>
    {{/* 根上下文不会被改变 */}}
    <p>根上下文的标题：{{ $.Title }}</p>
{{ else }}
    {{/* 此处不会改变上下文 */}}
{{ end }}
```

```bash-session
当前页面的标题：Hugo 模板语法
当前站点的标题：King's Blog
根上下文的标题：Hugo 模板语法
```




### range 语句


`range` 用于遍历数据，会创建新的作用域，并重新绑定 `.` 为当前迭代的元素：


```go-template
{{ $array := slice "a" "b" "c" }}
{{ range $array }}
    <p>输出：{{ . }}</p>
{{ end }}
```

```bash-session
输出：a
输出：b
输出：c
```

遍历并获取索引：

```go-template
{{ $array := slice "a" "b" "c" }}
{{ range $index, $element := $array }}
    <p>第 {{ $index }} 个: {{ $element }}</p>
{{ end }}
```

```bash-session
第 0 个: a
第 1 个: b
第 2 个: c
```

处理空值：

```go-template
{{ range .Pages }}
    {{ .Title }}
{{ else }}
    <p>暂无内容</p>
{{ end }}
```

```bash-session
暂无内容
```



### 空白字符

使用 `-` 清除空白字符。

默认不清除：

```go-template
<pre>|    {{ .Title }}    |</pre>
```

```bash-session
|    Hugo 模板语法    |
```

清除左侧空白字符：

```go-template
<pre>|    {{- .Title }}    |</pre>
```

```bash-session
|Hugo 模板语法    |
```

清除两侧空白字符：


```go-template
<pre>|    {{- .Title -}}    |</pre>
```

```bash-session
|Hugo 模板语法|
```


### 管道操作

管道 `|` 左侧的值会成为 `|` 右侧函数或方法的最后一个参数：

```go-template
{{ "HELLO WORLD" | lower }}    {{/* lower 函数将所有字符转化为小写 */}}
```

```bash-session
hello world
```


### Nil 空值

```go-template
{{ if gt 42 nil }}
  <p>42 is greater than nil</p>
{{ end }}
```



### 行分割

```go-template
{{ $v := or 
  $arg1
  $arg2
}}
```

```go-template
{{ $msg := `This is line one.
This is line two.`
}}
```


## 访问站点配置与前置元数据

{{< bar block="站点配置" title="hugo.toml" >}}

```toml
[params]
	headerTitle = "夜不能寐"
```

{{< bar block="前置元数据" title="content/posts/hugo-template-syntax.md" >}}

```yaml
---
title: "Hugo 模板语法"
date: "2025-12-26"
toc: true
---
```


方法一：调用 `Site` 与 `Page` 对象的 `Params` 方法：

```go-template
{{ .Site.Params.headerTitle }}  →  夜不能寐
{{ .Page.Params.title }}        →  Hugo 模板语法
{{ .Params.title }}             →  Hugo 模板语法   {{/* 在模板顶层 . 与 Page 绑定 */}}
```


方法二：通过全局函数 `site` 与 `page` 调用 `Params` 方法：

```go-template
{{ site.Params.headerTitle }}   →  夜不能寐
{{ page.Params.title }}         →  Hugo 模板语法
```

> `site` 函数提供对 `Site` 对象的全局访问，`page` 函数提供对 `Page` 对象的全局访问。



## 函数

{{< table thead="false" >}}

|||
|:--|:--|:--|:--|:--|
|**数据类型转换**|
|[float](https://gohugo.io/functions/cast/tofloat/ "将值转换为十进制浮点数（以 10 为底）")|[int](https://gohugo.io/functions/cast/toint/ "将值转换为十进制整数（基数为 10）") |[string](https://gohugo.io/functions/cast/tostring/ "将值转换为字符串")|
|**集合**|
|[after](https://gohugo.io/functions/collections/after/ "将数组切片为第 N 项之后的元素") |[append](https://gohugo.io/functions/collections/append/ "将一个或多个元素追加到切片中，并返回结果切片") |[apply](https://gohugo.io/functions/collections/apply/ "返回一个新集合，其中每个元素都经过给定函数的转换") |[complement](https://gohugo.io/functions/collections/complement/ "返回最后一个集合中不在任何其他集合中的元素") |[collections.D](https://gohugo.io/functions/collections/d/ "返回一个已排序的唯一随机整数切片。")|
|[delimit](https://gohugo.io/functions/collections/delimit/ "遍历任何数组、切片或映射，并返回由分隔符分隔的所有值组成的字符串。") |[dict](https://gohugo.io/functions/collections/dictionary/ "返回由给定键值对组成的映射。") |[first](https://gohugo.io/functions/collections/first/ "返回给定的集合，限制为前 N 个元素。") |[group](https://gohugo.io/functions/collections/group/ "将给定的页面集合按指定键进行分组。") |[in](https://gohugo.io/functions/collections/in/ "报告给定值是否为给定集合的成员。")|
|[index](https://gohugo.io/functions/collections/indexfunction/ "返回与给定键或键集相关联的对象、元素或值。") |[intersect](https://gohugo.io/functions/collections/intersect/ "返回两个数组或切片中的共同元素，顺序与第一个数组保持一致。") |[isset](https://gohugo.io/functions/collections/isset/ "报告该键是否存在于集合中。") |[keyVals](https://gohugo.io/functions/collections/keyvals/ "返回一个 KeyVals 结构体。") |[last](https://gohugo.io/functions/collections/last/ "返回给定的集合，限制为最后 N 个元素。")|
|[merge](https://gohugo.io/functions/collections/merge/ "返回合并两个或多个映射的结果。") |[newScratch](https://gohugo.io/functions/collections/newscratch/ "返回一个局部作用域的“暂存区”，用于存储和操作数据。") |[querify](https://gohugo.io/functions/collections/querify/ "返回由给定键值对组成的 URL 查询字符串，经过编码并按键排序。") |[collections.Reverse](https://gohugo.io/functions/collections/reverse/ "反转集合的顺序") |[seq](https://gohugo.io/functions/collections/seq/ "返回一个整数切片。")|
|[shuffle](https://gohugo.io/functions/collections/shuffle/ "返回给定数组或切片的一个随机排列。") |[slice](https://gohugo.io/functions/collections/slice/ "返回由给定值组成的切片。") |[sort](https://gohugo.io/functions/collections/sort/ "对切片、映射和页面集合进行排序。") |[symdiff](https://gohugo.io/functions/collections/symdiff/ "返回两个集合的对称差集。") |[union](https://gohugo.io/functions/collections/union/ "给定两个数组或切片，返回一个新数组，该数组包含属于任一或两个数组/切片的元素。")|
|[uniq](https://gohugo.io/functions/collections/uniq/ "返回给定集合，移除重复元素。") |[where](https://gohugo.io/functions/collections/where/ "返回给定的集合，移除不满足比较条件的元素。")|
|**比较**|
|[cond](https://gohugo.io/functions/compare/conditional/ "根据控制参数的值返回两个参数中的一个。") |[default](https://gohugo.io/functions/compare/default/ "如果设置了第二个参数，则返回第二个参数，否则返回第一个参数。") |[eq](https://gohugo.io/functions/compare/eq/ "返回 arg1 == arg2 或 arg1 == arg3 的布尔真值。") |[ge](https://gohugo.io/functions/compare/ge/ "返回布尔值真值：arg1 >= arg2 && arg1 >= arg3。") |[gt](https://gohugo.io/functions/compare/gt/ "返回布尔值，表示 arg1 > arg2 且 arg1 > arg3 的真假。")|
|[le](https://gohugo.io/functions/compare/le/ "返回 arg1 <= arg2 && arg1 <= arg3 的布尔真值。") |[lt](https://gohugo.io/functions/compare/lt/ "返回布尔真值：arg1 < arg2 && arg1 < arg3。") |[ne](https://gohugo.io/functions/compare/ne/ "返回 arg1 != arg2 && arg1 != arg3 的布尔真值。")|
|**CSS**|
|[postCSS](https://gohugo.io/functions/css/postcss/ "使用任何 PostCSS 插件，通过 PostCSS 处理给定的资源。") |[css.Quoted](https://gohugo.io/functions/css/quoted/ "返回给定的字符串，将其数据类型设置为指示在 CSS 中使用时必须加引号。") |[css.Sass](https://gohugo.io/functions/css/sass/ "将 Sass 编译为 CSS。") |[css.TailwindCSS](https://gohugo.io/functions/css/tailwindcss/ "使用 Tailwind CSS CLI 处理给定的资源。") |[css.Unquoted](https://gohugo.io/functions/css/unquoted/ "返回给定的字符串，并将其数据类型设置为指示在 CSS 中使用时不应加引号。")|
|**格式化输出**|
|[errorf](https://gohugo.io/functions/fmt/errorf/ "从模板中记录一个错误。") |[erroridf](https://gohugo.io/functions/fmt/erroridf/ "从模板中记录一个可抑制的错误。") |[print](https://gohugo.io/functions/fmt/print/ "使用标准 fmt.Print 函数打印给定参数的默认表示形式。") |[printf](https://gohugo.io/functions/fmt/printf/ "使用标准的 fmt.Sprintf 函数格式化字符串。") |[println](https://gohugo.io/functions/fmt/println/ "使用标准 fmt.Print 函数打印给定参数的默认表示形式并强制换行。")|
|[warnf](https://gohugo.io/functions/fmt/warnf/ "从模板记录一条警告。") |[warnidf](https://gohugo.io/functions/fmt/warnidf/ "从模板记录一条可抑制的警告。")|
|**全局**|
|[page](https://gohugo.io/functions/global/page/ "提供对 Page 对象的全局访问。") |[site](https://gohugo.io/functions/global/site/ "提供对当前站点对象的全局访问。")|
|**Go 模板**|
|[and](https://gohugo.io/functions/go-template/and/ "返回第一个假值参数。如果所有参数都为真值，则返回最后一个参数。") |[block](https://gohugo.io/functions/go-template/block/ "定义一个模板并在原地执行它。") |[break](https://gohugo.io/functions/go-template/break/ "与 range 语句配合使用时，停止最内层迭代并跳过所有剩余迭代。") |[continue](https://gohugo.io/functions/go-template/continue/ "与 range 语句配合使用时，停止最内层迭代并继续执行下一次迭代。") |[define](https://gohugo.io/functions/go-template/define/ "定义一个模板。")|
|[else](https://gohugo.io/functions/go-template/else/ "为 if、with 和 range 语句开启一个替代块。") |[end](https://gohugo.io/functions/go-template/end/ "终止 if、with、range、block 和 define 语句。") |[if](https://gohugo.io/functions/go-template/if/ "如果表达式为真值，则执行该代码块。") |[len](https://gohugo.io/functions/go-template/len/ "返回字符串、切片、映射或集合的长度。") |[not](https://gohugo.io/functions/go-template/not/ "返回其单个参数的布尔否定值。")|
|[or](https://gohugo.io/functions/go-template/or/ "返回第一个真值参数。如果所有参数均为假值，则返回最后一个参数。") |[range](https://gohugo.io/functions/go-template/range/ "遍历一个非空集合，将上下文（点号）绑定到连续的元素上，并执行代码块。") |[return](https://gohugo.io/functions/go-template/return/ "在部分模板中使用，终止模板执行并返回给定值（如果有的话）。") |[template](https://gohugo.io/functions/go-template/template/ "执行给定的模板，可选择传递上下文。") |[try](https://gohugo.io/functions/go-template/try/ "在评估给定表达式后返回一个 TryValue 对象。")|
|[urlquery](https://gohugo.io/functions/go-template/urlquery/ "返回其参数文本表示的转义值，格式适用于嵌入 URL 查询中。") |[with](https://gohugo.io/functions/go-template/with/ "将上下文（点）绑定到表达式，并在表达式为真时执行代码块。")|
|**hugo**|
|[hugo.BuildDate](https://gohugo.io/functions/hugo/builddate/ "返回 Hugo 二进制文件的编译日期。") |[hugo.CommitHash](https://gohugo.io/functions/hugo/commithash/ "返回 Hugo 二进制文件的 Git 提交哈希值。") |[hugo.Deps](https://gohugo.io/functions/hugo/deps/ "返回一个项目依赖项的切片，这些依赖项可以是 Hugo 模块或本地主题组件。") |[hugo.Environment](https://gohugo.io/functions/hugo/environment/ "返回当前运行环境。") |[hugo.Generator](https://gohugo.io/functions/hugo/generator/ "渲染一个 HTML 元元素，用于标识生成该站点的软件。")|
|[hugo.GoVersion](https://gohugo.io/functions/hugo/goversion/ "返回用于编译 Hugo 二进制文件的 Go 版本") |[hugo.IsDevelopment](https://gohugo.io/functions/hugo/isdevelopment/ "报告当前运行环境是否为“开发”环境。") |[hugo.IsExtended](https://gohugo.io/functions/hugo/isextended/ "报告 Hugo 二进制文件是否为扩展版或扩展/部署版。") |[hugo.IsMultihost](https://gohugo.io/functions/hugo/ismultihost/ "报告每个配置的语言是否具有唯一的基准 URL。") |[hugo.IsMultilingual](https://gohugo.io/functions/hugo/ismultilingual/ "报告是否配置了两种或更多语言。")|
|[hugo.IsProduction](https://gohugo.io/functions/hugo/isproduction/ "报告当前运行环境是否为“生产环境”。") |[hugo.IsServer](https://gohugo.io/functions/hugo/isserver/ "报告内置开发服务器是否正在运行。") |[hugo.Store](https://gohugo.io/functions/hugo/store/ "返回一个全局作用域的“暂存区”，用于存储和操作数据。") |[hugo.Version](https://gohugo.io/functions/hugo/version/ "返回 Hugo 二进制文件的当前版本。") |[hugo.WorkingDir](https://gohugo.io/functions/hugo/workingdir/ "返回项目工作目录。")|
|**图像**|
|[images.AutoOrient](https://gohugo.io/functions/images/autoorient/ "返回一个图像过滤器，根据需要根据其 EXIF 方向标签旋转和翻转图像。") |[images.Brightness](https://gohugo.io/functions/images/brightness/ "返回一个改变图像亮度的图像滤镜。") |[images.ColorBalance](https://gohugo.io/functions/images/colorbalance/ "返回一个改变图像色彩平衡的图像滤镜。") |[images.Colorize](https://gohugo.io/functions/images/colorize/ "返回一个图像过滤器，用于生成图像的彩色化版本。") |[images.Config](https://gohugo.io/functions/images/config/ "返回相对于工作目录指定路径处图像的 image.Config 结构。")|
|[images.Contrast](https://gohugo.io/functions/images/contrast/ "返回一个改变图像对比度的图像滤镜。") |[images.Dither](https://gohugo.io/functions/images/dither/ "返回一个对图像进行抖动的图像过滤器。") |[images.Filter](https://gohugo.io/functions/images/filter/ "对给定的图像资源应用一个或多个图像滤镜。") |[images.Gamma](https://gohugo.io/functions/images/gamma/ "返回一个对图像执行伽马校正的图像滤镜。") |[images.GaussianBlur](https://gohugo.io/functions/images/gaussianblur/ "返回一个对图像应用高斯模糊的图像滤镜。")|
|[images.Grayscale](https://gohugo.io/functions/images/grayscale/ "返回一个图像过滤器，该过滤器可生成图像的灰度版本。") |[images.Hue](https://gohugo.io/functions/images/hue/ "返回一个旋转图像色调的图像滤镜。") |[images.Invert](https://gohugo.io/functions/images/invert/ "返回一个图像滤镜，该滤镜会反转图像的颜色。") |[images.Mask](https://gohugo.io/functions/images/mask/ "返回一个对源图像应用蒙版的图像过滤器。") |[images.Opacity](https://gohugo.io/functions/images/opacity/ "返回一个改变图像不透明度的图像过滤器。")|
|[images.Overlay](https://gohugo.io/functions/images/overlay/ "返回一个图像滤镜，该滤镜将源图像叠加在相对于左上角给定坐标的位置上。") |[images.Padding](https://gohugo.io/functions/images/padding/ "返回一个调整图像画布大小但不调整图像本身的图像过滤器。") |[images.Pixelate](https://gohugo.io/functions/images/pixelate/ "返回一个对图像应用像素化效果的图像滤镜。") |[images.Process](https://gohugo.io/functions/images/process/ "返回一个图像过滤器，该过滤器使用给定的规格处理指定的图像。") |[images.QR](https://gohugo.io/functions/images/qr/ "使用指定选项将给定文本编码为二维码，返回图像资源。")|
|[images.Saturation](https://gohugo.io/functions/images/saturation/ "返回一个改变图像饱和度的图像滤镜。") |[images.Sepia](https://gohugo.io/functions/images/sepia/ "返回一个图像滤镜，该滤镜可生成图像的棕褐色调版本。") |[images.Sigmoid](https://gohugo.io/functions/images/sigmoid/ "返回一个使用 S 型函数改变图像对比度的图像滤镜。") |[images.Text](https://gohugo.io/functions/images/text/ "返回一个向图像添加文本的图像过滤器。") |[images.UnsharpMask](https://gohugo.io/functions/images/unsharpmask/ "返回一个用于锐化图像的图像滤镜。")|
|**数学**|
|[math.Abs](https://gohugo.io/functions/math/abs/ "返回给定数字的绝对值。") |[math.Acos](https://gohugo.io/functions/math/acos/ "返回给定数字的反余弦值，单位为弧度。") |[add](https://gohugo.io/functions/math/add/ "将两个或多个数字相加。") |[math.Asin](https://gohugo.io/functions/math/asin/ "返回给定数字的反正弦值，单位为弧度。") |[math.Atan](https://gohugo.io/functions/math/atan/ "返回给定数字的反正切值，单位为弧度。")|
|[math.Atan2](https://gohugo.io/functions/math/atan2/ "返回给定数字对的反正切值（以弧度为单位），根据它们的符号确定正确的象限。") |[math.Ceil](https://gohugo.io/functions/math/ceil/ "返回大于或等于给定数字的最小整数值。") |[math.Cos](https://gohugo.io/functions/math/cos/ "返回给定弧度数的余弦值。") |[math.Counter](https://gohugo.io/functions/math/counter/ "递增并返回一个全局计数器。") |[div](https://gohugo.io/functions/math/div/ "将第一个数除以一个或多个数。")|
|[math.Floor](https://gohugo.io/functions/math/floor/ "返回小于或等于给定数字的最大整数值。") |[math.Log](https://gohugo.io/functions/math/log/ "返回给定数字的自然对数。") |[math.Max](https://gohugo.io/functions/math/max/ "返回所有数字中的最大值。接受标量、切片或两者。") |[math.MaxInt64](https://gohugo.io/functions/math/maxint64/ "返回有符号 64 位整数的最大值。") |[math.Min](https://gohugo.io/functions/math/min/ "返回所有数字中的最小值。接受标量、切片或两者。")|
|[mod](https://gohugo.io/functions/math/mod/ "返回两个整数的模。") |[modBool](https://gohugo.io/functions/math/modbool/ "报告两个整数的模是否等于 0。") |[mul](https://gohugo.io/functions/math/mul/ "将两个或多个数字相乘。") |[math.Pi](https://gohugo.io/functions/math/pi/ "返回数学常数π。") |[pow](https://gohugo.io/functions/math/pow/ "返回第一个数的第二个数次幂。")|
|[math.Product](https://gohugo.io/functions/math/product/ "返回所有数字的乘积。接受标量、切片或两者。") |[math.Rand](https://gohugo.io/functions/math/rand/ "返回一个在半开区间 [0.0, 1.0) 内的伪随机数。") |[math.Round](https://gohugo.io/functions/math/round/ "返回最接近的整数，四舍五入时远离零的方向取整。") |[math.Sin](https://gohugo.io/functions/math/sin/ "返回给定弧度数的正弦值。") |[math.Sqrt](https://gohugo.io/functions/math/sqrt/ "返回给定数字的平方根。")|
|[sub](https://gohugo.io/functions/math/sub/ "从第一个数中减去一个或多个数。") |[math.Sum](https://gohugo.io/functions/math/sum/ "返回所有数字的总和。接受标量、切片或两者。") |[math.Tan](https://gohugo.io/functions/math/tan/ "返回给定弧度数的正切值。") |[math.ToDegrees](https://gohugo.io/functions/math/todegrees/ "ToDegrees 将弧度转换为角度。") |[math.ToRadians](https://gohugo.io/functions/math/toradians/ "ToRadians 将角度转换为弧度。")|
|**系统**|
|[fileExists](https://gohugo.io/functions/os/fileexists/ "报告文件或目录是否存在。") |[getenv](https://gohugo.io/functions/os/getenv/ "返回环境变量的值，如果环境变量未设置，则返回空字符串。") |[readDir](https://gohugo.io/functions/os/readdir/ "返回一个按文件名排序的 FileInfo 结构数组，每个目录条目对应一个元素。") |[readFile](https://gohugo.io/functions/os/readfile/ "返回文件的内容。") |[os.Stat](https://gohugo.io/functions/os/stat/ "返回一个描述文件或目录的 FileInfo 结构。")|
|**局部模板**|
|[partial](https://gohugo.io/functions/partials/include/ "执行给定的模板，可选择传递上下文。如果部分模板包含返回语句，则返回给定值，否则返回渲染后的输出。") |[partialCached](https://gohugo.io/functions/partials/includecached/ "执行给定的模板并缓存结果，可选择传递一个或多个变体键。如果局部模板包含返回语句，则返回给定值，否则返回渲染后的输出。")|
|**路径**|
|[path.Base](https://gohugo.io/functions/path/base/ "将路径分隔符替换为斜杠（ / ）并返回给定路径的最后一个元素。") |[path.BaseName](https://gohugo.io/functions/path/basename/ "将路径分隔符替换为斜杠（ / ），并返回给定路径的最后一个元素，如果存在扩展名则将其移除。") |[path.Clean](https://gohugo.io/functions/path/clean/ "将路径分隔符替换为斜杠（ / ）并返回与给定路径等效的最短路径名。") |[path.Dir](https://gohugo.io/functions/path/dir/ "将路径分隔符替换为斜杠（/），并返回给定路径中除最后一个元素外的所有部分。") |[path.Ext](https://gohugo.io/functions/path/ext/ "将路径分隔符替换为斜杠（ / ）并返回给定路径的文件扩展名。")|
|[path.Join](https://gohugo.io/functions/path/join/ "将路径分隔符替换为斜杠（ / ），将给定的路径元素连接成单个路径，并返回与结果等效的最短路径名。") |[path.Split](https://gohugo.io/functions/path/split/ "将路径分隔符替换为斜杠（ / ），并在最后一个斜杠后立即分割结果路径，将其分离为目录和文件名组件。")|
|**资源**|
|[resources.ByType](https://gohugo.io/functions/resources/bytype/ "返回指定媒体类型的全局资源集合，若未找到则返回 nil。") |[resources.Concat](https://gohugo.io/functions/resources/concat/ "返回一个资源的拼接切片。") |[resources.Copy](https://gohugo.io/functions/resources/copy/ "将给定资源复制到目标路径。") |[resources.ExecuteAsTemplate](https://gohugo.io/functions/resources/executeastemplate/ "返回一个由 Go 模板创建的资源，该模板已根据给定上下文进行解析和执行。") |[fingerprint](https://gohugo.io/functions/resources/fingerprint/ "对给定资源的内容进行加密哈希处理。")|
|[resources.FromString](https://gohugo.io/functions/resources/fromstring/ "返回由字符串创建的资源。") |[resources.Get](https://gohugo.io/functions/resources/get/ "返回给定路径的全局资源，若未找到则返回 nil。") |[resources.GetMatch](https://gohugo.io/functions/resources/getmatch/ "返回与给定通配符模式匹配的路径中的第一个全局资源，如果未找到则返回 nil。") |[resources.GetRemote](https://gohugo.io/functions/resources/getremote/ "从给定 URL 返回远程资源，若未找到则返回 nil。") |[resources.Match](https://gohugo.io/functions/resources/match/ "返回与给定通配符模式匹配的路径中的全局资源集合，如果未找到则返回 nil。")|
|[minify](https://gohugo.io/functions/resources/minify/ "将给定资源进行压缩。") |[resources.PostProcess](https://gohugo.io/functions/resources/postprocess/ "在构建完成后处理给定的资源。")|
|**安全**|
|[safeCSS](https://gohugo.io/functions/safe/css/ "将给定字符串声明为安全的 CSS 字符串。") |[safeHTML](https://gohugo.io/functions/safe/html/ "将给定字符串声明为安全的 HTML 字符串。") |[safeHTMLAttr](https://gohugo.io/functions/safe/htmlattr/ "将给定的键值对声明为安全的 HTML 属性。") |[safeJS](https://gohugo.io/functions/safe/js/ "将给定字符串声明为安全的 JavaScript 表达式。") |[safeJSStr](https://gohugo.io/functions/safe/jsstr/ "将给定字符串声明为安全的 JavaScript 字符串。")|
|[safeURL](https://gohugo.io/functions/safe/url/ "将给定字符串声明为安全的 URL 或 URL 子字符串。")|
|**字符串**|
|[chomp](https://gohugo.io/functions/strings/chomp/ "返回给定字符串，移除所有末尾的换行符和回车符。") |[strings.Contains](https://gohugo.io/functions/strings/contains/ "报告给定的字符串是否包含给定的子字符串。") |[strings.ContainsAny](https://gohugo.io/functions/strings/containsany/ "报告给定字符串是否包含给定集合中的任何字符。") |[strings.ContainsNonSpace](https://gohugo.io/functions/strings/containsnonspace/ "报告给定字符串是否包含 Unicode 定义的非空格字符。") |[strings.Count](https://gohugo.io/functions/strings/count/ "返回给定字符串中给定子字符串的非重叠实例数量。")|
|[countrunes](https://gohugo.io/functions/strings/countrunes/ "返回给定字符串中除空白字符外的符文数量。") |[countwords](https://gohugo.io/functions/strings/countwords/ "返回给定字符串中的单词数量。") |[strings.Diff](https://gohugo.io/functions/strings/diff/ "返回以统一差异格式显示的旧文本 OLD 与新文本 NEW 之间的锚定差异。若 OLD 与 NEW 完全相同，则返回空字符串。") |[findRE](https://gohugo.io/functions/strings/findre/ "返回与正则表达式匹配的字符串切片。") |[findRESubmatch](https://gohugo.io/functions/strings/findresubmatch/ "返回正则表达式的所有连续匹配的切片。每个元素是一个字符串切片，包含正则表达式的最左匹配文本及其子表达式（如果有）的匹配结果。")|
|[strings.FirstUpper](https://gohugo.io/functions/strings/firstupper/ "返回给定字符串，将首字母大写。") |[hasPrefix](https://gohugo.io/functions/strings/hasprefix/ "判断给定字符串是否以指定前缀开头。") |[hasSuffix](https://gohugo.io/functions/strings/hassuffix/ "判断给定字符串是否以指定后缀结尾。") |[strings.Repeat](https://gohugo.io/functions/strings/repeat/ "返回一个由另一个字符串的零个或多个副本组成的新字符串。") |[replace](https://gohugo.io/functions/strings/replace/ "返回 INPUT 的副本，其中所有 OLD 的出现均被替换为 NEW。")|
|[replaceRE](https://gohugo.io/functions/strings/replacere/ "返回 INPUT 的副本，将所有匹配正则表达式的部分替换为指定的替换模式。") |[strings.RuneCount](https://gohugo.io/functions/strings/runecount/ "返回给定字符串中的符文数量。") |[slicestr](https://gohugo.io/functions/strings/slicestring/ "返回给定字符串的子串，从起始位置开始，到结束位置之前为止。") |[split](https://gohugo.io/functions/strings/split/ "通过按分隔符拆分给定字符串，返回一个字符串切片。") |[substr](https://gohugo.io/functions/strings/substr/ "返回给定字符串的子串，从起始位置开始，并在指定长度后结束。")|
|[title](https://gohugo.io/functions/strings/title/ "返回给定字符串，将其转换为标题大小写。") |[lower](https://gohugo.io/functions/strings/tolower/ "返回给定字符串，将所有字符转换为小写。") |[upper](https://gohugo.io/functions/strings/toupper/ "返回给定字符串，将所有字符转换为大写。") |[trim](https://gohugo.io/functions/strings/trim/ "返回给定字符串，移除在 cutset 中指定的前导和尾随字符。") |[strings.TrimLeft](https://gohugo.io/functions/strings/trimleft/ "返回给定字符串，移除在 cutset 中指定的前导字符。")|
|[strings.TrimPrefix](https://gohugo.io/functions/strings/trimprefix/ "返回给定字符串，移除字符串开头的指定前缀。") |[strings.TrimRight](https://gohugo.io/functions/strings/trimright/ "返回给定字符串，移除末尾在指定字符集（cutset）中的字符。") |[strings.TrimSpace](https://gohugo.io/functions/strings/trimspace/ "返回给定字符串，移除由 Unicode 定义的前导和尾随空白字符。") |[strings.TrimSuffix](https://gohugo.io/functions/strings/trimsuffix/ "返回给定字符串，移除字符串末尾的后缀。") |[truncate](https://gohugo.io/functions/strings/truncate/ "返回给定字符串，将其截断至最大长度，同时避免切断单词或留下未闭合的 HTML 标签。")|
|**模板**|
|[templates.Current](https://gohugo.io/functions/templates/current/ "返回当前正在执行的模板的相关信息。") |[templates.Defer](https://gohugo.io/functions/templates/defer/ "推迟模板的执行，直到所有站点和输出格式都已渲染完成。") |[templates.Exists](https://gohugo.io/functions/templates/exists/ "报告指定路径下（相对于布局目录）是否存在模板文件。")|
|**时间**|
|[time](https://gohugo.io/functions/time/astime/ "将给定的日期/时间字符串表示形式转换为 time.Time 值。") |[duration](https://gohugo.io/functions/time/duration/ "根据给定的时间单位和数值返回一个 time.Duration 值。") |[dateFormat](https://gohugo.io/functions/time/format/ "返回给定日期/时间作为格式化且本地化的字符串。") |[time.In](https://gohugo.io/functions/time/in/ "返回给定日期/时间在指定 IANA 时区中的表示形式。") |[now](https://gohugo.io/functions/time/now/ "返回当前本地时间。")|
|[time.ParseDuration](https://gohugo.io/functions/time/parseduration/ "通过解析给定的持续时间字符串返回一个 time.Duration 值。")|
|**格式转换**|
|[transform.CanHighlight](https://gohugo.io/functions/transform/canhighlight/ "报告给定的代码语言是否受 Chroma 高亮器支持。") |[emojify](https://gohugo.io/functions/transform/emojify/ "将字符串通过 Emoji 表情符号处理器运行。") |[highlight](https://gohugo.io/functions/transform/highlight/ "使用语法高亮器渲染代码。") |[transform.HighlightCodeBlock](https://gohugo.io/functions/transform/highlightcodeblock/ "在代码块渲染钩子中高亮显示接收到的上下文代码。") |[htmlEscape](https://gohugo.io/functions/transform/htmlescape/ "返回给定的字符串，通过将特殊字符替换为 HTML 实体来进行转义。")|
|[transform.HTMLToMarkdown](https://gohugo.io/functions/transform/htmltomarkdown/ "将 HTML 转换为 Markdown。") |[htmlUnescape](https://gohugo.io/functions/transform/htmlunescape/ "返回给定字符串，将每个 HTML 实体替换为其对应的字符。") |[markdownify](https://gohugo.io/functions/transform/markdownify/ "将 Markdown 渲染为 HTML。") |[plainify](https://gohugo.io/functions/transform/plainify/ "返回一个移除了所有 HTML 标签的字符串。") |[transform.PortableText](https://gohugo.io/functions/transform/portabletext/ "将 Portable 文本转换为 Markdown 格式。")|
|[transform.PortableText](https://gohugo.io/functions/transform/portabletext/ "将 Portable 文本转换为 Markdown 格式。") |[transform.Remarshal](https://gohugo.io/functions/transform/remarshal/ "将一串序列化数据或映射，转换为指定格式的序列化数据字符串。") |[transform.ToMath](https://gohugo.io/functions/transform/tomath/ "渲染使用 LaTeX 标记语言编写的数学方程和表达式。") |[unmarshal](https://gohugo.io/functions/transform/unmarshal/ "解析序列化数据并返回映射或数组。支持 CSV、JSON、TOML、YAML 和 XML。") |[transform.XMLEscape](https://gohugo.io/functions/transform/xmlescape/ "返回给定字符串，移除不允许的字符后，将结果转义为其 XML 等价形式。")|
|**URL**|
|[absLangURL](https://gohugo.io/functions/urls/abslangurl/ "返回带有语言前缀的绝对 URL（如果存在）。") |[absURL](https://gohugo.io/functions/urls/absurl/ "返回一个绝对 URL。") |[anchorize](https://gohugo.io/functions/urls/anchorize/ "返回给定字符串，经过处理以适用于 HTML id 属性。") |[urls.JoinPath](https://gohugo.io/functions/urls/joinpath/ "将提供的元素连接成 URL 字符串，并清理结果中的任何 `./` 或 `../` 元素。如果参数列表为空，`JoinPath` 将返回空字符串。") |[urls.Parse](https://gohugo.io/functions/urls/parse/ "将 URL 解析为 URL 结构。")|
|[urls.PathEscape](https://gohugo.io/functions/urls/pathescape/ "返回给定字符串，将所有百分比编码序列替换为对应的未转义字符。") |[urls.PathUnescape](https://gohugo.io/functions/urls/pathunescape/ "返回给定字符串，对特殊字符和保留分隔符进行百分比编码，以便安全地用作 URL 路径中的一段。") |[ref](https://gohugo.io/functions/urls/ref/ "返回指定路径、语言和输出格式的页面的绝对 URL。") |[relLangURL](https://gohugo.io/functions/urls/rellangurl/ "返回一个带有语言前缀的相对 URL（如果存在的话）。") |[relref](https://gohugo.io/functions/urls/relref/ "返回指定路径、语言和输出格式的页面的相对 URL。")|
|[relURL](https://gohugo.io/functions/urls/relurl/ "返回一个相对 URL。") |[urlize](https://gohugo.io/functions/urls/urlize/ "返回给定字符串，已针对在 URL 中使用进行净化处理。")|

{{< /table >}}






## 方法

{{< table thead="false" >}}

|||
|:--|:--|:--|:--|:--|
|**Duration 时长**|
|[Abs](https://gohugo.io/methods/duration/abs/ "返回给定时间间隔值的绝对值")|[Hours](https://gohugo.io/methods/duration/hours/ "返回 time.Duration 值作为浮点数形式的小时数")|[Microseconds](https://gohugo.io/methods/duration/microseconds/ "返回 time.Duration 值作为整数微秒计数")|[Milliseconds](https://gohugo.io/methods/duration/milliseconds/ "返回 time.Duration 值作为整数毫秒计数")|[Minutes](https://gohugo.io/methods/duration/minutes/ "返回 time.Duration 值作为浮点数表示的分钟数")|
|[Nanoseconds](https://gohugo.io/methods/duration/nanoseconds/ "返回 time.Duration 值作为整数纳秒计数")|[Round](https://gohugo.io/methods/duration/round/ "将 DURATION1 四舍五入到最接近的 DURATION2 倍数后返回结果") |[Seconds](https://gohugo.io/methods/duration/seconds/ "返回 time.Duration 值作为秒数的浮点数表示") |[Truncate](https://gohugo.io/methods/duration/truncate/ "返回将 DURATION1 向零方向舍入至 DURATION2 倍数的结果")
|**Menu 菜单**|
|[ByName](https://gohugo.io/methods/menu/byname/ "返回按名称排序的给定菜单及其条目。") |[ByWeight](https://gohugo.io/methods/menu/byweight/ "返回按权重排序的给定菜单及其条目，其次按名称排序，最后按标识符排序。") |[Limit](https://gohugo.io/methods/menu/limit/ "返回给定的菜单，限制为前 N 个条目。") |[Reverse](https://gohugo.io/methods/menu/reverse/ "返回给定的菜单，将其条目的排序顺序反转。")|
|**Menu entry  菜单项**|
|[Children](https://gohugo.io/methods/menu-entry/children/ "返回给定菜单条目下的子菜单条目集合（如果存在）。") |[HasChildren](https://gohugo.io/methods/menu-entry/haschildren/ "报告给定菜单条目是否拥有子菜单条目。") |[Identifier](https://gohugo.io/methods/menu-entry/identifier/ "返回给定菜单项的 identifier 属性。") |[KeyName](https://gohugo.io/methods/menu-entry/keyname/ "返回给定菜单项的 identifier 属性，若不存在则回退至其 name 属性。") |[Menu](https://gohugo.io/methods/menu-entry/menu/ "返回包含给定菜单项的菜单标识符。")|
|[Name](https://gohugo.io/methods/menu-entry/name/ "返回给定菜单项的 name 属性。") |[Page](https://gohugo.io/methods/menu-entry/page/ "返回与给定菜单条目关联的 Page 对象。") |[PageRef](https://gohugo.io/methods/menu-entry/pageref/ "返回给定菜单项的 pageRef 属性。") |[Params](https://gohugo.io/methods/menu-entry/params/ "返回给定菜单项的 params 属性。") |[Parent](https://gohugo.io/methods/menu-entry/parent/ "返回给定菜单项的 parent 属性。")
|[Post](https://gohugo.io/methods/menu-entry/post/ "返回给定菜单项的 post 属性。") |[Pre](https://gohugo.io/methods/menu-entry/pre/ "返回给定菜单项的 pre 属性。") |[Title](https://gohugo.io/methods/menu-entry/title/ "返回给定菜单项的 title 属性。") |[URL](https://gohugo.io/methods/menu-entry/url/ "返回与给定菜单条目关联页面的相对永久链接，否则返回其 url 属性。") |[Weight](https://gohugo.io/methods/menu-entry/weight/ "返回给定菜单项的 weight 属性。")|
|**Page 页面**|
|[Aliases](https://gohugo.io/methods/page/aliases/ "返回在 front matter 中定义的 URL 别名") |[AllTranslations](https://gohugo.io/methods/page/alltranslations/ "返回给定页面的所有翻译版本，包括当前语言，并按语言权重排序") |[AlternativeOutputFormats](https://gohugo.io/methods/page/alternativeoutputformats/ "返回一个 OutputFormat 对象切片，其中排除了当前输出格式，每个对象代表为指定页面启用的输出格式之一") |[Ancestors](https://gohugo.io/methods/page/ancestors/ "返回一个 Page 对象集合，其中每个对象对应给定页面的一个祖先部分") |[BundleType](https://gohugo.io/methods/page/bundletype/ "返回给定页面的捆绑类型，如果该页面不是页面捆绑，则返回空字符串")|
|[CodeOwners](https://gohugo.io/methods/page/codeowners/ "返回给定页面的代码所有者切片，该信息源自项目根目录下的 CODEOWNERS 文件。") |[Content](https://gohugo.io/methods/page/content/ "返回指定页面的渲染内容。") |[ContentWithoutSummary](https://gohugo.io/methods/page/contentwithoutsummary/ "返回给定页面的渲染内容，不包括内容摘要。") |[CurrentSection](https://gohugo.io/methods/page/currentsection/ "返回给定页面所在章节的页面对象。") |[Data](https://gohugo.io/methods/page/data/ "为每种页面类型返回一个唯一的数据对象。")|
|[Date](https://gohugo.io/methods/page/date/ "返回给定页面的日期。") |[Description](https://gohugo.io/methods/page/description/ "返回给定页面的描述，该描述在 front matter 中定义。") |[Draft](https://gohugo.io/methods/page/draft/ "判断指定页面是否根据前置元数据定义为草稿。") |[Eq](https://gohugo.io/methods/page/eq/ "判断两个 Page 对象是否相等。") |[ExpiryDate](https://gohugo.io/methods/page/expirydate/ "返回给定页面的到期日期。")|
|[File](https://gohugo.io/methods/page/file/ "对于由文件支持的页面，返回指定页面的文件信息。") |[FirstSection](https://gohugo.io/methods/page/firstsection/ "返回给定页面所属的顶级分区的 Page 对象。") |[Fragments](https://gohugo.io/methods/page/fragments/ "返回给定页面中片段的数据结构。") |[FuzzyWordCount](https://gohugo.io/methods/page/fuzzywordcount/ "返回给定页面内容中的单词数量，向上取整至最接近的 100 的倍数。") |[GetPage](https://gohugo.io/methods/page/getpage/ "根据给定路径返回一个 Page 对象。")|
|[GetTerms](https://gohugo.io/methods/page/getterms/ "返回给定分类法中定义在指定页面上的术语页面集合，按照它们在 front matter 中出现的顺序排列。") |[GitInfo](https://gohugo.io/methods/page/gitinfo/ "返回与给定页面的最后一次提交相关的 Git 信息。") |[HasMenuCurrent](https://gohugo.io/methods/page/hasmenucurrent/ "报告给定的页面对象是否与给定菜单中给定菜单条目下的子菜单条目之一相关联的页面对象匹配。") |[HasShortcode](https://gohugo.io/methods/page/hasshortcode/ "报告指定页面是否调用了给定的短代码。") |[HeadingsFiltered](https://gohugo.io/methods/page/headingsfiltered/ "返回与给定页面相关的每个页面的标题切片。")|
|[InSection](https://gohugo.io/methods/page/insection/ "报告给定页面是否位于给定部分中。") |[IsAncestor](https://gohugo.io/methods/page/isancestor/ "报告 PAGE1 是否为 PAGE2 的祖先。") |[IsDescendant](https://gohugo.io/methods/page/isdescendant/ "报告 PAGE1 是否为 PAGE2 的后代页面。") |[IsHome](https://gohugo.io/methods/page/ishome/ "判断给定页面是否为首页。") |[IsMenuCurrent](https://gohugo.io/methods/page/ismenucurrent/ "报告给定的 Page 对象是否与给定菜单中给定菜单条目关联的 Page 对象匹配。")|
|[IsNode](https://gohugo.io/methods/page/isnode/ "判断给定页面是否为节点。") |[IsPage](https://gohugo.io/methods/page/ispage/ "判断给定页面是否为常规页面。") |[IsSection](https://gohugo.io/methods/page/issection/ "判断给定页面是否为章节页面。") |[IsTranslated](https://gohugo.io/methods/page/istranslated/ "报告指定页面是否已存在一个或多个翻译版本。") |[Keywords](https://gohugo.io/methods/page/keywords/ "返回一个切片，包含在 front matter 中定义的关键词。")|
|[Kind](https://gohugo.io/methods/page/kind/ "返回给定页面的类型。") |[Language](https://gohugo.io/methods/page/language/ "返回指定页面的语言对象。") |[Lastmod](https://gohugo.io/methods/page/lastmod/ "返回给定页面的最后修改日期。") |[Layout](https://gohugo.io/methods/page/layout/ "返回在 front matter 中定义的指定页面的布局。") |[Len](https://gohugo.io/methods/page/len/ "返回给定页面渲染内容的字节长度。")|
|[LinkTitle](https://gohugo.io/methods/page/linktitle/ "返回给定页面的链接标题。") |[Next](https://gohugo.io/methods/page/next/ "返回站点常规页面集合中相对于当前页面的下一页。") |[NextInSection](https://gohugo.io/methods/page/nextinsection/ "返回给定页面所在章节中的下一个常规页面。") |[OutputFormats](https://gohugo.io/methods/page/outputformats/ "返回一个 OutputFormat 对象切片，每个对象代表为给定页面启用的输出格式之一。") |[Page](https://gohugo.io/methods/page/page/ "返回指定页面的 Page 对象。")|
|[Pages](https://gohugo.io/methods/page/pages/ "返回当前章节内的常规页面集合，以及直接子章节的章节页面。") |[Paginate](https://gohugo.io/methods/page/paginate/ "对页面集合进行分页。") |[Paginator](https://gohugo.io/methods/page/paginator/ "对上下文接收到的常规页面集合进行分页处理。") |[Param](https://gohugo.io/methods/page/param/ "返回具有给定键的页面参数，如果存在则回退到站点参数。") |[Params](https://gohugo.io/methods/page/params/ "返回给定页面前置元数据中定义的自定义参数字典。")|
|[Parent](https://gohugo.io/methods/page/parent/ "返回给定页面的父级部分的页面对象。") |[Path](https://gohugo.io/methods/page/path/ "返回给定页面的逻辑路径。") |[Permalink](https://gohugo.io/methods/page/permalink/ "返回指定页面的永久链接。") |[Plain](https://gohugo.io/methods/page/plain/ "返回给定页面的渲染内容，移除所有 HTML 标签。") |[PlainWords](https://gohugo.io/methods/page/plainwords/ "调用 Plain 方法，将结果分割成单词切片，并返回该切片。")|
|[Prev](https://gohugo.io/methods/page/prev/ "返回站点常规页面集合中相对于当前页面的前一页。") |[PrevInSection](https://gohugo.io/methods/page/previnsection/ "返回给定页面所在章节中的上一个常规页面。") |[PublishDate](https://gohugo.io/methods/page/publishdate/ "返回给定页面的发布日期。") |[RawContent](https://gohugo.io/methods/page/rawcontent/ "返回指定页面的原始内容。") |[ReadingTime](https://gohugo.io/methods/page/readingtime/ "返回给定页面的预计阅读时间，单位为分钟。")|
|[Ref](https://gohugo.io/methods/page/ref/ "返回指定路径、语言和输出格式的页面的绝对 URL。") |[RegularPages](https://gohugo.io/methods/page/regularpages/ "返回当前章节内的常规页面集合。") |[RegularPagesRecursive](https://gohugo.io/methods/page/regularpagesrecursive/ "返回当前章节内的常规页面，以及所有子章节内的常规页面集合。") |[RelPermalink](https://gohugo.io/methods/page/relpermalink/ "返回给定页面的相对永久链接。") |[RelRef](https://gohugo.io/methods/page/relref/ "返回指定路径、语言和输出格式的页面的相对 URL。")|
|[Render](https://gohugo.io/methods/page/render/ "使用给定的页面作为上下文渲染指定的模板。") |[RenderShortcodes](https://gohugo.io/methods/page/rendershortcodes/ "渲染给定页面内容中的所有短代码，同时保留周围的标记。") |[RenderString](https://gohugo.io/methods/page/renderstring/ "将 markup 渲染为 HTML。") |[Resources](https://gohugo.io/methods/page/resources/ "返回页面资源的集合。") |[Rotate](https://gohugo.io/methods/page/rotate/ "返回指定维度上共享相同身份的所有页面的集合，包括当前页面，并按该维度的权重排序。")|
|[Section](https://gohugo.io/methods/page/section/ "返回给定页面所属的顶级章节名称。") |[Sections](https://gohugo.io/methods/page/sections/ "返回一个章节页面集合，其中包含给定页面的每个直接子章节对应的页面。") |[Site](https://gohugo.io/methods/page/site/ "返回 Site 对象。") |[Sitemap](https://gohugo.io/methods/page/sitemap/ "返回指定页面的站点地图设置，该设置依据前置内容定义，若未定义则回退至站点配置中定义的站点地图设置。") |[Sites](https://gohugo.io/methods/page/sites/ "返回所有站点对象的集合，每个语言对应一个，按语言权重排序。")|
|[Slug](https://gohugo.io/methods/page/slug/ "返回给定页面的 URL slug，如前置元数据中所定义。") |[Store](https://gohugo.io/methods/page/store/ "返回一个“便签本”，用于存储和操作数据，其作用域限定在当前页面。") |[Summary](https://gohugo.io/methods/page/summary/ "返回给定页面的摘要。") |[TableOfContents](https://gohugo.io/methods/page/tableofcontents/ "返回指定页面的目录。") |[Title](https://gohugo.io/methods/page/title/ "返回给定页面的标题。")|
|[TranslationKey](https://gohugo.io/methods/page/translationkey/ "返回给定页面的翻译键。") |[Translations](https://gohugo.io/methods/page/translations/ "返回给定页面的所有翻译版本，排除当前语言，并按语言权重排序。") |[Truncated](https://gohugo.io/methods/page/truncated/ "报告内容长度是否超过摘要长度。") |[Type](https://gohugo.io/methods/page/type/ "返回给定页面的内容类型。") |[Weight](https://gohugo.io/methods/page/weight/ "返回给定页面在 front matter 中定义的权重。")|
|[WordCount](https://gohugo.io/methods/page/wordcount/ "返回给定页面内容中的单词数量。")|
|**Pager 分页器**|
|[First](https://gohugo.io/methods/pager/first/ "返回分页器集合中的第一个分页器。") |[HasNext](https://gohugo.io/methods/pager/hasnext/ "报告当前分页器之后是否还有分页器。") |[HasPrev](https://gohugo.io/methods/pager/hasprev/ "报告当前分页器之前是否存在分页器。") |[Last](https://gohugo.io/methods/pager/last/ "返回分页器集合中的最后一个分页器。") |[Next](https://gohugo.io/methods/pager/next/ "返回分页器集合中的下一个分页器。")|
|[NumberOfElements](https://gohugo.io/methods/pager/numberofelements/ "返回当前分页器中的页面数量。") |[PageGroups](https://gohugo.io/methods/pager/pagegroups/ "返回当前分页器中的页面组。") |[PageNumber](https://gohugo.io/methods/pager/pagenumber/ "返回当前分页器在分页器集合中的编号。") |[Pagers](https://gohugo.io/methods/pager/pagers/ "返回分页器集合。") |[PagerSize](https://gohugo.io/methods/pager/pagersize/ "返回每个分页器的页面数量。")|
|[Pages](https://gohugo.io/methods/pager/pages/ "返回当前分页器中的页面。") |[Prev](https://gohugo.io/methods/pager/prev/ "返回分页器集合中的上一个分页器。") |[TotalNumberOfElements](https://gohugo.io/methods/pager/totalnumberofelements/ "返回分页器集合中的页面总数。") |[TotalPages](https://gohugo.io/methods/pager/totalpages/ "返回分页器集合中的分页器数量。") |[URL](https://gohugo.io/methods/pager/url/ "返回相对于网站根目录的当前分页器的 URL。")|
|**Pages 页面集合**|
|[ByDate](https://gohugo.io/methods/pages/bydate/ "返回按日期升序排列的给定页面集合。") |[ByExpiryDate](https://gohugo.io/methods/pages/byexpirydate/ "返回按到期日期升序排序的给定页面集合。") |[ByLanguage](https://gohugo.io/methods/pages/bylanguage/ "返回按语言升序排序的给定页面集合。") |[ByLastmod](https://gohugo.io/methods/pages/bylastmod/ "返回按最后修改日期升序排列的给定页面集合。") |[ByLength](https://gohugo.io/methods/pages/bylength/ "返回按内容长度升序排列的给定页面集合。")|
|[ByLinkTitle](https://gohugo.io/methods/pages/bylinktitle/ "返回按链接标题升序排列的给定页面集合，若未定义链接标题则回退至标题排序。") |[ByParam](https://gohugo.io/methods/pages/byparam/ "返回按给定参数升序排列的指定页面集合。") |[ByPublishDate](https://gohugo.io/methods/pages/bypublishdate/ "返回按发布日期升序排列的指定页面集合。") |[ByTitle](https://gohugo.io/methods/pages/bytitle/ "返回按标题升序排列的给定页面集合。") |[ByWeight](https://gohugo.io/methods/pages/byweight/ "返回按权重升序排列的给定页面集合。")|
|[GroupBy](https://gohugo.io/methods/pages/groupby/ "返回按指定字段升序排列的给定页面集合分组结果。") |[GroupByDate](https://gohugo.io/methods/pages/groupbydate/ "返回按日期降序分组的给定页面集合。") |[GroupByExpiryDate](https://gohugo.io/methods/pages/groupbyexpirydate/ "返回按过期日期降序分组的给定页面集合。") |[GroupByLastmod](https://gohugo.io/methods/pages/groupbylastmod/ "返回按最后修改日期降序分组的给定页面集合。") |[GroupByParam](https://gohugo.io/methods/pages/groupbyparam/ "返回按给定参数升序分组的页面集合。")|
|[GroupByParamDate](https://gohugo.io/methods/pages/groupbyparamdate/ "返回按给定日期参数降序分组后的页面集合。") |[GroupByPublishDate](https://gohugo.io/methods/pages/groupbypublishdate/ "返回按发布日期降序分组的给定页面集合。") |[Len](https://gohugo.io/methods/pages/len/ "返回给定页面集合中的页面数量。") |[Limit](https://gohugo.io/methods/pages/limit/ "从给定的页面集合中返回前 N 个页面。") |[Next](https://gohugo.io/methods/pages/next/ "返回页面集合中相对于给定页面的下一页。")|
|[Prev](https://gohugo.io/methods/pages/prev/ "返回页面集合中相对于给定页面的前一页。") |[Related](https://gohugo.io/methods/pages/related/ "返回与给定页面相关的页面集合。") |[Reverse](https://gohugo.io/methods/pages/reverse/ "返回给定的页面集合，按相反顺序排列。")|
|**Resource 资源**|
|[Colors](https://gohugo.io/methods/resource/colors/ "适用于图像，通过简单的直方图方法返回一个最主要颜色的切片。") |[Content](https://gohugo.io/methods/resource/content/ "返回给定资源的内容。") |[Crop](https://gohugo.io/methods/resource/crop/ "适用于图像，返回按给定尺寸裁剪而不调整大小的图像资源。") |[Data](https://gohugo.io/methods/resource/data/ "适用于通过 resources.GetRemote 函数返回的资源，返回 HTTP 响应中的信息。") |[Exif](https://gohugo.io/methods/resource/exif/ "适用于 JPEG、PNG、TIFF 和 WebP 格式的图像，返回包含图像元数据的 EXIF 对象。")|
|[Fill](https://gohugo.io/methods/resource/fill/ "适用于图像，返回一个按给定尺寸裁剪并调整大小的图像资源。") |[Filter](https://gohugo.io/methods/resource/filter/ "适用于图像，对给定的图像资源应用一个或多个图像滤镜。") |[Fit](https://gohugo.io/methods/resource/fit/ "适用于图像，返回一个按比例缩放以适应指定尺寸的图像资源。") |[Height](https://gohugo.io/methods/resource/height/ "适用于图像，返回给定资源的高度。") |[MediaType](https://gohugo.io/methods/resource/mediatype/ "返回给定资源的媒体类型对象。")|
|[Name](https://gohugo.io/methods/resource/name/ "返回给定资源在 front matter 中可选定义的名称，若无定义则回退至其文件路径。") |[Params](https://gohugo.io/methods/resource/params/ "返回一个资源参数映射，该映射根据前置元数据定义。") |[Permalink](https://gohugo.io/methods/resource/permalink/ "发布指定资源并返回其永久链接。") |[Process](https://gohugo.io/methods/resource/process/ "适用于图像，返回经过给定规格处理的图像资源。") |[Publish](https://gohugo.io/methods/resource/publish/ "发布指定的资源。")|
|[RelPermalink](https://gohugo.io/methods/resource/relpermalink/ "发布给定资源并返回其相对永久链接。") |[Resize](https://gohugo.io/methods/resource/resize/ "适用于图像，返回调整至指定宽度和/或高度的图像资源。") |[ResourceType](https://gohugo.io/methods/resource/resourcetype/ "返回给定资源媒体类型的主要类型。") |[Title](https://gohugo.io/methods/resource/title/ "返回给定资源在 front matter 中可选定义的标题，若未定义则根据资源类型回退到相对路径或哈希文件名。") |[Width](https://gohugo.io/methods/resource/width/ "适用于图像，返回给定资源的宽度。")|
|**Shortcode 短代码**|
|[Get](https://gohugo.io/methods/shortcode/get/ "返回给定参数的值。") |[Inner](https://gohugo.io/methods/shortcode/inner/ "返回短代码开始和结束标签之间的内容，适用于短代码调用包含闭合标签的情况。") |[InnerDeindent](https://gohugo.io/methods/shortcode/innerdeindent/ "返回短代码开闭标签之间的内容，并移除缩进，适用于短代码调用包含闭合标签的情况。") |[IsNamedParams](https://gohugo.io/methods/shortcode/isnamedparams/ "报告短代码调用是否使用了命名参数。") |[Name](https://gohugo.io/methods/shortcode/name/ "返回短代码文件名，不包括文件扩展名。")|
|[Ordinal](https://gohugo.io/methods/shortcode/ordinal/ "返回短代码相对于其父级的从零开始的序号。") |[Page](https://gohugo.io/methods/shortcode/page/ "返回调用短代码的页面对象。") |[Params](https://gohugo.io/methods/shortcode/params/ "返回短代码参数的集合。") |[Parent](https://gohugo.io/methods/shortcode/parent/ "返回嵌套短代码中的父级短代码上下文。") |[Position](https://gohugo.io/methods/shortcode/position/ "返回调用短代码的文件名和位置。")|
|[Ref](https://gohugo.io/methods/shortcode/ref/ "返回指定路径、语言和输出格式的页面的绝对 URL。") |[RelRef](https://gohugo.io/methods/shortcode/relref/ "返回指定路径、语言和输出格式的页面的相对 URL。") |[Site](https://gohugo.io/methods/shortcode/site/ "返回 Site 对象。") |[Store](https://gohugo.io/methods/shortcode/store/ "返回一个“便签板”，用于存储和操作数据，其作用域限定在当前短代码内。")|
|**Site 站点**|
|[AllPages](https://gohugo.io/methods/site/allpages/ "返回所有语言中的所有页面集合。") |[BaseURL](https://gohugo.io/methods/site/baseurl/ "返回站点配置中定义的基础 URL。") |[BuildDrafts](https://gohugo.io/methods/site/builddrafts/ "报告当前构建是否包含草稿页面。") |[Config](https://gohugo.io/methods/site/config/ "返回站点配置的一个子集。") |[Copyright](https://gohugo.io/methods/site/copyright/ "返回站点配置中定义的版权声明。")|
|[Data](https://gohugo.io/methods/site/data/ "返回由数据目录中的文件组成的数据结构。") |[Dimension](https://gohugo.io/methods/site/dimension/ "返回给定站点对应维度的维度对象。") |[GetPage](https://gohugo.io/methods/site/getpage/ "根据给定路径返回一个 Page 对象。") |[Home](https://gohugo.io/methods/site/home/ "返回给定站点的主页对象。") |[Language](https://gohugo.io/methods/site/language/ "返回给定站点的语言对象。")|
|[Lastmod](https://gohugo.io/methods/site/lastmod/ "返回网站内容的最后修改日期。") |[MainSections](https://gohugo.io/methods/site/mainsections/ "返回站点配置中定义的主要版块名称切片，若未定义则回退至包含最多页面的顶级版块。") |[Menus](https://gohugo.io/methods/site/menus/ "返回给定站点的菜单对象集合。") |[Pages](https://gohugo.io/methods/site/pages/ "返回所有页面的集合。") |[Param](https://gohugo.io/methods/site/param/ "返回具有给定键的站点参数。")|
|[RegularPages](https://gohugo.io/methods/site/regularpages/ "返回所有常规页面的集合。") |[Role](https://gohugo.io/methods/site/role/ "返回给定站点的角色对象。") |[Sections](https://gohugo.io/methods/site/sections/ "返回顶级章节页面的集合。") |[Sites](https://gohugo.io/methods/site/sites/ "返回所有站点对象的集合，每个语言对应一个站点对象，按默认内容语言排序，然后按语言权重排序。") |[Store](https://gohugo.io/methods/site/store/ "返回一个“便签板”，用于存储和操作数据，作用范围限定在当前站点。")|
|[Taxonomies](https://gohugo.io/methods/site/taxonomies/ "返回一个数据结构，其中包含站点的分类法对象、每个分类法对象内的术语，以及这些术语所分配的页面。") |[Title](https://gohugo.io/methods/site/title/ "返回站点配置中定义的标题。") |[Version](https://gohugo.io/methods/site/version/ "返回给定站点的版本对象。")|
|**Taxonomy 分类法**|
|[Alphabetical](https://gohugo.io/methods/taxonomy/alphabetical/ "返回按术语字母顺序排序的有序分类法。") |[ByCount](https://gohugo.io/methods/taxonomy/bycount/ "返回一个按每个术语关联页面数量排序的有序分类法。") |[Count](https://gohugo.io/methods/taxonomy/count/ "返回指定术语已被分配的加权页面数量。") |[Get](https://gohugo.io/methods/taxonomy/get/ "返回一个加权页面切片，其中包含已分配给定术语的页面。") |[Page](https://gohugo.io/methods/taxonomy/page/ "返回分类页面，如果分类没有术语则返回 nil。")|
|**Time 时间**|
|[Add](https://gohugo.io/methods/time/add/ "返回给定时间加上给定时长后的结果。") |[AddDate](https://gohugo.io/methods/time/adddate/ "返回将给定年、月、日数加到给定时间后所对应的时间值。") |[After](https://gohugo.io/methods/time/after/ "判断 TIME1 是否晚于 TIME2。") |[Before](https://gohugo.io/methods/time/before/ "判断 TIME1 是否早于 TIME2。") |[Day](https://gohugo.io/methods/time/day/ "返回给定时间值中的月份日期。")|
|[Equal](https://gohugo.io/methods/time/equal/ "判断 TIME1 是否等于 TIME2。") |[Format](https://gohugo.io/methods/time/format/ "返回根据布局字符串格式化的 time.Time 值的文本表示。") |[Hour](https://gohugo.io/methods/time/hour/ "返回给定时间在一天中的小时数。时间值范围在[0, 23]之间。") |[IsDST](https://gohugo.io/methods/time/isdst/ "判断给定的 time.Time 值是否处于夏令时。") |[IsZero](https://gohugo.io/methods/time/iszero/ "判断给定的 time.Time 值是否表示零时间点，即 UTC 时间公元 1 年 1 月 1 日 00:00:00。")|
|[Local](https://gohugo.io/methods/time/local/ "返回给定的 time.Time 值，并将其时区设置为本地时间。") |[Minute](https://gohugo.io/methods/time/minute/ "返回给定时间在小时内的分钟偏移量。时间值，范围在[0, 59]之间。") |[Month](https://gohugo.io/methods/time/month/ "返回给定时间值所属年份的月份。") |[Nanosecond](https://gohugo.io/methods/time/nanosecond/ "返回给定时间值在秒内的纳秒偏移量，范围在 [0, 999999999] 之间。") |[Round](https://gohugo.io/methods/time/round/ "将 TIME 四舍五入至自 UTC 时间 0001 年 1 月 1 日 00:00:00 起最接近的 DURATION 倍数后返回结果。")|
|[Second](https://gohugo.io/methods/time/second/ "返回给定时间在分钟内的秒偏移量，时间值范围在[0, 59]之间。") |[Sub](https://gohugo.io/methods/time/sub/ "返回由 TIME1 减去 TIME2 计算得出的时长。") |[Truncate](https://gohugo.io/methods/time/truncate/ "返回将时间向下舍入至自 UTC 时间 0001 年 1 月 1 日 00:00:00 起 DURATION 的整数倍的结果。") |[Unix](https://gohugo.io/methods/time/unix/ "返回给定的 time.Time 值，表示为自 1970 年 1 月 1 日 UTC 起经过的秒数。") |[UnixMicro](https://gohugo.io/methods/time/unixmicro/ "返回给定时间值，以自 1970 年 1 月 1 日 UTC 起经过的微秒数表示。")|
|[UnixMilli](https://gohugo.io/methods/time/unixmilli/ "返回给定的 time.Time 值，表示为自 1970 年 1 月 1 日 UTC 起经过的毫秒数。") |[UnixNano](https://gohugo.io/methods/time/unixnano/ "返回给定时间点自 1970 年 1 月 1 日 UTC 起经过的纳秒数。") |[UTC](https://gohugo.io/methods/time/utc/ "返回给定的 time.Time 值，并将其时区设置为 UTC。") |[Weekday](https://gohugo.io/methods/time/weekday/ "返回给定时间值对应的星期几。") |[Year](https://gohugo.io/methods/time/year/ "返回给定 time.Time 值的年份。")|
|[YearDay](https://gohugo.io/methods/time/yearday/ "返回给定时间值在一年中的天数，非闰年范围为[1, 365]，闰年范围为[1, 366]。")|

{{< /table >}}



## 参考链接

- [Hugo 教程](https://jimmysong.io/zh/book/hugo-handbook/template-system/overview/)
- [Quick reference](https://gohugo.io/quick-reference/)
