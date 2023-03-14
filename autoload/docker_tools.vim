"docker tools controls{{{
function! docker_tools#dt_open() abort
	if !exists('s:dockertools_winid')
		silent execute printf("topleft %s split DOCKER",g:dockertools_size)
		let b:show_help = 0
		let b:show_all_containers = g:dockertools_default_all
		if !exists('s:manager_position')
			let s:manager_position = 0
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
	let s:manager_position = (s:manager_position+a:i)%len(g:dockertools_managers)
	call s:dt_switch_panel()
endfunction

function! docker_tools#dt_go(i)
	let s:manager_position = a:i
	call s:dt_switch_panel()
endfunction
"}}}
"docker tools commands{{{
function! docker_tools#dt_action(action) abort
	if s:dt_container_selected()
		let l:manager = g:dockertools_managers[s:manager_position]
		call s:dt_do(l:manager,a:action,s:dt_get_id(l:manager))
	endif
endfunction

function! docker_tools#dt_action_option(action) abort
	if s:dt_container_selected()
		let l:options = input("Option(s): ")
		if l:options != ''
			call s:dt_do(g:dockertools_managers[s:manager_position],a:action,s:dt_get_id(),l:options)
		endif
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
function! s:dt_get_id(manager) abort
	let l:row_num = getcurpos()[1]
	let l:Key = function('docker_tools#'.a:manager.'#key')
	call search(l:Key())
	let l:current_cursor = getcurpos()
	if l:current_cursor[1] !=# b:first_row
		call s:echo_error(printf("No %s found",l:Key()))
		return ""
	endif
	let l:current_cursor[1] = l:row_num
	call setpos('.', l:current_cursor)
	return expand('<cWORD>')
endfunction

function! s:dt_set_mapping() abort
	silent mapclear <buffer>
	let l:list_mapping = s:dt_load_mapping('list')
	execute 'nnoremap <buffer> <silent>' . l:list_mapping['close'] . ' :DockerToolsClose<CR>'
	execute 'nnoremap <buffer> <silent>' . l:list_mapping['toggle-all'] . ' :call docker_tools#dt_toggle_all()<CR>'
	execute 'nnoremap <buffer> <silent>' . l:list_mapping['refresh'] . ' :call docker_tools#dt_reload()<CR>'
	execute 'nnoremap <buffer> <silent>' . l:list_mapping['toggle-help'] . ' :call docker_tools#dt_toggle_help()<CR>'
	execute 'nnoremap <buffer> <silent>' . l:list_mapping['filter'] . ' :call docker_tools#dt_ui_set_filter()<CR>'
	execute 'nnoremap <buffer> <silent>' . l:list_mapping['next-panel'] . ' :call docker_tools#dt_swap(1)<CR>'
	execute 'nnoremap <buffer> <silent>' . l:list_mapping['previous-panel'] . ' :call docker_tools#dt_swap(-1)<CR>'
	let l:mapping = s:dt_load_mapping(g:dockertools_managers[s:manager_position])
	for [l:action,l:key] in items(l:mapping)
		execute printf("nnoremap <buffer> <silent> %s :call docker_tools#dt_action('%s')<CR>",l:key,l:action)
		execute printf("nnoremap <buffer> <silent> %s%s :call docker_tools#dt_action_option('%s')<CR>",l:list_mapping['option'],l:key,l:action)
	endfor
	for l:i in range(1,len(g:dockertools_managers))
		execute printf("nnoremap <buffer> <silent> <leader>%d :call docker_tools#dt_go(%d)<CR>",l:i,l:i-1)
	endfor
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

	let l:manager = g:dockertools_managers[s:manager_position]
	silent! execute printf("read ! %s%s %s ls %s %s %s",s:sudo_mode(),g:dockertools_docker_cmd,l:manager,['','-a'][b:show_all_containers&&s:manager_position!=2&&s:manager_position!=-1], s:dockertools_ls_filter, s:dt_set_format(l:manager))

	silent 1d
	call setpos('.', l:save_cursor)
	setlocal nomodifiable
endfunction

function! s:dt_get_help() abort
	let l:manager = g:dockertools_managers[s:manager_position]
	let l:mapping = s:dt_load_mapping(l:manager)
	let l:Helper = function('docker_tools#'.l:manager.'#help')
	let l:list_mapping = s:dt_load_mapping('list')
	let l:List_helper = function('docker_tools#list#help')
	let help = "# vim-docker-tools quickhelp\n"
	let help .= "# ------------------------------------------------------------------------------\n"
	let help .= l:Helper(l:mapping)
	let help .= "# ------------------------------------------------------------------------------\n"
	let help .= l:List_helper(l:list_mapping)
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
	let l:manager = g:dockertools_managers[s:manager_position]
	let l:valid_filters = function('docker_tools#'.l:manager.'#filter')()
	let l:filters = ''
	for l:ls_filter in split(a:filters, ' ')
		let l:filter_components = split(l:ls_filter, '=')
		if index(l:valid_filters, filter_components[0]) > -1
			let l:filters = join([l:filters, '-f', l:ls_filter], ' ')
		endif
	endfor
	let s:dockertools_ls_filter = l:filters
