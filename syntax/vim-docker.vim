if exists("b:current_syntax")
	finish
endif

syn match VDKeyword /\v(CONTAINER ID|IMAGE|COMMAND|CREATED|STATUS|PORTS|NAMES)/
syn match VDQuickHelp /\v#.*$/
syn match VDContainerID /\v[a-zA-Z0-9]{12}/ containedin=VDContainer
syn match VDContainerCommand /".*"/ containedin=VDContainer
syn match VDContainerName /\s\S*$/ containedin=VDContainer contained
syn match VDContainer /\v[a-zA-Z0-9]{12}.*$/ contains=VDContainerID,VDContainerCommand,VDContainerName
syn match VDExitedContainer /\v[a-zA-Z0-9]{12}.*Exited.*$/

hi def link VDKeyword Keyword
hi def link VDQuickHelp Constant

hi def link VDContainerID Identifier
hi def link VDContainerCommand Function
hi def link VDContainerName Identifier
hi def link VDContainer String
hi def link VDExitedContainer Comment

let b:current_syntax = "vim-docker"
