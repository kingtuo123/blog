---
title: "Git"
date: "2026-07-04"
toc: true
---








## 基础

### 对象模型


**blob**

存储文件的内容。

-----

**tree**

记录了 blob 对象或其它的 tree 对象的信息。

-----

**commit**

记录了作者、时间戳、父提交、tree 对象等信息。

-----

**tag**

记录了 commit 对象、标签名、作者等信息。

-----

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


### 相对引用

相对引用允许你从一个已知的提交（**HEAD**、**分支名** 或 **标签**）出发，找到它的父提交，而不必使用哈希值。

{{< table border=true thead=false >}}
|        |         |         |                |
|:-------|:--------|:--------|:---------------|
|`HEAD^` |`HEAD^1` |`HEAD~1` |表示相对 HEAD 的第一个父提交|
|`HEAD^^`|`HEAD^2` |`HEAD~2` |表示相对 HEAD 的第二个父提交|
|        |         |         |以此类推        |
{{< /table >}}






## 分支合并

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


#### 目录变化

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











## 回滚提交


```bash{ nonebg=true }
git reset [选项] <commit>
```

{{< table border=true thead=true min-width="120" >}}
|选项      |                                                                                                                 |
|:---------|:----------------------------------------------------------------------------------------------------------------|
|`--soft`  |更新 `HEAD` 和分支指针。                                                                                           |
|`--mixed` |更新 `HEAD` 和分支指针，重置 `index`。                                                                               |
|`--hard`  |更新 `HEAD` 和分支指针，重置 `index`，重置工作区（彻底重置，不保留任何更改）。                                       |
|`--keep`  |更新 `HEAD` 和分支指针，重置 `index`，重置工作区（仅保留 `<commit>` 与 `HEAD` 之间无差异文件在工作区的更改）。       |
|`--merge` |更新 `HEAD` 和分支指针，重置 `index`，重置工作区（仅保留 `<commit>` 与 `HEAD` 之间无差异文件在工作区的未暂存更改）。 |
{{< /table >}}


### soft


- 更新 `HEAD` 和分支指针。
- 保留 `index`。
- 保留工作区。


```bash-session
$ git init test && cd test
$ echo 1 > 1.txt && git add -A && git commit -m "C1: add 1.txt"
$ echo 2 > 2.txt && git add -A && git commit -m "C2: add 2.txt"
$ echo 3 > 3.txt && git add -A && git commit -m "C3: add 3.txt"

{{< text fg="yellow" >}}[修改 3.txt]{{< /text >}}
$ echo "hello world" > 3.txt && git add 3.txt

{{< text fg="yellow" >}}[暂存区 index]{{< /text >}}
$ git ls-files --stage
100644 d00491fd7e5bb6fa28c517a0bb32b8b506539d4d 0	1.txt
100644 0cfbf08886fca9a91cb753ec8734c84fcbe52c9f 0	2.txt
100644 3b18e512dba79e4c8300dd08aeb37f8e728b8dad 0	3.txt
$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	{{< text fg="green" >}}modified:   3.txt{{< /text >}}

{{< text fg="yellow" >}}[重置]{{< /text >}}
$ git reset --soft HEAD^^

{{< text fg="yellow" >}}[工作区被保留]{{< /text >}}
$ grep --color '' *.txt
{{< text fg="purple" >}}1.txt:{{< /text >}} 1
{{< text fg="purple" >}}2.txt:{{< /text >}} 2
{{< text fg="purple" >}}3.txt:{{< /text >}} hello world

{{< text fg="yellow" >}}[暂存区 index 被保留]{{< /text >}}
$ git ls-files --stage
100644 d00491fd7e5bb6fa28c517a0bb32b8b506539d4d 0	1.txt
100644 0cfbf08886fca9a91cb753ec8734c84fcbe52c9f 0	2.txt
100644 3b18e512dba79e4c8300dd08aeb37f8e728b8dad 0	3.txt
$ git status
On branch master
Changes to be committed:    {{< text fg="yellow" >}}[待提交文件：index 与 HEAD 比较 -> 2.txt 和 3.txt 是新文件]{{< /text >}}
  (use "git restore --staged <file>..." to unstage)
	{{< text fg="green" >}}new file:   2.txt{{< /text >}}
	{{< text fg="green" >}}new file:   3.txt{{< /text >}}
```





### mixed


- 更新 `HEAD` 和分支指针。
- 重置 `index`。
- 保留工作区。


