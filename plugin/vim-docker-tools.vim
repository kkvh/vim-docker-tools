let s:default_key_mapping = {'container-start' : 's', 'container-stop' : 'S', 'container-restart' : 'R', 'container-delete' : 'd', 'container-pause' : 'p', 'container-unpause' : 'P', 'container-execute' : '!', 'container-show-logs' : '<CR>', 'ui-toggle-all' : 'a', 'ui-reload' : 'r', 'ui-close' : 'q', 'ui-toggle-help' : '?', 'ui-filter' : 'f'}

if !exists('g:dockertools_size')
	let g:dockertools_size = 15
endif

if !exists('g:dockertools_term_size')
	let g:dockertools_term_size = 15
endif

if !exists('g:dockertools_term_closeonexit')
	let g:dockertools_term_closeonexit = 1
endif

if !exists('g:dockertools_logs_size')
	let g:dockertools_logs_size = 30
endif

if !exists('g:dockertools_default_all')
	let g:dockertools_default_all = 1
endif

if !exists('g:dockertools_sudo_mode')
	let g:dockertools_sudo_mode = 0
endif

if !exists('g:dockertools_disable_job')
	let g:dockertools_disable_job = 0
endif

if exists('g:dockertools_docker_host')
	call docker_tools#dt_set_host(g:dockertools_docker_host)
else
	call docker_tools#dt_set_host()
endif

if !exists('g:dockertools_ps_filter')
	let g:dockertools_ps_filter = ''
else
	call docker_tools#dt_set_filter(g:dockertools_ps_filter)
endif

if exists('g:dockertools_user_key_mapping')
	let g:dockertools_key_mapping = extend(s:default_key_mapping, g:dockertools_user_key_mapping) 
else
	let g:dockertools_key_mapping = s:default_key_mapping
endif

command! DockerToolsOpen call docker_tools#dt_open()
command! DockerToolsClose call docker_tools#dt_close()
command! DockerToolsToggle call docker_tools#dt_toggle()
command! DockerToolsClearFilter call docker_tools#dt_set_filter('')
command! -nargs=* DockerToolsSetFilter call docker_tools#dt_set_filter(<q-args>)
command! -nargs=? DockerToolsSetHost call docker_tools#dt_set_host(<q-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerStart call docker_tools#container_action('start',<f-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerStop call docker_tools#container_action('stop',<f-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerRemove call docker_tools#container_action('rm',<f-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerRestart call docker_tools#container_action('restart',<f-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerPause call docker_tools#container_action('pause',<f-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerUnpause call docker_tools#container_action('unpause',<f-args>)
command! -complete=customlist,docker_tools#complete -nargs=+ ContainerLogs call docker_tools#container_logs(<f-args>)
