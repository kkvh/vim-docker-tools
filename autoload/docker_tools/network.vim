function! docker_tools#network#config() abort
	return s:config
endfunction

let s:config = {
\}

function! docker_tools#network#mapping() abort
	return s:mapping
endfunction

let s:mapping = {
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
	let l:help = ""
	return help
endfunction
