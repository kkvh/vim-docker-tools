if exists('b:current_syntax')
	finish
endif

syn match VDKeyword /\v(REPOSITORY|TAG|IMAGE ID|CREATED|SIZE)/
syn match VDQuickHelp /\v#.*$/
syn match VDFilter /\vFilter\(s\): .*$/
syn match VDImageID /\v[a-f0-9]{12}/ containedin=VDImage
syn match VDImage /\v.*[a-f0-9]{12}.*$/ contains=VDImageID

hi def link VDKeyword Keyword
hi def link VDQuickHelp Constant
hi def link VDFilter Tag

hi def link VDImageID Identifier
hi def link VDImage String

let b:current_syntax = 'docker-tools-image'