```bash-session
$ git init test && cd test
$ echo 1 > 1.txt && git add -A && git commit -m "C1: add 1.txt"
$ echo 2 > 2.txt && git add -A && git commit -m "C2: add 2.txt"
$ echo 3 > 3.txt && git add -A && git commit -m "C3: add 3.txt"

{{< text fg="yellow" >}}[修改 3.txt]{{< /text >}}
$ echo "hello world" > 3.txt && git add 3.txt

{{< text fg="yellow" >}}[暂存区 index]{{< /text >}}
$ git ls-files --stage
100644 d00491fd7e5bb6fa28c517a0bb32b8b506539d4d 0	1.txt
100644 0cfbf08886fca9a91cb753ec8734c84fcbe52c9f 0	2.txt
100644 3b18e512dba79e4c8300dd08aeb37f8e728b8dad 0	3.txt
$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	{{< text fg="green" >}}modified:   3.txt{{< /text >}}

{{< text fg="yellow" >}}[重置]{{< /text >}}
$ git reset --mixed HEAD^^

{{< text fg="yellow" >}}[工作区被保留]{{< /text >}}
$ grep --color '' *.txt
{{< text fg="purple" >}}1.txt:{{< /text >}} 1
{{< text fg="purple" >}}2.txt:{{< /text >}} 2
{{< text fg="purple" >}}3.txt:{{< /text >}} hello world

{{< text fg="yellow" >}}[暂存区 index 被重置]{{< /text >}}
$ git ls-files --stage
100644 d00491fd7e5bb6fa28c517a0bb32b8b506539d4d 0	1.txt
$ git status
On branch master
Untracked files:    {{< text fg="yellow" >}}[未跟踪文件：工作区与 index 比较 -> 2.txt 和 3.txt 未添加跟踪]{{< /text >}}
  (use "git add <file>..." to include in what will be committed)
	{{< text fg="red" >}}2.txt{{< /text >}}
	{{< text fg="red" >}}3.txt{{< /text  >}}
```





### hard


- 更新 `HEAD` 和分支指针。
- 重置 `index`。
- 重置工作区（彻底重置，不保留任何更改）。


```bash-session
$ git init test && cd test
$ echo 1 > 1.txt && git add -A && git commit -m "C1: add 1.txt"
$ echo 2 > 2.txt && git add -A && git commit -m "C2: add 2.txt"
$ echo 3 > 3.txt && git add -A && git commit -m "C3: add 3.txt"

{{< text fg="yellow" >}}[修改 3.txt]{{< /text >}}
$ echo "hello world" > 3.txt && git add 3.txt

{{< text fg="yellow" >}}[暂存区 index]{{< /text >}}
$ git ls-files --stage
100644 d00491fd7e5bb6fa28c517a0bb32b8b506539d4d 0	1.txt
100644 0cfbf08886fca9a91cb753ec8734c84fcbe52c9f 0	2.txt
100644 3b18e512dba79e4c8300dd08aeb37f8e728b8dad 0	3.txt
$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	{{< text fg="green" >}}modified:   3.txt{{< /text >}}

{{< text fg="yellow" >}}[重置]{{< /text >}}
$ git reset --hard HEAD^^

{{< text fg="yellow" >}}[工作区被重置]{{< /text >}}
$ ls && cat *.txt
1.txt
1

{{< text fg="yellow" >}}[暂存区 index 被重置]{{< /text >}}
$ git ls-files --stage
100644 d00491fd7e5bb6fa28c517a0bb32b8b506539d4d 0	1.txt
$ git status
On branch master
nothing to commit, working tree clean
```





### keep


- 更新 `HEAD` 和分支指针。
- 重置 `index`。
- 重置工作区（仅保留 `<commit>` 与 `HEAD` 之间无差异文件在工作区的更改）。


适用场景：你想丢弃几个最近的提交，但要保留工作区里还有不想丢失的、与这些提交无关的修改。

```bash-session
$ git init test && cd test
$ echo 1 > 1.txt && git add -A && git commit -m "C1: add 1.txt"
$ echo 2 > 2.txt && git add -A && git commit -m "C2: add 2.txt"
$ echo 3 > 3.txt && git add -A && git commit -m "C3: add 3.txt"

{{< text fg="yellow" >}}[目标树]{{< /text >}}
$ git ls-tree -r HEAD^^
100644 blob d00491fd7e5bb6fa28c517a0bb32b8b506539d4d	1.txt

{{< text fg="yellow" >}}[旧树]{{< /text >}}
$ git ls-tree -r HEAD
100644 blob d00491fd7e5bb6fa28c517a0bb32b8b506539d4d	1.txt    {{< text fg="green" >}}无差异 -> 1.txt 在工作区中的更改可保留{{< /text >}}
100644 blob 0cfbf08886fca9a91cb753ec8734c84fcbe52c9f	2.txt    {{< text fg="red"   >}}有差异 -> 2.txt 在工作区中不可更改{{< /text >}}
100644 blob 00750edc07d6415dcc07ae0351e9397b0222b7ba	3.txt    {{< text fg="red"   >}}有差异 -> 3.txt 在工作区中不可更改{{< /text >}}

{{< text fg="yellow" >}}[修改 1.txt]{{< /text >}}
$ echo "hello world" > 1.txt && git add 1.txt

{{< text fg="yellow" >}}[暂存区 index]{{< /text >}}
$ git ls-files --stage
100644 3b18e512dba79e4c8300dd08aeb37f8e728b8dad 0	1.txt
100644 0cfbf08886fca9a91cb753ec8734c84fcbe52c9f 0	2.txt
100644 00750edc07d6415dcc07ae0351e9397b0222b7ba 0	3.txt
$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	{{< text fg="green" >}}modified:   1.txt{{< /text >}}

{{< text fg="yellow" >}}[重置]{{< /text >}}
$ git reset --keep HEAD^^

{{< text fg="yellow" >}}[1.txt 改动被保留]{{< /text >}}
$ cat 1.txt
hello world

{{< text fg="yellow" >}}[暂存区 index 被重置]{{< /text >}}
$ git ls-files --stage
100644 d00491fd7e5bb6fa28c517a0bb32b8b506539d4d 0	1.txt
$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	{{< text fg="red" >}}modified:   1.txt{{< /text >}}
```







