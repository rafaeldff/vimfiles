"necessary on some Linux distros for pathogen to properly load bundles
filetype off

"load pathogen managed plugins
call pathogen#runtime_append_all_bundles()

"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible

"allow backspacing over everything in insert mode
set backspace=indent,eol,start

"store lots of :cmdline history
set history=1000

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom

set hlsearch    "hilight searches by default

set number      "add line numbers
set showbreak=...
set wrap linebreak nolist

"add some line space for easy reading
set linespace=4

"disable visual bell
set visualbell t_vb=

"turn off needless toolbar and scrollbars on gvim/mvim
set guioptions-=M
set guioptions-=r
set guioptions-=l
set guioptions-=L
set guioptions-=T

" COMMENTING OUT AS IT DOESN'T WORK WITH POWERLINE
"recalculate the trailing whitespace warning when idle, and after saving
"autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
"function! StatuslineTrailingSpaceWarning()
    "if !exists("b:statusline_trailing_space_warning")
        "if search('\s\+$', 'nw') != 0
            "let b:statusline_trailing_space_warning = '[\s]'
        "else
            "let b:statusline_trailing_space_warning = ''
        "endif
    "endif
    "return b:statusline_trailing_space_warning
"endfunction

"recalculate the tab warning flag when idle and after writing
"autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
"function! StatuslineTabWarning()
    "if !exists("b:statusline_tab_warning")
        "let tabs = search('^\t', 'nw') != 0
        "let spaces = search('^ ', 'nw') != 0

        "if tabs && spaces
            "let b:statusline_tab_warning =  '[mixed-indenting]'
        "elseif (spaces && !&et) || (tabs && &et)
            "let b:statusline_tab_warning = '[&et]'
        "else
            "let b:statusline_tab_warning = ''
        "endif
    "endif
    "return b:statusline_tab_warning
"endfunction

"indent settings
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent

"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

set wildmode=list:longest   "make cmdline tab completion similar to bash
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*.class,*.jar,*~ "stuff to ignore when tab completing

"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

"load ftplugins and indent files
filetype plugin on
filetype indent on 
"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

colorscheme xoria256
if has("gui_running")
    "tell the term has 256 colors
    set t_Co=256

    set guitablabel=%M%t
    "set lines=40
    "set columns=115

    if has("gui_gnome")
        set term=gnome-256color
        set guifont=Consolas\ for\ Powerline\ 11
    endif
else
    "dont load csapprox if there is no gui support - silences an annoying warning
    let g:CSApprox_loaded = 1
endif

"map to bufexplorer
nnoremap <leader>b :BufExplorer<cr>

"make Y consistent with C and D
nnoremap Y y$

"mark syntax errors with :signs
let g:syntastic_enable_signs=1

"snipmate setup
source ~/.vim/snippets/support_functions.vim
autocmd vimenter * call s:SetupSnippets()
function! s:SetupSnippets()

    "if we're in a rails env then read in the rails snippets
    if filereadable("./config/environment.rb")
        call ExtractSnips("~/.vim/snippets/ruby-rails", "ruby")
        call ExtractSnips("~/.vim/snippets/eruby-rails", "eruby")
    endif

    call ExtractSnips("~/.vim/snippets/html", "eruby")
    call ExtractSnips("~/.vim/snippets/html", "xhtml")
    call ExtractSnips("~/.vim/snippets/html", "php")
endfunction

"visual search mappings
function! s:VSetSearch()
    echom "in vsetsearch"
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>


"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

"key mapping for window navigation
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

"Map backspace to clear matches
nmap <BS> :nohlsearch<CR>:match none<CR>

" Make j and k behave will with long lines
nmap j gj
nmap k gk

"Powerline plugin
let g:Powerline_symbols = 'fancy'

"CTRL.P.vim plugin
set runtimepath^=~/.vim/bundle/ctrlp.vim

" Open a split with vimrc
nnoremap <leader>ev :vsplit $HOME/.vim/vimrc<cr>
nnoremap <leader>sv :source %<cr>      


" Clojure
let g:vimclojure#ParenRainbow=1

let vimclojure#SetupKeyMap = 0

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

set maxfuncdepth=16384

function! JumpToDir(dest)
  execute "cd  ~/.marks/" . a:dest
  pwd
endfunction

function! JumpToDirCompletions(arg_lead, L, P)
  "return globpath("~/.marks", a:arg_lead . "*")
  return system("ls -1d ~/.marks/* | sed 's,^.*.marks/,,'")
endfunction

command! -complete=custom,JumpToDirCompletions -nargs=1 Jump call JumpToDir("<args>")
nnoremap <leader>w :%s/facts\?/& :wip/g<cr>
nnoremap <leader>W :%s/ :wip//g<cr>

vnoremap <leader>w :s/facts\?/& :wip/g<cr>
vnoremap <leader>W :s/ :wip//g<cr>

nnoremap <leader>d mf"dyiwgg/(defn\?\s*d<cr><esc>:nohlsearch<cr>

nnoremap <leader>r mob"ayt/gg2w"nyt./:require<cr>:nohlsearch<cr>o[<esc>"npa :as <esc>"apa]<esc>3bea.

function! OpenTest()
  let file_path = @%
  "let file_name = strpart(file_path, strridx(file_path, "/") + 1)
  let test_file_path_suffixed = substitute(file_path, "\.clj", "_test.clj", "")
  let test_file_path = substitute(test_file_path_suffixed, "src/", "test/", "")
  echom "Opening " . test_file_path
  execute "normal! :topleft vs " . test_file_path . "\<cr>"
endfunction
nnoremap <leader>t :call OpenTest()<cr>


function! OpenSource()
  let file_path = @%
  "let file_name = strpart(file_path, strridx(file_path, "/") + 1)
  let src_file_path_suffixed = substitute(file_path, "_test.clj", ".clj", "")
  let src_file_path = substitute(src_file_path_suffixed, "test/", "src/", "")
  echom "Opening " . src_file_path
  execute "normal! :botright vs " . src_file_path . "\<cr>"
endfunction
nnoremap <leader>s :call OpenSource()<cr>

nnoremap <leader>bl :%s/"bookmarks"/"remote_bookmarks"/<cr>:%s/"local_bookmarks"/"bookmarks"/<cr>
nnoremap <leader>br :%s/"bookmarks"/"local_bookmarks"/<cr>:%s/"remote_bookmarks"/"bookmarks"/<cr>


vnoremap m y`<v`>

nnoremap <leader>jt mob"ayt/f/l"dyegg/:as a\><cr>:nohlsearch<cr>T["nyt `o:execute "normal! :tabnew src/" . substitute(substitute("n", '-', '_', 'g'), '\.', '/', 'g') . ".clj\<lt>cr>"<cr>/d<cr>

nnoremap <leader>jr mob"ayt/f/l"dyegg/:as a\><cr>:nohlsearch<cr>0f[

nnoremap <leader>d bi...<esc>ea...<esc>
