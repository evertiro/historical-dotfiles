syntax on		" Enable syntax highlighting
filetype on
filetype indent on
filetype plugin on
set autoindent		" Auto indent to previous line
set background=dark	" Optimize colors for dark backgrounds
set cindent		" Strict indenting for C programs
set ignorecase		" Case insensitive search
set mouse=a		" Enable mouse support
set nobackup		" Disable tilda file backups
set nowritebackup
set nowrap		" Disable line wrapping
set shortmess=aTI
set smartcase		" Case sensitive search if caps used
set sw=4
set ts=4

" Preview in chromium
command PreviewWeb :!$BROWSER %<CR>

" Toggle line numbers with F2
nnoremap <silent> <F2> :set number!<CR>

" Toggle spellcheck with F11
map <F11> :set spell!<CR><Bar>:echo "Spell Check: " . strpart("OffOn", 3 * &spell, 3)<CR>

" Toggle paste mode with F12
nnoremap <F12> :set invpaste paste?<CR>
set pastetoggle=<F12>
set showmode

" Use folding if we can
if has ('folding')
	set foldenable
	set foldmethod=marker
	set foldmarker={{{,}}}
	set foldcolumn=0
endif
