---
title: "Shortcodes 样式测试"
date: "2021-05-01"
toc: true
---





## notice

```go-template
{{</* notice class="blue" */>}}
这是 blue 样式
{{</* /notice */>}}
```

{{< notice class="blue" >}}
这是 blue 样式
{{< /notice >}}

{{< notice class="green" >}}
这是 green 样式
{{< /notice >}}

{{< notice class="yellow" >}}
这是 yellow 样式
{{< /notice >}}

{{< notice class="red" >}}
这是 red 样式
{{< /notice >}}





## img

```go-template
{{</* img src="example.png" align="left" */>}}
```

{{< table min-width="150">}}

|参数           |说明                                               |
|:--------------|:--------------------------------------------------|
|`align`        |对齐 `left` `center` `right`                       |
|`zoom`         |缩放，默认 `0.5`，svg 图片默认 `1`                 |
|`auto-dim`     |深色模式图片是否变暗，默认 `true`，对 svg 图片无效 |
|`font-family`  |字体，只对 svg 图片有效，默认 `LXGW WenKai Mono`   |
|`font-size`    |字体大小，只对 svg 图片有效，默认 `16px`           |
|`scroll-x`     |图片溢出后左右滚动，默认 `false`，只对 svg 图片有效|
|`margin`       |图片边距，格式：`margin="10px 0 15px 0"`           |

{{< /table >}}







## table

```go-template
{{</* table thead=true wrap=false min-width="100,200,300"*/>}}
|选项|说明|
|:---|:---|
|参数|123 |
{{</* /table */>}}
```

{{< table thead=true wrap=true min-width="150">}}

|参数        |说明                                                                          |
|:-----------|:-----------------------------------------------------------------------------|
|`thead`     |是否显示表头，默认 `true`                                                     |
|`warp`      |长文本是否换行，默认 `false`                                                  |
|`mono`      |使用等宽字体，默认 `false`                                                    |
|`min-width` |单元格最小宽度                                                                |
|            |`min-width="100,200,300"` 表示第一列最小宽 100px , 第二列 200px ，第三列 300px|
|            |`min-width="100,,300"` 表示第一列最小宽 100px ，第三列 300px                  |

{{< /table >}}













## text

```html
{{</* text fg="green" */>}} hello world {{</* /text */>}}
```

{{< table min-width="150">}}
|参数    |说明                                            |
|:-------|:-----------------------------------------------|
|`fg`    |文本前景色。                                    |
|`bold`  |粗体，默认 `false`。                            |
{{< /table >}}

```text{ nonebg=true }
{{<text fg="foreground ">}}foreground{{</text>}}
{{<text fg="red">}}red{{</text>}}
{{<text fg="orange">}}orange{{</text>}}
{{<text fg="yellow">}}yellow{{</text>}}
{{<text fg="green">}}green{{</text>}}
{{<text fg="blue">}}blue{{</text>}}
{{<text fg="aqua">}}aqua{{</text>}}
{{<text fg="purple">}}purple{{</text>}}
{{<text fg="background-dim">}}background-dim{{</text>}}
{{<text fg="background-0">}}background-0{{</text>}}
{{<text fg="background-1">}}background-1{{</text>}}
{{<text fg="background-2">}}background-2{{</text>}}
{{<text fg="background-3">}}background-3{{</text>}}
{{<text fg="background-4">}}background-4{{</text>}}
{{<text fg="background-5">}}background-5{{</text>}}
{{<text fg="background-red">}}background-red{{</text>}}
{{<text fg="background-visual">}}background-visual{{</text>}}
{{<text fg="background-yellow">}}background-yellow{{</text>}}
{{<text fg="background-green">}}background-green{{</text>}}
{{<text fg="background-blue">}}background-blue{{</text>}}
{{<text fg="gray-0">}}gray-0{{</text>}}
{{<text fg="gray-1">}}gray-1{{</text>}}
{{<text fg="gray-2">}}gray-2{{</text>}}
```






## button-file

{{< highlight html >}}
```text{ nonebg=true }
./
├── configure.ac
├── {{</* button-file target="targetDiV" src="files/test1.c"  title=" test1.c"  */>}}
└── 󰉖 src/
    ├── {{</* button-file target="targetDiV" src="files/test2.c"  title=" test2.c" fg="purple" */>}}
    └── 󰉖 subdir/
        └── {{</* button-file target="targetDiV" src="files/subdir/test2.c"  title=" test2.c" fg="purple" */>}}
```

<div id="targetDiV"></div>
{{< /highlight >}}




```text{ nonebg=true }
./
├── configure.ac
├── {{< button-file target="targetDiV" src="files/test1.c"  title=" test1.c"  >}}
└── 󰉖 src/
    ├── {{< button-file target="targetDiV" src="files/test2.c"  title=" test2.c" fg="purple" >}}
    └── 󰉖 subdir/
        └── {{< button-file target="targetDiV" src="files/subdir/test2.c"  title=" test2.c" fg="purple" >}}
```

<div id="targetDiV"></div>



{{< table min-width="150">}}
|参数    |说明                                                             |
|:-------|:----------------------------------------------------------------|
|`target`|目标元素的 id，如果 id 为空则直接在当前位置插入。                |
|`src`   |源文件位置。                                                     |
|`title` |按钮的标题。                                                     |
|`fg`    |按钮标题的前景色 foreground、 red、orange 等 core.css 中的颜色。 |
{{< /table >}}









## insert-file

```go-template
{{</* insert-file src="file/test.md" */>}}
```

{{< table min-width="150">}}
|参数    |说明                                                             |
|:-------|:----------------------------------------------------------------|
|`src`   |文件位置                                                         |
{{< /table >}}









## 代码块样式

> 该功能不是 Shortcodes，是 [Code block render hooks](https://gohugo.io/render-hooks/code-blocks/)。

文件标题栏：

{{< highlight text >}}
```text{ bar="hello.txt" }
hello world
```
{{< /highlight >}}

```text{ bar="hello.txt" }
hello world
```

自定义标题栏：

{{< highlight text >}}
```bash-session{ bar="终端:打印 hello world" }
$ echo hello world
```
{{< /highlight >}}


```bash-session{ bar="终端:打印 hello world" }
$ echo hello world
```



{{< table min-width="150">}}

|属性     |说明                                                       |
|:--------|:----------------------------------------------------------|
|`bar`    |格式 `类型:标题`，若不指定 `类型`，默认为 `文件`。         |
|`copy`   |显示 `复制` 按钮，默认 `false`。                           |
|`height` |最大高度（占视窗高度的百分比），范围 `1-100`，默认为 `空`。|
|`nonebg` |背景透明，默认 `false`。                                   |
|`hover`  |鼠标 hover 时高亮当前行，默认 `false`。                    |

{{< /table >}}

