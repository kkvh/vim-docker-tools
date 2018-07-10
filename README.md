# vim-docker-tools
![demo](https://thumbs.gfycat.com/SinfulNecessaryBlackfootedferret-size_restricted.gif) 
* Open DockerTools Panel with `:DockerToolsOpen`, close it with `:DockerToolsClose`
* Toggle DockerTools Panel with `:DockerToolsToggle`
* Support `:ContainerStart`, `:ContainerStop`, `:ContainerRemove`, `:ContainerRestart`, `:ContainerPause`, `:ContainerUnpause`, `ContainerLogs`. For details please check out the documentation (`:help docker-tools-commands`).
* Full documentation in `:help vim-docker-tools`
# Install
* Pathogen
  * `git clone https://github.com/kevinhui/vim-docker-tools.git ~/.vim/bundle/vim-docker-tools`
* Vim-plug
  * `Plug 'kevinhui/vim-docker-tools'`
* NeoBundle
  * `NeoBundle 'kevinhui/vim-docker-tools'`
* Vundle
  * `Plugin 'kevinhui/vim-docker-tools'`
* Manual
  * Copy all of the files into your `~/.vim` directory

# TODO
- [x] Container log ([#2](../../issues/2))
- [x] Autoloading
- [x] Documentations
- [x] Function name refractoring
- [ ] More config customizations
