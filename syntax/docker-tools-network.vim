if exists('b:current_syntax')
	finish
endif

syn match VDKeyword /\v(NETWORK ID|NAME|DRIVER|SCOPE)/
syn match VDQuickHelp /\v#.*$/
syn match VDFilter /\vFilter\(s\): .*$/
syn match VDNetworkID /\v[a-f0-9]{12}\s+\S+/ containedin=VDNetwork
syn match VDNetwork /\v[a-f0-9]{12}.*$/ contains=VDNetworkID

hi def link VDKeyword Keyword
hi def link VDQuickHelp Constant
hi def link VDFilter Tag

hi def link VDNetworkID Identifier
hi def link VDNetwork String

let b:current_syntax = 'docker-tools-network'
