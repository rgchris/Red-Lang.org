REBOL [
	Title: "Documents Helper"
	Date: 30-Dec-2011
	Type: 'roughcut
	Author: "Christopher Ross-Gill"
]

locate: func [id [integer!]][
	pad id 6
]

kind-of: func [record [object!]][
	record/owner/locals/name
]

record: make record [
	doc: none

	render: does [
		require %makedoc/makedoc.r

		make-doc/custom get 'text [
			document: %document.r
			markup: %html.r
			paragraph: %paragraph.r
		]
	]

	build: func [/with options [none! block!] /rebuild][
		require %makedoc/makedoc.r

		doc: load-doc/with/custom get 'text options [
			document: %document.r
			markup: %html.r
			paragraph: %paragraph.r
		]

		set 'document doc/document
		set 'html doc/render

		if rebuild [store]

		doc
	]

	bind-to: func [record [object!] user [object!] /with options [block!] /local doc kind][
		if not set 'text record/get 'text [
			either new? [return none][set 'text ""]
		]

		unless id [set 'id <auto>]

		doc: build/with options

		set 'kind kind: switch kind-of record [
			articles ["Article"]
			news ["News"]
			opinion ["Opinion"]
			places ["Place"]
			topics ["Topic"]
			notes ["Note"]
			users ["Author"]
			concepts ["Concept"]
			wiki ["Wiki"]
		]

		set 'title record/get (either kind = "Author" ['name]['title])
		set 'modified now
		set 'status "live"
		set 'editor user/id

		set 'name switch/default get 'kind [
			"News" "Opinion" [record/name]
		][record/get 'id]

		if error? err: try [store][
			probe errors
			:err
		]

		write path/(press [form-date now "draft!%Y-%m-%d%%2F%H%%3A%M%%3A%S!" user/id "!.rmd"]) doc/text
		record/set 'document id
	]

	history: does [
		collect [
			foreach doc read/custom path ["draft!" thru "!" thru "!.rmd" end][
				keep doc
				doc: parse dehex doc "!"
				keep to-date doc/2
				keep doc/3
			]
		]
	]

	recover: func [date [date!] user [string!]][
		read doc/path/(press [form-date/gmt date "draft!%Y-%m-%d%%2F%H%%3A%M%%3A%S!" user "!.rmd"])
	]

	first-image: has [image html][
		; foreach [style content] get 'document [
		; 	switch style [
		; 		image [break/return content]
		; 		flickr [break/return content]
		; 	]
		; ]
		all [
			html: get 'html
			html: find html "<img"
			html: find/tail html "src="
			image: first load/next html
			to-url either image/1 = #"/" [head change/part image settings/home 1][image]
		]
	]

	tags: does [
		collect [
			foreach [style content] get 'document [
				if style = 'tags [keep content]
			]
		]
	]
]
