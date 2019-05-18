"docker tools controls{{{
function! docker_tools#dt_open() abort
	if !exists('s:dockertools_winid')
		silent execute printf("topleft %s split DOCKER",g:dockertools_size)
		let b:show_help = 0
		let b:show_all_containers = g:dockertools_default_all
		if !exists('s:dockertools_scope')
			let s:dockertools_scope = index(s:docker_scope, g:dockertools_default_scope)
			if s:dockertools_scope == -1
				let s:dockertools_scope = 0
			endif
		endif
		if !exists('s:dockertools_ls_filter')
			let s:dockertools_ls_filter = ''
		endif
		setlocal buftype=nofile cursorline winfixheight bufhidden=delete readonly nobuflisted noswapfile
		call s:dt_switch_panel()
		silent 2
		let s:dockertools_winid = win_getid()
		autocmd BufWinLeave <buffer> call s:dt_unset_winid()
		autocmd CursorHold <buffer> call s:dt_ui_load()
		call s:dt_set_mapping()
	else
		call win_gotoid(s:dockertools_winid)
	endif
endfunction

function! docker_tools#dt_close() abort
	if exists('s:dockertools_winid')
		call win_gotoid(s:dockertools_winid)
		quit
	endif
endfunction

function! docker_tools#dt_reload() abort
		call s:dt_ui_load()
endfunction

function! docker_tools#dt_toggle() abort
	if !exists('s:dockertools_winid')
		call docker_tools#dt_open()
	else
		call docker_tools#dt_close()
	endif
endfunction

function! docker_tools#dt_swap(i)
	let s:dockertools_scope = (s:dockertools_scope+a:i)%len(s:docker_scope)
	call s:dt_switch_panel()
endfunction

function! docker_tools#dt_go(i)
	let s:dockertools_scope = a:i
	call s:dt_switch_panel()
endfunction
"}}}
"docker tools commands{{{
function! docker_tools#dt_action(action) abort
	if s:dt_container_selected()
		call s:dt_do(s:docker_scope[s:dockertools_scope],a:action,s:dt_get_id())
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

function! docker_tools#dt_ui_set_filter()
	let l:filter = input("Enter Filter(s): ")
	call s:dt_set_filter(l:filter)
	call s:dt_ui_load()
endfunction
"}}}
"docker tools callbacks{{{
function! docker_tools#action_cb(...) abort
	if has('nvim')
		if a:2[0] ==# ''
			return
		endif
	endif
	if exists('s:dockertools_winid')
		let l:current_windowid = win_getid()
		call win_gotoid(s:dockertools_winid)
		call s:dt_ui_load()
		call win_gotoid(l:current_windowid)
	endif
	if has('nvim')
		call s:echo_msg(a:2[0])
	else
		call s:echo_msg(a:2)
	endif
endfunction

function! docker_tools#err_cb(...) abort
	if has('nvim')
		if a:2[0] ==# ''
			return
		endif
		call s:echo_error(a:2[0])
	else
		call s:echo_error(a:2)
	endif
endfunction
"}}}
"docker tools functions{{{
function! s:dt_get_id() abort
	let l:row_num = getcurpos()[1]
	call search("CONTAINER ID")
	let l:current_cursor = getcurpos()
	if l:current_cursor[1] !=# b:first_row
		call s:echo_error("No container ID found")
		return ""
	endif
	let l:current_cursor[1] = l:row_num
	call setpos('.', l:current_cursor)
	return expand('<cWORD>')
endfunction

function! s:dt_set_mapping() abort
	let l:mapping = s:dt_load_mapping(s:docker_scope[s:dockertools_scope])
	for [l:key,l:action] in items(l:mapping)
		execute 'nnoremap <buffer> <silent>' . l:key . ' :call docker_tools#dt_action("' . l:action . '")<CR>'
	endfor
	execute 'nnoremap <buffer> <silent>' . g:dockertools_key_mapping['ui-close'] . ' :DockerToolsClose<CR>'
	execute 'nnoremap <buffer> <silent>' . g:dockertools_key_mapping['ui-toggle-all'] . ' :call docker_tools#dt_toggle_all()<CR>'
	execute 'nnoremap <buffer> <silent>' . g:dockertools_key_mapping['ui-reload'] . ' :call docker_tools#dt_reload()<CR>'
	execute 'nnoremap <buffer> <silent>' . g:dockertools_key_mapping['ui-toggle-help'] . ' :call docker_tools#dt_toggle_help()<CR>'
	execute 'nnoremap <buffer> <silent>' . g:dockertools_key_mapping['ui-filter'] . ' :call docker_tools#dt_ui_set_filter()<CR>'
	nnoremap <buffer> <silent> <leader>> :call docker_tools#dt_swap(1)<CR>
	nnoremap <buffer> <silent> <leader>< :call docker_tools#dt_swap(-1)<CR>
	nnoremap <buffer> <silent> <leader>1 :call docker_tools#dt_go(0)<CR>
	nnoremap <buffer> <silent> <leader>2 :call docker_tools#dt_go(1)<CR>
	nnoremap <buffer> <silent> <leader>3 :call docker_tools#dt_go(2)<CR>