endfunction

function! s:dt_set_format(manager) abort
	if !exists('g:dockertools_'.a:manager.'_format')
		return ''
	endif
	return shellescape(printf('--format=%s', eval('g:dockertools_'.a:manager.'_format')), 1)
endfunction

function! s:dt_do(manager,action,id,...) abort
	let l:config = s:dt_load_config(a:manager,a:action)
	if has_key(l:config,'options')
		let l:instruction = printf("%s%s %s %s %s %s %s",s:sudo_mode(),g:dockertools_docker_cmd,a:manager,l:config.command,join(a:000,' '),l:config.options,a:id)
	else
		let l:instruction = printf("%s%s %s %s %s %s",s:sudo_mode(),g:dockertools_docker_cmd,a:manager,l:config.command,join(a:000,' '),a:id)
	endif
	let l:runner = {'action':a:action,'id':a:id,'instruction':l:instruction}
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
	call s:dt_set_mapping()
	execute printf("setlocal filetype=docker-tools-%s", g:dockertools_managers[s:manager_position])
endfunction

function! s:dt_load_config(manager,action)
	if !has_key(s:config,a:manager)
		let l:Loader = function('docker_tools#'.a:manager.'#config')
		let s:config[a:manager] = Loader()
	endif
	return s:config[a:manager][a:action]
endfunction

function! s:dt_load_mapping(manager)
	if !has_key(s:mapping,a:manager)
		let l:Loader = function('docker_tools#'.a:manager.'#mapping')
		if exists('g:dockertools_'.a:manager.'_mapping')
			let s:mapping[a:manager] = extend(Loader(),eval('g:dockertools_'.a:manager.'_mapping'))
		else
			let s:mapping[a:manager] = Loader()
		endif
	endif
	return s:mapping[a:manager]
endfunction
"}}}
"container commands{{{
function! docker_tools#container_action(action,id,...) abort
	call s:dt_do('container',a:action,a:id,join(a:000,' '))
endfunction

function! docker_tools#command_run(manager,action,id,...) abort
	call s:dt_do(a:manager,a:action,a:id,join(a:000,' '))
endfunction
"}}}
"autocomplete functions{{{
function! s:refresh_container_list() abort
	let container_str = system(s:sudo_mode().g:dockertools_docker_cmd.' container ls -a --format="{{.ID}} {{.Names}}"')
	let s:container_list = split(container_str)
endfunction

function! docker_tools#container_complete(ArgLead, CmdLine, CursorPos) abort
	if !exists('s:container_list')
		call s:refresh_container_list()
	endif
	return filter(s:container_list, 'v:val =~ "^'.a:ArgLead.'"')
endfunction

function! s:refresh_image_list() abort
	let image_str = system(s:sudo_mode().g:dockertools_docker_cmd.' image ls -a --format="{{.ID}}"')
	let s:image_list = split(image_str)
endfunction

function! docker_tools#image_complete(ArgLead, CmdLine, CursorPos) abort
	if !exists('s:image_list')
		call s:refresh_image_list()
	endif
	return filter(s:image_list, 'v:val =~ "^'.a:ArgLead.'"')
endfunction

function! s:refresh_network_list() abort
	let network_str = system(s:sudo_mode().g:dockertools_docker_cmd.' network ls --format="{{.ID}} {{.Name}}"')
	let s:network_list = split(network_str)
endfunction

function! docker_tools#network_complete(ArgLead, CmdLine, CursorPos) abort
	if !exists('s:network_list')
		call s:refresh_network_list()
	endif
	return filter(s:network_list, 'v:val =~ "^'.a:ArgLead.'"')
endfunction
"}}}
"utils{{{
function! s:echo_msg(msg) abort
	redraw
	echom "docker-tools: " . a:msg
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
		call termopen(self.instruction, {"on_exit":{-> execute("$")}})
	elseif has('terminal')
		silent execute printf("%s %d split TERM",g:dockertools_term_position,g:dockertools_term_size)
		setlocal buftype=nofile bufhidden=delete nobuflisted noswapfile
		call term_start(self.instruction,{"term_finish":['open','close'][g:dockertools_term_closeonexit],"term_name":self.id,"curwin":"1"})
	else
		call s:echo_error('terminal is not supported')
	endif
endfunction

function! s:export_mode() abort dict
	silent execute printf("%s %d split %s",g:dockertools_logs_position,g:dockertools_logs_size,self.id)
	silent execute printf("read ! %s",self.instruction)
	silent 1d
	setlocal buftype=nofile bufhidden=delete cursorline nobuflisted readonly nomodifiable noswapfile
	nnoremap <buffer> <silent> q :quit<CR>
endfunction

function! s:execute_mode() abort dict
	if has('nvim')
		call jobstart(self.instruction,{'on_stdout': 'docker_tools#action_cb','on_stderr': 'docker_tools#err_cb'})
	elseif has('job') && !g:dockertools_disable_job
		call job_start(self.instruction,{'out_cb': 'docker_tools#action_cb','err_cb': 'docker_tools#err_cb'})
	else
		call system(self.instruction)
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
let s:config = {}
let s:mapping = {}
"}}}
" vim: fdm=marker:
