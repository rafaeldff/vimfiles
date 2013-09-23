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
"  echom "GO///////////"
  let opening = DoClimb("b", 0)
  normal mo
"  echom "Opening is " . opening

  if opening >= 0
"    echom "here!!"
    call DoClimb("f", 0)
    normal mc
    execute "normal! `ov`c"
  end
  
"  echom 'End\\\\\\\\\\\'
endfunction

function! DoClimb(direction, stack)
  let found = ScanForDelim(a:direction) 
"  echom "FOUND " . found
  if found < 0
    return found
  endif

  let matching = MatchesDirection(a:direction, found)
  if matching
"    echom "matching dir " . a:direction . " >> " . found
    if a:stack == 0
"      echom "Yatzi>> " . found
      return found
    else
"      echom "not yet"
      return DoClimb(a:direction,  a:stack - 1)
    endif
  else
"    echom "un-matching dir " . a:direction . " >> " . found
    return DoClimb(a:direction,  a:stack + 1)
  endif
endfunction


" Direction is either b for backwards or f for forwards
" Returns index of match (inside delimitor_pattern, i.e. all_delimitors
" or a negative number in case of no match.
function! ScanForDelim(direction)
  let direction_flag = (a:direction ==# "b") ? "b" : ""
  let flags = direction_flag . "pW"
  let search_match = search(g:delimitor_pattern, flags)

  return search_match - 2
endfunction

function! MatchesDirection(direction, found)
  if a:direction ==# "b" "looking backwards
    "return true if index of match is in the first part, the opening delims
    return a:found < len(g:opening_delimitors)
  else
    "return true if index of match is in the latter part, the closing delims
    return a:found >= len(g:opening_delimitors)
  endif
endfunction



