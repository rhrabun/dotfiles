" Yank to system clipboard
set clipboard=unnamed

inoremap jk <Esc>
inoremap kj <Esc>

" Have to unmap space to use it
unmap <Space>

" Save file
exmap save obcommand editor:save-file
nmap <Space>w :save<CR>

" Move file
exmap moveFile obcommand file-explorer:move-file
nmap <Space>m :moveFile<CR>

" Close current tab
exmap close obcommand workspace:close
nmap <Space>q :close

" Open file search
exmap fileSearch :obcommand switcher:open
exmap fileSearchNewTab :obcommand file-explorer:open
nmap <Space>f :fileSearchNewTab<CR>
nmap <Space><Space> :fileSearch<CR>

" Delete file (without CR so requires confirmation)
exmap fileDelete :obcommand app:delete-file
nmap <Space>D :fileDelete

" Rename title
exmap rename obcommand workspace:edit-file-title
nmap <Space>r :rename<CR>

" Follow link
exmap followlink :obcommand editor:follow-link
nmap gd :followlink<CR>

" Toggle sidebars
exmap tleftbar obcommand app:toggle-left-sidebar
exmap trightbar obcommand app:toggle-right-sidebar
nmap <C-A-e> :tleftbar<CR>
nmap <C-e> :trightbar<CR>

" Move lines
exmap lineUp obcommand editor:swap-line-up
exmap lineDown obcommand editor:swap-line-down
nmap <C-A-j> :lineDown<CR>
nmap <C-A-k> :lineUp<CR>

" Go back and forward
exmap back obcommand app:go-back
exmap forward obcommand app:go-forward
nmap <C-A-,> :back<CR>
nmap <C-A-.> :forward<CR>

" Splits
nmap <C-w>h :obcommand<space>workspace:split-horizontal<CR>
nmap <C-w>v :obcommand<space>workspace:split-vertical<CR>
nmap <C-j> :obcommand<space>editor:focus-bottom<CR>
nmap <C-k> :obcommand<space>editor:focus-top<CR>
nmap <C-l> :obcommand<space>editor:focus-right<CR>
nmap <C-h> :obcommand<space>editor:focus-left<CR>

" Surround
exmap surround_wiki surround [[ ]]
exmap surround_double_quotes surround " "
exmap surround_single_quotes surround ' '
exmap surround_backticks surround ` `
exmap surround_brackets surround ( )
exmap surround_square_brackets surround [ ]
exmap surround_curly_brackets surround { }
" NOTE: must use 'map' and not 'nmap'
map [[ :surround_wiki<CR>
nunmap S
vunmap S
map S" :surround_double_quotes<CR>
map S' :surround_single_quotes<CR>
map S` :surround_backticks<CR>
map Sb :surround_brackets<CR>
map S( :surround_brackets<CR>
map S) :surround_brackets<CR>
map S[ :surround_square_brackets<CR>
map S] :surround_square_brackets<CR>
map S{ :surround_curly_brackets<CR>
map S} :surround_curly_brackets<CR>