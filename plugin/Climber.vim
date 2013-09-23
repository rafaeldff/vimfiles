nnoremap <space> viw
vnoremap <space> :<C-u>call ClimbUp()<CR>
vnoremap <S-space> :<C-u>call ClimbDown()<CR>

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

function! ClimbDown()
  execute "normal `>"
  let opening = DoClimb("b", "f", 0)
  normal mo

  if opening >= 0
    call DoClimb("b", "b", 0)
    normal mc
    execute "normal! `ov`c"
  end
endfunction

function! ClimbUp()
  execute "normal `>"
  let opening = DoClimb("f", "f", 0)
  normal mo

  if opening >= 0
    call DoClimb("b", "b", 0)
    normal mc
    execute "normal! `ov`c"
  end
endfunction

function! DoClimb(scan_direction, match_direction, stack)
  let found = ScanForDelim(a:scan_direction) 
  if found < 0
    return found
  endif

  let matching = MatchesDirection(a:match_direction, found)
  if matching
    if a:stack == 0
      return found
    else
      return DoClimb(a:scan_direction, a:match_direction,  a:stack - 1)
    endif
  else
    return DoClimb(a:scan_direction, a:match_direction,  a:stack + 1)
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



