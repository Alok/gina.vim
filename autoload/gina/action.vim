let s:Action = vital#gina#import('Action')


function! gina#action#attach(...) abort
  return call(s:Action.attach, ['gina'] + a:000, s:Action)
endfunction

function! gina#action#include(scheme) abort
  let binder = s:get()
  if binder is# v:null
    return
  endif
  let scheme = substitute(a:scheme, '-', '_', 'g')
  try
    return call(
          \ printf('gina#action#%s#define', scheme),
          \ [binder]
          \)
  catch /^Vim\%((\a\+)\)\=:E117: [^:]\+: gina#action#[^#]\+#define/
    call gina#core#console#debug(v:exception)
    call gina#core#console#debug(v:throwpoint)
  endtry
  throw gina#core#exception#error(printf(
        \ 'No action script "gina/action/%s.vim" is found',
        \ a:scheme,
        \))
endfunction

function! gina#action#alias(...) abort
  let binder = s:get()
  if binder is# v:null
    return
  endif
  return call(binder.alias, a:000, binder)
endfunction

function! gina#action#shorten(action_scheme, ...) abort
  let excludes = get(a:000, 0, [])
  let binder = s:get()
  if binder is# v:null
    return
  endif
  let action_scheme = substitute(a:action_scheme, '-', '_', 'g')
  let names = filter(
        \ keys(binder.actions),
        \ 'v:val =~# ''^'' . action_scheme . '':'''
        \)
  for name in filter(names, 'index(excludes, v:val) == -1')
    call binder.alias(matchstr(name, '^' . action_scheme . ':\zs.*'), name)
  endfor
endfunction

function! gina#action#call(name_or_alias, ...) abort
  let binder = s:get()
  if binder is# v:null
    return
  endif
  let candidates = a:0 > 0 ? a:1 : binder.get_candidates(1, line('$'))
  return gina#core#exception#call(
        \ binder.call,
        \ [a:name_or_alias, candidates],
        \ binder
        \)
endfunction

function! gina#action#candidates(...) abort
  let binder = s:get()
  if binder is# v:null
    return
  endif
  if a:0 == 0
    let fline = 1
    let lline = line('$')
  else
    let fline = get(a:000, 0, 1)
    let lline = get(a:000, 1, fline)
  endif
  return binder.get_candidates(fline, lline)
endfunction


" Private --------------------------------------------------------------------
function! s:get(...) abort
  return call(s:Action.get, ['gina'] + a:000, s:Action)
endfunction
