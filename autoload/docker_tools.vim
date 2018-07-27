"docker tools controls{{{
function! docker_tools#dt_open() abort
	if !exists('g:vdocker_windowid')
		silent execute printf("topleft %s split DOCKER",g:dockertools_size)
		silent topleft
		let b:show_help = 0
		let b:show_all_containers = g:dockertools_default_all
		setlocal buftype=nofile
		setlocal cursorline
		setlocal filetype=docker-tools
		setlocal winfixheight
		call s:dt_ui_load()
		silent 2
		setlocal nobuflisted
		let g:vdocker_windowid = win_getid()
		autocmd BufWinLeave <buffer> call s:dt_unset_winid()
		autocmd CursorHold <buffer> call s:dt_ui_load()
		call s:dt_set_mapping()
	else
		call win_gotoid(g:vdocker_windowid)
	endif
endfunction

function! docker_tools#dt_close() abort
	if exists('g:vdocker_windowid')
		call win_gotoid(g:vdocker_windowid)
		quit
	endif
endfunction

function! docker_tools#dt_toggle() abort
	if !exists('g:vdocker_windowid')
		call docker_tools#dt_open()
	else
		call docker_tools#dt_close()
	endif
endfunction

function! docker_tools#dt_set_host(...) 
	if a:0 == 1
		let g:dockertools_docker_cmd = join(['docker -H', a:1], ' ')
	else
		let g:dockertools_docker_cmd = 'docker'
	endif
endfunction

"}}}
"docker tools commands{{{
function! docker_tools#dt_action(action) abort
	if s:dt_container_selected()
		call docker_tools#container_action(a:action,s:dt_get_id())
	endif
endfunction

function! docker_tools#dt_run_command() abort
	if s:dt_container_selected()
		let command = input('Enter command: ')
		call s:container_exec(command)
	endif
endfunction

function! docker_tools#dt_toggle_help() abort
	let b:show_help = !b:show_help
	call s:dt_ui_load()
endfunction

function! docker_tools#dt_toggle_all() abort
	let b:show_all_containers = !b:show_all_containers
	call s:dt_ui_load()
endfunction

function! docker_tools#dt_logs() abort
	if s:dt_container_selected()
		call docker_tools#container_logs(s:dt_get_id())
	endif
endfunction
"}}}
"docker tools callbacks{{{
function! docker_tools#action_cb(...) abort
	if exists('g:vdocker_windowid')
		let a:current_windowid = win_getid()
		call win_gotoid(g:vdocker_windowid)
		call s:dt_ui_load()
		call win_gotoid(a:current_windowid)
	endif
	if has('nvim')
		call s:echo_msg(a:2[0])
	else
		call s:echo_msg(a:2)
	endif
endfunction

function! docker_tools#err_cb(...) abort
	if has('nvim')
		call s:echo_error(a:2[0])
	else
		call s:echo_error(a:2)
	endif
endfunction
"}}}
"docker tools functions{{{
function! s:dt_get_id() abort
	let a:row_num = getcurpos()[1]
	call search("CONTAINER ID")
	let a:current_cursor = getcurpos()
	if a:current_cursor[1] !=# b:first_row
		call s:echo_error("No container ID found")
		return ""
	endif
	let a:current_cursor[1] = a:row_num
	call setpos('.', a:current_cursor)
	return expand('<cWORD>')
endfunction

function! s:dt_set_mapping() abort
		nnoremap <buffer> <silent> q :DockerToolsClose<CR>
		nnoremap <buffer> <silent> s :call docker_tools#dt_action('start')<CR>
		nnoremap <buffer> <silent> d :call docker_tools#dt_action('stop')<CR>
		nnoremap <buffer> <silent> x :call docker_tools#dt_action('rm')<CR>
		nnoremap <buffer> <silent> r :call docker_tools#dt_action('restart')<CR>
		nnoremap <buffer> <silent> p :call docker_tools#dt_action('pause')<CR>
		nnoremap <buffer> <silent> u :call docker_tools#dt_action('unpause')<CR>
		nnoremap <buffer> <silent> > :call docker_tools#dt_run_command()<CR>
		nnoremap <buffer> <silent> < :call docker_tools#dt_logs()<CR>
		nnoremap <buffer> <silent> a :call docker_tools#dt_toggle_all()<CR>
		nnoremap <buffer> <silent> ? :call docker_tools#dt_toggle_help()<CR>
endfunction

function! s:dt_ui_load() abort
	setlocal modifiable
	let a:save_cursor = getcurpos()
	silent 1,$d
	if b:show_help
		call s:dt_get_help()
		let b:first_row = getcurpos()[1]
	else
		let help = "# Press ? for help"
		silent! put =help
		let b:first_row = 2
	endif

	silent! execute printf("read ! %s%s ps%s",s:sudo_mode(),g:dockertools_docker_cmd,['',' -a'][b:show_all_containers])

	silent 1d
	call setpos('.', a:save_cursor)
	setlocal nomodifiable
