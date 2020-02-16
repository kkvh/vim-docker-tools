function! docker_tools#container#config() abort
	return s:config
endfunction

let s:config = {
	\'start': {
		\'command': 'start',
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Starting container'},
	\'stop': {
		\'command': 'stop',
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Stopping container'},
	\'rm': {
		\'command': 'rm',
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Removing container'},
	\'restart': {
		\'command': 'restart',
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Restarting container'},
	\'pause': {
		\'command': 'pause',
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Pausing container'},
	\'unpause': {
		\'command': 'unpause',
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Unpausing container'},
	\'exec': {
		\'command': 'exec',
		\'mode': 'interactive',
		\'type': 'input',
		\'options': '-it',
		\'args': {
			\'input_msg': 'Enter command: '}
		\},
	\'logs': {
		\'command': 'logs',
		\'mode': 'export',
		\'type': 'normal'}
\}

function s:config.exec.args.Input_fn(response) abort dict
	let self.instruction = printf("%s %s",self.instruction,a:response)
endfunction

function! docker_tools#container#mapping() abort
	return s:mapping
endfunction

let s:mapping = {
	\'start':'s',
	\'stop':'d',
	\'restart':'r',
	\'rm':'x',
	\'pause':'p',
	\'unpause':'u',
	\'exec':'>',
	\'logs':'<'
\}

function! docker_tools#container#key() abort
	return s:key
endfunction

let s:key = 'CONTAINER ID'

function! docker_tools#container#filter() abort
	return s:filter
endfunction

let s:filter  = ['id', 'name', 'label', 'exited', 'status', 'ancestor', 'before', 'since', 'volume', 'network', 'publish', 'expose', 'health', 'isolation', 'is-task']

function! docker_tools#container#help(mapping) abort
	let l:help = printf("# %s: start container\n",a:mapping['start'])
	let l:help .= printf("# %s: stop container\n",a:mapping['stop'])
	let l:help .= printf("# %s: restart container\n",a:mapping['restart'])
	let l:help .= printf("# %s: delete container\n",a:mapping['rm'])
	let l:help .= printf("# %s: pause container\n",a:mapping['pause'])
	let l:help .= printf("# %s: unpause container\n",a:mapping['unpause'])
	let l:help .= printf("# %s: execute command to container\n",a:mapping['exec'])
	let l:help .= printf("# %s: show container logs\n",a:mapping['logs'])
	return help
endfunction
