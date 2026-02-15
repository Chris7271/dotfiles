# Vim + tmux + Glow Markdown 预览完全指南

> 适用于传统 Vim（非 Neovim）的 Markdown 实时预览解决方案

## 目录

- [简介](#简介)
- [环境要求](#环境要求)
- [快速开始](#快速开始)
- [实际配置（~/.vimrc）](#实际配置vimrc)
- [使用说明](#使用说明)
- [工作流程](#工作流程)
- [高级功能](#高级功能)
- [tmux 中复制文本](#tmux-中复制文本)
- [故障排查](#故障排查)
- [参考命令](#参考命令)

---

## 简介

### 什么是这个方案？

Vim + tmux + glow 组合可以实现：
- **左侧编辑，右侧预览** - 同屏显示，无需切换窗口
- **纯键盘操作** - 高效流畅的工作流
- **实时刷新** - 保存后一键更新预览
- **美观渲染** - glow 提供精美的终端渲染效果

### 为什么选择这个方案？

- ✅ 纯命令行环境，不需要浏览器
- ✅ 适用于传统 Vim（无需 Neovim）
- ✅ 轻量级，资源占用少
- ✅ 会话持久化，断线可恢复

---

## 环境要求

### 必需组件

| 组件 | 版本要求 | 说明 |
|------|----------|------|
| Vim | ≥ 7.4 | 传统 Vim（建议 8.0+） |
| tmux | ≥ 2.0 | 终端复用器 |
| glow | ≥ 1.0 | Markdown 渲染工具 |

### 检查当前环境

```bash
# 检查 Vim 版本
vim --version | head -1

# 检查 tmux 是否安装
tmux -V

# 检查 glow 是否安装
glow --version
```

---

## 快速开始

### 第一步：安装所需工具

#### 安装 tmux

```bash
sudo apt update
sudo apt install tmux
```

#### 安装 glow

```bash
# 方法 1: 使用官方源（推荐）
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update && sudo apt install glow

# 方法 2: 下载二进制文件
wget https://github.com/charmbracelet/glow/releases/download/v1.5.1/glow_1.5.1_linux_amd64.tar.gz
tar -xzf glow_1.5.1_linux_amd64.tar.gz
sudo mv glow /usr/local/bin/
rm glow_1.5.1_linux_amd64.tar.gz
```

### 第二步：Vim 配置已就绪

Markdown 预览配置已写入 `~/.vimrc`，无需手动操作。

### 第三步：体验工作流

```bash
# 1. 启动 tmux
tmux new -s writing

# 2. 打开 Markdown 文件
vim README.md

# 3. 在 Vim 中按 \p 打开右侧预览
# 4. 编辑内容，:w 保存后按 \r 刷新预览
# 5. 完成后按 \q 关闭预览
```

---

## 实际配置（~/.vimrc）

以下是已写入 `~/.vimrc` 的 Markdown 预览配置：

```vim
" ============================================
" Markdown 预览（Vim + tmux + glow）
" ============================================
"
" 快捷键说明（leader 键默认为 \）：
"
" --- 基础预览 ---
"   F5         全屏预览当前文件（任何环境可用）
"
" --- tmux 集成（需要在 tmux 中使用）---
"   \p         右侧窗格预览（50% 宽度）
"   \P         下方窗格预览（30% 高度）
"   \r         刷新右侧预览（编辑后更新）
"   \q         关闭预览窗格
"   \w         在新 tmux 窗口预览
"
" --- 主题切换 ---
"   \md        深色主题预览
"   \ml        浅色主题预览
"
" ============================================

" 基础预览（任何环境可用）
nnoremap <F5> :!glow -p %<CR>

" tmux 集成
if exists('$TMUX')
  " 右侧窗格预览（50% 宽度）
  nnoremap <leader>p :silent !tmux split-window -h -l 50\% 'glow -p %'<CR>:redraw!<CR>

  " 下方窗格预览（30% 高度）
  nnoremap <leader>P :silent !tmux split-window -v -l 30\% 'glow -p %'<CR>:redraw!<CR>

  " 在新 tmux 窗口预览
  nnoremap <leader>w :silent !tmux new-window 'glow -p %'<CR>:redraw!<CR>

  " 刷新右侧预览
  nnoremap <leader>r :silent !tmux send-keys -t right 'glow -p %' Enter<CR>:redraw!<CR>

  " 关闭预览窗格
  nnoremap <leader>q :silent !tmux kill-pane -t right<CR>:redraw!<CR>

  " 深色主题预览
  nnoremap <leader>md :silent !tmux split-window -h -l 50\% 'glow -s dark -p %'<CR>:redraw!<CR>

  " 浅色主题预览
  nnoremap <leader>ml :silent !tmux split-window -h -l 50\% 'glow -s light -p %'<CR>:redraw!<CR>

  " 保存时自动刷新预览（取消注释启用）
  " autocmd BufWritePost *.md silent! !tmux send-keys -t right 'glow -p %' Enter

  " 打开 Markdown 文件时显示帮助
  autocmd FileType markdown echo "[Markdown] \\p 预览 | \\r 刷新 | \\q 关闭 | F5 全屏 | \\md 深色 | \\ml 浅色"
else
  " 不在 tmux 中时提示
  autocmd FileType markdown echo "[Markdown] F5 预览 | 在 tmux 中使用可获得分屏预览体验"
endif
```

### 配置说明

#### leader 键

Vim 的 leader 键默认为 `\`（反斜杠）。所有 `\` 开头的快捷键都需要先按 `\` 再按后续键。

例如：`\p` = 先按 `\`，再按 `p`

#### 环境自适应

配置会自动检测当前环境：

- **在 tmux 中**: 启用所有分屏预览功能，底部显示完整快捷键提示
- **不在 tmux 中**: 只启用 F5 全屏预览，底部提示使用 tmux

#### 命令解释

```vim
:silent !tmux split-window -h -l 50\% 'glow -p %'<CR>:redraw!<CR>
│       │                   │  │   │    │      │
│       │                   │  │   │    │      └─ % = 当前文件名（Vim 自动展开）
│       │                   │  │   │    └─ -p = glow 分页模式（可滚动）
│       │                   │  │   └─ 50\% = 占 50% 宽度（\% 转义，避免被 Vim 展开）
│       │                   │  └─ -l = 指定大小（tmux 3.1+）
│       │                   └─ -h = horizontal（左右分割）
│       └─ 执行外部 shell 命令
└─ 静默执行（不显示命令输出）

:redraw!<CR>
└─ 刷新 Vim 屏幕（避免显示错乱）
```

---

## 使用说明

### 快捷键一览

| 快捷键 | 功能 | 需要 tmux | 说明 |
|--------|------|-----------|------|
| `F5` | 全屏预览 | 否 | 任何环境可用 |
| `\p` | 右侧分屏预览 | 是 | 50% 宽度 |
| `\P` | 下方分屏预览 | 是 | 30% 高度 |
| `\r` | 刷新预览 | 是 | 编辑后更新右侧预览 |
| `\q` | 关闭预览窗格 | 是 | 关闭右侧预览 |
| `\w` | 新窗口预览 | 是 | 独立 tmux 窗口 |
| `\md` | 深色主题预览 | 是 | 右侧深色主题 |
| `\ml` | 浅色主题预览 | 是 | 右侧浅色主题 |

### 完整工作流演示

```bash
# 1. 启动 tmux
tmux new -s writing

# 2. 打开文件
vim README.md

# 3. 打开预览（按 \p）
#    屏幕变成：
#    ┌──────────────┬──────────────┐
#    │              │              │
#    │   Vim 编辑   │  glow 预览   │
#    │              │              │
#    └──────────────┴──────────────┘

# 4. 编辑内容
i                    # 进入插入模式
# 编写 Markdown...
Esc                  # 退出插入模式
:w                   # 保存文件

# 5. 刷新预览（按 \r）
#    右侧预览自动更新显示

# 6. 继续编辑 → 保存 → \r 刷新
#    重复这个循环...

# 7. 完成后关闭预览（按 \q）
```

### 提示信息

打开 Markdown 文件时，Vim 底部会自动显示可用快捷键提示：

- **在 tmux 中**: `[Markdown] \p 预览 | \r 刷新 | \q 关闭 | F5 全屏 | \md 深色 | \ml 浅色`
- **不在 tmux 中**: `[Markdown] F5 预览 | 在 tmux 中使用可获得分屏预览体验`

### 预览窗格大小调整

如果想调整预览窗格的宽度，修改 `~/.vimrc` 中 `-p` 后的数字：

```vim
" -p 30  = 30% 宽度（窄预览，更多编辑空间）
" -p 40  = 40% 宽度
" -p 50  = 50% 宽度（默认，左右各半）
" -p 60  = 60% 宽度（宽预览）
```

### 可选：保存时自动刷新

如果想保存文件时自动刷新预览（不用手动按 `\r`），编辑 `~/.vimrc`，找到这行取消注释：

```vim
" 改这行：
" autocmd BufWritePost *.md silent! !tmux send-keys -t right 'glow -p %' Enter

" 变成（去掉开头的 " ）：
autocmd BufWritePost *.md silent! !tmux send-keys -t right 'glow -p %' Enter
```

### 多文档切换

编辑不同文件时，预览窗格可以跟随切换：

```bash
# 在 Vim 中
:e file1.md    # 打开第一个文件
\p             # 打开预览

:e file2.md    # 切换到第二个文件
\r             # 刷新预览（显示 file2.md）

:e file3.md    # 切换到第三个文件
\r             # 刷新预览（显示 file3.md）
```

### tmux 配置

tmux 配置已写入 `~/.tmux.conf`，详细说明请参阅：
- `tmux-best-practices.md` - tmux 完整指南
- `tmux-shortcuts-reference.md` - tmux 快捷键速查表

---

## 工作流程

### 场景 1：新建文档编辑

```bash
# 1. 启动 tmux 会话
tmux new -s writing

# 2. 打开 Vim
vim document.md

# 3. 进入插入模式并编辑
i
# 输入内容...
# 按 Esc 退出插入模式

# 4. 保存文件
:w

# 5. 打开预览（按 ,p）
# 右侧自动显示渲染效果

# 6. 继续编辑
i
# 修改内容...
Esc
:w

# 7. 刷新预览（按 ,r）
```

### 场景 2：编辑现有项目

```bash
# 1. 进入项目目录
cd ~/projects/docs

# 2. 启动命名会话
tmux new -s docs-edit

# 3. 打开文档
vim README.md

# 4. 打开预览
# 在 Vim 中按 ,p

# 5. 工作完成后离开会话（后台保持）
# 按 Ctrl+b 然后按 d

# 6. 稍后继续工作
tmux attach -t docs-edit
```

### 场景 3：多文档切换

```bash
# 在 Vim 中
:e file1.md    # 打开第一个文件
,p             # 预览

:e file2.md    # 切换到第二个文件
,r             # 刷新预览（显示 file2.md）

:e file3.md    # 切换到第三个文件
,r             # 刷新预览
```

---

## 高级功能

### 自动化启动脚本

创建 `~/bin/md-edit.sh`：

```bash
#!/bin/bash
# Markdown 编辑环境启动脚本

if [ -z "$1" ]; then
  echo "用法: md-edit.sh <markdown文件>"
  exit 1
fi

FILE="$1"
SESSION="md-$(basename "$FILE" .md)"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach -t "$SESSION"
else
  tmux new-session -d -s "$SESSION"
  tmux send-keys -t "$SESSION" "vim $FILE" C-m
  sleep 0.5
  tmux split-window -h -t "$SESSION" -p 50
  tmux send-keys -t "$SESSION:0.1" "glow -p $FILE" C-m
  tmux select-pane -t "$SESSION:0.0"
  tmux attach -t "$SESSION"
fi
```

设置执行权限并使用：

```bash
chmod +x ~/bin/md-edit.sh
~/bin/md-edit.sh README.md
```

### 配置说明

#### Vim 命令解释

```vim
:silent !tmux split-window -h -l 50\% 'glow -p %'
│       │                   │  │   │    │      │
│       │                   │  │   │    │      └─ % = 当前文件名（Vim 自动展开）
│       │                   │  │   │    └─ -p = glow 分页模式
│       │                   │  │   └─ 50\% = 占 50% 宽度（\% 转义）
│       │                   │  └─ -l = 指定大小（tmux 3.1+）
│       │                   └─ -h = horizontal（左右分割）
│       └─ 执行外部 shell 命令
└─ 静默执行（不显示命令输出）

:redraw!<CR>
└─ 刷新 Vim 屏幕（避免显示错乱）
```

#### 窗格大小调整

```vim
" 调整预览窗格宽度
" -p 30  = 30% 宽度（窄）
" -p 40  = 40% 宽度
" -p 50  = 50% 宽度（默认）
" -p 60  = 60% 宽度（宽）

nnoremap <leader>p :silent !tmux split-window -h -p 40 'glow -p %'<CR>:redraw!<CR>
```

---

## tmux 中复制文本

在 tmux 中使用 Vim 编辑和 glow 预览时，经常需要复制终端中的内容。以下是两种常用方式：

### 鼠标复制

```bash
Shift+鼠标拖选 → Ctrl+Shift+C    # 复制到系统剪贴板
Ctrl+Shift+V                      # 粘贴
```

> **注意**：必须按住 Shift 再拖动鼠标，否则 tmux 会拦截鼠标事件。

### 键盘复制（Vim 风格）

```bash
Ctrl+b [          # 1. 进入复制模式
/搜索关键词        # 2. 搜索定位（可选）
v                 # 3. 开始选择
hjkl 或方向键      # 4. 扩展选区
y                 # 5. 复制
Ctrl+Shift+V      # 6. 在任何程序中粘贴（需 xclip）
```

### 安装 xclip（系统剪贴板支持）

默认情况下 `y` 只复制到 tmux 内部缓冲区。安装 xclip 后可复制到系统剪贴板：

```bash
sudo apt install xclip          # 安装
Ctrl+b r                        # 重载 tmux 配置使其生效
```

安装后，`y` 复制的内容可以用 `Ctrl+Shift+V` 粘贴到浏览器、编辑器等任何程序中。

---

## 故障排查

### 问题 1: "size missing" 或 "size invalid"

**原因**：tmux 3.1+ 版本中百分比语法变了，且 Vim 的 `%` 会被展开为文件名

**关键点**：
- tmux 3.1+ 使用 `-l 50%` 代替旧版的 `-p 50`
- 在 Vim 的 `:!` 命令中，`%` 会被自动展开为当前文件名
- 因此必须用 `\%` 转义百分号：`-l 50\%`

**正确写法**：
```vim
" 正确（\% 转义）
nnoremap <leader>p :silent !tmux split-window -h -l 50\% 'glow -p %'<CR>:redraw!<CR>

" 错误（50% 会被 Vim 展开为 50filename.md）
nnoremap <leader>p :silent !tmux split-window -h -l 50% 'glow -p %'<CR>:redraw!<CR>
```

### 问题 2: "failed to connect to server"

**原因**：不在 tmux 环境中

**解决方案**：
```bash
# 检查是否在 tmux 中
echo $TMUX
# 如果输出为空，说明不在 tmux 中

# 启动 tmux
tmux
# 然后再打开 Vim
```

### 问题 2: 快捷键不工作

**检查映射**：
```vim
" 在 Vim 中执行
:verbose map ,p
" 应该显示类似：
" n  ,p    * :silent !tmux split-window...
```

**解决方案**：
```bash
# 重新加载配置
vim ~/.vimrc
:source %
```

### 问题 3: 预览窗格位置错误

**调整窗格大小**：
```vim
" 修改 ~/.vimrc 中的百分比
nnoremap <leader>p :silent !tmux split-window -h -p 40 'glow -p %'<CR>:redraw!<CR>
```

### 问题 4: glow 命令未找到

**检查安装**：
```bash
which glow
# 如果无输出，说明未安装或不在 PATH 中

# 检查 PATH
echo $PATH

# 如果安装在 /usr/local/bin，确保在 PATH 中
export PATH="/usr/local/bin:$PATH"
```

### 问题 5: tmux 窗格无法切换

**使用鼠标**：
- 确保 `~/.tmux.conf` 中有 `set -g mouse on`
- 重新加载：`tmux source-file ~/.tmux.conf`

**使用键盘**：
```
Ctrl+b  然后按方向键
或
Alt+方向键（如果配置了）
```

---

## 参考命令

### Vim 快捷键

| 快捷键 | 功能 | 需要 tmux |
|--------|------|-----------|
| `F5` | 全屏预览 | 否 |
| `\p` | 右侧分屏预览（50% 宽度） | 是 |
| `\P` | 下方分屏预览（30% 高度） | 是 |
| `\r` | 刷新右侧预览 | 是 |
| `\q` | 关闭预览窗格 | 是 |
| `\w` | 新窗口预览 | 是 |
| `\md` | 深色主题预览 | 是 |
| `\ml` | 浅色主题预览 | 是 |

### tmux 基础命令

**会话管理**：
```bash
tmux                          # 新建会话
tmux new -s name              # 新建命名会话
tmux ls                       # 列出所有会话
tmux attach -t name           # 连接到会话
tmux kill-session -t name     # 关闭会话
```

**在 tmux 中（Ctrl+b 作为前缀键）**：

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+b %` | 垂直分割（左右） |
| `Ctrl+b "` | 水平分割（上下） |
| `Ctrl+b 方向键` | 切换窗格 |
| `Ctrl+b x` | 关闭当前窗格 |
| `Ctrl+b z` | 全屏/取消全屏 |
| `Ctrl+b d` | 离开会话（后台运行） |
| `Ctrl+b [` | 进入滚动模式（q 退出） |
| `Ctrl+b c` | 创建新窗口 |
| `Ctrl+b n` | 下一个窗口 |
| `Ctrl+b p` | 上一个窗口 |
| `Ctrl+b ,` | 重命名窗口 |

**自定义快捷键（需要配置）**：

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+b \|` | 垂直分割 |
| `Ctrl+b -` | 水平分割 |
| `Alt+方向键` | 切换窗格（无需前缀） |
| `Ctrl+b r` | 重载配置 |

### glow 命令行选项

```bash
glow file.md              # 快速预览
glow -p file.md           # 分页预览（可滚动）
glow -s dark file.md      # 深色主题
glow -s light file.md     # 浅色主题
glow -w 80 file.md        # 指定宽度为 80 列
glow                      # 交互式浏览器模式
```

---

## 附录

### 配置文件位置

| 文件 | 路径 | 说明 |
|------|------|------|
| Vim 配置 | `~/.vimrc` | Markdown 预览快捷键 |
| tmux 配置 | `~/.tmux.conf` | 窗格分割、快捷键等 |

**查看配置**：
```bash
vim ~/.vimrc          # 查看 Vim 配置
vim ~/.tmux.conf      # 查看 tmux 配置
```

### 相关文档

| 文档 | 说明 |
|------|------|
| `tmux-best-practices.md` | tmux 完整使用指南 |
| `tmux-shortcuts-reference.md` | tmux 快捷键速查表 |

### 学习资源

- **glow 官方文档**: https://github.com/charmbracelet/glow
- **tmux 官方文档**: https://github.com/tmux/tmux/wiki
- **Vim 文档**: `:help` 在 Vim 中查看

### 贡献与反馈

如有问题或建议，欢迎反馈改进本文档。

---

**文档版本**: 2.0
**最后更新**: 2026-02-15
**适用环境**: Ubuntu/Debian + Vim + tmux
