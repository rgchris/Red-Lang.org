REBOL [
	Title: "Pictures"
	Date: 20-Jul-2013
	Author: "Christopher Ross-Gill"
	Type: 'controller
	Template: %templates/red.rsp
]

route () to %photos [
	get [photos/fetch]
]