endfunction

function! s:dt_get_help() abort
	let help = "# vim-docker-tools quickhelp\n"
	let help .= "# ------------------------------------------------------------------------------\n"
	let help .= "# s: start container\n"
	let help .= "# d: stop container\n"
	let help .= "# r: restart container\n"
	let help .= "# x: delete container\n"
	let help .= "# p: pause container\n"
	let help .= "# u: unpause container\n"
	let help .= "# >: execute command to container\n"
	let help .= "# <: show container logs\n"
	let help .= "# a: toggle show all/running containers\n"
	let help .= "# ?: toggle help\n"
	let help .= "# ------------------------------------------------------------------------------\n"
	silent! put =help
endfunction

function! s:dt_unset_winid() abort
	if exists('g:vdocker_windowid')
		unlet g:vdocker_windowid
	endif
endfunction

function! s:dt_container_selected() abort
	let a:row_num = getcurpos()[1]
	if a:row_num <=# b:first_row
		return 0
	endif
	return 1
endfunction
"}}}
"container commands{{{
function! docker_tools#container_action(action,id,...) abort
	call s:container_action_run(a:action,a:id,join(a:000,' '))
endfunction

function! docker_tools#container_logs(id,...) abort
	silent execute printf("botright %d split %s_LOGS",g:dockertools_logs_size,a:id)
	setlocal buftype=nofile
	setlocal cursorline
	setlocal nobuflisted
	nnoremap <buffer> <silent> q :quit<CR>
	silent execute printf("read ! %s%s container logs %s %s",s:sudo_mode(),g:dockertools_docker_cmd,join(a:000,' '),a:id)
	silent 1d
endfunction
"}}}
"container functions{{{
function! s:container_exec(command) abort
	if a:command !=# ""
		let containerid = s:dt_get_id()
		call s:term_win_open(printf('%s%s exec -ti %s sh -c "%s"',s:sudo_mode(),g:dockertools_docker_cmd,containerid,a:command),containerid)
	endif
endfunction

function! s:container_action_run(action,id,options) abort
	call s:echo_container_action_msg(a:action,a:id)
	if has('nvim')
		call jobstart(printf('%s%s container %s %s %s',s:sudo_mode(),g:dockertools_docker_cmd,a:action,a:options,a:id),{'on_stdout': 'docker_tools#action_cb','on_stderr': 'docker_tools#err_cb'})
	elseif has('job') && !g:dockertools_disable_job
		call job_start(printf('%s%s container %s %s %s',s:sudo_mode(),g:dockertools_docker_cmd,a:action,a:options,a:id),{'out_cb': 'docker_tools#action_cb','err_cb': 'docker_tools#err_cb'})
	else
		call system(printf('%s%s container %s %s %s',s:sudo_mode(),g:dockertools_docker_cmd,a:action,a:options,shellescape(a:id)))
	endif
endfunction

function! s:echo_container_action_msg(action,id) abort
	if a:action=='start'
		call s:echo_msg('Starting container '.a:id.'...')
	elseif a:action=='stop'
		call s:echo_msg('Stopping container '.a:id.'...')
	elseif a:action=='rm'
		call s:echo_msg('Removing container '.a:id.'...')
	elseif a:action=='restart'
		call s:echo_msg('Restarting container '.a:id.'...')
	endif
endfunction

function! s:refresh_container_list() abort
	let container_str = system(g:dockertools_docker_cmd + ' ps -a --format="{{.ID}} {{.Names}}"')
	let s:container_list = split(container_str)
endfunction

function! docker_tools#complete(ArgLead, CmdLine, CursorPos) abort
	if !exists('s:container_list')
		call s:refresh_container_list()
	endif
	return filter(s:container_list, 'v:val =~ "^'.a:ArgLead.'"')
endfunction
"}}}
"utils{{{
function! s:echo_msg(msg) abort
	redraw
	echom "vim-docker: " . a:msg
endfunction

function! s:echo_error(msg) abort
	echohl errormsg
	call s:echo_msg(a:msg)
	echohl normal
endfunction

function! s:echo_warning(msg) abort
	echohl warningmsg
	call s:echo_msg(a:msg)
	echohl normal
endfunction

function! s:term_win_open(command,termname) abort
	if has('nvim')
		silent execute printf("botright %d split TERM",g:dockertools_term_size)
		call termopen(a:command)
	elseif has('terminal')
		silent execute printf("botright %d split TERM",g:dockertools_term_size)
		call term_start(a:command,{"term_finish":['open','close'][g:dockertools_term_closeonexit],"term_name":a:termname,"curwin":"1"})
	else
		call s:echo_error('terminal is not supported')
	endif
endfunction

function! s:sudo_mode() abort
	return ['','sudo '][g:dockertools_sudo_mode]
endfunction
"}}}
" vim: fdm=marker:
