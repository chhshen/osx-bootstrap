
nnoremap <leader>w :w<CR>
nnoremap <leader>qq :q<CR>
nnoremap <leader>wq :wq<CR>
nnoremap <leader>qqa :qa<CR>
nnoremap <leader>wqa :wqa<CR>

" Window navigation
function! Wincmd(cmd)
    if exists('w:winmax')
        let l:prev_winmax = w:winmax
    else
        let l:prev_winmax = 0
    endif

    exe ":wincmd ".a:cmd

    if &previewwindow || &buftype ==# 'quickfix'
        resize 10
        return
    endif

    if a:cmd ==# '-' || a:cmd ==# '+'
        let t:winmax = 0
        let w:winmax = 0
        return
    endif

    let w:wineq = exists('w:wineq') && w:wineq
    if ((exists('t:winmax') && t:winmax) || (exists('w:winmax') && w:winmax)) && !w:wineq
        :wincmd _
    elseif l:prev_winmax || w:wineq
        :wincmd =
    endif
endfunction

nnoremap w_ :wincmd _<CR> :let t:winmax = 1<CR> :let w:wineq = 0<CR> :let w:winmax = 0<CR>
nnoremap w= :wincmd =<CR> :let t:winmax = 0<CR> :let w:wineq = 0<CR> :let w:winmax = 0<CR>
nnoremap ww_ :wincmd _<CR> :let w:winmax = 1<CR> :let w:wineq = 0<CR>
nnoremap ww= :wincmd =<CR> :let w:winmax = 0<CR> :let w:wineq = 1<CR>
nnoremap w- :call Wincmd('-')<CR>
nnoremap w+ :call Wincmd('+')<CR>
nnoremap wh :call Wincmd('h')<CR>
nnoremap wj :call Wincmd('j')<CR>
nnoremap wk :call Wincmd('k')<CR>
nnoremap wl :call Wincmd('l')<CR>

" Buffer navigatior
noremap <C-l> :bn<CR>
noremap <C-h> :bp<CR>
noremap <C-j> :b#<CR>

" Merge helpers
" Find the next merge section
nnoremap <leader>ml :exe "/<<<<<<<\\\|=======\\\|>>>>>>>"<CR>
nnoremap <leader>mh :exe "?<<<<<<<\\\|=======\\\|>>>>>>>"<CR>

vnoremap * :<C-u>exe '/'.GetVisualSelection()<CR>
vnoremap <leader>* :<C-u>call AgLiteral(GetVisualSelection())<CR>
nnoremap <leader>* *N:call ag#AgFromSearch('grep', '')<CR>

" Syntastic
nnoremap <leader>e :SyntasticCheck<CR>
nnoremap <leader>eh :lnext<CR>
nnoremap <leader>el :lprev<CR>

" Clear search
nnoremap <leader>/ :let @/ = ""<CR>

nnoremap <leader>rg :EditRelatedFilesGit<CR>
nnoremap <leader>rs :EditRelatedFilesName<CR>

" Errors
nnoremap <leader>ck :cnext<CR>
nnoremap <leader>cj :cprev<CR>

" Sort
function! SortLines(type, ...)
    let visual_mode = a:0
    let sort_line_args = ""
    if exists('g:sort_lines_default_args')
        let sort_line_args = g:sort_lines_default_args
    endif
    let cmd = ""
    if visual_mode
        let cmd .= "'<,'>"
    else
        let cmd .= "'[,']"
    endif
    let cmd .= "sort " . sort_line_args
    exe cmd
endfunction

nnoremap <leader>s :set opfunc=SortLines<CR>g@
vnoremap <leader>s :<C-U>call SortLines(visualmode(), 1)<CR>

" Indent text object. See http://vim.wikia.com/wiki/Indent_text_object
onoremap <silent>ai :<C-U>call <SID>IndTxtObj(0)<CR>
onoremap <silent>ii :<C-U>call <SID>IndTxtObj(1)<CR>
vnoremap <silent>ai :<C-U>call <SID>IndTxtObj(0)<CR><Esc>gv
vnoremap <silent>ii :<C-U>call <SID>IndTxtObj(1)<CR><Esc>gv

function! <SID>IndLevel(lineno, default)
    if g:LineIsBlank(a:lineno)
        return a:default
    else
        return indent(a:lineno)
    endif
endfunction

function! g:NextNonBlankLine()
    try
        exe '/^\s*\S'
    catch
        normal! gg
    endtry
endfunction

function! g:PrevNonBlankLine()
    try
        exe '?^\s*\S'
    catch
        normal! G
    endtry
endfunction

function! g:LineIsBlank(...)
    if a:0
        let ln = a:1
    else
        let ln = '.'
    endif
    return getline(ln) =~# '^\s*$'
endfunction

function! <SID>IndTxtObj(inner)
    let curcol = col(".")
    let curline = line(".")
    let lastline = line("$")
    let i = indent(line("."))

    " If line is blank, don't attempt to find indent level unless surrounding
    " lines are the same level.
    if g:LineIsBlank()
        call g:PrevNonBlankLine()
        let prevI = indent(line('.'))
        call g:NextNonBlankLine()
        let nextI = indent(line('.'))
        let @/ = ""
        call cursor(curline, curcol)
        if prevI !=# nextI
            return
        else
            let i = nextI
        endif
    endif

    let n = curline
    let trimLast = 1
    while n <= lastline && <SID>IndLevel(n, i) >= i
        normal! +
        let n = line(".")
        if n ==# lastline
            break
        endif
    endwhile
    if (a:inner || (exists('b:indentNoEndDelimiter') && b:indentNoEndDelimiter)) && <SID>IndLevel(n, i) < i
        normal! -
    endif

    if g:LineIsBlank()
        call g:PrevNonBlankLine()
    endif

    normal! 0V
    call cursor(curline, curcol)

    let p = curline
    while p >= 1 && <SID>IndLevel(p, i) >= i
        normal! -
        let p = line(".")
        if p ==# 1
            break
        endif
    endwhile
    if a:inner && <SID>IndLevel(p, i) < i
        normal! +
    endif

    if g:LineIsBlank()
        call g:NextNonBlankLine()
    endif

    normal! $
endfunction

" Vimux
nnoremap <leader>vl :VimuxRunLastCommand<CR>
nnoremap <leader>vc :VimuxRunCommand 'clear'<CR>
nnoremap <Leader>vp :VimuxPromptCommand<CR>
nnoremap <Leader>vi :VimuxInspectRunner<CR>
nnoremap <Leader>vq :VimuxCloseRunner<CR>
nnoremap <Leader>vx :VimuxInterruptRunner<CR>
nnoremap <Leader>vz :call VimuxZoomRunner()<CR>
nnoremap <leader>pl :call PylintFile()<CR>

function! PylintFile(...)
    if a:0 && len(a:0)
        let file = a:file
    else
        let file = '%'
    endif
    :VimuxRunCommand 'pylint '.expand(file)
endfunction
