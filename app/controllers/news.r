REBOL [
	Title: "News Controller"
	Date: 31-Aug-2012
	Author: "Christopher Ross-Gill"
	Type: 'controller
	Template: %templates/red.rsp
	Feed: [
		Title: "Red"
		Subtitle: "The Full-Stack Programming Language"
		ID: Base: http://www.red-lang.org/
		Link: %/news/
		Target: %/feeds/news.feed
		Logo: Icon: http://www.red-lang.org/assets/red-logo.png
		Tag: tag:red-lang.org
	]
]

event "before" does [require %text/wordify.r]

route () to %news [
	verify [
		where %,new [user/blogger?][
			reject 403 %errors/notauthorized
		]
	]

	get [
		title: "Red: News"
		where %.html [
			subhead: "Latest"
			history: news/locals/history
			collection: categorize select news [latest-full] func [item [object!]][
				all [
					item: item/get 'published
					to-date reduce [item/year item/month 1]
				]
			]
		]

		where %.atom [
			redirect-to %/feeds/news.feed
		]
	]

	get %,new [
		title: "Create News Post"
		draft: select news 'new
	]

	post %,new [
		title: "Create News Post"
		draft: select news 'new

		if verify [
			draft/submit create get-param/body 'draft []

			draft/make-id [
				draft/errors: [title ["A draft using that title already exists."]]
			]
		][
			draft/bind-to user
			draft/store
			redirect-to news/(draft/id)
		]
	]
]

route (year: integer! is between 2000x20000 month: opt integer! is between 1x12) to %news [
	get [
		date: now/date
		all [
			1000 > abs date/year - year
			date/year: year
		]
		date/month: any [month date/month]
		date/day: 1
		if now/date < date [date: now]

		date-back: date-next: date

		date-back/month: date-back/month - 1
		date-next/month: date-next/month + 1
		if date-next > now/date [date-next: none]

		subhead: form-date date "for %B %Y"
		history: news/locals/history

		collection: reduce [
			date select news [from form-date date "%Y/%m/%%"]
		]
	]
]

route ("draft" name: string! [1 52 name]) to %draft [
	verify [
		draft: select news id: press ["draft/" name] [
			; probe id
			reject 404 %errors/notfound.rsp
		]

		user/blogger? [
			reject 403 %errors/notauthorized.rsp
		]
	]

	get [
		draft/load-doc
		title: join "[DRAFT] " draft/title
	]

	put [
		if verify [
			draft/submit edit get-param/body 'draft []

			draft/make-id [
				draft/errors: [title ["A draft using that title already exists."]]
			]
		][
			draft/make-doc user
			draft/store
			redirect-to news/(draft/id)
		]
	]

	delete [
		draft/destroy
		redirect-to %/dashboard
	]


	put %,status [
		flash: func [message /show][
			session/message/hold message
			show: either show [draft/link][%/dashboard]
			redirect-to :show
		]

		unless change-status draft/get 'status get-param/body 'status [
			"draft" "live" (
				user/blogger?
				user/id = draft/author/id
			) [
				either draft/publish [
					news/locals/latest-feed header/feed
					flash/show ["Draft '" draft/title "' published."]
				][
					reject 400 "Post Title Already Exists"
				]
			]

			"ready" "live" (user/blogger?) [
				either draft/publish [
					news/locals/latest-feed header/feed
					flash/show ["Draft '" draft/title "' published."]
				][
					reject 400 "Post Title Already Exists"
				]
			]

			"draft" "ready" (user/id = draft/author/id) [
				draft/set 'status "ready"
				draft/store
				flash ["Draft '" draft/title "' submitted."]
			]

		][
			reject 403 %errors/notauthorized
		]
	]
]

route (
	year: integer!
	month: integer!
	name: string! [1 52 name]
)
to %item [
	verify [
		item: select news id: press [pad year 4 "/" pad month 2 "/" name] [
			reject 404 %errors/notfound
		]

		any [
			item/live?
			item/author/id = user/id
			user/blogger?
		][
			reject 403 %errors/notauthorized
		]

		where %,edit [not item/live?][
			reject 400 "Can't Edit a Live Post"
		]
	]

	get [
		title: item/title
		item/load-doc

		where %.rmd [
			print item/document/get 'text
		]
	]

	get %,edit [
		title: item/title
		item/load-doc

		unless item/live? [
			title: join "[EDIT] " title
		]

		draft: :item
		render %draft,edit
	]

	put %,edit [
		either item/submit edit get-param/body 'draft [
			item/make-doc user
			item/store
			redirect-to news/(item/id)
		][
			draft: :item
			render %draft,edit
		]
	]

	delete [
		draft/destroy
		redirect-to %/dashboard
	]

	put %,status [
		flash: func [message /show][
			session/message/hold message
			show: either show [item/link][%/dashboard]
			redirect-to :show
		]

		unless change-status item/get 'status get-param/body 'status [
			"live" "ready" (user/blogger?) [
				item/set 'status "Ready"
				item/store
				news/locals/latest-feed header/feed
				flash/show ["Item '" item/title "' returned to drafts."]
			]

			"ready" "live" (user/blogger?) [
				item/publish
				news/locals/latest-feed header/feed
				flash/show ["Item '" item/title "' republished."]
			]
		][
			reject 403 %errors/notauthorized
		]
	]
]
