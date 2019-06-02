# vim-docker-tools
![demo](https://thumbs.gfycat.com/JitteryHealthyAmericanshorthair-size_restricted.gif) 
* Open DockerTools Panel with `:DockerToolsOpen`, close it with `:DockerToolsClose`
* Toggle DockerTools Panel with `:DockerToolsToggle`
* Set Docker daemon host with `:DockerToolsSetHost`
* Support `:ContainerStart`, `:ContainerStop`, `:ContainerRemove`, `:ContainerRestart`, `:ContainerPause`, `:ContainerUnpause`, `ContainerLogs`. For details please check out the documentation (`:help docker-tools-commands`).
* Autocompletion for container commands
* Full documentation in `:help vim-docker-tools`
# Install
* Pathogen
  * `git clone https://github.com/kkvh/vim-docker-tools.git ~/.vim/bundle/vim-docker-tools`
* Vim-plug
  * `Plug 'kkvh/vim-docker-tools'`
* NeoBundle
  * `NeoBundle 'kkvh/vim-docker-tools'`
* Vundle
  * `Plugin 'kkvh/vim-docker-tools'`
* Manual
  * Copy all of the files into your `~/.vim` directory
# Roadmap
* [x] Refactor docker runner structure
* [x] Refactor key mapping
* [x] Support custom key mapping
  * [x] Update vim documentation
* [ ] Support key mapping with options
* [ ] Pause/Unpause toggle
* Container functions
* Image functions
* [ ] Image command autocomplete
* Network functions
* [ ] Network command autocomplete
* Dockerfile functions
# Contributing
Feel free to raise any questions/issues/comments. Submit pull request as you want.
