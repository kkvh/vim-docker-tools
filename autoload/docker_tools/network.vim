function! docker_tools#network#config() abort
	return s:config
endfunction

let s:config = {
	\'inspect': {
		\'command': 'inspect',
		\'mode': 'export',
		\'type': 'normal'},
	\'rm': {
		\'command': 'rm',
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Removing network'}
\}

function! docker_tools#network#mapping() abort
	return s:mapping
endfunction

let s:mapping = {
	\'inspect': 'i',
	\'rm': 'x'
\}

function! docker_tools#network#key() abort
	return s:key
endfunction

let s:key = 'NETWORK ID'

function! docker_tools#network#filter() abort
	return s:filter
endfunction

let s:filter  = ['driver', 'id', 'label', 'name', 'scope', 'type']

function! docker_tools#network#help(mapping) abort
	let l:help = printf("# %s: inspect network\n",a:mapping['inspect'])
	let l:help .= printf("# %s: delete network\n",a:mapping['rm'])
	return help
endfunction
