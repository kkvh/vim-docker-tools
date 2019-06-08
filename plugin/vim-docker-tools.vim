function! s:dt_set_host(...) 
	if a:0 == 1 && (index(["''",'""',''], a:1)) == -1
		let g:dockertools_docker_cmd = join(['docker -H', a:1], ' ')
	else
		let g:dockertools_docker_cmd = 'docker'
	endif
endfunction

if !exists('g:dockertools_size')
	let g:dockertools_size = 15
endif

if !exists('g:dockertools_term_size')
	let g:dockertools_term_size = 15
endif

if !exists('g:dockertools_term_position')
	let g:dockertools_term_position = 'botright'
endif

if !exists('g:dockertools_term_closeonexit')
	let g:dockertools_term_closeonexit = 1
endif

if !exists('g:dockertools_logs_size')
	let g:dockertools_logs_size = 30
endif

if !exists('g:dockertools_logs_position')
	let g:dockertools_logs_position = 'botright'
endif

if !exists('g:dockertools_default_all')
	let g:dockertools_default_all = 1
endif

if !exists('g:dockertools_managers')
	let g:dockertools_managers = ['container', 'image', 'network']
endif

if !exists('g:dockertools_sudo_mode')
	let g:dockertools_sudo_mode = 0
endif

if !exists('g:dockertools_disable_job')
	let g:dockertools_disable_job = 0
endif

if exists('g:dockertools_docker_host')
	call s:dt_set_host(g:dockertools_docker_host)
else
	call s:dt_set_host()
endif

command! DockerToolsOpen call docker_tools#dt_open()
command! DockerToolsClose call docker_tools#dt_close()
command! DockerToolsToggle call docker_tools#dt_toggle()
command! -nargs=? DockerToolsSetHost call docker_tools#dt_set_host(<q-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerStart call docker_tools#container_action('start',<f-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerStop call docker_tools#container_action('stop',<f-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerRemove call docker_tools#container_action('rm',<f-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerRestart call docker_tools#container_action('restart',<f-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerPause call docker_tools#container_action('pause',<f-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerUnpause call docker_tools#container_action('unpause',<f-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerLogs call docker_tools#container_action('logs',<f-args>)
