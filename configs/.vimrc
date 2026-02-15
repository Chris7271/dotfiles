" 显示行号
set number

" 语法高亮
syntax on
filetype plugin indent on

" 编码设置
set encoding=utf-8
set fileencoding=utf-8

" 缩进设置
set tabstop=4         " Tab显示宽度
set shiftwidth=4      " 自动缩进宽度
set softtabstop=4
set expandtab         " Tab转空格
set autoindent
set smartindent

" 搜索设置
set hlsearch          " 高亮搜索结果
set incsearch         " 增量搜索
set ignorecase        " 忽略大小写
set smartcase         " 智能大小写


" leader 键设为逗号（默认的 \ 太难按）
let mapleader = ","

" 增加 leader 键等待时间（毫秒）
set timeoutlen=2000
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
" --- 工作流 ---
"   1. 在 tmux 中打开 vim xxx.md
"   2. 按 \p 打开右侧预览
"   3. 编辑内容，:w 保存
"   4. 按 \r 刷新预览
"   5. 完成后按 \q 关闭预览
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
else
  " 不在 tmux 中时提示
endif