### merge


- 更新 `HEAD` 和分支指针。
- 重置 `index`。
- 重置工作区（仅保留 `<commit>` 与 `HEAD` 之间无差异文件在工作区的未暂存更改）。


适用场景：撤销合并。

```bash-session
$ git init test && cd test
$ echo 1 > 1.txt && git add -A && git commit -m "add 1.txt"

$ git switch -c feature-1
$ echo "hello" > 1.txt
$ echo 2 > 2.txt && git add -A && git commit -m "update 1.txt & add 2.txt"

$ git switch master
$ echo "world" > 1.txt
$ echo 3 > 3.txt && echo 4 > 4.txt && git add -A && git commit -m "update 1.txt & add 3.txt & add 4.txt"

$ git log --all --graph --oneline --decorate
* d9f0f72 (HEAD -> master) update 1.txt & add 3.txt & add 4.txt
| * 02181ef (feature-1) update 1.txt & add 2.txt
|/
* a9c378d add 1.txt

{{< text fg="yellow" >}}[合并 feature-1 到 master，文件 1.txt 冲突]{{< /text >}}
$ git merge feature-1 -m "merge feature-1 to master"
Auto-merging 1.txt
CONFLICT (content): Merge conflict in 1.txt
Automatic merge failed; fix conflicts and then commit the result.

{{< text fg="yellow" >}}[修改 3.txt 和 4.txt]{{< /text >}}
$ echo "保留的更改" > 3.txt
$ echo "不保留的更改" > 4.txt && git add 4.txt
$ git status
On branch master
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Changes to be committed:
	{{< text fg="green" >}}new file:   2.txt{{< /text >}}
	{{< text fg="green" >}}modified:   4.txt{{< /text >}}

Unmerged paths:
  (use "git add <file>..." to mark resolution)
	{{< text fg="red" >}}both modified:   1.txt{{< /text >}}

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	{{< text fg="red" >}}modified:   3.txt{{< /text >}}
$ grep --color '' *.txt
{{< text fg="purple" >}}1.txt:{{< /text >}} <<<<<<< HEAD
{{< text fg="purple" >}}1.txt:{{< /text >}} world
{{< text fg="purple" >}}1.txt:{{< /text >}} =======
{{< text fg="purple" >}}1.txt:{{< /text >}} hello
{{< text fg="purple" >}}1.txt:{{< /text >}} >>>>>>> feature-1
{{< text fg="purple" >}}2.txt:{{< /text >}} 2
{{< text fg="purple" >}}3.txt:{{< /text >}} 保留的更改
{{< text fg="purple" >}}4.txt:{{< /text >}} 不保留的更改

{{< text fg="yellow" >}}[ORIG_HEAD 和 HEAD 相同]{{< /text >}}
$ grep --color '' .git/{HEAD,refs/heads/master,ORIG_HEAD}
{{< text fg="purple" >}}.git/HEAD:{{< /text >}} ref: refs/heads/master
{{< text fg="purple" >}}.git/refs/heads/master:{{< /text >}} d9f0f72609052e686d353b09424c0003d72bfe84
{{< text fg="purple" >}}.git/ORIG_HEAD:{{< /text >}} d9f0f72609052e686d353b09424c0003d72bfe84

{{< text fg="yellow" >}}[目标树 ORIG_HEAD]{{< /text >}}
$ git ls-tree -r ORIG_HEAD
100644 blob cc628ccd10742baea8241c5924df992b5c019f71	1.txt
100644 blob 00750edc07d6415dcc07ae0351e9397b0222b7ba	3.txt
100644 blob b8626c4cff2849624fb67f87cd0ad72b163671ad	4.txt

{{< text fg="yellow" >}}[暂存区 index]{{< /text >}}
$ git ls-files --stage
100644 d00491fd7e5bb6fa28c517a0bb32b8b506539d4d 1	1.txt    {{< text fg="red"     >}}index == stage 1 (冲突条目){{< /text >}}
100644 cc628ccd10742baea8241c5924df992b5c019f71 2	1.txt    {{< text fg="red"     >}}index == stage 2 (冲突条目){{< /text >}}
100644 ce013625030ba8dba906f756967f9e9ca394464a 3	1.txt    {{< text fg="red"     >}}index == stage 3 (冲突条目){{< /text >}}
100644 0cfbf08886fca9a91cb753ec8734c84fcbe52c9f 0	2.txt    {{< text fg="yellow"  >}}index != 目标树  (不在目标树中){{< /text >}}
100644 00750edc07d6415dcc07ae0351e9397b0222b7ba 0	3.txt    {{< text fg="green"   >}}index == 目标树  (与目标树相同){{< /text >}}
100644 ef7afd5a2a346a3865c398549e6c94011fbc318c 0	4.txt    {{< text fg="yellow"  >}}index != 目标树  (与目标树不同){{< /text >}}

{{< text fg="yellow" >}}[重置]{{< /text >}}
$ git reset --merge ORIG_HEAD
$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	{{< text fg="red" >}}modified:   3.txt{{< /text >}}

{{< text fg="yellow" >}}[重置后的 index]{{< /text >}}
$ git ls-files --stage
100644 cc628ccd10742baea8241c5924df992b5c019f71 0	1.txt
100644 00750edc07d6415dcc07ae0351e9397b0222b7ba 0	3.txt
100644 b8626c4cff2849624fb67f87cd0ad72b163671ad 0	4.txt

{{< text fg="yellow" >}}[重置后的工作区]{{< /text >}}
$ grep --color '' *.txt
{{< text fg="purple" >}}1.txt:{{< /text >}} world
{{< text fg="purple" >}}3.txt:{{< /text >}} 保留的更改
{{< text fg="purple" >}}4.txt:{{< /text >}} 4
```


