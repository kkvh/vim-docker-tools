let g:vdocker_splitsize = 15

command! OpenVDSplit :call OpenVDSplit()
command! CloseVDSplit :call CloseVDSplit()
command! ToggleVDSplit :call ToggleVDSplit()
command! VDRunCommand :call VDRunCommand()

function! SetKeyMapping()
		nnoremap <buffer> <silent> q :CloseVDSplit<CR>
		nnoremap <buffer> <silent> s :call VDContainerAction('start')<CR>
		nnoremap <buffer> <silent> d :call VDContainerAction('stop')<CR>
		nnoremap <buffer> <silent> x :call VDContainerAction('rm')<CR>
		nnoremap <buffer> <silent> r :call VDContainerAction('restart')<CR>
		nnoremap <buffer> <silent> > :call VDExec('sh')<CR>
		nnoremap <buffer> <silent> < :call VDRunCommand()<CR>
		nnoremap <buffer> <silent> ? :call ToggleHelp()<CR>
endfunction

function! OpenVDSplit()
	if !exists('g:vdocker_windowid')
		silent execute "topleft ".g:vdocker_splitsize."split DOCKER"
		silent topleft 
		let b:show_help = 0
		setlocal buftype=nofile
		setlocal cursorline
		setlocal filetype=vim-docker
		call LoadDockerPS()
		normal! 2G
		setlocal nobuflisted
		let g:vdocker_windowid = win_getid()
		autocmd BufWinLeave <buffer> call LeaveVDSplit()
		call SetKeyMapping()
	else
		call win_gotoid(g:vdocker_windowid)
	endif
endfunction

function! CloseVDSplit()
	if exists('g:vdocker_windowid')
		call win_gotoid(g:vdocker_windowid)
		quit
	endif
endfunction

function! ToggleVDSplit()
	if !exists('g:vdocker_windowid')
		call OpenVDSplit()
	else
		call CloseVDSplit()
	endif
endfunction

function! LeaveVDSplit()
	if exists('g:vdocker_windowid')
		unlet g:vdocker_windowid
	endif
endfunction

function! LoadDockerPS()
	setlocal modifiable
	let a:save_cursor = getcurpos()
	normal! ggdG
	if b:show_help
		call GetHelp()
		let b:first_row = getcurpos()[1]
	else
		let help = "# Press ? for help"
		silent! put =help
		let b:first_row = 1
	endif
	silent! read ! docker ps -a
	normal! 1Gdd
	call setpos('.', a:save_cursor)
	setlocal nomodifiable
endfunction

function! RefreshPanel(timerId)
	call LoadDockerPS()
endfunction

function! FindContainerID()
	let a:row_num = getcurpos()[1]
	if a:row_num <=# b:first_row
		return ""
	endif
	call search("CONTAINER ID")
	let a:current_cursor = getcurpos()
	if a:current_cursor[1] !=# b:first_row
		call VDEchoError("No container ID found")
		return ""
	endif
	let a:current_cursor[1] = a:row_num
	call setpos('.', a:current_cursor)
	return expand('<cWORD>')
endfunction

function! ContainerAction(action,dockerid)
	call EchoContainerActionMessage(a:action,a:dockerid)
	if has('nvim')
		call jobstart('docker container '.a:action.' '.a:dockerid,{'on_stdout': 'ActionCallBack','on_stderr': 'ErrCallBack'})
	elseif has('job')
		call job_start('docker container '.a:action.' '.a:dockerid,{'out_cb': 'ActionCallBack','err_cb': 'ErrCallBack'})
	else
		call system('docker container '.a:action.' '.shellescape(a:dockerid))
	endif
endfunction

function! EchoContainerActionMessage(action,dockerid)
	if a:action=='start'
		call VDEcho('Starting container '.a:dockerid.'...')
	elseif a:action=='stop'
		call VDEcho('Stopping container '.a:dockerid.'...')
	elseif a:action=='rm'
		call VDEcho('Removing container '.a:dockerid.'...')
	elseif a:action=='restart'
		call VDEcho('Restarting container '.a:dockerid.'...')
	endif
endfunction

function! ActionCallBack(...)
	if exists('g:vdocker_windowid')
		let a:current_windowid = win_getid()
		call win_gotoid(g:vdocker_windowid)
		call LoadDockerPS()
		call win_gotoid(a:current_windowid)
		if has('nvim')
			call VDEcho(a:2[0])
		else
			call VDEcho(a:2)
		endif
	endif
endfunction

function! ErrCallBack(...)
	if has('nvim')
		call VDEchoError(a:2[0])
	else
		call VDEchoError(a:2)
	endif
endfunction

function! VDContainerAction(action)
	let id = FindContainerID()
	if id !=# ""
		call ContainerAction(a:action,id)
	endif
endfunction

function! TerminalCommand(command,termname)
	if has('nvim')
		silent execute "leftabove split TERM"
		call termopen(a:command)
	elseif has('terminal')
		call term_start(a:command,{"term_finish":"close","term_name":a:termname})
	else
		call VDEchoError('terminal is not supported')
	endif
endfunction

function! VDExec(command)
	call TerminalCommand('docker exec -ti '.FindContainerID().' sh -c "'.a:command.'"',FindContainerID())
endfunction

function! VDRunCommand()
	let command = input('Enter command: ')
	call VDExec(command)
endfunction

function! GetHelp()
	let help = "# Vim-docker Tools quickhelp\n"
	let help .= "# ------------------------------------------------------------------------------\n"
	let help .= "# s: start container\n"
	let help .= "# d: stop container\n"
	let help .= "# r: restart container\n"
	let help .= "# x: delete container\n"
	let help .= "# <: execute command to container\n"
	let help .= "# >: attach to container\n"
	let help .= "# ?: toggle help\n"
	let help .= "# ------------------------------------------------------------------------------\n"
	silent! put =help
endfunction

function! ToggleHelp()
	let b:show_help = !b:show_help
	call LoadDockerPS()
endfunction

function! VDEcho(msg)
	redraw
	echom "vim-docker: " . a:msg
endfunction

function! VDEchoError(msg)
	echohl errormsg
	call VDEcho(a:msg)
	echohl normal
endfunction

function! VDEchoWarning(msg)
	echohl warningmsg
	call VDEcho(a:msg)
	echohl normal
endfunction
