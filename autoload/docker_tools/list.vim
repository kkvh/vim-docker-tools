function! docker_tools#list#mapping() abort
	return s:mapping
endfunction

let s:mapping = {
	\'close':'q',
	\'toggle-all':'<leader>a',
	\'refresh':'<leader>r',
	\'toggle-help':'?',
	\'filter':'<leader>f',
	\'option':'o',
	\'next-panel':'<leader>>',
	\'previous-panel':'<leader><'
\}

function! docker_tools#list#help(mapping) abort
	let l:help = printf("# %s: toggle show all\n",a:mapping['toggle-all'])
	let l:help .= printf("# %s: set filter\n",a:mapping['filter'])
	let l:help .= printf("# %s: refresh list\n",a:mapping['refresh'])
	let l:help .= printf("# %s: close vim-docker-tools\n",a:mapping['close'])
	let l:help .= printf("# %s: toggle help\n",a:mapping['toggle-help'])
	let l:help .= printf("# %s <key>: perform action with option(s)\n",a:mapping['option'])
	let l:help .= printf("# %s: navigate next panel\n",a:mapping['next-panel'])
	let l:help .= printf("# %s: navigate previous panel\n",a:mapping['previous-panel'])
	return help
endfunction
