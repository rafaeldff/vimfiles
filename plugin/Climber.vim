nnoremap <space> viw
vnoremap <space> :<C-u>call Climb()<CR>

let g:opening_pattern = '[([{]'
let g:closing_pattern = '[)\]}]'
let g:climb_delimitors = { "(": ")", "{": "}", "[": "]", '"':'"'}

function! Climb()
  "search for next opening
  execute "normal! ?" . g:opening_pattern ."\<cr>"

  "Store char in @@
  normal! yl
  let opening = @@
  let closing = g:climb_delimitors[@@]

  execute "normal! v/" . closing . "\<CR>"
endfunction


