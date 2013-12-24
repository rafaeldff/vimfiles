nnoremap <space> :call StartClimbing()<CR>
vnoremap <space> :<C-u>call ClimbUp()<CR>
vnoremap <S-space> :<C-u>call ClimbDown()<CR>
vnoremap <C-l> :<C-u>call ClimbRight()<CR>
vnoremap <C-h> :<C-u>call ClimbLeft()<CR>

function! Concat(l1, l2)
    let new_list = deepcopy(a:l1)
    call extend(new_list, a:l2)
    return new_list
endfunction

let g:history = []

let g:opening_delimitors = '[(\[{]'
let g:closing_delimitors = '[)\]}]'
let g:unnested_delimitors = "['\"]"

function! StartClimbing()
  let g:history = []
  execute "normal! viw"
endfunction 

function! ClimbUp()
  call Push(g:history, getpos("."))
  execute "normal `>"
  let [l, r] =  Climb()
  call Select(l, r)
endfunction

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

  let [l, r] = Climb()
  call Select(l, r)
endfunction

function! ClimbRight()
  let ll = getpos("'<")
  let lr = getpos("'>")

  call Push(g:history, ll)

  call setpos(".", lr)
  let next_delimitor = ScanForDelim(OpeningPattern(), "f") 

  if IsWordOpening(next_delimitor)
    let [end_of_word_lnum, end_of_word_col] = searchpos('.\>', "n")
    let rr = [0, end_of_word_lnum, end_of_word_col, 0]
  else
    let [rl, rr] =  Climb()
  endif

  call Select(ll, rr)
endfunction

function! ClimbLeft()
  let rl = getpos("'<")
  let rr = getpos("'>")

  call Push(g:history, rl)

  call setpos(".", rl)
  call ScanForDelim(OpeningPattern(), "b") 
  let [ll, lr] =  Climb()
  call Select(ll, rr)
endfunction

function! Climb()
  let search_pattern = InitialPattern()
  let search_result = LookFor(search_pattern,"f", 0)
  let right = getpos(".")
  normal mo

  if NothingFound(search_result)
    let bof = [0,1,1,0]
    let eof = getpos("$")
    return [bof, eof]
  endif

  call LookFor(search_pattern, "b", 0)
  normal mc
  let left = getpos(".")
  return [left, right]
endfunction

function! Select(left, right)
  call setpos("'l", a:left)
  call setpos(".", a:right)
  normal v`l
endfunction

function! InitialPattern()
  let delimitor_pattern = '\(' . g:opening_delimitors . '\)\|\(' . g:closing_delimitors . '\)\|\(' . g:unnested_delimitors . '\)'

  return {"pattern-string": delimitor_pattern}
endfunction

function! OpeningPattern()
  let word_opening = '\(\<\)'
  let delimitor_pattern = '\(' . g:opening_delimitors . '\)\|\(' . g:closing_delimitors . '\)\|\(' . g:unnested_delimitors . '\)\|' . word_opening

  return {"pattern-string": delimitor_pattern}
endfunction

function! IsWordOpening(result)
  return a:result == 3
endfunction

function! LookFor(pattern, direction, depth)
  let found = ScanForDelim(a:pattern, a:direction) 
  if NothingFound(found)
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

function! FindChar(idx, pattern)
  return a:pattern["pattern-list"][a:idx]
endfunction

" Pattern contains a closing-delimitors-list
" Direction is 'f' or 'b'
" Found is an index within pattern-list (closing-delimitors-list is a prefix thereof)
"
" When direction is 'f', returns true iff found is a closing delimitor
" When direction is 'b', returns true iff found is an opening delimitor
function! MatchesDirection(pattern, direction, found)
  if IsUnnested(a:found, a:pattern)
    let delim_direction = UnnestedDirection(a:found, a:pattern)
  else
    " Closing delimitors match forward direction
    " Opening delimitors match backward direction
    let delim_direction = (IsClosingDelimiter(a:found, a:pattern) ? "f" : "b" )
  endif

  return a:direction ==# delim_direction "looking backwards
endfunction

"==== begin
" Pattern is actually a map of {"pattern-string": "()", "closing-delimitors-list": []}
" Direction is either b for backwards or f for forwards
"
" Returns index of match (inside pattern-list
" or a negative number in case of no match.)
function! ScanForDelim(pattern, direction)
  let direction_flag = (a:direction ==# "b") ? "b" : ""
  let flags = direction_flag . "pW"

"  echom "Scanning for " . a:pattern["pattern-string"]
  let search_match = search(a:pattern["pattern-string"], flags)


  return search_match - 2
endfunction

function! NothingFound(result)
  return a:result < 0
endfunction

function! IsUnnested(result, pattern)
  return a:result == 2 " Quotes are the third element in the pattern
endfunction

function! UnnestedDirection(result, pattern)
  normal "cyl
  let the_char = @c

  return ((QuoteIndex(the_char) % 2) == 0) ? "f" : "b"
endfunction

function! IsClosingDelimiter(result, pattern)
  return a:result == 1 " Closing delimitors are the second element in the pattern
endfunction
"==== end

function! QuoteIndex(quote_char)
  let save_cursor = getpos(".")
  
  " start at the last char in the file and wrap for the
  " first search to find match at start of file
  normal G$
  let flags = "w"
  let cnt = 0
  while search(a:quote_char, flags) > 0 
    let cnt = cnt + 1
    let flags = "W"
    if (getpos(".") == save_cursor)
      break
    end
  endwhile

  call setpos('.', save_cursor)
  return cnt
endfunction

function! NewDict(k, v)
  let dict = {}
  let dict[a:k] = a:v
  return dict
endfunction

function! Contains(list, element)
  return (index(a:list, a:element) >= 0)
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


