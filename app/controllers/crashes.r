REBOL [
	Title: "Crashes"
	Date: 23-Oct-2011
	Author: "Christopher Ross-Gill"
	Type: 'controller
	Location: wrt://space/crash/
]

route () to %errors/crashes [
	assert-all [
		user/has-role? 'moderator [
			reject 403 %errors/notauthorized.rsp
		]
	]

	get [
		crashes: map/only any [read header/location []] func [crash][load join header/location crash]
		sort/reverse crashes
		; send/subject rg.chris@gmail.com "<h1>Hello from Crashes</h1><p>Hello</p>" "Hello from Crashes!"
	]

	delete [if exists? header/location [close clear open header/location redirect-to %/crashes]]
]