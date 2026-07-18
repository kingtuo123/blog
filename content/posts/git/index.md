---
title: "Git"
date: "2026-07-04"
toc: true
draft: true
---



## Git 对象模型


**blob**

用于存储文件数据——它通常就是一个文件。

-----

**tree**

类似于一个目录，它会引用其它的 tree 或 blob。


-----

**commit**

一个 “commit” 指向单个 tree，将其标记为项目在某个特定时间点的样子。
它包含了关于该时间点的元信息，例如时间戳、自上次提交以来的变更作者、指向上一个提交的指针等。

-----

**tag**

是一种将特定提交标记为具有某种特殊意义的方式。它通常用于将某些提交标记为特定的发布版本或类似的用途。



## Git 目录结构


### objects - 对象数据库

```bash-session
$ git init test
$ cd test
$ tree .git/objects
.git/objects
├── info
└── pack
```

添加一个文件 `1.txt`：

```bash-session
$ echo 1 > 1.txt
$ git add 1.txt
$ tree .git/objects
.git/objects
├── {{< text fg="red" >}}d0{{< /text >}}
│   └── {{< text fg="red" >}}0491fd7e5bb6fa28c517a0bb32b8b506539d4d{{< /text >}}
├── info
└── pack
$ git cat-file -t d004 && git cat-file -p d004
blob
1
```

{{< img src="blob.svg" >}}

创建一个提交 `first commit`：

```bash-session
$ git commit -m "first commit"
$ tree .git/objects
.git/objects
├── {{< text fg="yellow" >}}38{{< /text >}}
│   └── {{< text fg="yellow" >}}fd29697b220f7e4ca15b044c3222eefe5afdc1{{< /text >}}
├── {{< text fg="green" >}}43{{< /text >}}
│   └── {{< text fg="green" >}}911c6c5a8aacd661e18417bc1602fe97463e2a{{< /text >}}
├── {{< text fg="red" >}}d0{{< /text >}}
│   └── {{< text fg="red" >}}0491fd7e5bb6fa28c517a0bb32b8b506539d4d{{< /text >}}
├── info
└── pack
$ git cat-file -t 38fd && git cat-file -p 38fd
tree
100644 blob {{< text fg="red" >}}d00491fd7e5bb6fa28c517a0bb32b8b506539d4d{{< /text >}}	1.txt
$ git cat-file -t {{< text >}}4391{{< /text >}} && git cat-file -p {{< text >}}4391{{< /text >}}
commit
tree {{< text fg="yellow" >}}38fd29697b220f7e4ca15b044c3222eefe5afdc1{{< /text >}}
author kingtuo123 <kingtuo123@foxmail.com> 1783325865 +0800
committer kingtuo123 <kingtuo123@foxmail.com> 1783325865 +0800

first commit
```

{{< img src="first-commit.svg" >}}

添加一个新文件 `2.txt`，并创建一个新提交 `second commit`：

```bash-session
$ echo 2 > 2.txt
$ git add 2.txt
$ git commit -m "second commit"
$ tree .git/objects
.git/objects
├── {{< text fg="red" >}}0c{{< /text >}}
│   └── {{< text fg="red" >}}fbf08886fca9a91cb753ec8734c84fcbe52c9f{{< /text >}}
├── 38
│   └── fd29697b220f7e4ca15b044c3222eefe5afdc1
├── {{< text fg="yellow" >}}43{{< /text >}}
│   ├── {{< text fg="yellow" >}}4943a8265129a744745e5d12fa2625a784b283{{< /text >}}
│   └── 911c6c5a8aacd661e18417bc1602fe97463e2a
├── {{< text fg="green" >}}4e{{< /text >}}
│   └── {{< text fg="green" >}}e2c410544a33f0bf171f7174c13283c7a80426{{< /text >}}
├── {{< text fg="red" >}}d0{{< /text >}}
│   └── {{< text fg="red" >}}0491fd7e5bb6fa28c517a0bb32b8b506539d4d{{< /text >}}
├── info
└── pack
$ git cat-file -t 0cfb && git cat-file -p 0cfb 
blob
2
$ git cat-file -t {{< text >}}4349{{< /text >}} && git cat-file -p {{< text >}}4349{{< /text >}}
tree
100644 blob {{< text fg="red" >}}d00491fd7e5bb6fa28c517a0bb32b8b506539d4d{{< /text >}}	1.txt
100644 blob {{< text fg="red" >}}0cfbf08886fca9a91cb753ec8734c84fcbe52c9f{{< /text >}}	2.txt
$ git cat-file -t 4ee2 && git cat-file -p 4ee2
commit
tree {{< text fg="yellow" >}}434943a8265129a744745e5d12fa2625a784b283{{< /text >}}
parent 43911c6c5a8aacd661e18417bc1602fe97463e2a
author kingtuo123 <kingtuo123@foxmail.com> 1783328632 +0800
committer kingtuo123 <kingtuo123@foxmail.com> 1783328632 +0800

second commit
```

