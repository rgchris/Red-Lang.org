REBOL [
	Title: "Notes Wiki Controller"
	Date: 29-Nov-2011
	Author: "Christopher Ross-Gill"
	Type: 'controller
	Template: %templates/red.rsp
]

route (id: string! [wiki]) to %note [
	verify [
		user/moderator? [
			reject 403 %errors/notauthorized
		]
	]

	get [
		id: url-encode/wiki title: url-decode/wiki id
		note: select notes id

		either note [
			note/load-doc
			; probe note/document/data
		][
			note: select notes 'new
			note/set 'id id
			note/set 'title title
			render %note,edit
		]
	]

	get %,edit [
		id: url-encode/wiki title: url-decode/wiki id
		note: select notes id
		either note [
			note/load-doc
		][
			note: select notes 'new
			note/set 'id id
			note/set 'title title
			response/aspect: %,edit
		]
	]

	put %,edit [
		id: url-encode/wiki title: url-decode/wiki id
		note: select notes id
		unless note [
			note: select notes 'new
			note/set 'id id
			note/set 'title title
		]

		either note/submit update get-param/body 'note [
			note/bind-to user
			note/set 'author user/id
			note/store
			redirect-to notes/(note/id)
		][
			response/aspect: %,edit
		]
	]

	delete %,edit [
		id: url-encode/wiki title: url-decode/wiki id
		note: select notes id
		if note [note/destroy]
		redirect-to %/dashboard
	]
]
