REBOL [
	Title: "Red Wiki"
	Date:  2-May-2013
	Author: "Christopher Ross-Gill"
	Type: 'controller
	Template: %templates/red.rsp
]

event "before" does [background: 'red]

route () to %page [
	verify [
		where %,edit [user/editor?][
			reject 403 %errors/notauthorized
		]
	]


	get [
		id: title: "Red"
		page: select wiki id

		either page [
			page/load-doc
		][
			reject 404 %errors/notfound
		]
	]
]


route (id: string! [wiki]) to %page [
	verify [
		where %,edit [user/editor?][
			reject 403 %errors/notauthorized
		]
	]

	get [
		id: url-encode/wiki 
		title: url-decode/wiki id
		page: select wiki id
	
		if all [
			not user/editor?
			id = "organisation"
		][
			reject 404 "Page Not Found" ; mimic a not found when trying to view the organiation page without contributor priviledges.
		]

		case [
			page [
				page/load-doc

				; probe page/document/data
			]
			user/editor? [
				page: select wiki 'new
				page/set 'id id
				page/set 'title title
				render %page,edit
			]
			else [
				reject 404 %errors/notfound
			]
		]
	]

	get %,edit [
		id: url-encode/wiki title: url-decode/wiki id
		page: select wiki id
		either page [
			page/load-doc
			where %,edit [
				unless user/editor? [
					reject 403 "Editing not authorized"
				]
			]
		][
			either user/editor? [
				page: select wiki 'new
				page/set 'id id
				page/set 'title title
				response/aspect: %,edit
			][
				reject 404 "Page Not Found"
			]
		]
	]

	put %,edit [
		id: url-encode/wiki title: url-decode/wiki id
		page: select wiki id
		unless page [
			page: select wiki 'new
			page/set 'id id
			page/set 'title title
		]

		either user/editor? [
			either page/submit update get-param/body 'page [
				page/bind-to user
				page/set 'author user/id
				page/store
				redirect-to wiki/(page/id)
			][
				response/packet: %,edit
			]
		][
			reject 404 "Page Not Found"
		]
	]

	delete %,edit [
		either user/editor? [
			id: url-encode/wiki title: url-decode/wiki id
			page: select wiki id
			if page [page/destroy]
			redirect-to %/dashboard
		][
			reject 403 "Not Authorized"
		]
	]
]

