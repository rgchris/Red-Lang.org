REBOL [
	Title: "HTML DOM"
	File: %html.r
	Purpose: "HTML Parser and Document API for Rebol"
	Author: "Christopher Ross-Gill"
	Home: http://www.ross-gill.com/page/XML_and_REBOL
	Date: 18-Apr-2013
	Version: 0.1.0
	Type: 'module
	Exports: [load-html]
	MezzModules: wrt://system/support/power-mezz/
	; MezzModules: %/Volumes/Sandbox/Downloads/power-mezz-built-1.0.0/
]

do header/mezzmodules/mezz/module.r
load-module/from header/mezzmodules

module [
	Title: "Load HTML"
	Globals: [html-loader]
	Imports: [%mezz/load-html.r]
][
	html-loader: use [
		html! doc make-node
		name attribute element
	][
		html!: context [
			name: space: value: tree: branch: position: none

			flatten: use [xml path emit encode form-name element attribute tag attr text][
				path: copy []
				emit: func [data][repend xml data]

				encode: use [ch tx][
					ch: #[bitset! 64#{/////7v//+////////////////////////////////8=}]
					; complement charset {<"&}
					tx: [
						some ch | text: skip (
							text: change/part text switch text/1 [
								#"<" ["&lt;"] #"^"" ["&quot;"] #"&" ["&amp;"]
							] 1
						)
					]
					func [text][parse/all text: copy text [some tx] head text]
				]

				form-name: func [name [tag! issue!]][
					join "" [to-string copy/part head name name ":" to-string name]
				]

				attribute: [
					set attr issue! set text [any-string! | number! | logic!] (
						attr: either head? attr [to-string attr][form-name attr]
						emit [" " attr {="} encode form text {"}]
					)
				]

				element: [
					set tag tag! (
						insert path tag: either head? tag [to-string tag][form-name tag]
						emit ["<" either head? tag [tag][]]
					) [
						  none! (emit " />" remove path)
						| set text string! (emit [">" encode text "</" tag ">"] remove path)
						| into [
							any attribute [
								  end (emit " />" remove path)
								| (emit ">") some element end (emit ["</" take path ">"])
							]
						]
					]
					| %.txt set text string! (emit encode text)
					| attribute
				]

				does [
					xml: copy ""
					if parse tree element [xml]
				]
			]

			find-element: func [element [tag! issue!]][
				find value element
			]

			get-by-tag: func [tag /local rule hit][
				collect [
					parse tree rule: [
						some [
							opt [hit: tag skip (keep make-node hit) :hit]
							skip [into rule | skip]
						]
					]
				]
			]

			get-by-id: func [id /local rule hit at][
				parse tree rule: [
					some [
						  at: tag! into [thru #id id to end] (hit: any [hit make-node at])
						| skip [into rule | skip]
					]
				] hit
			]

			get-by-class: func [class /local rule classes at][
				collect [
					parse tree rule: [
						some [
							  tag! at: into rule
							| #class set classes string! (
								if any [
									class = classes
									find parse/all classes " " class
								][
									keep make-node back at
								]
							)
							| skip skip
						]
					]
				]
			]

			text: has [rule text part][
				case/all [
					string? value [text: value]
					block? value [
						text: copy ""
						parse value rule: [
							any [[%.txt | tag!] set part string! (append text part) | skip into rule | 2 skip]
						]
						text: unless empty? text [trim/auto text]
					]
					string? text [trim/auto text]
				]
			]

			get: func [name [issue! tag!] /local hit at][
				if parse tree [
					tag! into [
						any [
							  at: name [block! (hit: make-node at) | set hit skip] to end
							| [issue! | tag! | file!] skip
						]
					]
				][hit]
			]

			sibling: func [/before /after][
				case [
					all [after find [tag! file!] type?/word position/3] [
						make-node skip position 2
					]
	 				all [before find [tag! file!] type?/word position/-2] [
						make-node skip position -2
					]
				]
			]

			parent: has [branch]["Need Branch" none]

			children: has [hits at][
				hits: copy []
				parse case [
					block? value [value] string? value [reduce [%.txt value]] none? value [[]]
				][
					any [issue! skip]
					any [at: [tag! | file!] skip (append hits make-node at)]
				]
				hits
			]

			attributes: has [hits at][
				hits: copy []
				parse either block? value [value][[]] [
					any [at: issue! skip (append hits make-node at)] to end
				]
				hits
			]

			clone: does [make-node tree]

			append-child: func [name data /local at][
				case [
					none? position/2 [value: tree/2: position/2: copy []]
					string? position/2 [
						new-line value: tree/2: position/2: compose [%.txt (position/2)] true
					]
				]

				either issue? name [
					parse position/2 [any [issue! skip] at:]
				][at: tail position/2]

				insert at reduce [name data]
				new-line at true
			]

			append-text: func [text][
				case [
					none? position/2 [value: tree/2: position/2: text]
					string? position/2 [append position/2 text]
					%.txt = pick tail position/2 -2 [append last position/2 text]
					block? position/2 [append-child %.txt text]
				]
			]

			append-attr: func [name value][
				name: any [remove find name: to-issue name "/" name]
				append-child name value
			]
		]

		doc: make html! [
			branch: make block! 16
			document: true
			dtd: none
			new: does [
				clear branch
				tree: position: reduce ['document none]
			]

			set-dtd: func [dtd][self/dtd: load dtd]

			open-tag: func [tag][
				insert/only branch position
				tag: any [remove find tag: to tag! tag "/" tag]
				tree: position: append-child tag none
			]

			close-tag: does [
				tree: position: take branch
			]
		]

		make-node: func [here /base][
			make either base [doc][html!][
				position: here
				name: here/1
				space: all [any-string? name not head? name copy/part head name name]
				value: here/2
				tree: reduce [name value]
			]
		]

		name: [word! | path!]

		element: use [this][
			[	  'declaration skip into ['value set this string! (doc/set-dtd this)]
				| 'text skip into ['value set this string! (doc/append-text this)]
				| 'comment skip skip
				| set this name (doc/open-tag this)
				  block!
				  opt into [any attribute]
				  any [into [element]]
				  end (doc/close-tag)
			]
		]

		attribute: use [attr value][
			[	set attr name set value skip
				(doc/append-attr attr value)
			]
		]

		html-loader: func [
			"Transform an HTML document to a REBOL block"
			document [any-string!] "An HTML string/location to transform"
			/dom "Returns an object with DOM-like methods to traverse the HTML tree"
			/local root
		][
			if any [file? document url? document][document: read document]
			root: doc/new
			parse (load-html document) ['root skip skip some [into [element]]]
			doc/tree: any [root/document []]
			doc/value: doc/tree/2
			either dom [make-node/base doc/tree][doc/tree]
		]
	]
]

load-html: :html-loader