{{< img src="second-commit.svg" >}}


### blob 对象复用

当两个文件内容完全一样时，其 blob 对象是复用的（哈希值相同）：

```bash-session
$ git init test && cd test && echo 123 | tee 1.txt 2.txt
$ git add -A
$ git ls-files -s
100644 190a18037c64c43e6b11489df4bf0b9eb6d2c9bf 0	1.txt
100644 190a18037c64c43e6b11489df4bf0b9eb6d2c9bf 0	2.txt
```


### index 暂存区

```bash-session
$ git init test && cd test && echo 123 | tee 1.txt 2.txt

{{< text fg="yellow" >}}[此时 .git/index 还不存在]{{< /text >}}
$ rm .git/index
rm: cannot remove '.git/index': No such file or directory
$ git ls-files -s
无输出
$ git status
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	{{< text fg="red" >}}1.txt{{< /text >}}
	{{< text fg="red" >}}2.txt{{< /text >}}

{{< text fg="yellow" >}}[添加文件到暂存区，也就是更新 .git/index]{{< /text >}}
$ git add -A
$ git ls-files -s
100644 190a18037c64c43e6b11489df4bf0b9eb6d2c9bf 0	1.txt
100644 190a18037c64c43e6b11489df4bf0b9eb6d2c9bf 0	2.txt
$ git status
Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
	{{< text fg="green" >}}new file:   1.txt{{< /text >}}
	{{< text fg="green" >}}new file:   2.txt{{< /text >}}

{{< text fg="yellow" >}}[删除 .git/index 后，会恢复到最初的状态]{{< /text >}}
$ rm .git/index
$ git ls-files -s
无输出
$ git status
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	{{< text fg="red" >}}1.txt{{< /text >}}
	{{< text fg="red" >}}2.txt{{< /text >}}

{{< text fg="yellow" >}}[blob 对象仍存在，也就是说暂存区不包含文件内容，暂存区包含的是已跟踪文件的列表（记录了文件的哈希值、文件模式等信息）]{{< /text >}}
$ git ls-files -s
无输出
$ tree .git/objects -A
.git/objects
├── 19
│   └── 0a18037c64c43e6b11489df4bf0b9eb6d2c9bf
├── info
└── pack
$ git cat-file -t 190a && git cat-file -p 190a
blob
123
```

小结：

1. index 就是下一次 git commit 将要创建的树（Tree）的 “预演”。
2. 以 index 作为参照，可以查看工作区有哪些已修改但未暂存的变化。
3. 以 HEAD（当前分支最新提交）作为参照，可以查看 index 中有哪些已暂存但未提交的变化。



### HEAD 指针


```bash-session
$ git init test && cd test && echo 1 > 1.txt && git add -A && git commit -m "1st commit"

{{< text fg="yellow" >}}[HEAD 指向当前分支的最新一次 commit]{{< /text >}}
$ grep --color '' .git/HEAD .git/refs/heads/*
{{< text fg="purple" >}}.git/HEAD{{< /text >}}:ref: refs/heads/master
{{< text fg="purple" >}}.git/refs/heads/master{{< /text >}}:f287aea16d69f4758c4f0c71333b3b183280ae6d
$ git cat-file -t f287 && git cat-file -p f287
commit
tree 38fd29697b220f7e4ca15b044c3222eefe5afdc1
author kingtuo123 <kingtuo123@foxmail.com> 1783417990 +0800
committer kingtuo123 <kingtuo123@foxmail.com> 1783417990 +0800

1st commit

{{< text fg="yellow" >}}[创建并切换新分支后，HEAD 指向 new-branch，但 commit 的哈希值不变因为没有新的提交]{{< /text >}}
$ git switch -c "new-branch"
Switched to a new branch 'new-branch'
$ grep --color '' .git/HEAD .git/refs/heads/*
{{< text fg="purple" >}}.git/HEAD{{< /text >}}:ref: refs/heads/new-branch
{{< text fg="purple" >}}.git/refs/heads/master{{< /text >}}:f287aea16d69f4758c4f0c71333b3b183280ae6d
{{< text fg="purple" >}}.git/refs/heads/new-branch{{< /text >}}:f287aea16d69f4758c4f0c71333b3b183280ae6d

{{< text fg="yellow" >}}[在新分支创建一个新提交，new-branch 的 commit 哈希值变化]{{< /text >}}
$ echo 2 > 2.txt && git add -A && git commit -m "2nd commit"
$ grep --color '' .git/HEAD .git/refs/heads/*
{{< text fg="purple" >}}.git/HEAD{{< /text >}}:ref: refs/heads/new-branch
{{< text fg="purple" >}}.git/refs/heads/master{{< /text >}}:f287aea16d69f4758c4f0c71333b3b183280ae6d
{{< text fg="purple" >}}.git/refs/heads/new-branch{{< /text >}}:b074ad5d461edb24c45123c1029e61a5c641529b
```

