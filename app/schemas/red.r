REBOL [
	Title: "Red Web Site Database Spec"
	Type: 'schema
]

db_red: database [
	sessions: table [
		id: tuple! 23 primary
		created: date!
		modified: date! index
		address: opt tuple! 20
		user: opt :users
		message: opt string! 600
		crumbs: opt block! 255
		other: opt block! 255
	]

	users: table [
		id: string! 20 primary index
		owner: opt logic!
		valikey: tuple! 23
		toc: logic!
		name: string! 80
		email: email! 80
		password: string! 100
		joined: date!
		roles: opt block! 255
		last-activity: date!
		biography: opt string! 255
		home-page: opt url! 150
		google-profile: opt url! 80
		twitter-id: opt string! 15
		facebook-profile: opt url! 80
		misc: opt block! 255
	]

	documents: table [
		id: integer! 11 primary increment
		name: string! 60 index
		title: string! 60 index
		kind: string! ["Item" "Article" "News" "Opinion" "Concept" "Resource" "Author" "Place" "Topic" "Note" "Wiki" "Comment"] index
		status: string! ["Live" "Archive"]
		editor: :users index
		modified: date!
		options: opt block! 100
		text: opt string!
		document: opt block!
		html: opt string!
		terms: opt string!
	]

	issues: table [
		id: integer! 11 primary increment
		summary: string! 120
		description: string!
		response: opt string!
		severity: string! ["Feature" "Trivial" "Text" "Tweak" "Minor" "Major" "Crash" "Block"]
		status: string! ["New" "Feedback" "Acknowledged" "Confirmed" "Assigned" "Resolved" "Closed"]
		resolution: string! ["Open" "Fixed" "Reopened" "Unconfirmed" "Unfixable" "Duplicate" "No Change" "Suspended" "Won't Fix"]
		priority: opt string! ["Low" "Normal" "Urgent" "Immediate"]
		submitted: date!
		submitter: :users
		reviewed: opt date!
		reviewer: opt :users
		assignee: opt :users
		resolved: opt date!
	]

	notes: table [
		id: string! 60 primary index
		title: string! 60
		public: logic!
		document: :documents
		modified: opt date!
		author: :users
		created: date!
	]

	wiki: table [
		id: string! 60 primary index
		title: string! 60
		public: logic!
		document: :documents
		modified: opt date!
		author: :users
		created: date!
	]

	news: table [
		id: string! 80 primary index ; "2012/08/peru-wins-world-cup"
		title: string! 60 index
		name: string! 60
		status: string! ["Draft" "Ready" "Live"] index
		short: string! 240
		document: :documents
		author: :users index
		created: date!
		published: opt date!
		modified: date!
		tags: opt block! 400
	]

	slideshows: table [
		id: string! 16 primary index
		title: string! 60
		type: string! ["S5" "Impress"]
		text: string!
		html: string!
		modified: opt date!
		author: :users
		created: date!
	]

	tags: table [
		id: string! 24
		description: string! 240
	]

	; join tables
	authors-news: table [
		author: :users
		item: :news
	]

	authors-wiki: table [
		author: :users
		page: :wiki
	]

	tags-news: table [
		tag: :tags
		item: :news
	]

	tags-wiki: table [
		tag: :tags
		page: :wiki
	]
]
