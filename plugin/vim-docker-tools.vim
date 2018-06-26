let g:vdocker_splitsize = 15
let g:vdocker_term_splitsize = 15
let g:vdocker_term_closeonexit = 1
let g:vdocker_logs_splitsize = 30

command! OpenVDSplit call docker_tools#OpenVDSplit()
command! CloseVDSplit call docker_tools#CloseVDSplit()
command! ToggleVDSplit call docker_tools#ToggleVDSplit()
command! VDRunCommand call docker_tools#VDRunCommand()
command! -nargs=+ ContainerStart call docker_tools#VDContainerAction('start',<f-args>)
command! -nargs=+ ContainerStop call docker_tools#VDContainerAction('stop',<f-args>)
command! -nargs=+ ContainerRemove call docker_tools#VDContainerAction('rm',<f-args>)
command! -nargs=+ ContainerRestart call docker_tools#VDContainerAction('restart',<f-args>)
command! -nargs=+ ContainerPause call docker_tools#VDContainerAction('pause',<f-args>)
command! -nargs=+ ContainerUnpause call docker_tools#VDContainerAction('unpause',<f-args>)
command! -nargs=+ ContainerLogs call docker_tools#VDContainerLogs(<f-args>)