{{< img src="head.svg" >}}



### tag 标签对象


```bash-session
$ git init test && cd test && echo 1 > 1.txt && git add -A && git commit -m "1st commit"

{{< text fg="yellow" >}}[在当前 HEAD 创建标签]{{< /text >}}
$ git tag -a v1.0.0 -m "Release version 1.0.0"
$ tree .git/objects/ .git/refs/tags/
.git/objects/
├── 38
│   └── fd29697b220f7e4ca15b044c3222eefe5afdc1
├── {{< text fg="purple" >}}76{{< /text >}}
│   └── {{< text fg="purple" >}}5ab40617481a637a1f84ceb6d760991b2dc720{{< /text >}}     {{< text fg="yellow" >}}[tag 对象]{{< /text >}}
├── {{< text fg="green" >}}c3{{< /text >}}
│   └── {{< text fg="green" >}}88239670a54d55963ed2b432df9fe6b7e63cff{{< /text >}}     {{< text fg="yellow" >}}[commit 对象]{{< /text >}}
├── d0
│   └── 0491fd7e5bb6fa28c517a0bb32b8b506539d4d
├── info
└── pack
.git/refs/tags/
└── {{< text fg="purple" >}}v1.0.0{{< /text >}}

{{< text fg="yellow" >}}[查看 v1.0.0 标签指针]{{< /text >}}
$ cat .git/refs/tags/v1.0.0
765ab40617481a637a1f84ceb6d760991b2dc720           {{< text fg="yellow" >}}[指向 tag 对象]{{< /text >}}

{{< text fg="yellow" >}}[查看 765ab... 类型及内容]{{< /text >}}
$ git cat-file -t 765a && git cat-file -p 765a
tag
object c388239670a54d55963ed2b432df9fe6b7e63cff    {{< text fg="yellow" >}}[指向 commit 对象]{{< /text >}}
type commit
tag v1.0.0
tagger kingtuo123 <kingtuo123@foxmail.com> 1783484010 +0800

Release version 1.0.0

{{< text fg="yellow" >}}[查看 c3882... 类型及内容]{{< /text >}}
$ git cat-file -t c388 && git cat-file -p c388 
commit
tree 38fd29697b220f7e4ca15b044c3222eefe5afdc1
author kingtuo123 <kingtuo123@foxmail.com> 1783483874 +0800
committer kingtuo123 <kingtuo123@foxmail.com> 1783483874 +0800

1st commit
```

{{< img src="tag.svg" >}}








## 分支

### 快速合并

```bash-session
$ git init test && cd test
$ echo 1 > 1.txt && git add -A && git commit -m "commit 1.txt"
$ git switch -c "feature-1"
$ echo 2 > 2.txt && git add -A && git commit -m "commit 2.txt"
$ echo 3 > 3.txt && git add -A && git commit -m "commit 3.txt"
$ ls
1.txt  2.txt  3.txt

{{< text fg="yellow" >}}[合并前]{{< /text >}}
$ git switch master
$ ls
1.txt
$ git log --all --graph --oneline --decorate
* 320e2ee (feature-1) commit 3.txt
* c191532 commit 2.txt
* a4d197d (HEAD -> master) commit 1.txt
$ grep --color '' .git/refs/heads/*
{{< text fg="purple" >}}.git/refs/heads/feature-1{{< /text >}}:320e2ee045cedcbec1f5770e3937c88d0cce2312
{{< text fg="purple" >}}.git/refs/heads/master{{< /text >}}:a4d197dfad3d82071f28fa86f6b9b6f40314cfa9

{{< text fg="yellow" >}}[合并后]{{< /text >}}
$ git merge feature-1 -m "merge feature-1 to master"
$ ls
1.txt  2.txt  3.txt
$ git log --all --graph --oneline --decorate
* 320e2ee (HEAD -> master, feature-1) commit 3.txt
* c191532 commit 2.txt
* a4d197d commit 1.txt
$ grep --color '' .git/refs/heads/*
{{< text fg="purple" >}}.git/refs/heads/feature-1{{< /text >}}:320e2ee045cedcbec1f5770e3937c88d0cce2312
{{< text fg="purple" >}}.git/refs/heads/master{{< /text >}}:320e2ee045cedcbec1f5770e3937c88d0cce2312
```

