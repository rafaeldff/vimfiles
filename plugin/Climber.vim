nnoremap <space> viw
vnoremap <space> :<C-u>call Climb()<CR>

let g:opening_pattern = '[([{]'
let g:closing_pattern = '[)\]}]'
let g:delimitor_pattern = '\(' . g:opening_pattern . '\|' . g:closing_pattern . '\)'
let g:climb_delimitors = { "(": ")", "{": "}", "[": "]", ")": "(", "}": "{", "]": "[" }

function! Climb()
"  echom "GO///////////"
  let opening = DoClimb(g:opening_pattern, "?", 0)
  normal mo
"  echom "Opening is " . opening

  if !empty(opening)
    call DoClimb(g:closing_pattern, "/", 0)
    normal mc
    execute "normal! `ov`c"
  end
  
"  echom 'End\\\\\\\\\\\'
endfunction

function! DoClimb(pattern, direction, stack)
  let found = ScanForDelim(a:direction) 
"  echom "FOUND " . found
  if empty(found)
    return found
  endif

  let matching = MatchPattern(a:pattern, found)
  if matching
"    echom "matching dir " . a:direction . " >> " . found
    if a:stack == 0
"      echom "Yatzi>> " . found
      return found
    else
"      echom "not yet"
      return DoClimb(a:pattern, a:direction,  a:stack - 1)
    endif
  else
"    echom "un-matching dir " . a:direction . " >> " . found
    return DoClimb(a:pattern, a:direction,  a:stack + 1)
  endif
endfunction


" Direction is either ? or /
function! ScanForDelim(direction)
  "search for next delim
  execute "normal! " . a:direction  . g:delimitor_pattern ."\<cr>"

  "Store char in @@
  normal! yl

  return @@
endfunction

function! MatchPattern(pattern, found)
  let idx_opening = match(a:found, a:pattern)
  return idx_opening + 1
endfunction

