# Bash 别名速查手册

> 已配置在 `~/.bashrc` 中的所有自定义别名

## 目录

- [tmux 别名](#tmux-别名)
- [Vim + Markdown 别名](#vim--markdown-别名)
- [文件与导航别名](#文件与导航别名)
- [Git 别名](#git-别名)
- [其他别名](#其他别名)
- [自定义别名](#自定义别名)

---

## tmux 别名

### 会话管理

| 别名 | 等同于 | 说明 | 用法示例 |
|------|--------|------|----------|
| `tn` | `tmux new -s` | 创建命名会话 | `tn work` |
| `tl` | `tmux ls` | 列出所有会话 | `tl` |
| `ta` | `tmux attach` | 连接到最近的会话 | `ta` |
| `tat` | `tmux attach -t` | 连接到指定会话 | `tat work` |
| `tk` | `tmux kill-session -t` | 删除会话 | `tk work` |
| `td` | `tmux detach` | 断开当前会话 | `td` |
| `ts` | `tmux switch-client -t` | 在 tmux 内切换会话 | `ts other` |

### 日常工作流

```bash
# 早上开始工作
tl                        # 查看有哪些会话
ta                        # 快速连接到最近的会话
# 或连接到指定会话
tat work                  # 连接到名为 work 的会话
# 或创建新会话
tn work                   # 创建新会话

# 工作中需要切换项目
tn project-b              # 创建新会话
ts work                   # 切回 work 会话

# 下班
td                        # 断开会话（后台运行）

# 清理不用的会话
tl                        # 查看所有会话
tk old-project            # 删除不需要的
```

---

## Vim + Markdown 别名

| 别名 | 等同于 | 说明 | 用法示例 |
|------|--------|------|----------|
| `mdp` | `glow -p` | 预览 Markdown 文件 | `mdp README.md` |
| `mde` | `tmux new -s md vim` | 启动 Markdown 编辑环境 | `mde` |

### 使用示例

```bash
# 快速预览一个 Markdown 文件
mdp README.md

# 启动完整的 Markdown 编辑环境（tmux + vim）
mde

# 在 vim 中按 ,p 可以打开 glow 预览
```

---

## 文件与导航别名

### 目录导航

| 别名 | 等同于 | 说明 |
|------|--------|------|
| `..` | `cd ..` | 上一级目录 |
| `...` | `cd ../..` | 上两级目录 |
| `....` | `cd ../../..` | 上三级目录 |
| `cls` | `clear` | 清屏 |

### 文件列表（系统预置）

| 别名 | 等同于 | 说明 |
|------|--------|------|
| `ll` | `ls -lF` | 长格式列表 |
| `lla` | `ls -alF` | 长格式（含隐藏文件） |
| `llh` | `ls -alFh` | 长格式（人类可读大小） |
| `la` | `ls -Ah` | 列出所有文件 |
| `l` | `ls -CFh` | 简洁列表 |

### 使用示例

```bash
# 快速跳转
..                        # 上一级
...                       # 上两级

# 查看文件
ll                        # 长格式列表
llh                       # 含文件大小（KB/MB/GB）

# 清屏
cls
```

---

## Git 别名

### 常用操作

| 别名 | 等同于 | 说明 | 用法示例 |
|------|--------|------|----------|
| `gs` | `git status` | 查看状态 | `gs` |
| `ga` | `git add` | 添加文件 | `ga file.txt` 或 `ga .` |
| `gc` | `git commit -m` | 提交 | `gc "fix bug"` |
| `gp` | `git push` | 推送 | `gp` |
| `gd` | `git diff` | 查看差异 | `gd` |
| `gl` | `git log --oneline -10` | 查看最近10条日志 | `gl` |
| `gco` | `git checkout` | 切换分支 | `gco main` |
| `gb` | `git branch` | 查看/创建分支 | `gb` 或 `gb new-feature` |

### 日常 Git 工作流

```bash
# 查看当前状态
gs

# 查看改了什么
gd

# 添加并提交
ga .
gc "add new feature"

# 推送到远程
gp

# 查看提交历史
gl

# 切换分支
gb                        # 查看所有分支
gco develop               # 切换到 develop
gco -b new-feature        # 创建并切换到新分支
```

### 完整开发流程示例

```bash
# 1. 开始新功能
gco -b feature/login      # 创建新分支

# 2. 开发中
gs                         # 随时查看状态
gd                         # 查看改动

# 3. 提交
ga .                       # 暂存所有改动
gc "implement login page"  # 提交

# 4. 推送
gp                         # 推送到远程

# 5. 完成后切回主分支
gco main
```

---

## 其他别名

### Claude Code

| 别名 | 说明 |
|------|------|
| `claude` | 启动 Claude Code（跳过权限确认） |

### Provider 切换

| 别名 | 说明 |
|------|------|
| `use-openrouter` | 切换到 OpenRouter |
| `use-subscription` | 切换到订阅模式 |
| `which-provider` | 查看当前 Provider |

---

## 自定义别名

### 如何添加新别名

编辑 `~/.bashrc`：

```bash
vim ~/.bashrc
```

在文件末尾添加：

```bash
alias 别名='完整命令'
```

使其生效：

```bash
source ~/.bashrc
```

### 示例

```bash
# 快速进入常用目录
alias proj='cd ~/projects'
alias docs='cd ~/documents'

# 快速编辑配置文件
alias vimrc='vim ~/.vimrc'
alias bashrc='vim ~/.bashrc'
alias tmuxconf='vim ~/.tmux.conf'
```

### 查看所有已定义的别名

```bash
alias
```

### 查看特定别名

```bash
alias gs
# 输出：alias gs='git status'
```

### 临时取消别名

```bash
# 在命令前加 \
\ls                       # 使用原始 ls 而非别名
```

---

## 别名完整列表

### 自定义别名一览

```bash
# tmux
tn    = tmux new -s             # 创建会话
tl    = tmux ls                 # 列出会话
ta    = tmux attach             # 快速连接最近会话
tat   = tmux attach -t          # 连接指定会话
tk    = tmux kill-session -t    # 删除会话
td    = tmux detach             # 断开会话
ts    = tmux switch-client -t   # 切换会话

# Vim + Markdown
mdp   = glow -p                 # 预览 Markdown
mde   = tmux new -s md vim      # 编辑环境

# 导航
..    = cd ..                   # 上一级
...   = cd ../..                # 上两级
....  = cd ../../..             # 上三级
cls   = clear                   # 清屏

# Git
gs    = git status              # 查看状态
ga    = git add                 # 暂存文件
gc    = git commit -m           # 提交
gp    = git push                # 推送
gd    = git diff                # 查看差异
gl    = git log --oneline -10   # 最近日志
gco   = git checkout            # 切换分支
gb    = git branch              # 分支管理
```

---

**配置文件位置**: `~/.bashrc`
**更新日期**: 2026-02-15