- **index == stage 1/2/3**
  - 行为：删除 index 中 stage 1/2/3 的条目，替换为目标树中的 stage 0 条目，重置工作区文件
  - 结果：`1.txt` → 重置
- **`index == 目标树`**
  - 行为：保留 index 条目，保留工作区文件
  - 结果：`3.txt` → 不变
- **`index != 目标树 && 工作区 == index`**
  - 行为：重置 index 为目标版本，重置工作区文件
  - 结果：`2.txt` → 不存在 → 删除，`4.txt` → 重置
- **`index != 目标树 && 工作区 != index`**
  - 行为：拒绝（中止操作）
  - 结果：本例中没有









## 撤销提交


```bash{ nonebg=true }
git revert [选项] <commit>
```

{{< table >}}
|选项              |                                                    |
|:-----------------|:---------------------------------------------------|
|`-e` `--edit`     |在提交前打开编辑器，手动编辑提交信息（默认行为）。  |
|`--no-edit`       |不打开编辑器，直接使用默认的提交信息。              |
|`-n` `--no-commit`|不自动创建提交，只将反向更改应用到工作区和暂存区。  |
{{< /table >}}


撤销单个提交：

```bash-session
$ git init test && cd test
$ echo 1 > 1.txt && git add -A && git commit -m "C1: add 1.txt"
$ echo 2 > 2.txt && git add -A && git commit -m "C2: add 2.txt"
$ echo 3 > 3.txt && git add -A && git commit -m "C3: add 3.txt"

$ git log --all --graph --oneline --decorate
* d830b1c (HEAD -> master) C3: add 3.txt
* 20de97e C2: add 2.txt
* 7af304f C1: add 1.txt

$ ls
1.txt  2.txt  3.txt

{{< text fg="yellow" >}}[撤销 C1 提交]{{< /text >}}
$ git revert --no-edit HEAD^^

$ git log --all --graph --oneline --decorate
* 67984ea (HEAD -> master) Revert "C1: add 1.txt" {{< text fg="yellow" >}}-> 通过创建一个新的提交来反向撤销指定提交引入的更改，从而安全地回退历史{{< /text >}}
* d830b1c C3: add 3.txt
* 20de97e C2: add 2.txt
* 7af304f C1: add 1.txt

$ ls
2.txt  3.txt
```

撤销多个提交：

```bash-session
$ git reset --hard HEAD^

{{< text fg="yellow" >}}[撤销 C1、C2 提交]{{< /text >}}
$ git revert --no-edit HEAD^^ HEAD^

$ git log --all --graph --oneline --decorate
* f55cd09 (HEAD -> master) Revert "C2: add 2.txt" {{< text fg="yellow" >}}-> 每个被撤销的提交，都会生成一个独立的 Revert 提交{{< /text >}}
* fdcac30 Revert "C1: add 1.txt"                  {{< text fg="yellow" >}}-> 每个被撤销的提交，都会生成一个独立的 Revert 提交{{< /text >}}
* a209994 C3: add 3.txt
* 5d0338c C2: add 2.txt
* 78f3621 C1: add 1.txt
```

使用 `--no-commit` 整合多个 Revert 为一条提交：

```bash-session
$ git reset --hard HEAD^^

{{< text fg="yellow" >}}[撤销 C1、C2 提交]{{< /text >}}
$ git revert --no-edit --no-commit HEAD^^ HEAD^
$ git log --all --graph --oneline --decorate
* a209994 (HEAD -> master) C3: add 3.txt
* 5d0338c C2: add 2.txt
* 78f3621 C1: add 1.txt
$ git status
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	{{< text fg="green" >}}deleted:    1.txt{{< /text >}}
	{{< text fg="green" >}}deleted:    2.txt{{< /text >}}

$ git commit -m "Revert C1 and C2"
$ git log --all --graph --oneline --decorate
* 5c8bf5f (HEAD -> master) Revert C1 and C2
* a209994 C3: add 3.txt
* 5d0338c C2: add 2.txt
* 78f3621 C1: add 1.txt
```

### 冲突

