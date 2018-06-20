function! docker_tools#GetHelp() abort
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
	call LoadDockerPS()
endfunction

function! docker_tools#VDEcho(msg) abort
	redraw
	echom "vim-docker: " . a:msg
endfunction

function! docker_tools#VDEchoError(msg) abort
	echohl errormsg
	call docker_tools#VDEcho(a:msg)
	echohl normal
endfunction

function! docker_tools#VDEchoWarning(msg) abort
	echohl warningmsg
	call docker_tools#VDEcho(a:msg)
	echohl normal
endfunction

function! docker_tools#VDExec(command) abort
	call docker_tools#TerminalCommand(printf('docker exec -ti %s sh -c "%s"',FindContainerID(),a:command),FindContainerID())
endfunction

function! docker_tools#TerminalCommand(command,termname) abort
	if has('nvim')
		silent execute printf("botright %d split TERM",g:vdocker_term_splitsize)
		call termopen(a:command)
	elseif has('terminal')
		silent execute printf("botright %d split TERM",g:vdocker_term_splitsize)
		call term_start(a:command,{"term_finish":['open','close'][g:vdocker_term_closeonexit],"term_name":a:termname,"curwin":"1"})
	else
		call docker_tools#VDEchoError('terminal is not supported')
	endif
endfunction

function! docker_tools#EchoContainerActionMessage(action,id) abort
	if a:action=='start'
		call docker_tools#VDEcho('Starting container '.a:id.'...')
	elseif a:action=='stop'
		call docker_tools#VDEcho('Stopping container '.a:id.'...')
	elseif a:action=='rm'
		call docker_tools#VDEcho('Removing container '.a:id.'...')
	elseif a:action=='restart'
		call docker_tools#VDEcho('Restarting container '.a:id.'...')
	endif
endfunction

function! docker_tools#ContainerAction(action,id,options) abort
	call docker_tools#EchoContainerActionMessage(a:action,a:id)
	if has('nvim')
		call jobstart(printf('docker container %s %s %s',a:action,a:options,a:id),{'on_stdout': 'docker_tools#ActionCallBack','on_stderr': 'docker_tools#ErrCallBack'})
	elseif has('job')
		call job_start(printf('docker container %s %s %s',a:action,a:options,a:id),{'out_cb': 'docker_tools#ActionCallBack','err_cb': 'docker_tools#ErrCallBack'})
	else
		call system(printf('docker container %s %s %s',a:action,a:options,shellescape(a:id)))
	endif
endfunction

function! docker_tools#ActionCallBack(...) abort
	if exists('g:vdocker_windowid')
		let a:current_windowid = win_getid()
		call win_gotoid(g:vdocker_windowid)
		call LoadDockerPS()
		call win_gotoid(a:current_windowid)
	endif
	if has('nvim')
		call docker_tools#VDEcho(a:2[0])
	else
		call docker_tools#VDEcho(a:2)
	endif
endfunction

function! docker_tools#LeaveVDSplit() abort
	if exists('g:vdocker_windowid')
		unlet g:vdocker_windowid
	endif
endfunction

function! docker_tools#ErrCallBack(...) abort
	if has('nvim')
		call docker_tools#VDEchoError(a:2[0])
	else
		call docker_tools#VDEchoError(a:2)
	endif
endfunction

function! docker_tools#SetKeyMapping() abort
		nnoremap <buffer> <silent> q :CloseVDSplit<CR>
		nnoremap <buffer> <silent> s :call VDContainerAction('start',FindContainerID())<CR>
		nnoremap <buffer> <silent> d :call VDContainerAction('stop',FindContainerID())<CR>
		nnoremap <buffer> <silent> x :call VDContainerAction('rm',FindContainerID())<CR>
		nnoremap <buffer> <silent> r :call VDContainerAction('restart',FindContainerID())<CR>
		nnoremap <buffer> <silent> p :call VDContainerAction('pause',FindContainerID())<CR>
		nnoremap <buffer> <silent> u :call VDContainerAction('unpause',FindContainerID())<CR>
		nnoremap <buffer> <silent> > :call VDRunCommand()<CR>
		nnoremap <buffer> <silent> < :call VDContainerLogs(FindContainerID())<CR>
		nnoremap <buffer> <silent> ? :call docker_tools#ToggleHelp()<CR>
endfunction
