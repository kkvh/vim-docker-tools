let s:config = {
	\'start': {
		\'mode': 'execute',
		\'type': 'normal'},
	\'stop': {
		\'mode': 'execute',
		\'type': 'normal'},
	\'rm': {
		\'mode': 'execute',
		\'type': 'normal'},
	\'restart': {
		\'mode': 'execute',
		\'type': 'normal'},
	\'pause': {
		\'mode': 'execute',
		\'type': 'normal'},
	\'unpause': {
		\'mode': 'execute',
		\'type': 'normal'},
	\'exec': {
		\'mode': 'interactive',
		\'type': 'input',
		\'args': {
			\'input_msg': 'Enter command: '}
		\},
	\'logs': {
		\'mode': 'export',
		\'type': 'normal'}
\}

function! docker_tools#container#config() abort
	return s:config
endfunction