当 master 分支没有新 commit，feature-1 合并到 master 后并不会创建新的 commit，而是修改 master 指针。


{{< img src="branch-merge-1.svg" >}}

> `git merge` 可以使用 `--no-ff` 参数强制创建一个新的合并 commit，从而保留分支合并的记录。



### 普通合并

```bash-session
$ git init test && cd test
$ echo 1 > 1.txt && git add -A && git commit -m "commit 1.txt"
$ git branch "feature-1"
$ echo 2 > 2.txt && git add -A && git commit -m "commit 2.txt"
$ git switch "feature-1"
$ echo 3 > 3.txt && git add -A && git commit -m "commit 3.txt"
$ ls
1.txt  3.txt

{{< text fg="yellow" >}}[合并前]{{< /text >}}
$ git switch master
$ ls
1.txt  2.txt
$ git log --all --graph --oneline --decorate
* f6c832f (feature-1) commit 3.txt
| * f1a9a1f (HEAD -> master) commit 2.txt
|/
* 1795e59 commit 1.txt

{{< text fg="yellow" >}}[合并后]{{< /text >}}
$ git merge feature-1 -m "merge feature-1 to master"
$ ls
1.txt  2.txt  3.txt
$ git log --all --graph --oneline --decorate
*   8c14c2b (HEAD -> master) merge feature-1 to master
|\
| * f6c832f (feature-1) commit 3.txt
* | f1a9a1f commit 2.txt
|/
* 1795e59 commit 1.txt
$ git cat-file -p 8c14c2b
tree 7eab585dfd08ca9f7524e71369236c074c9e4d93
{{< text fg="red" >}}parent{{< /text >}} f1a9a1fb436b5afdf5fcda85ac65cf8e9742d882
{{< text fg="red" >}}parent{{< /text >}} f6c832fafaed888114e05bcc134b249b96469b15
author kingtuo123 <kingtuo123@foxmail.com> 1784126376 +0800
committer kingtuo123 <kingtuo123@foxmail.com> 1784126376 +0800

merge feature-1 to master
```

当 master 和 feature-1 分支都有新 commit 时，分支合并后的新 commit 有两个 parent 指针。


{{< img src="branch-merge-2.svg" >}}




### 合并冲突

```bash-session
$ git init test && cd test
$ echo "标题：合并冲突" > 1.txt && git add -A && git commit -m "first commit 1.txt"
$ git branch "feature-1"

{{< text fg="yellow" >}}[master 分支]{{< /text >}}
$ echo "正文：master 分支提交的内容" >> 1.txt && git add -A && git commit -m "update 1.txt"
$ cat 1.txt
标题：合并冲突
正文：master 分支提交的内容

{{< text fg="yellow" >}}[feature-1 分支]{{< /text >}}
$ git switch "feature-1"
$ echo "正文：feature-1 分支提交的内容" >> 1.txt && git add -A && git commit -m "update 1.txt"
$ cat 1.txt
标题：合并冲突
正文：feature-1 分支提交的内容

{{< text fg="yellow" >}}[合并前 | master 暂存区文件]{{< /text >}}
$ git switch master
$ git ls-files --stage
100644 baa89ed3dcde695109f9809cd2ee4b115c14f5f0 0	1.txt
$ git cat-file -p baa89ed3dcde695109f9809cd2ee4b115c14f5f0
标题：合并冲突
正文：master 分支提交的内容

{{< text fg="yellow" >}}[合并冲突 | master 暂存区文件]{{< /text >}}
$ git merge feature-1 --no-ff -m "merge 1.txt from feature-1 to master"
Auto-merging 1.txt
CONFLICT (content): {{< text fg="red" >}}Merge conflict in 1.txt{{< /text >}}
Automatic merge failed; fix conflicts and then commit the result.
$ git ls-files --stage
100644 b61ed4fb22945e8fbae9d4b865494d9da09160f3 1	1.txt    {{< text fg="yellow" >}}[共同祖先]{{< /text >}} 
100644 baa89ed3dcde695109f9809cd2ee4b115c14f5f0 2	1.txt    {{< text fg="yellow" >}}[当前分支]{{< /text >}} 
100644 583fb4cfc87c7610bb84b4b11b8f082ad1eedf32 3	1.txt    {{< text fg="yellow" >}}[被合并分支]{{< /text >}} 
$ git cat-file -p b61ed
标题：合并冲突
$ git cat-file -p baa89
标题：合并冲突
正文：master 分支提交的内容
$ git cat-file -p 583fb
标题：合并冲突
正文：feature-1 分支提交的内容

{{< text fg="yellow" >}}[可以看到分支尚未合并]{{< /text >}}
$ git log --all --graph --oneline --decorate
* 3bdae2b (feature-1) update 1.txt
| * 0994f55 (HEAD -> master) update 1.txt
|/
* 7f7bf32 first commit 1.txt
```