endfunction

function! s:dt_ui_load() abort
	setlocal modifiable
	let l:save_cursor = getcurpos()
	silent 1,$d
	if b:show_help
		call s:dt_get_help()
		let b:first_row = getcurpos()[1]
	else
		let help = "# Press ? for help"
		silent! put =help
		let b:first_row = 2
	endif

	if s:dockertools_ls_filter != ''
		silent! put ='Filter(s): '.s:dockertools_ls_filter
		let b:first_row += 1
	endif

	silent! execute printf("read ! %s%s %s ls %s %s",s:sudo_mode(),g:dockertools_docker_cmd,s:docker_scope[s:dockertools_scope],['','-a'][b:show_all_containers&&s:dockertools_scope!=2], s:dockertools_ls_filter)

	silent 1d
	call setpos('.', l:save_cursor)
	setlocal nomodifiable
endfunction

function! s:dt_get_help() abort
	let help = "# vim-docker-tools quickhelp\n"
	let help .= "# ------------------------------------------------------------------------------\n"
	let help .= "# " . g:dockertools_key_mapping['container-start'] . ": start container\n"
	let help .= "# " . g:dockertools_key_mapping['container-stop'] . ": stop container\n"
	let help .= "# " . g:dockertools_key_mapping['container-restart'] . ": restart container\n"
	let help .= "# " . g:dockertools_key_mapping['container-delete'] . ": delete container\n"
	let help .= "# " . g:dockertools_key_mapping['container-pause'] . ": pause container\n"
	let help .= "# " . g:dockertools_key_mapping['container-unpause'] . ": unpause container\n"
	let help .= "# " . g:dockertools_key_mapping['container-execute'] . ": execute command to container\n"
	let help .= "# " . g:dockertools_key_mapping['container-show-logs'] . ": show container logs\n"
	let help .= "# " . g:dockertools_key_mapping['ui-toggle-all'] . ": toggle show all/running containers\n"
	let help .= "# " . g:dockertools_key_mapping['ui-filter'] . ": set container filter\n"
	let help .= "# " . g:dockertools_key_mapping['ui-reload'] . ": refresh container status\n"
	let help .= "# " . g:dockertools_key_mapping['ui-close'] . ": close vim-docker-tools\n"
	let help .= "# " . g:dockertools_key_mapping['ui-toggle-help'] . ": toggle help\n"
	let help .= "# ------------------------------------------------------------------------------\n"
	silent! put =help
endfunction

function! s:dt_unset_winid() abort
	if exists('s:dockertools_winid')
		unlet s:dockertools_winid
	endif
endfunction

function! s:dt_container_selected() abort
	let l:row_num = getcurpos()[1]
	if l:row_num <=# b:first_row
		return 0
	endif
	return 1
endfunction

function! s:dt_set_filter(filters) abort
	"validate the filter keys
	"expect filters to be space delimited
	"expect key value to be '=' delimited
	if a:filters == ''
		let s:dockertools_ls_filter = ''
		return
	endif
	let l:filters = ''
	for l:ps_filter in split(a:filters, ' ')
		let l:filter_components = split(l:ps_filter, '=')
		if index(s:container_filters, filter_components[0]) > -1
			let l:filters = join([l:filters, '-f', l:ps_filter], ' ')
		endif
	endfor
	let s:dockertools_ls_filter = l:filters
endfunction

