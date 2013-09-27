nnoremap <space> :call StartClimbing()<CR>
vnoremap <space> :<C-u>call ClimbUp()<CR>
vnoremap <S-space> :<C-u>call ClimbDown()<CR>

function! Concat(l1, l2)
    let new_list = deepcopy(a:l1)
    call extend(new_list, a:l2)
    return new_list
endfunction

let g:unnested = ['"']
let g:climb_delimitors = { "(": ")", "{": "}", '\[': '\]', '"': '"'}
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

  let opening = DoClimb("f", 0)
  normal mo

  if opening >= 0
    call DoClimb("b", 0)
    normal mc
    execute "normal! `ov`c"
  end
endfunction

function! StartClimbing()
  let g:history = []
  execute "normal! viw"
endfunction 

function! ClimbUp()
  call Push(g:history, getpos("."))

  execute "normal `>"
  let opening = DoClimb("f", 0)
  normal mo

  if opening >= 0
    call DoClimb("b", 0)
    normal mc
    execute "normal! `ov`c"
  end
endfunction

function! DoClimb(direction, depth)
  let found = ScanForDelim(a:direction) 
  if found < 0
    return found
  endif

  let matching = MatchesDirection(a:direction, found)
  if matching
    if a:depth == 0
      return found
    else
      return DoClimb(a:direction, a:depth - 1)
    endif
  else
    return DoClimb(a:direction, a:depth + 1)
  endif
endfunction


" Direction is either b for backwards or f for forwards
" Returns index of match (inside delimitor_pattern, i.e. all_delimitors
" or a negative number in case of no match.)
function! ScanForDelim(direction)
  let direction_flag = (a:direction ==# "b") ? "b" : ""
  let flags = direction_flag . "pW"
  let search_match = search(g:delimitor_pattern, flags)

  return search_match - 2
endfunction

function! MatchesDirection(direction, found)
  let delim_direction = (a:found < len(g:opening_delimitors) ? "b" : "f" )

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

