REBOL [
	Title: "Wiki Model"
	Date: 26-Nov-2011
	Author: "Christopher Ross-Gill"
	Type: 'roughcut
]

forms: make forms [
	update: [
		text: string! else "Content is required"
		length is less-than 20'000 else "Content is Too Long"
		public: logic!
	]
]

record: make record [
	document: public?: none

	on-create: does [set 'created now]
	on-save: does [set 'modified now]
	on-load: does [public?: get 'public]

	title: does [any [get 'title "No Title"]]

	load-doc: does [document: select documents get 'document]

	bind-to: func [user [object!]][
		document: select documents any [get 'document 'new]
		document/bind-to self user
	]

	text: does [
		any [
			get 'text
			all [document document/get 'text]
		]
	]

	html: does [
		any [
			all [document document/get 'html]
			"<p><i>No Content</i></p>"
		]
	]
]