{{< notice class="green" >}}
`git ls-files --stage` 命令输出格式说明：

第 1 列：权限模式。

第 2 列：Blob 对象哈希值。

第 3 列：stage 编号（0 = 正常，1 = 共同祖先，2 = 当前分支，3 = 被合并分支）。

第 4 列：文件名。
{{< /notice >}}


#### Git 目录变化

当发生合并冲突时，`.git` 目录有以下变化：

```bash-session
$ ls -1 .git/{MERGE_*,ORIG_HEAD,index}
.git/MERGE_HEAD    → {{< text fg="yellow" >}}存放被合并分支 feature-1 顶端 commit 的哈希值，{{< /text >}}{{< text fg="red" >}}存在该文件就表示当前仓库处于合并冲突状态。{{< /text >}}
.git/MERGE_MODE    → {{< text fg="yellow" >}}存放合并选项（如 --no-ff、--squash 等），供后续 git commit 完成合并时使用。{{< /text >}}
.git/MERGE_MSG     → {{< text fg="yellow" >}}存放合并提交消息（git merge -m 选项的消息）。{{< /text >}}
.git/ORIG_HEAD     → {{< text fg="yellow" >}}存放合并前 HEAD 指向的 commit 哈希值。用于 git merge --abort 回退或 git reset --merge ORIG_HEAD 恢复。{{< /text >}}
.git/index         → {{< text fg="yellow" >}}暂存区：未冲突的文件仍以 stage 0 记录，{{< /text >}}{{< text fg="red" >}}发生冲突的文件则拆分成三个 stage 条目。{{< /text >}}

$ for i in .git/{MERGE_*,ORIG_HEAD}; do echo -e "\e[35m$i:\e[0m\n$(<$i)\n"; done
{{< text fg="purple" >}}.git/MERGE_HEAD:{{< /text >}}
3bdae2b2b3f0317824758730734661dbdfda6d60

{{< text fg="purple" >}}.git/MERGE_MODE:{{< /text >}}
no-ff

{{< text fg="purple" >}}.git/MERGE_MSG:{{< /text >}}
merge 1.txt from feature-1 to master

{{< text >}}# Conflicts:{{< /text >}}
{{< text >}}#	1.txt{{< /text >}}

{{< text fg="purple" >}}.git/ORIG_HEAD:{{< /text >}}
0994f559d7ee216188310397c4752a643ed8a8fe
```







#### 解决冲突

`<<<<<<<` 和 `>>>>>>>` 之间就是冲突的内容，手动编辑 `1.txt`，最后删除 `<<<<<<<`、`=======`、`>>>>>>>` 这些行：

```text{ bar="1.txt" }
标题：合并冲突
<<<<<<< HEAD
正文：master 分支提交的内容
=======
正文：feature-1 分支提交的内容
>>>>>>> feature-1
```

编辑后如下：

```text{ bar="1.txt" }
标题：合并冲突
正文：master + feature-1 合并冲突，手动编辑后的内容
```

最后再手动 commit：
```bash-session
$ git add 1.txt
$ git commit -m "merge 1.txt from feature-1 to master"
$ git log --all --graph --oneline --decorate
*   9bf5dca (HEAD -> master) merge 1.txt from feature-1 to master
|\
| * 3bdae2b (feature-1) update 1.txt
* | 0994f55 update 1.txt
|/
* 7f7bf32 first commit 1.txt
```




#### 撤销合并

若合并冲突，回到合并前的状态：

```bash-session
$ git merge --abort
```

若合并完成，回到合并前的状态：

```bash-session
$ git reset --hard ORIG_HEAD
```




git merge --abort —— 等同于 git reset --merge ORIG_HEAD







## 回退提交

**`--soft`**

更新 HEAD、分支指针。

-----

**`--mixed`**

更新 HEAD、分支指针 + 重置暂存区。

-----

**`--hard`**

更新 HEAD、分支指针 + 重置暂存区  + 重置工作目录（彻底重置，不保留任何修改）。

-----

**`--merge`**

更新 HEAD、分支指针 + 重置暂存区  + 重置工作目录（保留未跟踪文件，若已跟踪文件有未暂存的更改 → 中止操作）。

