function! docker_tools#container#config() abort
	return s:config
endfunction

let s:config = {
	\'start': {
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Starting container'},
	\'stop': {
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Stopping container'},
	\'rm': {
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Removing container'},
	\'restart': {
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Restarting container'},
	\'pause': {
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Pausing container'},
	\'unpause': {
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Unpausing container'},
	\'exec': {
		\'mode': 'interactive',
		\'type': 'input',
		\'options': '-it',
		\'args': {
			\'input_msg': 'Enter command: '}
		\},
	\'logs': {
		\'mode': 'export',
		\'type': 'normal'}
\}

function s:config.exec.args.Input_fn(response) abort dict
	let self.command = printf("%s %s",self.command,a:response)
endfunction
