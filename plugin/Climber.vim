nnoremap <space> viw
vnoremap <space> :<C-u>call Climb()<CR>

function! Concat(l1, l2)
    let new_list = deepcopy(a:l1)
    call extend(new_list, a:l2)
    return new_list
endfunction

let g:opening_pattern = '('
let g:closing_pattern = ')'
let g:climb_delimitors = { "(": ")", "{": "}", '\[': '\]' }
let g:opening_delimitors = keys(g:climb_delimitors)
let g:closing_delimitors = values(g:climb_delimitors)
let g:all_delimitors = Concat(g:opening_delimitors, g:closing_delimitors)
let g:delimitor_pattern = '\(' . join(g:all_delimitors, '\)\|\(' ) . '\)'


function! Climb()
  echom "GO///////////"
  let opening = DoClimb("b", "b", 0)
  normal mo
  echom "Opening is " . opening

  if opening
    call DoClimb("f", "", 0)
    normal mc
    execute "normal! `ov`c"
  end
  
  echom 'End\\\\\\\\\\\'
endfunction

function! DoClimb(pattern, direction, stack)
  let found = ScanForDelim(a:direction) 
  echom "FOUND " . found
  if found == 0
    return found
  endif

  let matching = MatchPattern(a:pattern, found)
  if matching
    echom "matching dir " . a:direction . " >> " . found
    if a:stack == 0
      echom "Yatzi>> " . found
      return found
    else
      echom "not yet"
      return DoClimb(a:pattern, a:direction,  a:stack - 1)
    endif
  else
    echom "un-matching dir " . a:direction . " >> " . found
    return DoClimb(a:pattern, a:direction,  a:stack + 1)
  endif
endfunction


" Direction is either b for backwards or ""
function! ScanForDelim(direction)
  let flags = a:direction . "pW"
  let search_match = search(g:delimitor_pattern, flags)

  "if search_match ==# 0
    "not found
    "return ''
  "else
    " search_match will be 2 + index of group,
    " and the groups in delimitor_pattern are one-to-one
    " with all_delimitors
    "return get(g:all_delimitors, search_match - 2)
  "endif

  if search_match == 0
    "not found
    return 0
  endif
  return search_match - 2
endfunction

function! MatchPattern(pattern, found)
  if a:pattern ==# "b"
    return a:found < len(g:opening_delimitors)
  else
    return a:found >= len(g:opening_delimitors)
  endif
endfunction



