# Dotfiles - 一键部署开发环境

在新服务器上一键安装 tmux + vim + glow 工作环境。

## 快速安装

```bash
git clone git@github.com:<user>/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
bash install.sh
```

## 包含内容

### 配置文件

| 文件 | 说明 |
|------|------|
| `configs/.tmux.conf` | tmux 配置（快捷键、状态栏、插件、Vim 风格复制） |
| `configs/.vimrc` | Vim 配置（基础设置 + Markdown 预览集成） |
| `configs/bash_aliases` | Bash 别名（tmux、git、导航、Markdown 快捷命令） |

### 参考文档

| 文件 | 说明 |
|------|------|
| `docs/tmux-best-practices.md` | tmux 完整使用指南 |
| `docs/tmux-shortcuts-reference.md` | tmux 快捷键速查表 |
| `docs/vim-tmux-glow-guide.md` | Vim + tmux + glow Markdown 预览指南 |
| `docs/bash-aliases-guide.md` | Bash 别名速查手册 |

## install.sh 做了什么

1. **安装依赖**: tmux, vim, glow, xclip, git
2. **部署配置**: 备份已有配置（`.bak`），复制新配置到 `~/`
3. **别名注入**: 将 `bash_aliases` 追加到 `~/.bashrc`（标记避免重复）
4. **tmux 插件**: 克隆 TPM、tmux-resurrect、tmux-continuum
5. **复制文档**: 参考文档复制到 `~/projects/tools/docs/`

## 安装后验证

```bash
source ~/.bashrc          # 使别名生效
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
├── install.sh              # 一键安装脚本
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
