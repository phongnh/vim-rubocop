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

let s:rubocop_switches = [
            \ '-F', '--fail-fast',
            \ '-D', '--display-cop-names',
            \ '-S', '--display-style-guide',
            \ '-R', '--rails',
            \ '-n', '--no-color', '--color',
            \ '-l', '--lint',
            \ '-a', '--auto-correct',
            \ '-v', '--version',
            \ '-V', '--verbose-version'
            \ ]

function! s:RuboCopSwitches(...) abort
  return join(s:rubocop_switches, "\n")
endfunction

function! s:RuboCop(filename, current_args) abort
  let l:filename       = a:filename
  let l:extra_args     = g:vimrubocop_extra_args
  let l:rubocop_cmd    = g:vimrubocop_rubocop_cmd
  let l:rubocop_opts   = ' --format emacs '.a:current_args.' '.l:extra_args

  if g:vimrubocop_config != ''
    let l:rubocop_opts = ' --config '.g:vimrubocop_config.' '.l:rubocop_opts
  endif

  let l:rubocop_output  = system(l:rubocop_cmd.l:rubocop_opts.' '.l:filename)
  if !empty(matchstr(l:rubocop_opts, '--auto-correct\|-\<a\>'))
    "Reload file if using auto correct
    edit
  endif
  let l:rubocop_output  = substitute(l:rubocop_output, '\\"', "'", 'g')
  let l:rubocop_results = split(l:rubocop_output, "\n")
  lexpr l:rubocop_results
  if len(l:rubocop_results) > 0
    lopen
  else
    lclose
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