-----

**`--keep`**

更新 HEAD、分支指针 + 重置暂存区 + 重置工作目录（保留未跟踪文件、与被丢弃提交无关的修改，若包含与被丢弃提交有关的修改 → 中止操作）。

-----

### soft

```bash-session
$ git init test && cd test
$ echo "第一次提交的内容" >  1.txt && git add -A && git commit -m "first commit 1.txt"
$ echo "第二次提交的内容" >> 1.txt && git add -A && git commit -m "update 1.txt"
$ echo "第三次提交的内容" >> 1.txt && git add -A && git commit -m "update 1.txt"
$ echo "第四次提交的内容" >  2.txt && git add -A && git commit -m "first commit 2.txt"

{{< text fg="yellow" >}}[重置前]{{< /text >}}
$ cat 1.txt
第一次提交的内容
第二次提交的内容
第三次提交的内容
$ cat 2.txt
第四次提交的内容
$ git ls-files --stage
100644 99cf674e063a2805a2595c910af41d0dc90bb7f5 0	1.txt
100644 bb2df640b55c1e18a8c6af5aa36f90459a1217b5 0	2.txt
$ git log --all --graph --oneline --decorate
* f469712 (HEAD -> master) first commit 2.txt
* 2712469 update 1.txt
* 28a8c20 update 1.txt
* 9e810e1 first commit 1.txt

{{< text fg="yellow" >}}[重置后 | 暂存区不变 | 工作目录不变]{{< /text >}}
$ git reset --soft 9e810e1
$ cat 1.txt
第一次提交的内容
第二次提交的内容
第三次提交的内容
$ cat 2.txt
第四次提交的内容
$ git ls-files --stage
100644 99cf674e063a2805a2595c910af41d0dc90bb7f5 0	1.txt
100644 bb2df640b55c1e18a8c6af5aa36f90459a1217b5 0	2.txt
$ git log --all --graph --oneline --decorate
* 9e810e1 (HEAD -> master) first commit 1.txt
$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	{{< text fg="green" >}}modified:   1.txt{{< /text >}}
	{{< text fg="green" >}}new file:   2.txt{{< /text >}}

{{< text fg="yellow" >}}[暂存区没变，所以可以直接提交，相当于将几次提交 “压缩” 成一次]{{< /text >}}
$ git commit -m "update 1.txt 2.txt"
$ git log --all --graph --oneline --decorate
* a22f8b4 (HEAD -> master) update 1.txt 2.txt
* 9e810e1 first commit 1.txt
```


### mixed

```bash-session
$ git init test && cd test
$ echo "第一次提交的内容" >  1.txt && git add -A && git commit -m "first commit 1.txt"
$ echo "第二次提交的内容" >> 1.txt && git add -A && git commit -m "update 1.txt"
$ echo "第三次提交的内容" >> 1.txt && git add -A && git commit -m "update 1.txt"
$ echo "第四次提交的内容" >  2.txt && git add -A && git commit -m "first commit 2.txt"

{{< text fg="yellow" >}}[重置前]{{< /text >}}
$ cat 1.txt
第一次提交的内容
第二次提交的内容
第三次提交的内容
$ cat 2.txt
第四次提交的内容
$ git ls-files --stage
100644 99cf674e063a2805a2595c910af41d0dc90bb7f5 0	1.txt
100644 bb2df640b55c1e18a8c6af5aa36f90459a1217b5 0	2.txt
$ git log --all --graph --oneline --decorate
* 7e8095d (HEAD -> master) first commit 2.txt
* a628d7d update 1.txt
* 6330fa9 update 1.txt
* 2c589a9 first commit 1.txt

{{< text fg="yellow" >}}[重置后 | 工作目录不变 | 暂存区改变]{{< /text >}}
$ git reset --mixed 2c589a9
$ cat 1.txt
第一次提交的内容
第二次提交的内容
第三次提交的内容
$ cat 2.txt
第四次提交的内容
$ git ls-files --stage
100644 7e40a79316ae0753d11ae20a0c3458c040fd0ada 0	1.txt
$ git cat-file -p 7e40a
第一次提交的内容
$ git log --all --graph --oneline --decorate
* 2c589a9 (HEAD -> master) first commit 1.txt
$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	{{< text fg="red" >}}modified:   1.txt{{< /text >}}

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	{{< text fg="red" >}}2.txt{{< /text >}}
```



### merge

**`git reset --merge <commit>`**

- 移动 `HEAD` 与分支指针 → 
- 重置暂存区 → 
- 将 `<commit>` 与 `HEAD` 之间有差异的文件更新到工作区，保留暂存区和工作区之间存在差异的文件（未暂存的更改）。

