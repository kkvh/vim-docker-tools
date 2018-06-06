let g:vdocker_splitsize = 15
let g:vdocker_term_splitsize = 15
let g:vdocker_term_closeonexit = 0

command! OpenVDSplit call OpenVDSplit()
command! CloseVDSplit call CloseVDSplit()
command! ToggleVDSplit call ToggleVDSplit()
command! VDRunCommand call VDRunCommand()
command! -nargs=+ ContainerStart call VDContainerAction('start',<f-args>)
command! -nargs=+ ContainerStop call VDContainerAction('stop',<f-args>)
command! -nargs=+ ContainerRemove call VDContainerAction('rm',<f-args>)
command! -nargs=+ ContainerRestart call VDContainerAction('restart',<f-args>)
command! -nargs=+ ContainerPause call VDContainerAction('pause',<f-args>)
command! -nargs=+ ContainerUnpause call VDContainerAction('unpause',<f-args>)

function! SetKeyMapping() abort
		nnoremap <buffer> <silent> q :CloseVDSplit<CR>
		nnoremap <buffer> <silent> s :call VDContainerAction('start',FindContainerID())<CR>
		nnoremap <buffer> <silent> d :call VDContainerAction('stop',FindContainerID())<CR>
		nnoremap <buffer> <silent> x :call VDContainerAction('rm',FindContainerID())<CR>
		nnoremap <buffer> <silent> r :call VDContainerAction('restart',FindContainerID())<CR>
		nnoremap <buffer> <silent> p :call VDContainerAction('pause',FindContainerID())<CR>
		nnoremap <buffer> <silent> u :call VDContainerAction('unpause',FindContainerID())<CR>
		nnoremap <buffer> <silent> > :call VDRunCommand()<CR>
		nnoremap <buffer> <silent> ? :call docker_tools#ToggleHelp()<CR>
endfunction

function! OpenVDSplit() abort
	if !exists('g:vdocker_windowid')
		silent execute printf("topleft %s split DOCKER",g:vdocker_splitsize)
		silent topleft 
		let b:show_help = 0
		setlocal buftype=nofile
		setlocal cursorline
		setlocal filetype=docker-tools
		setlocal winfixheight
		call LoadDockerPS()
		silent 2

		setlocal nobuflisted
		let g:vdocker_windowid = win_getid()
		autocmd BufWinLeave <buffer> call LeaveVDSplit()
		autocmd CursorHold <buffer> call LoadDockerPS()
		call SetKeyMapping()
	else
		call win_gotoid(g:vdocker_windowid)
	endif
endfunction

function! CloseVDSplit() abort
	if exists('g:vdocker_windowid')
		call win_gotoid(g:vdocker_windowid)
		quit
	endif
endfunction

function! ToggleVDSplit() abort
	if !exists('g:vdocker_windowid')
		call OpenVDSplit()
	else
		call CloseVDSplit()
	endif
endfunction

function! LeaveVDSplit() abort
	if exists('g:vdocker_windowid')
		unlet g:vdocker_windowid
	endif
endfunction

function! LoadDockerPS() abort
	setlocal modifiable
	let a:save_cursor = getcurpos()
	silent 1,$d
	if b:show_help
		call docker_tools#GetHelp()
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

function! FindContainerID() abort
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

function! ContainerAction(action,id,options) abort
	call EchoContainerActionMessage(a:action,a:id)
	if has('nvim')
		call jobstart(printf('docker container %s %s %s',a:action,a:options,a:id),{'on_stdout': 'ActionCallBack','on_stderr': 'ErrCallBack'})
	elseif has('job')
		call job_start(printf('docker container %s %s %s',a:action,a:options,a:id),{'out_cb': 'ActionCallBack','err_cb': 'ErrCallBack'})
	else
		call system(printf('docker container %s %s %s',a:action,a:options,shellescape(a:id)))
	endif
endfunction

function! EchoContainerActionMessage(action,id) abort
	if a:action=='start'
		call VDEcho('Starting container '.a:id.'...')
	elseif a:action=='stop'
		call VDEcho('Stopping container '.a:id.'...')
	elseif a:action=='rm'
		call VDEcho('Removing container '.a:id.'...')
	elseif a:action=='restart'
		call VDEcho('Restarting container '.a:id.'...')
	endif
endfunction

function! ActionCallBack(...) abort
	if exists('g:vdocker_windowid')
		let a:current_windowid = win_getid()
		call win_gotoid(g:vdocker_windowid)
		call LoadDockerPS()
		call win_gotoid(a:current_windowid)
	endif
	if has('nvim')
		call VDEcho(a:2[0])
	else
		call VDEcho(a:2)
	endif
endfunction

function! ErrCallBack(...) abort
	if has('nvim')
		call VDEchoError(a:2[0])
	else
		call VDEchoError(a:2)
	endif
endfunction

function! VDContainerAction(action,id,...) abort
	if a:id !=# ""
		call ContainerAction(a:action,a:id,join(a:000,' '))
	endif
endfunction

function! TerminalCommand(command,termname) abort
	if has('nvim')
		silent execute printf("botright %d split TERM",g:vdocker_term_splitsize)
		call termopen(a:command)
	elseif has('terminal')
		silent execute printf("botright %d split TERM",g:vdocker_term_splitsize)
		call term_start(a:command,{"term_finish":['open','close'][g:vdocker_term_closeonexit],"term_name":a:termname,"curwin":"1"})
	else
		call VDEchoError('terminal is not supported')
	endif
endfunction

function! VDExec(command) abort
	call TerminalCommand(printf('docker exec -ti %s sh -c "%s"',FindContainerID(),a:command),FindContainerID())
endfunction

function! VDRunCommand() abort
	let command = input('Enter command: ')
	call VDExec(command)
endfunction

function! VDEcho(msg) abort
	redraw
	echom "vim-docker: " . a:msg
endfunction

function! VDEchoError(msg) abort
	echohl errormsg
	call VDEcho(a:msg)
	echohl normal
endfunction

function! VDEchoWarning(msg) abort
	echohl warningmsg
	call VDEcho(a:msg)
	echohl normal
endfunction
