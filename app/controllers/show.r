REBOL [
	Title: "Red Presentations"
	Date:  2-May-2013
	Author: "Christopher Ross-Gill"
	Type: 'controller
	Template: %templates/red.rsp
]

route () to %slideshows [
	verify [
		where %,new [
			user/author?
		][
			reject 400 "Presentations can only be created by Authors."
		]
	]

	get [
		id: title: "Slide Shows"
		collection: copy slideshows
	]

	get %,new [
		id: title: "New Slide Show"
		slides: select slideshows 'new
	]

	put %,new [
		slides: select slideshows 'new

		if slides/submit create get-param/body 'slides [
			slides/author: :user
			slides/store
			redirect-to show/(slides/id)
		]
	]
]

route (id: string!) to %slides [
	verify [
		slides: select slideshows id [
			reject 404 %errors/notfound
		]

		where %,edit [
			any [
				user/id = slides/author/id
				user/editor?
			]
		][
			reject 403 %errors/notauthorized
		]
	]

	get [
		title: slides/title
		where/else %.rmd [
			print slides/get 'text
		][
			slides/init-doc
		]
	]

	get %,show [
		render/template slides/html none
	]

	post %,edit [
		if slides/submit update get-param/body 'slides [
			slides/store
			redirect-to show/(slides/id)
		]
	]

	delete %,edit [
		slides/destroy
		redirect-to %/show
	]
]

