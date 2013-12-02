REBOL [
	Title: "Issues Model"
	Date:  6-Jun-2012
	Author: "Christopher Ross-Gill"
	Type: 'roughcut
	Severities: ["Feature" "Trivial" "Text" "Tweak" "Minor" "Major" "Crash"]
	Resolutions: ["Open" "Fixed" "Reopened" "Unconfirmed" "Unfixable" "Duplicate" "No change" "Won't Fix"]
	Statuses: ["New" "Feedback" "Reviewed" "Assigned" "Resolved" "Closed"]
	Priorities: ["Low" "Normal" "High" "Urgent" "Immediate"]
]

forms: make forms [
	create: revise: [
		summary: string! length is less-than 120
		description: string! length is less-than 3'000
		severity: string! is within (header/severities)
	]

	review: inherit create [
		response: opt string! length is less-than 3'000
		resolution: string! is within (header/resolutions)
		priority: string! is within (header/priorities)
	]
]

queries: make queries [
	recent: {SELECT * FROM issues WHERE status NOT IN ('resolved','closed') ORDER BY submitted DESC LIMIT 0,15}
	priority: {SELECT * FROM issues WHERE status NOT IN ('resolved','closed') ORDER BY priority}
	for-user: {SELECT * FROM issues WHERE submitter = ?}
	open-for-user: {SELECT * FROM issues WHERE submitter = ? AND status NOT IN ('resolved','closed')}
]

record: make record [
	on-create: does [
		set 'id <auto>
		set 'submitted now
		set 'status "New"
		set 'resolution "Open"
	]

	by: summary: description: resolved?: none

	on-load: does [
		summary: get 'summary
		resolved?: find ["resolved" "closed"] get 'status
		by: select users get 'submitter
	]

	create: func [user [object!] details [block! none!]][
		if submit create details [
			set 'submitter user/id
			store
		]
	]

	response: does [
		any [
			get 'response
			"No response yet."
		]
	]

	revise: func [details [block! none!]][
		; doesn't update status
		if submit revise details [store]
	]

	review: func [details [block! none!]][
		if submit review details [
			if unworked? [
				set 'status "Reviewed"
				set 'reviewed now
			]
			store
		]
	]

	ticket: does [all [id pad id 4]]
	title: does [join "Issue #" ticket]

	unworked?: does [found? find ["New" "Feedback" #[none]] get 'status]
	open?: does [find ["Feedback" "Reviewed" "Assigned"] get 'status]
	reviewed?: does [find ["Reviewed" "Assigned"] get 'status]
	closed?: does [find ["Closed" "Resolved"] get 'status]

	can-edit?: func [user [object!]][
		all [
			unworked?
			user/id = get 'submitter
		]
	]

	can-review?: func [user [object!]][
		all [
			user/developer?
			any [unworked? reviewed?]
		]
	]

	can-resolve?: func [user [object!]][
		all [
			user/developer?
			reviewed?
		]
	]

	can-reopen?: func [user [object!]][
		all [
			user/developer?
			closed?
		]
	]
]