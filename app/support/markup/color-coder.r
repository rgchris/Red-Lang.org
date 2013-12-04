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

color-code: use [out emit whitelist emit-var emit-header rule value][
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

	emit-var: func [value start stop /local type][
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

		value: either all [
			url? value
			parse/all value [
				"http" opt "s" "://" whitelist to end
			]
		][
			rejoin [
				"-[" {-a class=-|} {-dt-url-} {|- href=-|} "-" value "-" {|--} "]-" copy/part start stop "-[" {-/a-} "]-"
			]
		][
			copy/part start stop
		]

		either type [ ; (Done this way so script can color itself.)
			emit [
				"-[" {-var class=-|} {-dt-} type {-} {|--} "]-"
				value
				"-[" "-/var-" "]-"
			]
		][
			emit value
		]
	]

	rule: use [str new rule hx percent][
		hx: charset "0123456789abcdefABCDEF"
		
		percent: use [dg nm sg sp ex][
			dg: charset "0123456789"
			nm: [dg any [some dg | "'"]]
			sg: charset "-+"
			sp: charset ".,"
			ex: ["E" opt sg some dg]

			[opt sg [nm opt [ex | sp nm opt ex] | sp nm opt ex] "%"]
		]

		rule: [
			some [
				str:
				some [" " | tab] new: (emit copy/part str new) |
				newline (emit "^/") |
				#";" [thru newline | to end] new:
					(emit-var none str new) |
				#"[" (emit "_[" emit "_") |
				#"(" (emit "(") rule |
				[#"]" | #")"] (emit first str) break |
				[8 hx | 4 hx | 2 hx] #"h" new:
					(emit-var 0 str new) |
				percent new: (emit-var 0.1 str new) |
				skip (
					set [value new] load/next str
					emit-var :value str new
				) :new
			]
		]

		[
			rule [end | str: to end (emit str)]
		]
	]

	func [
		[catch] "Return color source code as HTML."
		text [string!] "Source code text"
	][
		out: make binary! 3 * length? text
		parse/all text [rule]
		out: sanitize to string! out

		foreach [from to] reduce [ ; (join avoids the pattern)
			; "&" "&amp;" "<" "&lt;" ">" "&gt;" "^(A9)2" "&copy;2"
			join "-[" "-" "<" join "-" "]-" ">" join "-|" "-" {"}
			join "_[" "_" "["
		][
			replace/all out from to
		]

		insert out {<pre class="code rebol">}
		append out {</pre>}
	]
]
