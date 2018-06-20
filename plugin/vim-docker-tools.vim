let g:vdocker_splitsize = 15
let g:vdocker_term_splitsize = 15
let g:vdocker_term_closeonexit = 1
let g:vdocker_logs_splitsize = 30

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
command! -nargs=+ ContainerLogs call VDContainerLogs(<f-args>)

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
		autocmd BufWinLeave <buffer> call docker_tools#LeaveVDSplit()
		autocmd CursorHold <buffer> call LoadDockerPS()
		call docker_tools#SetKeyMapping()
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
		call docker_tools#VDEchoError("No container ID found")
		return ""
	endif
	let a:current_cursor[1] = a:row_num
	call setpos('.', a:current_cursor)
	return expand('<cWORD>')
endfunction

function! VDContainerAction(action,id,...) abort
	call docker_tools#ContainerAction(a:action,a:id,join(a:000,' '))
endfunction

function! VDContainerLogs(id,...) abort
	silent execute printf("botright %d split %s_LOGS",g:vdocker_logs_splitsize,a:id)
	setlocal buftype=nofile
	setlocal cursorline
	setlocal nobuflisted
	nnoremap <buffer> <silent> q :quit<CR>
	silent execute printf("read ! docker container logs %s %s",join(a:000,' '),a:id)
	silent 1d
endfunction

function! VDRunCommand() abort
	let command = input('Enter command: ')
	call docker_tools#VDExec(command)
endfunction
