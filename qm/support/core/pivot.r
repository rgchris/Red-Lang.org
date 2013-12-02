REBOL [
	Title: "Pivot"
	Date:  7-Nov-2013
	Author: "Christopher Ross-Gill"
	Version: 0.2.1
	Type: 'module
	Exports: [pivot]
	Example: [
		probe pivot [n v][
			#a ["b" "c"]
			#b ["c" "d"]
		]

		== [
			v [
				"b" [#a]
				"c" [#a #b]
				"d" [#b]
			]
		]
	]
]

pivot: func [values [block!] data [block!] /local out reducees][
	out: collect [
		foreach name next values [
			keep name
			keep/only copy []
		]
	]

	reducees: collect [
		foreach name next values [
			keep to lit-word! name
			keep name
		]
	]

	foreach :values data compose/deep [
		foreach [name* values*] reduce [(reducees)][
			foreach value* values* [
				append first any [
					find/tail select out name* value*
					back insert tail select out name* reduce [value* copy []]
				] (values/1)
			]
		]
	]

	; Neaten the result set
	foreach [name values] out [
		new-line/all/skip values true 2
		foreach [name values] values [
			either tail? skip values 6 [
				new-line/all values false
			][
				new-line/all/skip values true 4
			]
		]
	]

	new-line/all/skip out true 2
]
