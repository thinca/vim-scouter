" Measures Battle Power of a vimmer.
" Version: 0.1.2
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

function! s:files(files)
  if type(a:files) == type([])
    let files = []
    for f in a:files
      let files += s:files(f)
    endfor
    return files
  endif
  return split(glob(a:files . (isdirectory(expand(a:files)) ? '/**/*.vim'
  \                                                         : '')), "\n")
endfunction

function! s:show(verbose, ...)
  let res = call('ScouterVerbose', a:000)
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
      for file in s:files(arg)
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
command! -bar -bang -nargs=* -complete=file
\        Scouter call s:show(<bang>0, <f-args>)



let &cpo = s:save_cpo
unlet s:save_cpo
