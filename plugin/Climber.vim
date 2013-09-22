nnoremap <space> viw
vnoremap <space> :<C-u>call Climb()<CR>

let g:climb_delimitors = { "(": ")", "{": "}", "[": "]", '"':'"'}

function! Climb()
  let pattern = '[([{]'

  "search for next opening
  execute "normal! ?" . pattern ."\<cr>"

  "Store char in @@
  normal! yl
  let opening = @@
  let closing = g:climb_delimitors[@@]

  execute "normal! v/" . closing . "\<CR>"
endfunction


