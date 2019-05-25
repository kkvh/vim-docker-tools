function! docker_tools#list#mapping() abort
	return s:mapping
endfunction

let s:mapping = {
	\'close':'q',
	\'toggle-all':'a',
	\'refresh':'R',
	\'toggle-help':'?',
	\'filter':'f'
\}

function! docker_tools#list#help(mapping) abort
	let l:help = printf("# %s: toggle show all\n",a:mapping['toggle-all'])
	let l:help .= printf("# %s: set filter\n",a:mapping['filter'])
	let l:help .= printf("# %s: refresh list\n",a:mapping['refresh'])
	let l:help .= printf("# %s: close vim-docker-tools\n",a:mapping['close'])
	let l:help .= printf("# %s: toggle help\n",a:mapping['toggle-help'])
	return help
endfunction
