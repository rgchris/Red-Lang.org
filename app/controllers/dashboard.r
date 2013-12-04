REBOL [
	Title: "Dashboard Controller"
	Date: 18-Oct-2011
	Author: "Christopher Ross-Gill"
	Type: 'controller
	Template: %templates/red.rsp
]

route () to %dashboard [
	verify [
		not empty? users [
			redirect-to/status %users,register 307
		]

		not user/new? [
			redirect-to/status %/users,sign-in 307
		]
	]

	get [
		title: "Dashboard"
		background: 'navy

		case/all [
			user/moderator? [
				pending-users: select users [pending]
			]

			user/blogger? [
				drafts: select news [drafts-for-user user/id]
			]
		]

		if user/pending? [
			render %pending
		]
	]
]