```bash-session
$ git init test && cd test
$ echo -e "line1\nline2\nline3" > 1.txt && git add -A && git commit -m "C1: add 1.txt"
$ sed -i "2c new line2 of C2" 1.txt && git add -A && git commit -m "C2: update 1.txt"
$ sed -i "2c new line2 of C3" 1.txt && git add -A && git commit -m "C3: update 1.txt"

$ cat 1.txt
line1
new line2 of C3
line3

{{< text fg="yellow" >}}[撤销 C2 提交]{{< /text >}}
$ git revert --no-edit HEAD^
Auto-merging 1.txt
CONFLICT (content): Merge conflict in 1.txt
error: could not revert c82bc28... C2: update 1.txt
```

#### 目录变化

发生冲突时，`.git` 目录有以下变化：

```bash-session
$ ls -1 .git/{REVERT*,MERGE*,index}
.git/MERGE_MSG      {{< text fg="yellow">}}-> 存放 Revert 提交消息{{< /text >}}
.git/REVERT_HEAD    {{< text fg="yellow">}}-> 指向正在被 revert 的那个提交{{< /text >}}
.git/index          {{< text fg="yellow">}}-> 发生冲突的文件被拆分成三个 stage 条目{{< /text >}}

$ git log --all --graph --oneline --decorate
* a79a201 (HEAD -> master) C3: update 1.txt
* {{< text fg="red">}}c82bc28{{< /text >}} C2: update 1.txt
* 565097b C1: add 1.txt

$ cat .git/REVERT_HEAD
{{< text fg="red">}}c82bc28{{< /text >}}c6d712256153215314f1ee5c42f65a295

$ git ls-files --stage
100644 8f0e9c9ee94e69f8f27ce526c79151cc6230824b 1	1.txt
100644 ac133abcc43f7c3149ac0850c2dc938cbe55d614 2	1.txt
100644 83db48f84ec878fbfb30b46d16630e944e34f205 3	1.txt
```

#### 解决冲突

```{ bar="1.txt" }
line1
<<<<<<< HEAD
new line2 of C3
=======
line2
>>>>>>> {{< text fg="red">}}parent of{{< /text >}} c82bc28 (C2: update 1.txt)
line3
```

- `<<<<<<<` 与 `=======` 之间的是当前分支 HEAD 的内容。
- `=======` 与 `>>>>>>>` 之间的是 revert 试图应用的旧内容（C2 的父提交，也就是 C1 中的 line2）。

编辑完冲突文件后，再执行以下命令：

```bash-session
{{< text fg="yellow" >}}[标记冲突已解决]{{< /text >}}
$ git add 1.txt

{{< text fg="yellow" >}}[继续完成 revert]{{< /text >}}
$ git revert --continue --no-edit
```

#### 放弃 Revert

中止整个 revert 操作，回到执行前的干净状态：

```bash-session
$ git revert --abort
```






## 变基

```bash-session
$ git init test && cd test
$ echo "V1" >> 1.txt && git add -A && git commit -m "C1: add V1"
$ echo "V2" >> 1.txt && git add -A && git commit -m "C2: add V2"

$ git switch -c feature
$ echo "feature A" >> 1.txt && git add -A && git commit -m "F1: add feature A"
$ echo "feature B" >> 1.txt && git add -A && git commit -m "F2: add feature B"

$ git switch master
$ echo "V3" >> 1.txt && git add -A && git commit -m "C3: add V3"
$ echo "V4" >> 1.txt && git add -A && git commit -m "C4: add V4"
$ cat 1.txt
V1
V2
V3
V4

$ git switch feature
$ cat 1.txt
V1
V2
feature A
feature B

{{< text fg="yellow" >}}[以 master 为新基底]{{< /text >}}
$ git rebase master
Auto-merging 1.txt
CONFLICT (content): Merge conflict in 1.txt
```

```text{ bar="冲突文件:1.txt" }
V1
V2
<<<<<<< HEAD
V3
V4
=======
feature A
>>>>>>> 5c611ea (F1: add feature A)
```

```text{ bar="编辑后:1.txt" }
V1
V2
V3
V4
feature A
```

```bash-session
$ git add 1.txt
$ git rebase --continue
$ cat 1.txt
V1
V2
V3
V4
feature A
feature B
$ git log --all --graph --oneline --decorate
* 22ce511 (HEAD -> feature) F2: add feature B
* 37c218f F1: add feature A
* 142e47d (master) C4: add V4
* dfe9662 C3: add V3
* 0fd4f05 C2: add V2
* 71060d4 C1: add V1
```

{{< img src="rebase.svg" >}}




## cherry-pick

用于将指定的一个或多个已有提交的变更，应用到当前分支的头部，相当于 “摘取” 某次提交。