{{< notice class="yellow">}}
如果 `<commit>` 和暂存区之间存在差异的文件有未暂存的更改，重置操作将中止。 *`工作区 ≠ 暂存区`*，则中止回退。
{{< /notice >}}

```bash-session
$ git init test && cd test
$ echo 1 > 1.txt && git add -A && git commit -m "C1: add 1.txt"
$ git branch feature-1

$ echo "hello" >> 1.txt
$ echo 2 > 2.txt && git add -A && git commit -m "C2: add 2.txt"

$ git switch feature-1
$ echo "world" >> 1.txt
$ echo 3 > 3.txt && git add -A && git commit -m "C3: add 3.txt"


$ git switch master
$ git merge feature-1 -m "merge feature-1 to master"



$ git log --all --graph --oneline --decorate
$ git ls-files --stage
```

-----

```bash-session
$ git init test && cd test
$ echo "第一次提交的内容" >  1.txt && git add -A && git commit -m "first commit 1.txt"
$ echo "第二次提交的内容" >> 1.txt && git add -A && git commit -m "update 1.txt"
$ echo "第三次提交的内容" >> 1.txt && git add -A && git commit -m "update 1.txt"
$ echo "第四次提交的内容" >  2.txt && git add -A && git commit -m "first commit 2.txt"

{{< text fg="yellow" >}}[重置前]{{< /text >}}
$ cat 1.txt
第一次提交的内容
第二次提交的内容
第三次提交的内容
$ cat 2.txt
第四次提交的内容
$ git ls-files --stage
100644 99cf674e063a2805a2595c910af41d0dc90bb7f5 0	1.txt
100644 bb2df640b55c1e18a8c6af5aa36f90459a1217b5 0	2.txt
$ git log --all --graph --oneline --decorate
* 7e8095d (HEAD -> master) first commit 2.txt
* a628d7d update 1.txt
* 6330fa9 update 1.txt
* 2c589a9 first commit 1.txt

{{< text fg="yellow" >}}[修改文件]{{< /text >}}
$ echo "重置前新增的内容" >> 1.txt
$ echo "重置前新增的文件" >> 3.txt

{{< text fg="yellow" >}}[重置后 | 暂存区改变 | 工作目录改变]{{< /text >}}
$ git reset --merge 2257563
$ cat 1.txt
第一次提交的内容
第二次提交的内容
第三次提交的内容
$ cat 2.txt
cat: 2.txt: No such file or directory
$ git ls-files --stage
100644 7e40a79316ae0753d11ae20a0c3458c040fd0ada 0	1.txt
$ git cat-file -p 7e40a
第一次提交的内容
$ git log --all --graph --oneline --decorate
* 2257563 (HEAD -> master) first commit 1.txt
$ git status
On branch master
nothing to commit, working tree clean
```


### keep

**`git reset --keep <commit>`**

- 效果：移动 `HEAD` 与分支指针 → 重置暂存区 → 将 `<commit>` 与 `HEAD` 之间有差异的文件更新到工作区，保留无差异文件（不更新）。
- 效果：移动 HEAD 与分支指针 → 重置暂存区 → 重置工作区（保留 *`<commit>`* 与 *`HEAD`* 之间无差异文件的本地修改）。
- 适用场景：你想丢弃几个最近的提交，但要保留工作区里还有不想丢失的、与这些提交无关的修改。

{{< notice class="yellow">}}
如果在 *`<commit>`* 和 *`HEAD`* 之间存在差异的文件有本地修改，则中止回退。
{{< /notice >}}

```bash-session
$ git init test && cd test
$ echo 1 > 1.txt && git add -A && git commit -m "C1: add 1.txt"
$ echo 2 > 2.txt && git add -A && git commit -m "C2: add 2.txt"
$ echo 3 > 3.txt && git add -A && git commit -m "C3: add 3.txt"

{{< text fg="yellow" >}}[文件 1.txt 在 C1 和 C3 的提交中没有差异，因此回退 C3 -> C1 时 1.txt 在工作区的修改可以被保留]{{< /text >}}
$ git ls-tree -r HEAD
{{< text fg="red" >}}100644 blob d00491fd7e5bb6fa28c517a0bb32b8b506539d4d	1.txt{{< /text >}}
100644 blob 0cfbf08886fca9a91cb753ec8734c84fcbe52c9f	2.txt
100644 blob 00750edc07d6415dcc07ae0351e9397b0222b7ba	3.txt
$ git ls-tree -r HEAD^^
{{< text fg="red" >}}100644 blob d00491fd7e5bb6fa28c517a0bb32b8b506539d4d	1.txt{{< /text >}}

{{< text fg="yellow" >}}[C1 和 C3 提交中有差异的文件是 2.txt 和 3.txt，所以这两个文件不能有本地修改，否则会报错]{{< /text >}}
$ echo "文件 1.txt 修改后的内容" > 1.txt
$ git status
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	{{< text fg="red" >}}modified:   1.txt{{< /text >}}

{{< text fg="yellow" >}}[回退到 C1 提交]{{< /text >}}
$ git reset --keep HEAD^^

{{< text fg="yellow" >}}[文件 1.txt 中的修改被保留]{{< /text >}}
$ cat 1.txt
文件 1.txt 修改后的内容
$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	{{< text fg="red" >}}modified:   1.txt{{< /text >}}
```
























