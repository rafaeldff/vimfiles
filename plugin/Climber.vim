nnoremap <space> :call StartClimbing()<CR>
vnoremap <space> :<C-u>call ClimbUp()<CR>
vnoremap <S-space> :<C-u>call ClimbDown()<CR>

function! Concat(l1, l2)
    let new_list = deepcopy(a:l1)
    call extend(new_list, a:l2)
    return new_list
endfunction

let g:climb_delimitors = { ")": "(", "}": "{", '\]': '\['}
let g:opening_delimitors = keys(g:climb_delimitors)
let g:closing_delimitors = values(g:climb_delimitors)
let g:all_delimitors = Concat(g:opening_delimitors, g:closing_delimitors)
let g:delimitor_pattern = '\(' . join(g:all_delimitors, '\)\|\(' ) . '\)'
let g:history = []

function! ClimbDown()
  if Empty(g:history)
    return
  endif

  let last_pos = Pop(g:history)
  call setpos(".", last_pos)

  if Empty(g:history)
    execute "normal! \<esc>viw"
    return
  endif

  call Climb()
endfunction

function! StartClimbing()
  let g:history = []
  execute "normal! viw"
endfunction 

function! ClimbUp()
  call Push(g:history, getpos("."))
  execute "normal `>"
  call Climb()
endfunction

function! Climb()
  let closing = LookFor(BuildPattern(g:climb_delimitors),"f", 0)
  let delim = get(g:all_delimitors, closing)
  normal mo

  if closing >= 0
    let delimitor_pair = NewDict(delim, g:climb_delimitors[delim])
    call LookFor(BuildPattern(delimitor_pair), "b", 0)
    normal mc
    execute "normal! `ov`c"
  endif
endfunction

function! NewDict(k, v)
  let dict = {}
  let dict[a:k] = a:v
  return dict
endfunction

function! BuildPattern(delim_map)
  let closing_delimitors = keys(a:delim_map)
  let opening_delimitors = values(a:delim_map)
  let all_delimitors = Concat(closing_delimitors, opening_delimitors)
  let delimitor_pattern = '\(' . join(all_delimitors, '\)\|\(' ) . '\)'
"  echom delimitor_pattern
  return {"pattern-string": delimitor_pattern, "pattern-list": closing_delimitors}
endfunction

function! LookFor(pattern, direction, depth)
"  echom "LookFor(" . a:direction . "," . a:depth . ")"
  let found = ScanForDelim(a:pattern, a:direction) 
  if found < 0
    return found
  endif

  let matching = MatchesDirection(a:pattern, a:direction, found)
  if matching
    if a:depth == 0
      return found
    else
      return LookFor(a:pattern, a:direction, a:depth - 1)
    endif
  else
    return LookFor(a:pattern, a:direction, a:depth + 1)
  endif
endfunction


" Pattern is actually a map of {"pattern-string": "()", "pattern-list": []}
" Direction is either b for backwards or f for forwards
" Returns index of match (inside delimitor_pattern, i.e. all_delimitors
" or a negative number in case of no match.)
function! ScanForDelim(pattern, direction)
  let direction_flag = (a:direction ==# "b") ? "b" : ""
  let flags = direction_flag . "pW"

  let search_match = search(a:pattern["pattern-string"], flags)

  let res = search_match - 2
"  echo "found " res "  in pattern " . string(a:pattern)
  return search_match - 2
endfunction

function! MatchesDirection(pattern, direction, found)
  let delimiter_list = a:pattern["pattern-list"]
  " Closing delimitors match forward direction
  " Opening delimitors match backward direction
  let delim_direction = (a:found < len(delimiter_list) ? "f" : "b" )
"  echom "delimiter_list: " . string(delimiter_list) " delim_dir: " . delim_direction

  return a:direction ==# delim_direction "looking backwards
endfunction

function! Push(stack, new_element)
  call add(a:stack, a:new_element)
endfunction

function! Pop(stack)
  let size = len(a:stack)
  let last_element = get(a:stack, size - 1)
  call remove(a:stack, size - 1)
  return last_element
endfunction

function! Empty(stack)
  return empty(a:stack)
endfunction

function! First(stack)
  return len(a:stack) == 1
endfunction