```bash-session
$ git init test && cd test
$ echo "V1" >> 1.txt && git add -A && git commit -m "C1: add V1"
$ echo "V2" >> 1.txt && git add -A && git commit -m "C2: add V2"

$ git switch -c feature
$ echo "feature A" >> 1.txt && git add -A && git commit -m "F1: add feature A"
$ echo "feature B" >> 1.txt && git add -A && git commit -m "F2: add feature B"

$ git switch master
$ echo "V3" >> 1.txt && git add -A && git commit -m "C3: add V3"
$ echo "V4" >> 1.txt && git add -A && git commit -m "C4: add V4"
$ cat 1.txt
V1
V2
V3
V4


{{< text fg="yellow" >}}[将 F1 提交的更改应用到当前分支]{{< /text >}}
$ git cherry-pick feature~1
Auto-merging 1.txt
CONFLICT (content): Merge conflict in 1.txt
error: could not apply 2fdfcf3... F1: add feature A
```

```text{ bar="冲突文件:1.txt" }
V1
V2
<<<<<<< HEAD
V3
V4
=======
feature A
>>>>>>> e71fd18 (F1: add feature A)
```

```text{ bar="编辑后:1.txt" }
V1
V2
V3
V4
feature A
```

```bash-session
$ git add 1.txt
$ git cherry-pick --continue
$ cat 1.txt
V1
V2
V3
V4
feature A
$ git log --all --graph --oneline --decorate
* 5f8bf04 (HEAD -> master) F1: add feature A
* 44d27c0 C4: add V4
* 3ab6b32 C3: add V3
| * c4740f1 (feature) F2: add feature B
| * e71fd18 F1: add feature A
|/  
* 549a938 C2: add V2
* d7b6c1d C1: add V1
```


{{< img src="cherry-pick.svg" >}}




## 常用命令


### init

{{< table thead=false min-width="150" border=true >}}
|                                        |                                            |
|:---------------------------------------|:-------------------------------------------|
|*`git init`*                            |在当前目录初始化。                          |
|*`git init 目录`*                       |以指定目录名初始化。                        |
{{< /table >}}




### config

{{< table border=true thead=false min-width="150,250" >}}
|                 |               |                                         |
|:----------------|:--------------|:----------------------------------------|
|**本地级配置**   |对当前仓库生效 |`.git/config`                            |
|**全局级配置**   |对当前用户生效 |`~/.gitconfig` 或 `~/.config/git/config` |
|**系统级配置**   |对所有用户生效 |`/etc/gitconfig`                         |
{{< /table >}}

> 优先级从高到低为：本地（local）→ 全局（global）→ 系统（system）。

{{< table thead=false min-width="400" border=true >}}
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






### status

{{< table thead=false min-width="400" border=true >}}
|                                           |                    |
|:------------------------------------------|:-------------------|
|*`git status`*                             |显示工作区与暂存区的状态。|
|*`git status -s`*                          |以简短格式输出状态（用字母标记状态）。|
|*`git status -b`*                          |在简短格式中同时显示当前分支与上游分支的跟踪信息。|
{{< /table >}}




### add

{{< table thead=false min-width="400" border=true >}}
|                                           |                    |
|:------------------------------------------|:-------------------|
|*`git add <文件>`*                           |添加指定文件。|
|*`git add <路径>`*                           |添加指定路径下的所有 **新增、修改、删除**。|
|*`git add -A`*                             |添加整个仓库下的所有 **新增、修改、删除**。|
|*`git add -u`*                             |添加整个仓库下的所有 **修改、删除**。|
{{< /table >}}




### remote

{{< table thead=false min-width="400" border=true >}}
|                                             |                      |
|:--------------------------------------------|:---------------------|
|*`git remote -v`*                            |列出所有远程仓库      |
|*`git remote show <仓库名>`*                 |查看远程仓库详细信息  |
|*`git remote add <仓库名> <仓库地址>`*       |添加一个远程仓库      |
|*`git remote remove <仓库名>`*               |移除远程仓库          |
|*`git remote rename <旧名称> <新名称>`*      |重命名远程仓库        |
{{< /table >}}

#### 远程引用

远程引用（remote reference）是用来追踪远程仓库分支状态的本地引用，它们本质上是指向远程分支最新提交的指针。。

- 存放位置：`.git/refs/remotes/<远程名>/<分支名>`，如 `.git/refs/remotes/origin/main`。
- 表示形式：在命令行中可使用 `<远程名>/<分支名>` ，如 `origin/main`。
- 更新方式：当执行 `git fetch`、`git pull` 或 `git remote update` 时，Git 会将远程仓库的当前分支状态写入远程引用中。






### switch

{{< table thead=false min-width="400" border=true >}}
|                                             |                                          |
|:--------------------------------------------|:-----------------------------------------|
|*`git switch <分支名>`*                      |切换到目标分支                            |
|*`git switch -c <分支名>`*                   |创建新分支并切换过去                      |
|*`git switch -C <分支名>`*                   |强制创建新分支（若已存在则重置到起始点）  |
|*`git switch --orphan <分支名>`*             |创建孤儿分支                              |
|*`git switch -f <分支名>`*                   |强制丢弃本地所有修改并切回目标分支        |
|*`git switch -m <分支名>`*                   |切回目标分支并将本地修改合并到目标分支    |
|*`git switch -d <commit>`*                   |切换到某个提交（detached HEAD 状态）      |
{{< /table >}}

#### 孤儿分支

