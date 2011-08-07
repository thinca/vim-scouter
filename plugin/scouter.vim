" Measures Battle Power of a vimmer.
" Version: 0.1.3
" Author : thinca <thinca+vim@gmail.com>
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>

if exists('g:loaded_scouter')
  finish
endif
let g:loaded_scouter = 1

let s:save_cpo = &cpo
set cpo&vim


" functions  {{{1
function! s:sum(list)
  return eval(join(a:list, '+'))
endfunction

function! s:measure(lines)
  let pat = '^\s*$\|^\s*["\\]'
  return len(filter(a:lines, 'v:val !~ pat'))
endfunction

function! s:glob(pattern)
  if type(a:pattern) == type([])
    let files = []
    for f in a:pattern
      let files += s:glob(f)
    endfor
    return files
  endif
  let pat = a:pattern
  if isdirectory(pat)
    let pat .= '/**/*.vim'
  elseif filereadable(pat)
    return [pat]
  elseif getftype(pat) != ''  " exists, but unreadable.
    return []
  endif
  return s:glob(split(glob(pat), "\n"))
endfunction

function! s:show(verbose, args, use_range, line1, line2)
  let args = copy(a:args)
  if a:use_range
    call add(args, getline(a:line1, a:line2))
  endif
  let res = call('ScouterVerbose', args)
  let sum = s:sum(values(res))
  if a:verbose
    for file in sort(keys(res))
      echo file . ': ' . res[file]
    endfor
    let sum = 'Total: ' . sum
  endif
  echo sum
endfunction

function! ScouterVerbose(...)
  let res = {}
  let n = 1
  for arg in a:0 ? a:000 : [$MYVIMRC]
    if type(arg) == type([])
      let res['*' . n] = s:measure(copy(arg))
      let n += 1
    elseif type(arg) == type('')
      for file in s:glob(arg)
        let res[file] = s:measure(readfile(file))
      endfor
    endif
    unlet arg
  endfor
  return res
endfunction

function! Scouter(...)
  return s:sum(values(call('ScouterVerbose', a:000)))
endfunction



" command  {{{1
command! -bar -bang -nargs=* -range=0 -complete=file
\        Scouter call s:show(<bang>0, [<f-args>], <count>, <line1>, <line2>)



let &cpo = s:save_cpo
unlet s:save_cpo
