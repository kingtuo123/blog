---
title: "Markdown 语法&测试"
date: "2021-05-01"
toc: true
---




## 标题

<div class="sp-container">
<div class="sp-item">

```markdown
## 这是二级标题
### 这是三级标题
#### 这是四级标题
##### 这是五级标题
###### 这是六级标题
```

</div>
<div class="sp-item" style="flex:1;">

## 这是二级标题
### 这是三级标题
#### 这是四级标题
##### 这是五级标题
###### 这是六级标题

</div>
</div>












## 字体样式

<div class="sp-container">
<div class="sp-item">

```markdown
*倾斜的文字*
**加粗的文字**
***斜体加粗的文字***
~~加删除线的文字~~
```

</div>
<div class="sp-item" style="flex:1;">

*倾斜的文字*

**加粗的文字**

***斜体加粗的文字***

~~加删除线的文字~~

</div>
</div>












## 引用

<div class="sp-container">
<div class="sp-item">

```markdown
> 这是默认样式

> 引用内换行则使用单个 >
>
> 引用内换行则使用单个 >
```

</div>
<div class="sp-item" style="flex:1;">

> 这是默认样式

> 引用内换行则使用单个 `>`
>
> 引用内换行则使用单个 `>`

</div>
</div>









<div class="sp-container">
<div class="sp-item">

{{< highlight html >}}

<blockquote class="blue">

这是蓝色样式

</blockquote>

<blockquote class="yellow">
<blockquote class="red">

{{< /highlight >}}

</div>
<div class="sp-item" style="flex:1;">

<blockquote class="blue">

这是蓝色样式

</blockquote>

<blockquote class="yellow">

这是黄色样式

</blockquote>

<blockquote class="red">

这是红色样式

</blockquote>

</div>
</div>
















## 分割线


<div class="sp-container">
<div class="sp-item">

```markdown
---
----
***
*****
```

三个或者三个以上的 `-` 或者 `*` 都可以

</div>
<div class="sp-item" style="flex:1;">

测试三条分割线

----

----

----

</div>
</div>



## 图片

```markdown
![ ](图片url)
```

指定图片大小及位置：

```html
<div align="center">
    <img src="1.png" style="max-height:180px"></img>
</div>
```

超链接图片：

```html
<div align="center">
    <a href="链接地址" target="_blank">
        <img src="1.jpg" style="max-height:980px"></img>
    </a>
</div>
```


## 超链接


```markdown
[超链接名称](超链接url)
```

[超链接名称](超链接url)











## 列表

<div class="sp-container">
<div class="sp-item">

```markdown
- 无序列表
- 无序列表
- 无序列表
```

</div>
<div class="sp-item" style="flex:1;">

- 无序列表
- 无序列表
- 无序列表

</div>
</div>







<div class="sp-container">
<div class="sp-item">

```markdown
1. 有序列表
2. 有序列表
3. 有序列表
```

</div>
<div class="sp-item" style="flex:1;">

1. 有序列表
2. 有序列表
3. 有序列表

</div>
</div>





<div class="sp-container">
<div class="sp-item">

```markdown
- 多级列表
  - 二级无序列表内容
  - 二级无序列表内容
  - 二级无序列表内容
```

</div>
<div class="sp-item" style="flex:1;">

- 多级列表
  - 二级无序列表内容
  - 二级无序列表内容
  - 二级无序列表内容

</div>
</div>










## 表格

<div class="sp-container">
<div class="sp-item">

```markdown
|左对齐    |居中      |右对齐    |
|:---------|:--------:|---------:|
|内容      |内容      |内容      |
|内容      |内容      |内容      |
```

</div>
<div class="sp-item" style="flex:1;">
<div class="table-container">

|左对齐    |居中      |右对齐    |
|:---------|:--------:|---------:|
|内容      |内容      |内容      |
|内容      |内容      |内容      |

</div>
</div>
</div>


<div class="sp-container">
<div class="sp-item">

{{< highlight html >}}

<div class="table-container no-thead">

|无表头    |          |          |
|:---------|:--------:|---------:|
|内容      |内容      |内容      |
|内容      |内容      |内容      |

</div>

{{< /highlight >}}


</div>
<div class="sp-item" style="flex:1;">
<div class="table-container no-thead">

|左对齐    |居中      |右对齐    |
|:---------|:--------:|---------:|
|内容      |内容      |内容      |
|内容      |内容      |内容      |

</div>
</div>
</div>












## 左右分隔代码块

<div class="sp-container">
<div class="sp-item">

Markdown 文件：

{{< highlight html >}}

<div class="sp-container">
<div class="sp-item">

这是代码一

```bash
echo 123
```

</div>
<div class="sp-item" style="flex:1;">

这是代码二

```bash
echo 123
echo 123
echo 123
```

</div>
</div>

{{< /highlight >}}

</div>
<div class="sp-item" style="flex:1;">

CSS 文件：

```css
.sp-container {
    display: flex;
    flex-wrap: wrap; /* 空间不足时自动换行 */
    gap: 10px;
}

.sp-item{
    flex: 1;
}

@media (max-width: 900px) {
    .sp-container {
        flex-direction: column;
        gap: 0px;
    }
    .sp-item{
        width: 100%;
    }
}
```


</div>
</div>



> 左右的宽度比例可以通过设置 style，如 `style="flex:1.5;"` 为 `1:1.5`


<blockquote class="yellow">

代码行数不等可以用带一个空格的行使两边对齐，暂时不知道怎么用 CSS 对齐？

</blockquote>


<blockquote class="red">

`<div>` 前面不能有空格，必须顶到行首！

</blockquote>



## 任务列表

<div class="sp-container">
<div class="sp-item">

```markdown
- [x] 我是已完成的任务一
- [ ] 我是未完成的任务二
- [ ] 我是未完成的任务三
```

</div>
<div class="sp-item" style="flex:1;">

- [x] 我是已完成的任务一
- [ ] 我是未完成的任务二
- [ ] 我是未完成的任务三

</div>
</div>









## 定义列表

<div class="sp-container">
<div class="sp-item">

```markdown
我是选项一
: 我是选项一的巴拉巴拉巴拉巴拉...

我是选项二
: 我是选项二的巴拉巴拉巴拉巴拉...
```

</div>
<div class="sp-item" style="flex:1;">

选项一
: 我是选项一的巴拉巴拉巴拉巴拉...

选项二
: 我是选项二的巴拉巴拉巴拉巴拉...


</div>
</div>







## 空格

普通空格 `&nbsp;`：|&nbsp;|

半角空格 `&ensp;`：|&ensp;|

全角空格 `&emsp;`：|&emsp;|
