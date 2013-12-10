REBOL [
	Title: "Color REBOL Code in HTML"
	Date: 23-Oct-2009
	File: %color-code.r
	Author: "Carl Sassenrath"
	Type: 'module
	Exports: [color-code]
	Purpose: {
		Colorize source code based on datatype.
		Result is HTML <pre> block.
		Works with R3
		Sample CSS: http://www.ross-gill.com/styles/rebol-code.css
	}
	History: [
		29-May-2003 "Fixed deep parse rule bug."
	]
]

color-code: use [out emit whitelist emit-var rule value][
	out: none
	emit: func [data][
		data: reduce envelop data until [append out take data empty? data]
	]

	whitelist: [
		  "reb4.me"
		| opt "www." "ross-gill.com"
		| ["chat." | "www." |]"stackoverflow.com"
		| opt "www." "re" opt "-" "bol"
		| opt "www." "red-lang."
		| opt "www." "github." ["io" | "com"] "/"
		| "opensource.org"
		| "recode.revault.org"
	]

	emit-var: func [value start stop /local type out][
		either none? :value [type: "cmt"][
			if path? :value [value: first :value]

			type: either word? :value [
				any [
					all [find [Rebol Red Topaz Freebell] value "rebol"]
					all [value? :value any-function? get :value "function"]
					all [value? :value datatype? get :value "datatype"]
					"word"
				]
			][
				any [replace to-string type?/word :value "!" ""]
			]
		]

		out: sanitize copy/part start stop

		either all [
			url? value
			parse/all value [
				"http" opt "s" "://" whitelist to end
			]
		][
			rejoin [
				{<a class="dt-url" href="} out {">} out {</a>}
			]
		][
			either type [
				emit [{<var class="dt-} type {">} out {</var>}]
			][
				emit out
			]
		]
	]

	rule: use [
		str new val rule
		hex alpha digit sign space?
		number percent word
	][
		space?: use [mark][
			[mark: [" " | newline | tab | "," | end] :mark]
		]

		alpha: charset [#"a" - #"z"]
		digit: charset "0123456789"
		hex: charset "0123456789abcdefABCDEF"
		sign: charset "-+"

		number: [digit any [digit | "'"]]

		word: use [word][
			word: union union alpha digit charset "-_!"
			[alpha any word]
		]

		percent: use [sp ex][
			sp: charset ".,"
			ex: ["E" opt sign some digit]

			[opt sign [number opt [ex | sp number opt ex] | sp number opt ex] "%"]
		]

		rule: [
			some [
				str:
				some [" " | tab] new: (emit copy/part str new) |
				newline (emit "^/") |
				#";" [thru newline | to end] new:
					(emit-var none str new) |
				[#"[" | #"("] (emit first str) rule |
				[#"]" | #")"] (emit first str) break |

				; non-Rebol 2 values:
				[8 hex | 4 hex | 2 hex] #"h" new:
					(emit-var 0 str new) | ; Red - Hex Integer! notation
				percent new: (emit-var 0.1 str new) | ; Rebol 3 Percent!
				":" new: space? [thru newline | to end] new: (emit-var none str new) | ; Commentize isolated colons
				"," new: space? (emit ",") | ; Ignore commas
				"<" word ">:" [thru newline | to end] new: (emit-var none str new) | ; Commentize 'set-tag-words', used in Red docs
				; copy val word new: "," (emit-var to word! val str new emit ",") | ; Ignore words followed by commas
				opt sign number [
					2 10 alpha new: space? (emit-var 0 str new) ; Ignore 'measure!' types
					| opt ["." number] 2 10 alpha new: space? (emit-var 1.0 str new)
				] |

				; Rebol 2 values:
				skip (
					set [value new] load/next str
					emit-var :value str new
				) :new
			]
		]

		[
			rule [end | str: to end (emit sanitize str)]
		]
	]

	func [
		[catch] "Return color source code as HTML."
		text [string!] "Source code text"
	][
		out: make binary! 3 * length? text
		parse/all text [rule]

		insert out {<pre class="code rebol">}
		append out {</pre>}
	]
]
