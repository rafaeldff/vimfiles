nnoremap <space> viw
vnoremap <space> :<C-u>call Climb()<CR>

let g:opening_pattern = '[([{]'
let g:closing_pattern = '[)\]}]'
let g:delimitor_pattern = '\(' . g:opening_pattern . '\|' . g:closing_pattern . '\)'
let g:climb_delimitors = { "(": ")", "{": "}", "[": "]", ")": "(", "}": "{", "]": "[" }

function! Climb()
  call DoClimb(0)
  normal mc
endfunction

function! DoClimb(stack)
  let found = ScanForDelim()

  let opening = IsOpening(found)
  if opening
    echo "opening " . found
    if a:stack == 0
      echom "Yatzi!!"
    else
      echom "not yet"
      call DoClimb(a:stack - 1)
    endif
  else
    echom "closing " . found
    call DoClimb(a:stack + 1)
  endif
  
  echom "found " . found . " is opening? " . opening
endfunction


function! ScanForDelim()
  "search for next delim
  execute "normal! ?" . g:delimitor_pattern ."\<cr>"

  "Store char in @@
  normal! yl

  return @@
endfunction

function! IsOpening(found)
  let idx_opening = match(a:found, g:opening_pattern)
  return idx_opening + 1
endfunction

function! Foo() 
  let res = call Bar()
  echom "foo: bar is " . res
endfunction

function! Bar() 
  return "baaaar"
endfunction