<!--

## 仓库初始化

{{< table thead=false min-width="150" border=true >}}
|                                        |                                            |
|:---------------------------------------|:-------------------------------------------|
|*`git init`*                            |在当前目录初始化。                          |
|*`git init 目录`*                       |以指定目录名初始化                          |
{{< /table >}}







## 仓库配置

### 配置文件

{{< table border=true thead=false min-width="150,250" >}}
|                 |               |                                         |
|:----------------|:--------------|:----------------------------------------|
|**本地级配置**   |对当前仓库生效 |`.git/config`                            |
|**全局级配置**   |对当前用户生效 |`~/.gitconfig` 或 `~/.config/git/config` |
|**系统级配置**   |对所有用户生效 |`/etc/gitconfig`                         |
{{< /table >}}

> 优先级从高到低为：本地（local）→ 全局（global）→ 系统（system）。





### 配置命令

{{< table thead=false min-width="400" border=false >}}
|                                           |                    |
|:------------------------------------------|:-------------------|
|**全局配置**                               |                    |
|*`git config --global user.name "用户名"`* |设置用户名。        |
|*`git config --global user.email "邮箱"`*  |设置邮箱。          |
|*`git config --global --edit`*             |直接编辑配置文件。  |
|**查看所有配置**                        |                                            |
|*`git config --list`*                   |列出所有配置。                              |
|*`git config --list --show-origin`*     |列出所有配置及其来源的配置文件。            |
|**查看单项配置**                        |                                            |
|*`git config user.name`*                |查看用户名。                                |
|*`git config --show-origin user.email`* |查看邮箱及其来源的配置文件。                |
|**只查看对应级别配置**                  |                                            |
|*`git config --list --local`*           | 查看本地仓库配置，必须在仓库中执行该命令。 |
{{< /table >}}

> 不写级别默认是 `--local`。






## 工作树


worktree：可以实际编辑和查看的文件目录树。


{{< table thead=false min-width="400" border=true >}}
|                                           |                    |
|:------------------------------------------|:-------------------|
|**查看状态**                         ||
|*`git status`*                             |显示工作区与暂存区的状态。|
|*`git status -s`*                          |以简短格式输出状态（用字母标记状态）。|
|*`git status -b`*                          |在简短格式中同时显示当前分支与上游分支的跟踪信息。|
|**添加更改**||
|*`git add 文件`*                           |添加指定文件。|
|*`git add 路径`*                           |添加指定路径下的所有 **新增、修改、删除**。|
|*`git add -A`*                             |添加整个仓库下的所有 **新增、修改、删除**。|
|*`git add -u`*                             |添加整个仓库下的所有 **修改、删除**。|
|**撤销更改**                               ||
{{< /table >}}






git restore --worktree 从 statge 恢复文件到工作树



## 暂存区（索引 / index）



```bash-session
$ git init test && cd test
$ echo 123 | tee 1.txt 2.txt
$ git add -A
$ git commit -m "first commit"
$ tree .git/objects
.git/objects
├── 14
│   └── 8922302de3ea7c41efb9597f6d64f36a30eb37
├── {{< text fg="red" >}}19{{< /text >}}
│   └── {{< text fg="red" >}}0a18037c64c43e6b11489df4bf0b9eb6d2c9bf{{< /text >}}
├── 8e
│   └── c76af43da31ed0f5450c3a853a7fc95aecf139
├── info
└── pack
$ git cat-file -t {{< text >}}1489{{< /text >}} && git cat-file -p {{< text >}}1489{{< /text >}}
tree
100644 blob {{< text fg="red" >}}190a18037c64c43e6b11489df4bf0b9eb6d2c9bf{{< /text >}}	1.txt
100644 blob {{< text fg="red" >}}190a18037c64c43e6b11489df4bf0b9eb6d2c9bf{{< /text >}}	2.txt
$ git cat-file -t 190a && git cat-file -p 190a
blob
123
```
-->

