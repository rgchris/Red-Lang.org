REBOL [
	Title: "News Articles"
	Type: 'roughcut
	Statuses: ["draft" "live"]
	Kinds: ["News" "Opinion"]
]

forms: make forms [
	create: edit: [
		title: string! else "Title is required"
		length is between [1 52] else "No Title"
		short: string! else "Short is required"
		length is less-than 240 else "Brief is Too Long"
		text: string! else "Article is required"
		length is less-than 200'000 else "Article length exceeds current size limit"
	]
]

queries: make queries [
	; article: [set: * tables: articles clauses: id = ?]
	; drafts-for-user: [set: * tables: articles clauses: all [status = "draft" author = ?]]

	; item: "SELECT * FROM news WHERE id = ?"
	drafts-for-user: "SELECT * FROM news WHERE status <> 'Live' AND author = ? ORDER BY created DESC"
	pending-drafts: "SELECT * FROM news WHERE status = 'Ready' ORDER BY created DESC"

	latest: "SELECT * FROM news WHERE status = 'Live' ORDER BY published DESC LIMIT 0,10"
	latest-full: "SELECT i.*, d.html FROM news i JOIN documents d ON i.document = d.id WHERE i.status = 'Live' ORDER BY i.published DESC LIMIT 0,4"
	from: "SELECT i.*, d.html FROM news i JOIN documents d ON i.document = d.id WHERE i.status = 'Live' AND i.id LIKE ? ORDER BY i.published DESC"

	find-in-title: {
		SELECT * FROM news
		WHERE title LIKE ?
	}

	find-in-article: {
		SELECT i.* FROM news i JOIN documents d ON i.document = d.id
		WHERE d.text LIKE ?
	}

	by-author: {
		SELECT i.*
		FROM news i JOIN authors_news a ON a.item = i.id
		WHERE a.author = ?
		LIMIT 0,11
	}

	connect-author: "INSERT INTO authors_news (author,item) VALUES (?,?)"
	purge-author: "DELETE FROM authors_news WHERE item = ?"

	update-id: "UPDATE news SET id = ? WHERE id = ?"

	history: {
		SELECT
			YEAR(published) as year,
			MONTH(published) AS month,
			COUNT(*) AS count
		FROM news
		WHERE status = 'live'
		GROUP BY year, month
		ORDER BY year DESC, month DESC
	}
]

record: make record [
	document: author: link: perma: draft?: none

	on-create: does [
		set 'created now
		set 'status "draft"
		set 'rating 0
		draft?: true
	]

	on-load: does [
		title: get 'title
		name: get 'name
		author: select users get 'author
		draft?: find ["Draft" "Ready"] get 'status
		link: link-to news/:id
		perma: link-to/full (link)
	]

	on-save: does [
		set 'modified now
	]

	name: title: none

	text: does [
		any [
			get 'text
			; read path/article.txt
			all [document document/get 'text]
		]
	]

	html: does [
		any [
			all [document document/get 'html]
			"<p><i>Article Pending</i></p>"
		]
	]

	; contributor?: func [user-id][
	; 	user-id = get 'author
	; ]

	tag: does [
		join form-date get 'published "tag:red-lang.org,%Y-%m-%d:" next link
	]

	created: does [get 'created]
	published: does [get 'published]

	status: does [
		any [
			get 'status
			unless new? ["draft"]
		]
	]

	draft?: does [status = "draft"]
	live?: does [status = "live"]

	rank: 0
	finds?: func [query /local content] [
		; Show the results of a blog search, listed by search-hit rank:
		unless string? query [return none]

		rank: 0
		query: parse query none

		foreach term query [
			if find/any title term [rank: rank + 4]
			content: text
			while [content: find/any/tail content term][rank: rank + 1]
		]

		rank > 0
	]

	load-doc: does [
		document: select documents get 'document
	]

	make-doc: func [user [object!]][
		document: select documents any [get 'document 'new]
		document/bind-to self user
	]

	bind-to: func [author [object!]][
		set 'creator author/id
		set 'author author/id
		make-doc author
	]

	make-id: has [ni nn][
		ni: press [
			either ni: get 'published [
				form-date ni "%Y/%m/"
			]["draft/"]
			nn: wordify get 'title
		]

		case [
			id = ni [id] ; no id change

			find owner ni [none] ; exists already

			id = none [ ; new draft
				name: set 'name nn
				id: set 'id ni
			]

			ni [ ; update draft
				name: set 'name nn
				select owner [update-id ni id]
				id: set 'id ni
			]
		]
	]

	publish: does [
		load-doc

		set 'published any [get 'published now]
		set 'status "Live"

		if make-id [
			store

			select owner [connect-author get 'author id]

			link: link-to news/:id
		]
	]

	demote: does [
		set 'status "Ready"
		store
		select owner [purge-author id]
	]
]

history: does [query-db/flat queries/history]

latest-feed: func [header [block! object!]][
	require %feeds/feeds.r
	foreach entry entries: select news [latest] [entry/load-doc]
	write wrt://site/feeds/news.feed build-feed header entries
]
