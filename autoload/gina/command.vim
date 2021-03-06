function! gina#command#call(bang, range, rargs, mods) abort
  if a:bang ==# '!'
    return gina#command#call('', a:range, '_raw ' . a:rargs, a:mods)
  endif
  let args = gina#core#args#new(a:rargs)
  try
    call gina#core#exception#call(
          \ printf('gina#command#%s#call', args.params.scheme),
          \ [a:range, args, a:mods],
          \)
    return
  catch /^Vim\%((\a\+)\)\=:E117: [^:]\+: gina#command#[^#]\+#call/
    call gina#core#console#debug(v:exception)
    call gina#core#console#debug(v:throwpoint)
  endtry
  return gina#command#call('', a:range, '_raw ' . a:rargs, a:mods)
endfunction

function! gina#command#complete(arglead, cmdline, cursorpos) abort
  if a:cmdline =~# '^Gina!'
    return gina#command#complete(
          \ a:arglead,
          \ substitute(a:cmdline, '^Gina!', 'Gina _raw', ''),
          \ a:cursorpos,
          \)
  elseif a:cmdline =~# printf('^Gina\s\+%s$', a:arglead)
    return gina#complete#common#command(a:arglead, a:cmdline, a:cursorpos)
  endif
  let cmdline = matchstr(a:cmdline, '^Gina\s\+\zs.*')
  let scheme = matchstr(cmdline, '^\S\+')
  let scheme = substitute(scheme, '!$', '', '')
  let scheme = substitute(scheme, '\W', '_', 'g')
  try
    return gina#core#exception#call(
          \ printf('gina#command#%s#complete', scheme),
          \ [a:arglead, cmdline, a:cursorpos],
          \)
  catch /^Vim\%((\a\+)\)\=:E117: [^:]\+: gina#command#[^#]\+#complete/
    call gina#core#console#debug(v:exception)
    call gina#core#console#debug(v:throwpoint)
  endtry
  return gina#command#complete(
        \ a:arglead,
        \ substitute(a:cmdline, '^Gina', 'Gina _raw', ''),
        \ a:cursorpos,
        \)
endfunction

function! gina#command#scheme(sfile) abort
  let name = fnamemodify(a:sfile, ':t')
  let name = matchstr(name, '.*\ze\.vim')
  let scheme = substitute(name, '_', '-', 'g')
  return scheme
endfunction


" Obsolete -------------------------------------------------------------------
function! gina#command#custom(scheme, query, ...) abort
  call gina#core#console#warn(
        \ 'gina#command#custom is obsolete. Use gina#custom#command#option'
        \)
  call gina#custom#command#option(a:scheme, a:query, get(a:000, 0, 1))
endfunction
