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

command! DockerToolsOpen call docker_tools#dt_open()
command! DockerToolsClose call docker_tools#dt_close()
command! DockerToolsToggle call docker_tools#dt_toggle()
command! -complete=customlist,docker_tools#Complete -nargs=+ ContainerStart call docker_tools#container_action('start',<f-args>)
command! -complete=customlist,docker_tools#Complete -nargs=+ ContainerStop call docker_tools#container_action('stop',<f-args>)
command! -complete=customlist,docker_tools#Complete -nargs=+ ContainerRemove call docker_tools#container_action('rm',<f-args>)
command! -complete=customlist,docker_tools#Complete -nargs=+ ContainerRestart call docker_tools#container_action('restart',<f-args>)
command! -complete=customlist,docker_tools#Complete -nargs=+ ContainerPause call docker_tools#container_action('pause',<f-args>)
command! -complete=customlist,docker_tools#Complete -nargs=+ ContainerUnpause call docker_tools#container_action('unpause',<f-args>)
command! -complete=customlist,docker_tools#Complete -nargs=+ ContainerLogs call docker_tools#container_logs(<f-args>)
