function! docker_tools#GetHelp() abort
	let help = "# Vim-docker Tools quickhelp\n"
	let help .= "# ------------------------------------------------------------------------------\n"
	let help .= "# s: start container\n"
	let help .= "# d: stop container\n"
	let help .= "# r: restart container\n"
	let help .= "# x: delete container\n"
	let help .= "# p: pause container\n"
	let help .= "# u: unpause container\n"
	let help .= "# >: execute command to container\n"
	let help .= "# ?: toggle help\n"
	let help .= "# ------------------------------------------------------------------------------\n"
	silent! put =help
endfunction

function! docker_tools#ToggleHelp() abort
	let b:show_help = !b:show_help
	call LoadDockerPS()
endfunction
