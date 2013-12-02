REBOL [
	title: "Sessions Model"
	type: 'roughcut
]

locate: func [id [tuple! string!]][
	all [
		id: as tuple! id
		replace/all form id "." "-"
	]
]

queries: make queries [
	purge: ["DELETE FROM sessions WHERE TIMEDIFF(?,modified) > ?;" now settings/session-timeout]
]

record: make record [
	on-create: does [
		until [not find owner set 'id random 99.99.99.99.99.99]
		touch 'created
	]

	on-save: does [
		touch 'modified
	]

	age?: does [
		difference now/precise get 'created
	]

	last-use?: does [
		difference now/precise get 'modified
	]

	expired?: does [
		last-use? > to-time reduce [0 settings/session-timeout 0]
	]

	as-cookie: does [form get 'id]

	message: func [/hold message [string! block!]][
		either message [
			set 'message press envelop message
			store
		][
			if message: get 'message [
				unset 'message
				store
			]
		]
		message
	]
]