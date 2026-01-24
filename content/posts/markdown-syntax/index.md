---
title: "Markdown 样式测试"
date: "2021-05-01"
toc: true
---


## 标题

```markdown
## 这是二级标题
### 这是三级标题
#### 这是四级标题
##### 这是五级标题
###### 这是六级标题
```

## 这是二级标题
### 这是三级标题
#### 这是四级标题
##### 这是五级标题
###### 这是六级标题





## 字体样式

```markdown
*倾斜的文字*
**加粗的文字**
***斜体加粗的文字***
~~加删除线的文字~~
```

*倾斜的文字*

**加粗的文字**

***斜体加粗的文字***

~~加删除线的文字~~





## 引用


```markdown
> 这是默认样式
```

> 这是默认样式

```markdown
> 这是默认样式
> 
> 这是换行
```

> 这是默认样式
> 
> 这是换行

{{< bar block="短代码" >}}

```go-template
{{</* notice type="info" */>}}
这是 info 样式
{{</* /notice */>}}
```

{{< notice type="info" >}}
这是 info 样式
{{< /notice >}}

{{< notice type="warn" >}}
这是 warn 样式
{{< /notice >}}

{{< notice type="alarm" >}}
这是 alarm 样式
{{< /notice >}}





## 分割线

三个及以上的 `-` 或者 `*` 都可以：

```markdown
-----
这是分割线
*****
```

-----
这是分割线
*****





## 图片

```markdown
![ ](图片url)
```

{{< bar block="短代码" >}}

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

{{< /table >}}





## 超链接


```markdown
[超链接名称](超链接url)
```

[超链接名称](超链接url)





## 列表

```markdown
- 无序列表
- 无序列表
- 无序列表
```

- 无序列表
- 无序列表
- 无序列表

```markdown
1. 有序列表
2. 有序列表
3. 有序列表
```

1. 有序列表
2. 有序列表
3. 有序列表

```markdown
- 多级列表
  - 二级无序列表内容
  - 二级无序列表内容
  - 二级无序列表内容
```

- 多级列表
  - 二级无序列表内容
  - 二级无序列表内容
  - 二级无序列表内容





## 表格

```markdown
|左对齐    |居中      |右对齐    |
|:---------|:--------:|---------:|
|内容      |内容      |内容      |
|内容      |内容      |内容      |
```

|左对齐    |居中      |右对齐    |
|:---------|:--------:|---------:|
|内容      |内容      |内容      |
|内容      |内容      |内容      |

{{< bar block="短代码" >}}

```go-template
{{</* table thead="true" wrap="false" min-width="100,200,300"*/>}}
|选项|说明|
|:---|:---|
|参数|123 |
{{</* /table */>}}
```

{{< table thead="true" wrap="true" min-width="120">}}

|参数        |说明                                                                          |
|:-----------|:-----------------------------------------------------------------------------|
|`thead`     |是否显示表头，默认 `true`                                                     |
|`warp`      |是否换行，默认 `false`                                                        |
|`min-width` |单元格最小宽度                                                                |
|            |`min-width="100,200,300"` 表示第一列最小宽 100px , 第二列 200px ，第三列 300px|
|            |`min-width="100,,300"` 表示第一列最小宽 100px ，第三列 300px                  |

{{< /table >}}





## 代码块顶部样式

代码文件样式：

{{< highlight go-template >}}

{{</* bar title="hello.txt" */>}}
```text
hello world 
```

{{< /highlight >}}

{{< bar title="hello.txt" >}}
```text
hello world 
```

终端样式：

{{< highlight go-template >}}

{{</* bar block="终端" title="打印 hello world" type="terminal" */>}}
```bash-session
$ echo hello world
hello world 
```

{{< /highlight >}}

{{<bar block="终端" title="打印 hello world" type="terminal" >}}
```bash-session
$ echo hello world
hello world 
```

{{< table min-width="80">}}

|参数    |说明                      |
|:-------|:-------------------------|
|`block` |方块内的文字，默认 `文件` |
|`title` |标题                      |
|`type`  |目前只有 `terminal`       |

{{< /table >}}





## 任务列表

```markdown
- [x] 我是已完成的任务一
- [ ] 我是未完成的任务二
- [ ] 我是未完成的任务三
```

- [x] 我是已完成的任务一
- [ ] 我是未完成的任务二
- [ ] 我是未完成的任务三





## 定义列表

```markdown
选项一
: 我是选项一的内容

选项二
: 我是选项二的内容
```

选项一
: 我是选项一的内容

选项二
: 我是选项二的内容





## 空格

普通空格 `&nbsp;`：|&nbsp;|

半角空格 `&ensp;`：|&ensp;|

全角空格 `&emsp;`：|&emsp;|
