function! docker_tools#image#config() abort
	return s:config
endfunction

let s:config = {
	\'rm': {
		\'command': 'rm',
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Removing image'}
\}

function! docker_tools#image#mapping() abort
	return s:mapping
endfunction

let s:mapping = {
	\'rm':'x'
\}

function! docker_tools#image#key() abort
	return s:key
endfunction

let s:key = 'IMAGE ID'

function! docker_tools#image#filter() abort
	return s:filter
endfunction

let s:filter  = ['before', 'dangling', 'label', 'reference', 'since']

function! docker_tools#image#help(mapping) abort
	let l:help = printf("# %s: delete image\n",a:mapping['rm'])
	return help
endfunction
