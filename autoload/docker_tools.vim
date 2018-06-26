function! s:help_get() abort
	let help = "# Vim-docker Tools quickhelp\n"
	let help .= "# ------------------------------------------------------------------------------\n"
	let help .= "# s: start container\n"
	let help .= "# d: stop container\n"
	let help .= "# r: restart container\n"
	let help .= "# x: delete container\n"
	let help .= "# p: pause container\n"
	let help .= "# u: unpause container\n"
	let help .= "# >: execute command to container\n"
	let help .= "# <: show container logs\n"
	let help .= "# ?: toggle help\n"
	let help .= "# ------------------------------------------------------------------------------\n"
	silent! put =help
endfunction

function! docker_tools#ToggleHelp() abort
	let b:show_help = !b:show_help
	call s:ui_load()
endfunction

function! s:msg_echo(msg) abort
	redraw
	echom "vim-docker: " . a:msg
endfunction

function! s:error_echo(msg) abort
	echohl errormsg
	call s:msg_echo(a:msg)
	echohl normal
endfunction

function! s:warning_echo(msg) abort
	echohl warningmsg
	call s:msg_echo(a:msg)
	echohl normal
endfunction

function! s:container_exec(command) abort
	call s:term_win_open(printf('docker exec -ti %s sh -c "%s"',docker_tools#FindContainerID(),a:command),docker_tools#FindContainerID())
endfunction

function! s:term_win_open(command,termname) abort
	if has('nvim')
		silent execute printf("botright %d split TERM",g:vdocker_term_splitsize)
		call termopen(a:command)
	elseif has('terminal')
		silent execute printf("botright %d split TERM",g:vdocker_term_splitsize)
		call term_start(a:command,{"term_finish":['open','close'][g:vdocker_term_closeonexit],"term_name":a:termname,"curwin":"1"})
	else
		call s:error_echo('terminal is not supported')
	endif
endfunction

function! s:action_msg_echo(action,id) abort
	if a:action=='start'
		call s:msg_echo('Starting container '.a:id.'...')
	elseif a:action=='stop'
		call s:msg_echo('Stopping container '.a:id.'...')
	elseif a:action=='rm'
		call s:msg_echo('Removing container '.a:id.'...')
	elseif a:action=='restart'
		call s:msg_echo('Restarting container '.a:id.'...')
	endif
endfunction

function! docker_tools#ContainerAction(action,id,options) abort
	call s:action_msg_echo(a:action,a:id)
	if has('nvim')
		call jobstart(printf('docker container %s %s %s',a:action,a:options,a:id),{'on_stdout': 'docker_tools#action_cb','on_stderr': 'docker_tools#err_cb'})
	elseif has('job')
		call job_start(printf('docker container %s %s %s',a:action,a:options,a:id),{'out_cb': 'docker_tools#action_cb','err_cb': 'docker_tools#err_cb'})
	else
		call system(printf('docker container %s %s %s',a:action,a:options,shellescape(a:id)))
	endif
endfunction

function! docker_tools#action_cb(...) abort
	if exists('g:vdocker_windowid')
		let a:current_windowid = win_getid()
		call win_gotoid(g:vdocker_windowid)
		call s:ui_load()
		call win_gotoid(a:current_windowid)
	endif
	if has('nvim')
		call s:msg_echo(a:2[0])
	else
		call s:msg_echo(a:2)
	endif
endfunction

function! s:window_close() abort
	if exists('g:vdocker_windowid')
		unlet g:vdocker_windowid
	endif
endfunction

function! docker_tools#err_cb(...) abort
	if has('nvim')
		call s:error_echo(a:2[0])
	else
		call s:error_echo(a:2)
	endif
endfunction

function! docker_tools#VDContainerAction(action,id,...) abort
	call docker_tools#ContainerAction(a:action,a:id,join(a:000,' '))
endfunction

function! docker_tools#VDContainerLogs(id,...) abort
	silent execute printf("botright %d split %s_LOGS",g:vdocker_logs_splitsize,a:id)
	setlocal buftype=nofile
	setlocal cursorline
	setlocal nobuflisted
	nnoremap <buffer> <silent> q :quit<CR>
	silent execute printf("read ! docker container logs %s %s",join(a:000,' '),a:id)
	silent 1d
endfunction

function! docker_tools#VDRunCommand() abort
	let command = input('Enter command: ')
	call s:container_exec(command)
endfunction

function! s:mapping_set() abort
		nnoremap <buffer> <silent> q :CloseVDSplit<CR>
		nnoremap <buffer> <silent> s :call docker_tools#VDContainerAction('start',docker_tools#FindContainerID())<CR>
		nnoremap <buffer> <silent> d :call docker_tools#VDContainerAction('stop',docker_tools#FindContainerID())<CR>
		nnoremap <buffer> <silent> x :call docker_tools#VDContainerAction('rm',docker_tools#FindContainerID())<CR>
		nnoremap <buffer> <silent> r :call docker_tools#VDContainerAction('restart',docker_tools#FindContainerID())<CR>
		nnoremap <buffer> <silent> p :call docker_tools#VDContainerAction('pause',docker_tools#FindContainerID())<CR>
		nnoremap <buffer> <silent> u :call docker_tools#VDContainerAction('unpause',docker_tools#FindContainerID())<CR>
		nnoremap <buffer> <silent> > :call docker_tools#VDRunCommand()<CR>
		nnoremap <buffer> <silent> < :call docker_tools#VDContainerLogs(docker_tools#FindContainerID())<CR>
		nnoremap <buffer> <silent> ? :call docker_tools#ToggleHelp()<CR>
endfunction

function! docker_tools#FindContainerID() abort
	let a:row_num = getcurpos()[1]
	if a:row_num <=# b:first_row
		return ""
	endif
	call search("CONTAINER ID")
	let a:current_cursor = getcurpos()
	if a:current_cursor[1] !=# b:first_row
		call s:error_echo("No container ID found")
		return ""
	endif
	let a:current_cursor[1] = a:row_num
	call setpos('.', a:current_cursor)
	return expand('<cWORD>')
endfunction

function! s:ui_load() abort
	setlocal modifiable
	let a:save_cursor = getcurpos()
	silent 1,$d
	if b:show_help
		call s:help_get()
		let b:first_row = getcurpos()[1]
	else
		let help = "# Press ? for help"
		silent! put =help
		let b:first_row = 2
	endif
	silent! read ! docker ps -a
	silent 1d
	call setpos('.', a:save_cursor)
	setlocal nomodifiable
endfunction

function! docker_tools#OpenVDSplit() abort
	if !exists('g:vdocker_windowid')
		silent execute printf("topleft %s split DOCKER",g:vdocker_splitsize)
		silent topleft 
		let b:show_help = 0
		setlocal buftype=nofile
		setlocal cursorline
		setlocal filetype=docker-tools
		setlocal winfixheight
		call s:ui_load()
		silent 2

		setlocal nobuflisted
		let g:vdocker_windowid = win_getid()
		autocmd BufWinLeave <buffer> call s:window_close()
		autocmd CursorHold <buffer> call s:ui_load()
		call s:mapping_set()
	else
		call win_gotoid(g:vdocker_windowid)
	endif
endfunction

function! docker_tools#CloseVDSplit() abort
	if exists('g:vdocker_windowid')
		call win_gotoid(g:vdocker_windowid)
		quit
	endif
endfunction

function! docker_tools#ToggleVDSplit() abort
	if !exists('g:vdocker_windowid')
		call docker_tools#OpenVDSplit()
	else
		call docker_tools#CloseVDSplit()
	endif
endfunction
