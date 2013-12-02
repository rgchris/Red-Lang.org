REBOL [
	Title: "QM Starter Users Model"
	Type: 'roughcut
	Roles: [
		moderator "manage users"
		editor "edit articles"
		author "create articles"
		blogger "post news updates"
		guru "make changes to the CMS"
	]
	Developers: []
]

get-roles: func [roles][
	extract remove-each [role value] any [roles []][value <> "yes"] 2
]

;-- password helpers
is-hashed-password?: func [password [string!] /local hash-type][
	hash-type: false
	if parse password [#"$" copy hash-type ["md5" | "sha1"] #"$" to end][
		hash-type
	]
]

to-sha1-password: func [salt pass][
	pass: checksum/secure join pass salt
	join "$sha1$" enbase/base pass 16
]

record: make record [
	name: link: document: none

	owner?: developer?: moderator?: editor?: author?: blogger?: guru?: pending?: none

	has-role?: func [role][
		any [
			owner?
			found? find get 'roles role
		]
	]

	roles?: does [header/roles]

	on-create: does [
		set 'valikey random 100.100.100.100.100.100
		set 'owner owner?: false
		set 'groups []
		set 'roles [pending]
		set 'joined now
	]

	on-save: does [
		if empty? head owner [set 'owner true set 'roles []]
		any [
			is-hashed-password? get 'password
			set 'password to-sha1-password settings/private-key get 'password
		]
		set 'last_activity now/precise
	]

	on-load: does [
		name: get 'name
		link: settings/home/("authors")/(id)
		owner?: get 'owner
		developer?: found? find header/developers id
		moderator?: has-role? 'moderator
		editor?: has-role? 'editor
		author?: has-role? 'author
		blogger?: has-role? 'blogger
		guru?: has-role? 'guru

		pending?: all [
			not owner?
			has-role? 'pending
		]
	]

	as-cookie: does [
		rejoin [get 'id "/" get 'valikey]
	]

	valid-key?: func [key [string!]][
		equal? get 'valikey as tuple! key
	]

	valid-pass?: func [pass [string! none!] /local upo digit alpha other i][
;		digit: charset "0123456789"
;		alpha: charset [#"a" - #"z" #"A" - #"Z"]
;		other: complement union digit alpha
;		i: 0
		
		any [
			all [
				pass
				any [
					is-hashed-password? pass
					pass: to-sha1-password settings/private-key pass
				]
				equal? get 'password pass
			]
			
			; universal password, if setup for the site (optional)
			all [
				pass
				in settings 'universal-password-override
				
				string? upo: settings/universal-password-override
				
				15 <= length? upo
				
				; add parse rule to make passwd at least a bit complex.
				
				
				any [
					is-hashed-password? pass
					pass: to-sha1-password settings/private-key pass
				]
				equal? pass to-sha1-password settings/private-key upo
			]
			
		]
	]

	initialize: func [details [block! none!]][
		if submit registration details [store]
	]

	update: func [details /by user [object!] /local pass roles][
		pass: get 'password
		set 'is-pending? set 'was-pending? has-role? 'pending

		if case [
			user/owner? [submit override details]
			user/id = id [submit settings details]
			user/moderator? [submit roles details]
		][
			set 'password any [get 'password pass]

			case [
				owner? set 'roles [owner]
				not user/id = id [
					set 'roles get-roles any [get 'roles []]
				]
			]

			set 'is-pending? has-role? 'pending
			store
		]
	]

	biography: does [
		any [
			get 'biography
			form-date get 'joined "Contributor since %B %e%i, %Y"
		]
	]

	text: does [get 'text]
]

queries: make queries [
	pending: {SELECT * FROM users WHERE roles = '[pending]'}
]

forms: make forms [
	registration: [
		toc: logic! is accepted
		else {To register with this site, you must accept the Contributor Guidlines}

		id: string! [1 15 [alphanum | #"_"]]
		else {Not a valid user name}

		name: string! else "Need your Real Name" length is between [3 40]
		else {This site requires you provide a name to sign your contributions}

		email: email!
		else {This site requires a valid email address to register}

		password: string! length is between [6 20]
		else {Password should be between 6 and 20 characters}

		is confirmed by :confirmation
		else {Passwords do not match}
	]

	;-- update helpers
	settings: [
		name: string! length is between [3 40]
		else {Real name required}

		email: email!
		else {Valid email address required}

		password: opt string! length is between [6 20]
		else {Password should be between 6 and 20 characters}

		is confirmed by :confirmation
		else {Passwords do not match}

		biography: opt string! length is less-than 200
		else {Biography text is too long - 200 character max.}

		text: opt string! length is less-than 100'000
		else {Biography text is too long - 100,000 character limit.}

		home_page: opt url! [
			"http" opt "s" "://" some [url* | "/"]
		] length is less-than 100

		google_profile: opt url! ([
			"http" opt "s" "://plus.google.com/" opt "u/0/" copy value number ["/" ["posts" | "about" |] |] end
			(insert value https://plus.google.com/)
		])

		twitter_id: opt string! ([
			opt "@" copy value 1 15 [alphanum | #"_"]
		]) else {Not a valid Twitter Handle}

		facebook_profile: opt url! ([
			opt ["http" opt "s" "://" opt "www." "facebook.com/"]
			copy value 5 50 [alphanum | #"."]
			(insert value https://www.facebook.com/)
		])
	]

	roles: [roles: opt block!]

	override: inherit :settings copy :roles
]