孤儿分支（Orphan Branch）是指一个没有任何父提交记录的分支。 常见用途：
- 完全重写项目：不想要旧历史时，在孤儿分支上从零开始重建代码，保留仓库但抛弃所有历史。
- 存放项目无关内容：例如在同一个仓库中放置单独的 wiki、设计素材等。

#### 分离头指针

分离头指针（detached HEAD）是指 HEAD 不再指向某个分支（`.git/refs/heads/<分支名>`），而是直接指向一个 commit。

- 正常指针：HEAD → 分支（如 main）→ 最新的 commit。
- 分离头指针：HEAD → 某个 commit（没有分支名）。


{{< notice class="yellow" >}}
在 detached HEAD 状态下，可以查看文件、做实验、创建新的 commit 等，但这些新的 commit 不属于任何分支，
一旦切换到别的分支就会丢失，所以在切换前需要创建一个新分支以保留这些 commit。
{{< /notice >}}



### resotre

{{< table thead=false border=true >}}
|                                                                |                        |
|:---------------------------------------------------------------|:-----------------------|
|*`git restore <文件名>`*                                        |从暂存区恢复文件到工作区|
|*`git restore --worktree <文件名>`*                             |从暂存区恢复文件到工作区|
|*`git restore --staged <文件名>`*                               |从 HEAD 恢复文件到暂存区|
|*`git restore --source=<commit> --staged --worktree <文件名>`*  |从 commit（也可以是分支名和标签）中恢复文件到暂存区和工作区|
{{< /table >}}

`--worktree` 可简写为 `-W`，`--staged` 可简写为 `-S`。


### commit

{{< table thead=false min-width="400" border=true >}}
|                                             |                      |
|:--------------------------------------------|:---------------------|
|*`git commit -m "提交说明"`*                 |指定提交说明          |
|*`git commit -am "提交说明"`*                |自动暂存所有已跟踪文件的修改并提交（跳过 git add）|
|*`git commit --amend -m "新的提交说明"`*     |将当前暂存区并入上一次提交，不新建提交（可重写提交说明）|
{{< /table >}}


### push

{{< table thead=false min-width="400" border=true >}}
|                                             |                                       |
|:--------------------------------------------|:--------------------------------------|
|*`git push`*                                 |推送当前分支到默认远程的同名分支       |
|*`git push <远程仓库> <分支名>`*             |推送指定分支到远程同名分支             |
|*`git push -u <远程仓库> <分支名>`*          |推送指定分支到远程同名分支，并设置上游 |
|*`git push -f <远程仓库> <分支名>`*          |强制推送指定分支到远程同名分支         |
|*`git push --all origin`*                    |推送所有分支                           |
|*`git push --tags`*                          |推送所有标签                           |
|*`git push <远程仓库> --delete <分支名>`*    |删除远程仓库中的分支                   |
|*`git push <远程仓库> --prune`*              |清理远程仓库中本地已不存在的分支       |
{{< /table >}}

> `-u` , `--set-upstream` 选项用于将当前本地分支与指定的远程分支建立跟踪关系（即设定 “上游分支”），
> 这样以后执行 `git push` 或 `git pull` 就不用带参数。




### fetch

{{< table thead=false min-width="400" border=true >}}
|                                             |                                |
|:--------------------------------------------|:-------------------------------|
|*`git fetch`*                                |从默认远程仓库获取所有分支和标签|
|*`git fetch <远程仓库>`*                     |从指定远程仓库获取              |
|*`git fetch <远程仓库> <分支名>`*            |从指定远程仓库的指定分支获取    |
|*`git fetch --all`*                          |获取所有远程仓库的更新          |
|*`git fetch --prune`*                        |获取并清理远程仓库已删除的分支  |
|*`git fetch --tags`*                         |获取所有标签                    |
|*`git fetch --recurse-submodules`*           |递归获取子模块更新              |
{{< /table >}}



### pull

{{< table thead=false min-width="400" border=true >}}
|                                             |                                  |
|:--------------------------------------------|:---------------------------------|
|*`git pull`*                                 |从默认远程仓库拉取当前分支的更新  |
|*`git pull <远程仓库> <分支名>`*             |从指定远程仓库拉取指定分支        |
|*`git pull --rebase`*                        |以变基方式拉取                    |
|*`git pull --ff-only`*                       |仅允许快速合并                    |
|*`git pull --tags`*                          |拉取时获取所有标签                |
|*`git pull --prune`*                         |拉取前清除远程已删除的本地分支    |
{{< /table >}}



### clone

{{< table thead=false min-width="400" border=true >}}
|                                             |                      |
|:--------------------------------------------|:---------------------|
|*`git clone <地址>`*                         |克隆远程仓库到当前目录下的同名文件夹|
|*`git clone <地址> <目录名>`*                |克隆到指定目录名                    |
|*`git clone --depth 1 <地址>`*               |浅克隆（仅保留最近 1 条历史）以加速下载|
|*`git clone --recurse-submodules <地址>`*    |克隆并自动初始化子模块|
{{< /table >}}



### submodule

