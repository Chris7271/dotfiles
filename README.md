# Dotfiles - 一键部署开发环境

支持 macOS 和 Linux (Debian/Ubuntu)，一键安装 tmux + vim + glow 工作环境。

## 快速安装

```bash
git clone git@github.com:<user>/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
bash install.sh
```

脚本会自动检测操作系统，选择对应的安装方式：

| | macOS | Linux (Debian/Ubuntu) |
|---|---|---|
| 包管理器 | Homebrew（自动安装） | apt |
| 剪贴板 | pbcopy（系统自带） | xclip（自动安装） |
| Shell 配置 | ~/.zshrc | ~/.bashrc |

## 包含内容

### 配置文件

| 文件 | 说明 |
|------|------|
| `configs/.tmux.conf` | tmux 配置（快捷键、状态栏、插件、Vim 风格复制） |
| `configs/.vimrc` | Vim 配置（基础设置 + Markdown 预览集成） |
| `configs/bash_aliases` | Shell 别名（tmux、git、导航、Markdown 快捷命令） |

### 参考文档

| 文件 | 说明 |
|------|------|
| `docs/tmux-best-practices.md` | tmux 完整使用指南 |
| `docs/tmux-shortcuts-reference.md` | tmux 快捷键速查表 |
| `docs/vim-tmux-glow-guide.md` | Vim + tmux + glow Markdown 预览指南 |
| `docs/bash-aliases-guide.md` | 别名速查手册 |

## install.sh 做了什么

1. **检测环境**: 识别 macOS/Linux，macOS 自动安装 Homebrew
2. **安装依赖**: tmux, vim, glow, git（Linux 额外安装 xclip）
3. **部署配置**: 备份已有配置（`.bak`），复制新配置到 `~/`
4. **别名注入**: 将别名追加到 shell 配置文件（标记避免重复）
5. **tmux 插件**: 克隆 TPM、tmux-resurrect、tmux-continuum
6. **复制文档**: 参考文档复制到 `~/projects/tools/docs/`

## 安装后验证

```bash
# macOS
source ~/.zshrc

# Linux
source ~/.bashrc

# 通用验证
tmux -V                   # 验证 tmux
glow --version            # 验证 glow
tl                        # 测试别名
tn test                   # 创建 tmux 会话
vim test.md               # 在 tmux 中按 ,p 预览
```

## 常用别名

```bash
# tmux
tn work       # 创建会话
tl            # 列出会话
ta            # 连接最近会话
tat work      # 连接指定会话
tk work       # 删除会话

# git
gs            # git status
ga .          # git add .
gc "msg"      # git commit -m "msg"
gp            # git push
gl            # git log --oneline -10

# 导航
..            # cd ..
cls           # clear

# Markdown
mdp file.md   # glow 预览
```

## 目录结构

```
dotfiles/
├── install.sh              # 一键安装脚本（macOS / Linux）
├── README.md               # 本文件
├── configs/
│   ├── .tmux.conf          # tmux 配置
│   ├── .vimrc              # vim 配置
│   └── bash_aliases        # 自定义别名
└── docs/
    ├── tmux-best-practices.md
    ├── tmux-shortcuts-reference.md
    ├── vim-tmux-glow-guide.md
    └── bash-aliases-guide.md
```
