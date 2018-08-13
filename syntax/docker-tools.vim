if exists('b:current_syntax')
	finish
endif

syn match VDKeyword /\v(CONTAINER ID|IMAGE|COMMAND|CREATED|STATUS|PORTS|NAMES)/
syn match VDQuickHelp /\v#.*$/
syn match VDFilter /\vFilter\(s\): .*$/
syn match VDContainerID /\v[a-zA-Z0-9]{12}/ containedin=VDContainer
syn region VDContainerCommand start=/\v"/ skip=/\v\\./ end=/\v"/ containedin=VDContainer
syn match VDContainerName /\s\S*$/ containedin=VDContainer contained
syn match VDContainer /\v[a-zA-Z0-9]{12}.*$/ contains=VDContainerID,VDContainerCommand,VDContainerName
syn match VDExitedContainer /\v[a-zA-Z0-9]{12}.*Exited.*$/
syn match VDPausedContainer /\v[a-zA-Z0-9]{12}.*(Paused).*$/

hi def link VDKeyword Keyword
hi def link VDQuickHelp Constant
hi def link VDFilter Tag

hi def link VDContainerID Identifier
hi def link VDContainerCommand Function
hi def link VDContainerName Identifier
hi def link VDContainer String
hi def link VDExitedContainer Comment
hi def link VDPausedContainer Constant

let b:current_syntax = 'docker-tools'
