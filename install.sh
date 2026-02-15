#!/bin/bash
# ============================================
# dotfiles 一键安装脚本
# ============================================
#
# 用法: bash install.sh
#
# 功能:
#   1. 安装依赖工具 (tmux, vim, glow, xclip, git)
#   2. 部署配置文件 (.tmux.conf, .vimrc, bash_aliases)
#   3. 安装 tmux 插件 (TPM, tmux-resurrect, tmux-continuum)
#   4. 复制参考文档
#   5. 显示安装结果摘要
#
# ============================================

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 标记，用于避免重复追加别名
ALIAS_MARKER="# >>> dotfiles bash_aliases >>>"
ALIAS_MARKER_END="# <<< dotfiles bash_aliases <<<"

# 结果跟踪
RESULTS=()

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
    RESULTS+=("${GREEN}✓${NC} $1")
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    RESULTS+=("${YELLOW}!${NC} $1")
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    RESULTS+=("${RED}✗${NC} $1")
}

# ============================================
# 1. 安装依赖工具
# ============================================
install_dependencies() {
    log_info "正在安装依赖工具..."

    sudo apt update -qq

    # 安装基础工具
    for pkg in tmux vim xclip git; do
        if dpkg -l "$pkg" &>/dev/null; then
            log_success "$pkg 已安装"
        else
            log_info "正在安装 $pkg..."
            if sudo apt install -y -qq "$pkg"; then
                log_success "$pkg 安装成功"
            else
                log_error "$pkg 安装失败"
            fi
        fi
    done

    # 安装 glow（需要添加 charm 源）
    if command -v glow &>/dev/null; then
        log_success "glow 已安装"
    else
        log_info "正在安装 glow..."
        sudo mkdir -p /etc/apt/keyrings
        if curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg 2>/dev/null; then
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
            sudo apt update -qq
            if sudo apt install -y -qq glow; then
                log_success "glow 安装成功"
            else
                log_error "glow 安装失败，请手动安装: https://github.com/charmbracelet/glow"
            fi
        else
            log_error "glow 源添加失败，请手动安装: https://github.com/charmbracelet/glow"
        fi
    fi
}

# ============================================
# 2. 部署配置文件
# ============================================
deploy_configs() {
    log_info "正在部署配置文件..."

    # 部署 .tmux.conf
    if [ -f ~/.tmux.conf ]; then
        cp ~/.tmux.conf ~/.tmux.conf.bak
        log_warn "已备份 ~/.tmux.conf → ~/.tmux.conf.bak"
    fi
    cp "$SCRIPT_DIR/configs/.tmux.conf" ~/.tmux.conf
    log_success ".tmux.conf 已部署"

    # 部署 .vimrc
    if [ -f ~/.vimrc ]; then
        cp ~/.vimrc ~/.vimrc.bak
        log_warn "已备份 ~/.vimrc → ~/.vimrc.bak"
    fi
    cp "$SCRIPT_DIR/configs/.vimrc" ~/.vimrc
    log_success ".vimrc 已部署"

    # 部署 bash_aliases（追加到 .bashrc，避免重复）
    if grep -q "$ALIAS_MARKER" ~/.bashrc 2>/dev/null; then
        # 已存在标记，替换旧内容
        # 删除旧的标记块
        sed -i "/$ALIAS_MARKER/,/$ALIAS_MARKER_END/d" ~/.bashrc
        log_info "已移除旧的别名配置，重新写入..."
    fi

    {
        echo ""
        echo "$ALIAS_MARKER"
        cat "$SCRIPT_DIR/configs/bash_aliases"
        echo "$ALIAS_MARKER_END"
    } >> ~/.bashrc
    log_success "bash_aliases 已追加到 ~/.bashrc"
}

# ============================================
# 3. 安装 tmux 插件
# ============================================
install_tmux_plugins() {
    log_info "正在安装 tmux 插件..."

    # 创建插件目录
    mkdir -p ~/.tmux/plugins

    # 安装 TPM
    if [ -d ~/.tmux/plugins/tpm ]; then
        log_success "TPM 已存在"
    else
        if git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null; then
            log_success "TPM 安装成功"
        else
            log_error "TPM 安装失败"
        fi
    fi

    # 安装 tmux-resurrect
    if [ -d ~/.tmux/plugins/tmux-resurrect ]; then
        log_success "tmux-resurrect 已存在"
    else
        if git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux/plugins/tmux-resurrect 2>/dev/null; then
            log_success "tmux-resurrect 安装成功"
        else
            log_error "tmux-resurrect 安装失败"
        fi
    fi

    # 安装 tmux-continuum
    if [ -d ~/.tmux/plugins/tmux-continuum ]; then
        log_success "tmux-continuum 已存在"
    else
        if git clone https://github.com/tmux-plugins/tmux-continuum ~/.tmux/plugins/tmux-continuum 2>/dev/null; then
            log_success "tmux-continuum 安装成功"
        else
            log_error "tmux-continuum 安装失败"
        fi
    fi
}

# ============================================
# 4. 复制文档
# ============================================
deploy_docs() {
    log_info "正在复制参考文档..."

    DOCS_DIR="$HOME/projects/tools/docs"
    mkdir -p "$DOCS_DIR"

    local count=0
    for doc in "$SCRIPT_DIR"/docs/*.md; do
        if [ -f "$doc" ]; then
            cp "$doc" "$DOCS_DIR/"
            count=$((count + 1))
        fi
    done

    log_success "已复制 $count 份文档到 $DOCS_DIR"
}

# ============================================
# 5. 使别名生效
# ============================================
apply_aliases() {
    log_info "正在使别名生效..."
    # 在当前 shell 中不能直接 source，提示用户
    log_success "别名已写入 ~/.bashrc"
    log_info "请运行 'source ~/.bashrc' 或重新打开终端使别名生效"
}

# ============================================
# 6. 显示安装结果摘要
# ============================================
show_summary() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  安装结果摘要${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""

    for result in "${RESULTS[@]}"; do
        echo -e "  $result"
    done

    echo ""
    echo -e "${BLUE}--------------------------------------------${NC}"
    echo -e "${GREEN}安装完成！${NC}"
    echo ""
    echo "后续步骤："
    echo "  1. source ~/.bashrc        # 使别名生效"
    echo "  2. tmux -V                 # 验证 tmux"
    echo "  3. glow --version          # 验证 glow"
    echo "  4. tl                      # 测试别名"
    echo "  5. tn test                 # 创建 tmux 会话"
    echo "  6. vim test.md → ,p        # 测试 Markdown 预览"
    echo ""
    echo "参考文档位置: ~/projects/tools/docs/"
    echo -e "${BLUE}============================================${NC}"
}

# ============================================
# 主流程
# ============================================
main() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  dotfiles 一键安装${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""

    install_dependencies
    deploy_configs
    install_tmux_plugins
    deploy_docs
    apply_aliases
    show_summary
}

main "$@"