{{< table thead=false min-width="400" border=true >}}
|                                             |                      |
|:--------------------------------------------|:---------------------|
|*`git submodule add <地址> <本地路径>`*      |添加子模块|
|*`git submodule status`*                     |查看子模块状态|
|*`git submodule update --init --recursive`*  |初始化并更新克隆后的子模块|
|*`git submodule update --remote --merge`*    |更新所有子模块到最新远程提交|
{{< /table >}}

#### 删除子模块

```bash-session
$ git submodule deinit -f -- path/to/submodule
$ rm -rf .git/modules/path/to/submodule
$ git rm -f path/to/submodule
```



### branch

{{< table thead=false min-width="400" border=true >}}
|                                             |                                          |
|:--------------------------------------------|:-----------------------------------------|
|*`git branch`*                               |列出所有本地分支                          |
|*`git branch <分支名>`*                      |创建分支                                  |
|*`git branch -f <分支名>`*                   |强制创建分支（重置已有分支）              |
|*`git branch <提交> <分支名>`*               |从指定提交创建分支                        |
|*`git branch -d <分支名>`*                   |删除已完全合并的分支                      |
|*`git branch -D <分支名>`*                   |强制删除分支（即使未合并）                |
|*`git branch -r <分支名>`*                   |删除本地的远程跟踪分支                    |
|*`git branch -a`*                            |列出本地和远程跟踪分支                    |
|*`git branch --merged`*                      |列出已合并到当前分支的分支                |
|*`git branch --no-merged <分支名>`*          |列出尚未合并到 *`<分支名>`* 的分支        |
|*`git branch -m <新名称>`*                   |重命名当前分支                            |
|*`git branch -M <新名称>`*                   |强制重命名，即使 *`<新名称>`* 已存在      |
|*`git branch -c <源分支> <目标分支>`*        |拷贝分支                                  |
|*`git branch -u <远程仓库>/<分支名>`*        |设置当前分支跟踪 *`<远程仓库>/<分支名>`*  |
|*`git branch --unset-upstream`*              |取消当前分支的上游设置                    |
|*`git branch -vv`*                           |示分支及上次提交信息、上游状态            |
{{< /table >}}





### log

{{< table thead=false min-width="400" border=true >}}
|                                              |                                          |
|:-------------------------------------------- |:-----------------------------------------|
|*`git log -5`*                                |最近 5 条提交                             |
|*`git log --oneline`*                         |单行显示                                  |
|*`git log --oneline --graph --decorate --all`*|显示所有分支的图形化历史                  |
{{< /table >}}





### diff

{{< table thead=false min-width="400" border=true >}}
|                                             |                                          |
|:--------------------------------------------|:-----------------------------------------|
|*`git diff`*                                 |对比工作区与暂存区                        |
|*`git diff <文件名>`*                        |对比该文件在工作区与暂存区的内容          |
|*`git diff HEAD`*                            |对比工作区与 HEAD                         |
|*`git diff --staged`*                        |对比暂存区与 HEAD                         |
|*`git diff <分支1>..<分支2>`*                |对比两个分支                              |
|*`git diff --stat`*                          |查看差异统计摘要（文件 + 增删行数）       |
{{< /table >}}




### tag

{{< table thead=false min-width="400" border=true >}}
|                                             |                                          |
|:--------------------------------------------|:-----------------------------------------|
|*`git tag`*                                  |列出所有标签                              |
|*`git tag v1.0.0`*                           |创建标签                                  |
|*`git tag -a v1.0.0 -m "附注信息"`*          |创建附注标签                              |
|*`git tag -d v1.0.0`*                        |删除本地标签                              |
{{< /table >}}








## 其它 - 杂七杂八


### 首次创建 / 提交基本流程

```bash-session
$ git init                                                          {{< text fg="gray-0" >}}初始化仓库{{< /text>}}
$ echo "Hello World" >> README.md                                   {{< text fg="gray-0" >}}添加文件到仓库{{< /text>}}
$ git add README.md                                                 {{< text fg="gray-0" >}}添加文件到暂存区{{< /text>}}
$ git commit -m "first commit"                                      {{< text fg="gray-0" >}}提交到本地仓库{{< /text>}}
$ git branch -M master                                              {{< text fg="gray-0" >}}创建 master 分支{{< /text>}}
$ git remote add origin git@github.com:kingtuo123/test-only.git     {{< text fg="gray-0" >}}添加远程仓库{{< /text>}}
$ git push -u origin master                                         {{< text fg="gray-0" >}}推送到远程仓库{{< /text>}}
```


### 清空历史 commits

```bash-session
$ git switch --orphan latest_branch    {{< text fg="gray-0" >}}创建孤儿分支，并切换到该分支{{< /text >}}
$ git add -A                           {{< text fg="gray-0" >}}暂存所有文件{{< /text >}}
$ git commit -am "First Commit"        {{< text fg="gray-0" >}}提交所有更改{{< /text>}}
$ git branch -D master                 {{< text fg="gray-0" >}}删除主分支 master{{< /text>}}
$ git branch -m master                 {{< text fg="gray-0" >}}重命名当前分支为 master{{< /text>}}
$ git push -f origin master            {{< text fg="gray-0" >}}强制推送本地分支{{< /text>}}
```