function! s:dt_do(scope,action,id,...) abort
	let l:config = s:dt_load_config(a:scope,a:action)
	if has_key(l:config,'options')
		let l:command = printf("%s%s %s %s %s %s %s",s:sudo_mode(),g:dockertools_docker_cmd,a:scope,a:action,join(a:000,' '),l:config.options,a:id)
	else
		let l:command = printf("%s%s %s %s %s %s",s:sudo_mode(),g:dockertools_docker_cmd,a:scope,a:action,join(a:000,' '),a:id)
	endif
	let l:runner = {'action':a:action,'id':a:id,'command':l:command}
	if has_key(l:config,'args')
		let l:runner.args = l:config.args
	endif
	let l:runner.Fn = funcref('s:'.l:config['mode'].'_mode')
	let l:runner.Do = funcref('s:'.l:config['type'].'_type')
	if has_key(l:config,'msg')
		call s:echo_msg(printf("%s %s...",l:config.msg,a:id))
	endif
	call l:runner.Do()
endfunction

function! s:dt_switch_panel()
	call s:dt_ui_load()
	execute printf("setlocal filetype=docker-tools-%s", s:docker_scope[s:dockertools_scope])
endfunction

function! s:dt_load_config(scope,action)
	if !has_key(s:config,a:scope)
		let l:Loader = function('docker_tools#'.a:scope.'#config')
		let s:config[a:scope] = Loader()
	endif
	return s:config[a:scope][a:action]
endfunction

function! s:dt_load_mapping(scope)
	if !has_key(s:config,a:scope)
		let l:Loader = function('docker_tools#'.a:scope.'#mapping')
		let s:mapping[a:scope] = Loader()
	endif
	return s:mapping[a:scope]
endfunction
"}}}
"container commands{{{
function! docker_tools#container_action(action,id,...) abort
	call s:dt_do('container',a:action,a:id,join(a:000,' '))
endfunction
"}}}
"container functions{{{
function! s:refresh_container_list() abort
	let container_str = system(s:sudo_mode().g:dockertools_docker_cmd.' ps -a --format="{{.ID}} {{.Names}}"')
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

function! s:interactive_mode() abort dict
	if has('nvim')
		silent execute printf("%s %d split TERM",g:dockertools_term_position,g:dockertools_term_size)
		setlocal buftype=nofile bufhidden=delete nobuflisted noswapfile
		call termopen(self.command, {"on_exit":{-> execute("$")}})
	elseif has('terminal')
		silent execute printf("%s %d split TERM",g:dockertools_term_position,g:dockertools_term_size)
		setlocal buftype=nofile bufhidden=delete nobuflisted noswapfile
		call term_start(self.command,{"term_finish":['open','close'][g:dockertools_term_closeonexit],"term_name":self.id,"curwin":"1"})
	else
		call s:echo_error('terminal is not supported')
	endif
endfunction

function! s:export_mode() abort dict
	silent execute printf("%s %d split %s",g:dockertools_logs_position,g:dockertools_logs_size,self.id)
	silent execute printf("read ! %s",self.command)
	silent 1d
	setlocal buftype=nofile bufhidden=delete cursorline nobuflisted readonly nomodifiable noswapfile
	nnoremap <buffer> <silent> q :quit<CR>
endfunction

function! s:execute_mode() abort dict
	if has('nvim')
		call jobstart(self.command,{'on_stdout': 'docker_tools#action_cb','on_stderr': 'docker_tools#err_cb'})
	elseif has('job') && !g:dockertools_disable_job
		call job_start(self.command,{'out_cb': 'docker_tools#action_cb','err_cb': 'docker_tools#err_cb'})
	else
		call system(self.command)
	endif
endfunction

function! s:sudo_mode() abort
	return ['', 'sudo '][g:dockertools_sudo_mode]
endfunction

function! s:normal_type() abort dict
	call self.Fn()
endfunction

function! s:confirm_type() abort dict
	if confirm(self.args.confirm_msg, "&yes\n&no") == 1
		call self.Fn()
	endif
endfunction

function! s:input_type() abort dict
	let l:input_response = input(self.args.input_msg)
	if l:input_response != ''
		call call(self.args.Input_fn,[l:input_response],self)
		call self.Fn()
	endif
endfunction
"}}}
"referral vars {{{
let s:container_filters  = ['id', 'name', 'label', 'exited', 'status', 'ancestor', 'before', 'since', 'volume', 'network', 'publish', 'expose', 'health', 'isolation', 'is-task']
let s:docker_scope = ['container', 'image', 'network']
let s:config = {}
let s:mapping = {}
"}}}
" vim: fdm=marker:
