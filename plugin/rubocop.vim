" The "Vim RuboCop" plugin runs RuboCop and displays the results in Vim.
"
" Author:    Yuta Nagamiya
" URL:       https://github.com/ngmy/vim-rubocop
" Version:   0.4
" Copyright: Copyright (c) 2013 Yuta Nagamiya
" License:   MIT
" ----------------------------------------------------------------------------

if exists('g:loaded_vimrubocop') || &cp
  finish
endif
let g:loaded_vimrubocop = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:vimrubocop_rubocop_cmd')
  let g:vimrubocop_rubocop_cmd = 'rubocop '
endif

" Options
if !exists('g:vimrubocop_config')
  let g:vimrubocop_config = ''
endif

if !exists('g:vimrubocop_extra_args')
  let g:vimrubocop_extra_args = ''
endif

if !exists('g:vimrubocop_keymap')
  let g:vimrubocop_keymap = 1
endif

if exists('*trim')
  function! s:Trim(str) abort
    return trim(a:str)
  endfunction
else
  function! s:Trim(str) abort
    return substitute(a:str, '^\s*\(.\{-}\)\s*$', '\1', '')
  endfunction
endif

let s:rubocop_switches = [
            \ '--force-default-config',
            \ '--except',
            \ '--only',
            \ '--only-guide-cops',
            \ '-F', '--fail-fast',
            \ '-d', '--debug',
            \ '-D', '--display-cop-names',
            \ '-E', '--extra-details',
            \ '-S', '--display-style-guide',
            \ '-a', '--auto-correct', '--safe-auto-correct',
            \ '-A', '--auto-correct-all',
            \ '--disable-pending-cops',
            \ '--enable-pending-cops',
            \ '--ignore-disable-comments',
            \ '--safe',
            \ '--color', '--no-color',
            \ '-v', '--version',
            \ '-V', '--verbose-version',
            \ '-P', '--parallel', '--no-parallel',
            \ '-l', '--lint',
            \ '-x', '--fix-layout',
            \ ]

function! s:RuboCopSwitches(...) abort
  return join(s:rubocop_switches, "\n")
endfunction

function! s:BuildRuboCopCommand(current_args) abort
  let l:cmd = [
        \ g:vimrubocop_rubocop_cmd,
        \ strlen(g:vimrubocop_config) ? '--config ' . g:vimrubocop_config : '',
        \ '--format emacs',
        \ a:current_args,
        \ g:vimrubocop_extra_args
        \]
  let l:cmd = filter(map(l:cmd, 's:Trim(v:val)'), 'strlen(v:val)')
  return join(l:cmd, ' ')
endfunction

function! s:RuboCop(filename, current_args) abort
  let l:filename      = a:filename
  let l:rubocop_cmd   = s:BuildRuboCopCommand(a:current_args)
  let l:quickfix_type = empty(l:filename) ? 'c' : 'l'

  let l:cmd = s:Trim(l:rubocop_cmd . ' ' . l:filename)
  let s:quickfix_title = l:cmd

  let l:rubocop_output  = system(l:cmd)
  if strlen(matchstr(l:rubocop_cmd, '--auto-correct-all\|--safe-auto-correct\|--auto-correct\|-\<a\>\|-\<A\>'))
    "Reload file if using auto correct
    edit
  endif
  let l:rubocop_output  = substitute(l:rubocop_output, '\\"', "'", 'g')
  let l:rubocop_results = split(l:rubocop_output, "\n")
  if l:quickfix_type == 'c'
    cexpr l:rubocop_results
  else
    lexpr l:rubocop_results
  endif
  if len(l:rubocop_results) > 0
    execute l:quickfix_type . 'open'
    let w:quickfix_title = s:quickfix_title
  else
    execute l:quickfix_type . 'close'
    echom 'Rubocop: Passed. Hooray!'
  endif
endfunction

command! -complete=custom,s:RuboCopSwitches -nargs=? RuboCop        :call <SID>RuboCop(@%, <q-args>)
command! -complete=custom,s:RuboCopSwitches -nargs=? RuboCopProject :call <SID>RuboCop('', <q-args>)

" Shortcuts for RuboCop
if g:vimrubocop_keymap == 1
  nnoremap <silent> <Leader>ru :RuboCop<CR>
  nnoremap <silent> <Leader>rp :RuboCopProject<CR>
endif

let &cpo = s:save_cpo
