REBOL [
	Title: "Legacy URL Handler"
	Date: 30-Jan-2014
	Author: "Christopher Ross-Gill"
	Type: 'controller
]

route ("wiki" page: string! [wordify]) to none [
	verify [
		page: pick select wiki [by-old-slug join "p/" page] 1 [
			reject 404 "Not Found"
		]
	]

	get [redirect-to wiki/(page/id)]
]

route (
	"news"
	year: string! [4 digit]
	month: string! [2 digit]
	item: string! [wordify]
) to none [
	verify [
		item: pick select news [by-old-slug rejoin [year "/" month "/" item]] 1 [
			reject 404 "Not Found"
		]
	]

	get [redirect-to news/(item/id)]
]