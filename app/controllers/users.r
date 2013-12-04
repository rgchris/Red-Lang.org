REBOL [
	Title: "User Account Controller"
	Type: 'controller
	Template: %templates/hjn.rsp
	Fail: {Can't log you in with these credentials.}
	Template: %templates/red.rsp
]

event "before" does [background: 'navy]

route () to %users [
	get %,sign-in [
		title: "Sign In"
		target: select users 'new
	]

	post %,sign-in [
		title: "Sign In"

		if verify [
			id: get-param/body 'user/id [
				target: select users 'new
			]

			target: select users id [
				target: select users 'new
				target/set 'id id
				target/errors: compose/deep [id [(header/fail)]]
			]

			target/valid-pass? get-param 'user/password [
				target/set 'id id
				target/errors: compose/deep [password [(header/fail)]]
			]
		][
			set-cookie/expires "usr" target/as-cookie now + 366
			redirect-to %/dashboard
		]
	]

	post %,sign-out [
		session/destroy
		clear-cookie "ssn"
		clear-cookie "usr"
		redirect-to %/dashboard
	]

	get %,register [
		tite: "Sign Up"
		prospect: select users 'new
	]

	post %,register [
		title: "Sign Up"
		prospect: select users 'new

		if prospect/initialize get-param/body 'prospect [
			set-cookie/expires "usr" prospect/as-cookie now + 366
			redirect-to %/dashboard
		]
	]
]

route ("list" page: opt integer!) to %list [
	verify [
		user/moderator? [
			reject 403 %errors/notauthorized.rsp
		]
	]

	get [
		title: "User Listing"
		page: paginate/size users page 8
	]
]

route ("profile" name: string! [ident]) to %profile [
	verify [
		target: select users name [
			reject 404 %errors/notfound.rsp
		]

		any [
			target?: user/id = target/id
			user/moderator?
		][
			reject 403 %errors/notauthorized.rsp
		]
	]

	get [
		title: join "@" target/id
		message: session/message
	]

	put [
		title: "Profile"
		either target/update/by get-param 'target user [
			session/set 'message "Profile Updated"
			session/store
			either target/id = user/id [
				redirect-to %/dashboard
			][
				redirect-to users/profile/(target/id)
			]
		][
			render %profile
		]
	]

	delete [
		either all [
			user/moderator?
			empty? target/get 'roles
			not target/owner?
		][
			target/destroy
			redirect-to %/users/list
		][
			reject 404 %errors/notfound.rsp
		]
	]
]
