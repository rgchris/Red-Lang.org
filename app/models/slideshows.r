REBOL [
	Title: "Slide Show Model"
	Date: 21-Jun-2013
	Author: "Christopher Ross-Gill"
	Type: 'roughcut
]

forms: make forms [
	create: update: [
		title: opt string! length is less-than 60
		text: string! else "Content is required"
		length is less-than 30'000 else "Content is Too Long"
		type: string! else "Pick your slide show type"
		is within ["S5" "Impress"] else "Please select the presentation type"
	]
]

make-hash: func [val [integer!]][
	copy/part lowercase enbase/base checksum/method form val 'md5 16 16
]

record: make record [
	on-create: does [
		until [not find owner set 'id make-hash random 99999999]
		touch 'created
	]

	on-save: does [
		touch 'modified
		set 'author any [get 'author author/id]
		set 'html render
	]

	on-update: does [
		write path/(press [form-date now "draft!%Y-%m-%d%%2F%H%%3A%M%%3A%S!" author/id "!.rmd"]) get 'text
	]

	on-load: does [
		title: get 'title
		author: select users get 'author
	]

	title: author: document: none

	init-doc: does [
		require %makedoc/makedoc.r
		require %dialects/cssr.r

		document: load-doc/custom/with get 'text switch kind? ["S5" [:s5] "Impress" [:impress]] dom
	]

	text: does [get 'text]
	kind?: does [any [get 'type "S5"]]

	render: func [/with target][
		require %makedoc/makedoc.r
		require %dialects/cssr.r

		init-doc
		document/render
	]

	; Both S5 and Impress Slideshows are Standalone HTML files, so we can
	; cache the whole thing in here.
	html: does [get 'html]
]

dom: [
	title: has [title][
		if parse document [opt ['options skip] 'para set title block! to end][
			form-para title
		]
	]

	boiler: has [boiler][
		collect [
			if parse document [opt ['options skip] 'para skip 'code set boiler string! to end][
				foreach para parse/all boiler "^/" [
					keep form-para para
				]
			]
		]
	]

	stylesheet: has [content][
		if parse document [thru 'style set content block!][
			require %dialects/cssr.r
			to-css content
		]
	]
]

s5: [
	template: %s5.rsp
	markup: %s5.r
]

impress: [
	template: %impress.rsp
	document: %impress-doc.r
	markup: %impress.r
	paragraph: %impress-para.r
]

form-para: func [para [string! block!]][
	para: compose [(para)]

	join "" collect [
		foreach part para [
			case [
				string? part [keep part]
				integer? part [keep encode-utf8 part]
				switch part [
					<quot> [keep to string! #{E2809C}]
					</quot> [keep to string! #{E2809D}]
					<apos> [keep to string! #{E28098}]
					</apos> [keep to string! #{E28099}]
				][]
				char? part [keep part]
			]
		]
	]
]

encode-utf8: func [
	"Encode a code point in UTF-8 format" 
	char [integer!] "Unicode code point"
][
	if char <= 127 [
		return as-string to binary! reduce [char]
	] 
	if char <= 2047 [
		return as-string to binary! reduce [
			char and 1984 / 64 + 192 
			char and 63 + 128
		]
	] 
	if char <= 65535 [
		return as-string to binary! reduce [
			char and 61440 / 4096 + 224 
			char and 4032 / 64 + 128 
			char and 63 + 128
		]
	] 
	if char > 2097151 [return ""] 
	as-string to binary! reduce [
		char and 1835008 / 262144 + 240 
		char and 258048 / 4096 + 128 
		char and 4032 / 64 + 128 
		char and 63 + 128
	]
]
