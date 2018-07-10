let g:dockertools_size = 15
let g:dockertools_term_size = 15
let g:dockertools_term_closeonexit = 1
let g:dockertools_logs_size = 30

command! DockerToolsOpen call docker_tools#dt_open()
command! DockerToolsClose call docker_tools#dt_close()
command! DockerToolsToggle call docker_tools#dt_toggle()
command! -nargs=+ ContainerStart call docker_tools#container_action('start',<f-args>)
command! -nargs=+ ContainerStop call docker_tools#container_action('stop',<f-args>)
command! -nargs=+ ContainerRemove call docker_tools#container_action('rm',<f-args>)
command! -nargs=+ ContainerRestart call docker_tools#container_action('restart',<f-args>)
command! -nargs=+ ContainerPause call docker_tools#container_action('pause',<f-args>)
command! -nargs=+ ContainerUnpause call docker_tools#container_action('unpause',<f-args>)
command! -nargs=+ ContainerLogs call docker_tools#container_logs(<f-args>)
