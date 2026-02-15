# tmux 使用最佳实践指南

> 从入门到精通的完整 tmux 参考文档

## 目录

- [核心概念](#核心概念)
- [安装与配置](#安装与配置)
- [常用命令速查](#常用命令速查)
- [最佳实践](#最佳实践)
- [实用场景](#实用场景)
- [高级技巧](#高级技巧)
- [快捷键完整参考](#快捷键完整参考)
- [故障排查](#故障排查)

---

## 核心概念

### tmux 三层结构

```
会话 (Session)
└── 窗口 (Window)
    └── 窗格 (Pane)
```

| 层级 | 说明 | 类比 |
|------|------|------|
| **会话 (Session)** | 一组窗口的集合，可以后台运行 | 浏览器进程 |
| **窗口 (Window)** | 全屏的工作区，类似标签页 | 浏览器标签 |
| **窗格 (Pane)** | 窗口的分割区域 | 分屏显示 |

### 前缀键 (Prefix Key)

- **默认前缀键**: `Ctrl+b`
- **使用方式**: 先按 `Ctrl+b`，释放，再按功能键
- **示例**: 分割窗口 → `Ctrl+b` 然后按 `%`

### 为什么使用 tmux？

✅ **会话持久化** - SSH 断线后工作不丢失
✅ **多任务管理** - 一个终端窗口管理多个任务
✅ **屏幕分割** - 同时查看多个程序输出
✅ **结对编程** - 多人共享同一会话
✅ **提高效率** - 纯键盘操作，无需鼠标

---

## 安装与配置

### 安装 tmux

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install tmux

# CentOS/RHEL
sudo yum install tmux

# macOS
brew install tmux

# 验证安装
tmux -V
```

### 基础配置文件 (~/.tmux.conf)

创建配置文件：

```bash
vim ~/.tmux.conf
```

**推荐的基础配置**：

```bash
# ============================================
# tmux 基础配置
# ============================================

# === 常规设置 ===

# 启用鼠标支持
set -g mouse on

# 历史记录行数
set-option -g history-limit 10000

# 从 1 开始编号（0 太远）
set -g base-index 1
setw -g pane-base-index 1

# 自动重新编号窗口
set -g renumber-windows on

# 减少 ESC 延迟（Vim 用户必备）
set -sg escape-time 0

# 刷新状态栏间隔（秒）
set -g status-interval 5

# === 快捷键绑定 ===

# 改变前缀键为 Ctrl+a（可选，更舒适）
# set-option -g prefix C-a
# unbind C-b
# bind C-a send-prefix

# 重载配置文件
bind r source-file ~/.tmux.conf \; display "配置已重载！"

# 更直观的分割键
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# 新窗口保持当前路径
bind c new-window -c "#{pane_current_path}"

# Vim 风格的窗格切换
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Alt+方向键切换窗格（无需前缀键）
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Shift+方向键切换窗口
bind -n S-Left previous-window
bind -n S-Right next-window

# 快速调整窗格大小
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# === 状态栏美化 ===

# 状态栏颜色
set -g status-bg colour235
set -g status-fg colour255

# 状态栏左侧
set -g status-left-length 50
set -g status-left "#[fg=colour39,bold]#S #[fg=colour245]| "

# 状态栏右侧
set -g status-right-length 100
set -g status-right "#[fg=colour245]%Y-%m-%d #[fg=colour255,bold]%H:%M #[fg=colour245]| #[fg=colour39]#H"

# 窗口列表样式
setw -g window-status-format "#[fg=colour245] #I:#W "
setw -g window-status-current-format "#[fg=colour39,bold] #I:#W "

# 活动窗口通知
setw -g monitor-activity on
set -g visual-activity off

# === 其他优化 ===

# 支持 256 色
set -g default-terminal "screen-256color"

# 允许窗口重命名
setw -g allow-rename off
setw -g automatic-rename off

# 调整消息显示时间
set -g display-time 2000
set -g display-panes-time 2000
```

**应用配置**：

```bash
# 在 tmux 外
tmux source-file ~/.tmux.conf

# 在 tmux 内
Ctrl+b :source-file ~/.tmux.conf
# 或使用快捷键（如果配置了）
Ctrl+b r
```

---

## 常用命令速查

### 会话管理

#### 创建会话

```bash
# 创建新会话
tmux

# 创建命名会话
tmux new -s work
tn work                       # Bash 别名，等同于上面

# 创建会话并指定窗口名
tmux new -s work -n editor

# 创建会话但不进入
tmux new -s work -d
```

#### 查看会话

```bash
# 列出所有会话
tmux ls
tl                            # Bash 别名，等同于上面

# 在 tmux 内查看
Ctrl+b s
```

#### 连接会话

```bash
# 连接到最近的会话
tmux attach
ta                            # Bash 别名，等同于上面

# 连接到指定会话
tmux attach -t work
tat work                      # Bash 别名，等同于上面

# 连接并断开其他客户端
tmux attach -dt work
```

#### 断开会话

```bash
# 断开当前会话（会话继续后台运行）
Ctrl+b d

# 断开其他客户端
Ctrl+b D
```

#### 删除会话

```bash
# 删除指定会话
tmux kill-session -t work
tk work                       # Bash 别名，等同于上面

# 删除所有会话（除了当前）
tmux kill-session -a

# 删除所有会话
tmux kill-server
```

#### Bash 别名速查

以下别名已配置在 `~/.bashrc` 中：

| 别名 | 等同于 | 用法示例 |
|------|--------|----------|
| `tn` | `tmux new -s` | `tn work` |
| `tl` | `tmux ls` | `tl` |
| `ta` | `tmux attach` | `ta` |
| `tat` | `tmux attach -t` | `tat work` |
| `tk` | `tmux kill-session -t` | `tk work` |

#### 重命名会话

```bash
# 命令行重命名
tmux rename-session -t old-name new-name

# 在 tmux 内
Ctrl+b $
```

#### 切换会话

```bash
# 在 tmux 内切换
Ctrl+b s       # 列表选择
Ctrl+b (       # 上一个会话
Ctrl+b )       # 下一个会话
```

### 窗口管理

#### 创建窗口

```bash
Ctrl+b c       # 创建新窗口
Ctrl+b ,       # 重命名当前窗口
```

#### 切换窗口

```bash
Ctrl+b 0-9     # 切换到指定编号的窗口
Ctrl+b n       # 下一个窗口
Ctrl+b p       # 上一个窗口
Ctrl+b l       # 最后使用的窗口
Ctrl+b w       # 窗口列表选择

# 如果配置了（见上面配置）
Shift+Left     # 上一个窗口（无需前缀）
Shift+Right    # 下一个窗口（无需前缀）
```

#### 关闭窗口

```bash
Ctrl+b &       # 关闭当前窗口（会确认）
exit           # 在窗口内输入 exit
Ctrl+d         # 在窗口内按 Ctrl+d
```

#### 查找窗口

```bash
Ctrl+b f       # 根据名称查找窗口
```

#### 移动与互换窗口

```bash
Ctrl+b .       # 与指定编号窗口互换（提示输入目标编号）
Ctrl+b <       # 当前窗口向左移一位（与左边窗口互换）
Ctrl+b >       # 当前窗口向右移一位（与右边窗口互换）

# 命令模式互换（Ctrl+b : 进入）
swap-window -s 2 -t 4     # 将窗口2和窗口4互换
move-window -t 3           # 移动当前窗口到编号3
```

**互换示例**：
```bash
# 场景：窗口1和窗口5互换
# 在窗口1中按 Ctrl+b . → 输入5 → 回车

# 场景：窗口3和窗口4互换（相邻）
# 在窗口3中按 Ctrl+b >
```

### 窗格管理

#### 分割窗格

```bash
# 默认键
Ctrl+b %       # 垂直分割（左右）
Ctrl+b "       # 水平分割（上下）

# 自定义键（需要配置）
Ctrl+b |       # 垂直分割
Ctrl+b -       # 水平分割
```

#### 切换窗格

```bash
Ctrl+b o       # 下一个窗格
Ctrl+b ;       # 上次使用的窗格
Ctrl+b 方向键   # 切换到指定方向的窗格
Ctrl+b q       # 显示窗格编号（然后按数字切换）

# 自定义键（需要配置）
Ctrl+b h/j/k/l # Vim 风格切换
Alt+方向键      # 直接切换（无需前缀）
```

#### 调整窗格大小

```bash
# 默认方式
Ctrl+b Ctrl+方向键    # 每次调整 1 单元
Ctrl+b Alt+方向键     # 每次调整 5 单元

# 自定义键（需要配置）
Ctrl+b H/J/K/L       # 调整大小
```

#### 关闭窗格

```bash
Ctrl+b x       # 关闭当前窗格（会确认）
exit           # 在窗格内输入 exit
Ctrl+d         # 在窗格内按 Ctrl+d
```

#### 窗格布局

```bash
Ctrl+b Space   # 循环切换预设布局
Ctrl+b Alt+1   # 水平平铺
Ctrl+b Alt+2   # 垂直平铺
Ctrl+b Alt+3   # 主窗格在左，其他在右垂直排列
Ctrl+b Alt+4   # 主窗格在上，其他在下水平排列
Ctrl+b Alt+5   # 平铺布局
```

#### 窗格操作

```bash
Ctrl+b z       # 全屏/取消全屏当前窗格
Ctrl+b !       # 将当前窗格分离为新窗口
Ctrl+b {       # 窗格左移/上移
Ctrl+b }       # 窗格右移/下移
Ctrl+b Ctrl+o  # 所有窗格向前轮换
Ctrl+b Alt+o   # 所有窗格向后轮换
```

### 复制模式

#### 两种复制方式

**方式一：鼠标复制（简单快捷）**

```bash
# 按住 Shift 拖动鼠标选择文本，然后：
Shift+鼠标拖选 → Ctrl+Shift+C    # 复制到系统剪贴板
Ctrl+Shift+V                      # 粘贴
```

**方式二：键盘复制（Vim 风格，推荐）**

```bash
Ctrl+b [       # 进入复制模式（滚动模式）
v              # 开始选择（Vim 风格，需配置 mode-keys vi）
V              # 行选择
y              # 复制选中内容（需安装 xclip 才能复制到系统剪贴板）
Ctrl+b ]       # 粘贴（tmux 内部粘贴）
Ctrl+Shift+V   # 粘贴到任何程序（系统剪贴板）
```

#### xclip 与系统剪贴板

安装 xclip 后，`y` 键会同时复制到系统剪贴板，可以粘贴到任何程序：

```bash
# 安装 xclip（系统剪贴板支持）
sudo apt install xclip

# 安装后重载 tmux 配置使其生效
Ctrl+b r       # 或 tmux source-file ~/.tmux.conf
```

**有无 xclip 的区别**：

| | 未安装 xclip | 已安装 xclip |
|---|---|---|
| `y` 复制到 | 仅 tmux 内部缓冲区 | tmux 缓冲区 + 系统剪贴板 |
| `Ctrl+b ]` 粘贴 | 可用 | 可用 |
| `Ctrl+Shift+V` 粘贴 | 不可用 | 可用（任何程序） |

#### 实用复制工作流

```bash
# 完整流程：搜索并复制终端中的内容
Ctrl+b [          # 1. 进入复制模式
/搜索关键词        # 2. 搜索定位到目标内容
v                 # 3. 按 v 开始选择
hjkl 或方向键      # 4. 移动光标扩展选区
y                 # 5. 复制（自动退出复制模式）
Ctrl+Shift+V      # 6. 在任何地方粘贴（需要 xclip）
```

#### 复制模式内导航

```bash
# 在复制模式中
q              # 退出复制模式
g              # 跳到顶部
G              # 跳到底部
/              # 向下搜索
?              # 向上搜索
n              # 下一个搜索结果
N              # 上一个搜索结果
h/j/k/l        # Vim 风格移动
w/b            # 按单词跳转
0/$            # 行首/行尾
```

### 其他常用命令

```bash
Ctrl+b ?       # 显示所有快捷键
Ctrl+b :       # 进入命令模式
Ctrl+b t       # 显示时钟
Ctrl+b i       # 显示当前窗格信息
```

---

## 最佳实践

### 1. 会话命名规范

**推荐的命名方式**：

```bash
# 按项目命名
tmux new -s project-frontend
tmux new -s project-backend

# 按功能命名
tmux new -s dev
tmux new -s monitor
tmux new -s debug

# 按客户命名
tmux new -s client-acme
tmux new -s client-beta
```

**避免**：
- 使用数字命名（难以记忆）
- 使用过长的名称
- 使用空格或特殊字符

### 2. 窗口组织策略

**典型的开发会话布局**：

```
会话: project-work
├── 窗口 0: editor      (Vim/编辑器)
├── 窗口 1: server      (本地服务器)
├── 窗口 2: git         (版本控制)
├── 窗口 3: test        (测试)
└── 窗口 4: monitor     (日志监控)
```

**创建脚本示例**：

```bash
#!/bin/bash
# 创建标准开发环境

SESSION="dev"

# 创建会话
tmux new-session -d -s $SESSION -n editor

# 窗口 0: 编辑器
tmux send-keys -t $SESSION:0 'cd ~/projects && vim' C-m

# 窗口 1: 服务器
tmux new-window -t $SESSION:1 -n server
tmux send-keys -t $SESSION:1 'cd ~/projects && npm run dev' C-m

# 窗口 2: Git
tmux new-window -t $SESSION:2 -n git
tmux send-keys -t $SESSION:2 'cd ~/projects && git status' C-m

# 窗口 3: 测试
tmux new-window -t $SESSION:3 -n test

# 窗口 4: 监控
tmux new-window -t $SESSION:4 -n monitor
tmux send-keys -t $SESSION:4 'htop' C-m

# 回到第一个窗口
tmux select-window -t $SESSION:0

# 连接到会话
tmux attach -t $SESSION
```

### 3. 窗格分割原则

**推荐**：

```
┌─────────────┬──────┐
│             │      │
│   Editor    │ Logs │
│   (70%)     │ (30%)│
│             │      │
└─────────────┴──────┘
```

**避免过度分割**：

```
┌────┬────┬────┐
│    │    │    │  太碎，难以使用
├────┼────┼────┤
│    │    │    │
└────┴────┴────┘
```

**实用配置**：
- **两栏布局**: 编辑器 + 终端
- **三栏布局**: 编辑器 + 服务器 + 日志
- **上下布局**: 编辑器（上）+ 终端（下）

### 4. 工作流程最佳实践

#### 日常开发流程

```bash
# 早上开始工作
ta                          # 快速连接到最近的会话
# 或连接到指定会话
tat dev                     # 连接到 dev 会话
# 如果会话不存在，创建新会话
tat dev || tn dev

# 工作中
# - 使用窗口分离不同任务
# - 使用窗格并排查看

# 中午离开
Ctrl+b d    # 自动保存 + 断开会话

# 下午继续
ta          # 快速连接到最近的会话

# 晚上下班
Ctrl+b d    # 断开会话，会话状态自动保存
```

#### 远程服务器工作

```bash
# SSH 连接
ssh user@server

# 立即创建或连接 tmux
ta || tn work

# 即使 SSH 断线，tmux 会话仍在运行
# 重新连接后
ta                          # 快速连接到最近的会话
```

### 5. 快捷键记忆技巧

**按功能分组记忆**：

| 功能 | 快捷键 | 助记 |
|------|--------|------|
| **会话** | `s` | **S**ession |
| **窗口** | `c` | **C**reate |
| | `w` | **W**indow |
| | `,` | 重命名（逗号像编辑符号）|
| **窗格** | `%` | 垂直（%像竖线）|
| | `"` | 水平（"像横线）|
| | `o` | **O**ther pane |
| | `x` | 关闭（X表示删除）|
| **其他** | `?` | 帮助（问号）|
| | `d` | **D**etach |

### 6. 避免的反模式

❌ **不要嵌套 tmux**
```bash
# 错误：在 tmux 中启动 tmux
# 会导致快捷键冲突
```

❌ **不要过度依赖鼠标**
```bash
# 学习键盘快捷键，提高效率
```

❌ **不要忘记命名会话**
```bash
# 错误
tmux new

# 正确
tmux new -s project-name
```

❌ **不要直接关闭终端**
```bash
# 错误：直接关闭终端窗口
# 正确：使用 Ctrl+b d 断开会话
```

---

## 实用场景

### 场景 1: 开发 Web 应用

**目标**: 编辑器 + 前端服务器 + 后端服务器 + 数据库

```bash
#!/bin/bash
SESSION="webapp"

tmux new-session -d -s $SESSION

# 第一个窗口：编辑器
tmux rename-window -t $SESSION:0 'editor'
tmux send-keys -t $SESSION:0 'cd ~/webapp && vim' C-m

# 第二个窗口：前端 + 后端（上下分割）
tmux new-window -t $SESSION:1 -n 'servers'
tmux send-keys -t $SESSION:1 'cd ~/webapp/frontend && npm run dev' C-m
tmux split-window -v -t $SESSION:1
tmux send-keys -t $SESSION:1.1 'cd ~/webapp/backend && npm start' C-m

# 第三个窗口：数据库
tmux new-window -t $SESSION:2 -n 'database'
tmux send-keys -t $SESSION:2 'mysql -u root -p' C-m

# 第四个窗口：Git 和终端
tmux new-window -t $SESSION:3 -n 'git'
tmux send-keys -t $SESSION:3 'cd ~/webapp && git status' C-m

tmux select-window -t $SESSION:0
tmux attach -t $SESSION
```

### 场景 2: 系统监控

**目标**: 同时监控 CPU、内存、网络、日志

```bash
#!/bin/bash
SESSION="monitor"

tmux new-session -d -s $SESSION -n 'system'

# 四分割布局
tmux send-keys -t $SESSION:0 'htop' C-m
tmux split-window -h -t $SESSION:0
tmux send-keys -t $SESSION:0.1 'watch -n 1 free -h' C-m
tmux split-window -v -t $SESSION:0.0
tmux send-keys -t $SESSION:0.2 'sudo iftop' C-m
tmux split-window -v -t $SESSION:0.1
tmux send-keys -t $SESSION:0.3 'tail -f /var/log/syslog' C-m

tmux select-pane -t $SESSION:0.0
tmux attach -t $SESSION
```

**布局示意**：
```
┌──────────┬──────────┐
│  htop    │  memory  │
├──────────┼──────────┤
│ network  │   logs   │
└──────────┴──────────┘
```

### 场景 3: 结对编程

**会话共享**：

```bash
# 程序员 A 创建会话
tmux new -s pair-programming

# 程序员 B 加入（只读）
tmux attach -t pair-programming -r

# 程序员 B 加入（可操作）
tmux attach -t pair-programming
```

### 场景 4: 长时间运行任务

**场景**: 需要运行几小时的任务（编译、备份等）

```bash
# 创建专用会话
tmux new -s long-task

# 运行任务
./long-running-script.sh

# 断开会话
Ctrl+b d

# 可以关闭 SSH 或终端
# 稍后检查进度
tmux attach -t long-task
```

### 场景 5: 多项目切换

**快速切换脚本** (`~/bin/tmux-switch.sh`):

```bash
#!/bin/bash

# 项目列表
projects=("project-a" "project-b" "project-c")

echo "选择项目："
select project in "${projects[@]}"; do
  if [ -n "$project" ]; then
    tmux attach -t "$project" || tmux new -s "$project" -c ~/projects/$project
    break
  fi
done
```

---

## 高级技巧

### 1. 自定义布局保存与恢复

**保存布局**：

```bash
# 在 tmux 中查看当前布局
tmux list-windows

# 示例输出
# 0: editor* (3 panes) [239x59] [layout 5d9e,239x59,0,0{179x59,0,0,0,59x59,180,0[59x29,180,0,1,59x29,180,30,2]}]

# 复制 [layout ...] 中的内容
```

**恢复布局**：

```bash
tmux select-layout "5d9e,239x59,0,0{179x59,0,0,0,59x59,180,0[59x29,180,0,1,59x29,180,30,2]}"
```

### 2. tmux 脚本化

**高级启动脚本** (`~/.tmux/dev-env.sh`):

```bash
#!/bin/bash

SESSION=$1

if [ -z "$SESSION" ]; then
  echo "用法: $0 <session-name>"
  exit 1
fi

# 检查会话是否存在
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
  # 创建新会话
  tmux new-session -d -s $SESSION

  # 设置窗口
  tmux rename-window -t $SESSION:0 'editor'
  tmux new-window -t $SESSION:1 -n 'server'
  tmux new-window -t $SESSION:2 -n 'git'
  tmux new-window -t $SESSION:3 -n 'test'

  # 窗口 0: 编辑器布局
  tmux send-keys -t $SESSION:0 'vim' C-m
  tmux split-window -h -t $SESSION:0 -p 30
  tmux send-keys -t $SESSION:0.1 'echo "Ready"' C-m

  # 窗口 1: 服务器
  tmux send-keys -t $SESSION:1 'echo "Starting server..."' C-m

  # 选择默认窗口
  tmux select-window -t $SESSION:0
  tmux select-pane -t $SESSION:0.0
fi

# 连接到会话
tmux attach -t $SESSION
```

**使用**：
```bash
chmod +x ~/.tmux/dev-env.sh
~/.tmux/dev-env.sh my-project
```

### 3. 窗格同步

**同时在多个窗格执行命令**：

```bash
# 开启同步
Ctrl+b :setw synchronize-panes on

# 现在所有窗格会同时接收输入
# 适用于同时操作多台服务器

# 关闭同步
Ctrl+b :setw synchronize-panes off
```

**配置快捷键**：
```bash
# 在 ~/.tmux.conf 添加
bind S setw synchronize-panes
```

### 4. 日志记录

**记录窗格输出**：

```bash
# 开始记录
Ctrl+b :pipe-pane -o 'cat >> ~/tmux-#S-#I-#P.log'

# 停止记录
Ctrl+b :pipe-pane
```

**配置快捷键**：
```bash
# 在 ~/.tmux.conf 添加
bind P pipe-pane -o "cat >>~/#W.log" \; display "Toggled logging to ~/#W.log"
```

### 5. 插件管理 (TPM)

**安装 TPM**：

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

**配置** (`~/.tmux.conf`):

```bash
# 插件列表
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'      # 会话保存/恢复
set -g @plugin 'tmux-plugins/tmux-continuum'      # 自动保存会话
set -g @plugin 'tmux-plugins/tmux-yank'           # 复制增强

# 自动保存会话间隔（分钟）
set -g @continuum-save-interval '15'

# 自动恢复会话
set -g @continuum-restore 'on'

# 初始化 TPM（保持在配置文件底部）
run '~/.tmux/plugins/tpm/tpm'
```

**使用**：
- 安装插件: `Ctrl+b I`
- 更新插件: `Ctrl+b U`
- 卸载插件: `Ctrl+b Alt+u`

### 6. 会话持久化（tmux-resurrect + tmux-continuum）

上面配置的 tmux-resurrect 和 tmux-continuum 插件配合使用，可以实现会话的完整保存与恢复，即使系统重启也不会丢失工作环境。

#### 手动操作

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Ctrl+b Ctrl+s` | 手动保存会话 | 保存所有会话、窗口、窗格布局 |
| `Ctrl+b Ctrl+r` | 手动恢复会话 | 从最近的保存中恢复 |

#### 自动化行为

- **自动保存**: tmux-continuum 每 **15 分钟**自动保存一次会话状态
- **自动恢复**: tmux 服务启动时自动恢复上次保存的会话（`@continuum-restore 'on'`）
- **断开时自动保存**: `Ctrl+b d` 断开会话时会自动触发保存

#### Ubuntu 重启后恢复工作环境

```bash
# 重启后，直接运行：
ta                            # tmux 自动恢复所有会话，连接到最近的会话

# 如果需要连接指定会话：
tl                            # 查看恢复后的会话列表
tat work                      # 连接到指定会话
```

#### 保存内容

tmux-resurrect 会保存以下内容：
- 所有会话及其名称
- 每个会话的窗口布局
- 窗格的工作目录
- 窗格中运行的程序（vim、htop 等）

### 7. 状态栏自定义

**显示系统信息**：

```bash
# ~/.tmux.conf

# CPU 使用率
set -g status-right "#[fg=colour39]CPU: #(top -bn1 | grep 'Cpu(s)' | awk '{print $2}')% "

# 内存使用
set -ag status-right "#[fg=colour245]| #[fg=colour39]MEM: #(free -h | awk '/^Mem/ {print $3\"/\"$2}') "

# 日期时间
set -ag status-right "#[fg=colour245]| #[fg=colour255]%Y-%m-%d %H:%M"
```

### 8. 快速跳转窗口

**配置数字键快速跳转**：

```bash
# ~/.tmux.conf
bind -n M-1 select-window -t :1
bind -n M-2 select-window -t :2
bind -n M-3 select-window -t :3
bind -n M-4 select-window -t :4
bind -n M-5 select-window -t :5
bind -n M-6 select-window -t :6
bind -n M-7 select-window -t :7
bind -n M-8 select-window -t :8
bind -n M-9 select-window -t :9
```

使用: `Alt+数字` 直接跳转（无需前缀键）

---

## 快捷键完整参考

### 会话操作

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+b d` | 断开会话 |
| `Ctrl+b D` | 选择要断开的会话 |
| `Ctrl+b (` | 切换到上一个会话 |
| `Ctrl+b )` | 切换到下一个会话 |
| `Ctrl+b s` | 列出所有会话 |
| `Ctrl+b $` | 重命名当前会话 |

### 窗口操作

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+b c` | 创建新窗口 |
| `Ctrl+b ,` | 重命名当前窗口 |
| `Ctrl+b &` | 关闭当前窗口 |
| `Ctrl+b n` | 下一个窗口 |
| `Ctrl+b p` | 上一个窗口 |
| `Ctrl+b 0-9` | 切换到指定窗口 |
| `Ctrl+b l` | 切换到上次使用的窗口 |
| `Ctrl+b w` | 窗口列表 |
| `Ctrl+b f` | 查找窗口 |
| `Ctrl+b .` | 与指定窗口互换 |
| `Ctrl+b <` | 窗口左移一位（互换） |
| `Ctrl+b >` | 窗口右移一位（互换） |

### 窗格操作

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+b %` | 垂直分割 |
| `Ctrl+b "` | 水平分割 |
| `Ctrl+b x` | 关闭窗格 |
| `Ctrl+b o` | 下一个窗格 |
| `Ctrl+b ;` | 上次使用的窗格 |
| `Ctrl+b 方向键` | 切换窗格 |
| `Ctrl+b q` | 显示窗格编号 |
| `Ctrl+b z` | 全屏/取消全屏 |
| `Ctrl+b !` | 窗格转为窗口 |
| `Ctrl+b {` | 窗格左移/上移 |
| `Ctrl+b }` | 窗格右移/下移 |
| `Ctrl+b Space` | 切换布局 |
| `Ctrl+b Ctrl+o` | 窗格向前轮换 |
| `Ctrl+b Alt+o` | 窗格向后轮换 |

### 窗格大小调整

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+b Ctrl+方向键` | 调整 1 单元 |
| `Ctrl+b Alt+方向键` | 调整 5 单元 |

### 复制模式

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+b [` | 进入复制模式 |
| `v` | 开始选择（Vim 风格） |
| `V` | 行选择 |
| `y` | 复制到剪贴板（需 xclip 才能复制到系统剪贴板） |
| `Ctrl+b ]` | 粘贴（tmux 内部） |
| `Ctrl+Shift+V` | 粘贴（系统剪贴板，需 xclip） |
| `Shift+鼠标拖选` | 鼠标选择文本（配合 `Ctrl+Shift+C` 复制） |
| `q` | 退出复制模式 |
| `g` / `G` | 跳到顶部 / 底部 |
| `/` / `?` | 向下 / 向上搜索 |
| `n` / `N` | 下一个 / 上一个搜索结果 |
| `h/j/k/l` | Vim 风格光标移动 |

> **提示**：安装 `xclip`（`sudo apt install xclip`）后按 `Ctrl+b r` 重载配置，`y` 即可复制到系统剪贴板。

### 其他

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+b ?` | 显示所有快捷键 |
| `Ctrl+b :` | 进入命令模式 |
| `Ctrl+b t` | 显示时钟 |
| `Ctrl+b i` | 显示当前窗格信息 |

---

## 故障排查

### 问题 1: 快捷键不工作

**检查前缀键**：
```bash
# 查看当前前缀键
tmux show-options -g | grep prefix
```

**重置配置**：
```bash
# 临时重置为默认
tmux source-file /etc/tmux.conf
```

### 问题 2: 颜色显示异常

**解决方案**：
```bash
# 在 ~/.tmux.conf 添加
set -g default-terminal "screen-256color"

# 或
set -g default-terminal "tmux-256color"
```

**测试颜色**：
```bash
# 256 色测试
for i in {0..255}; do
  printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
done
```

### 问题 3: 鼠标不工作

**启用鼠标**：
```bash
# 在 ~/.tmux.conf 添加
set -g mouse on

# 重载配置
tmux source-file ~/.tmux.conf
```

### 问题 4: 会话丢失

**列出所有会话**：
```bash
tl                            # 或 tmux ls
```

**恢复会话**：
```bash
# 如果 tmux 服务仍在运行，直接连接：
ta                            # 快速连接最近的会话

# 如果系统重启后（tmux-continuum 会自动恢复）：
ta                            # tmux 启动时自动恢复，直接连接即可

# 如果自动恢复失败，手动恢复：
Ctrl+b Ctrl+r                 # 使用 tmux-resurrect 手动恢复
```

### 问题 5: 复制粘贴问题

**配置系统剪贴板集成**：

```bash
# Ubuntu/Debian - 安装 xclip
sudo apt install xclip

# ~/.tmux.conf 添加
# Vim 风格复制
setw -g mode-keys vi
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
```

### 问题 6: ESC 键延迟（Vim 用户）

**减少延迟**：
```bash
# ~/.tmux.conf
set -sg escape-time 0
```

### 问题 7: 窗格标题不更新

**解决方案**：
```bash
# ~/.tmux.conf
setw -g allow-rename on
setw -g automatic-rename on
```

---

## 快速参考卡片

### 基础命令

```bash
# 会话
tmux                          # 新建会话
tmux new -s name              # 新建命名会话
tmux ls                       # 列出会话
tmux attach -t name           # 连接会话
tmux kill-session -t name     # 删除会话

# Bash 别名（已配置在 ~/.bashrc）
tn name                       # = tmux new -s name
tl                            # = tmux ls
ta                            # = tmux attach（连接最近的会话）
tat name                      # = tmux attach -t name（连接指定会话）
tk name                       # = tmux kill-session -t name

# 在 tmux 内
Ctrl+b d                      # 断开会话
Ctrl+b c                      # 新建窗口
Ctrl+b %                      # 垂直分割
Ctrl+b "                      # 水平分割
Ctrl+b 方向键                  # 切换窗格
Ctrl+b x                      # 关闭窗格
```

### 工作流程

1. **启动**: `tn work`（等同于 `tmux new -s work`）
2. **创建布局**: 分割窗格，创建窗口
3. **工作**: 正常使用
4. **离开**: `Ctrl+b d`（自动保存会话状态）
5. **回来**: `ta`（快速连接最近的会话）或 `tat work`（连接指定会话）
6. **重启后恢复**: `ta`（自动恢复所有会话）

---

## 学习资源

- **官方文档**: `man tmux` 或 https://github.com/tmux/tmux/wiki
- **快捷键帮助**: 在 tmux 中按 `Ctrl+b ?`
- **在线教程**: https://tmuxcheatsheet.com/

---

## 附录：完整配置示例

**下载配置模板**：

```bash
# 备份现有配置
mv ~/.tmux.conf ~/.tmux.conf.backup

# 复制本文档中的配置到 ~/.tmux.conf
vim ~/.tmux.conf
# 粘贴"基础配置文件"章节的内容

# 重载配置
tmux source-file ~/.tmux.conf
```

---

**文档版本**: 1.0
**最后更新**: 2026-02-15
**适用于**: tmux 2.0+
