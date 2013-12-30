REBOL [
	Title: "Scan Para"
	Date: 16-Feb-2009
	Author: "Christopher Ross-Gill"
	Type: 'paragraph
]

(
	literal: use [code][
		code: complement charset "\`"

		[any [some code | "\" ["\" | "`"]]]
	]

	emit-code: func [code][
		emit <code>
		emit foreach [from to][
			"\\" "\"
			"\`" "`"
		][
			replace/all code from to
		]
		emit </code>
	]
)

not-in-word any [
	  some space (emit copy " ") not-in-word
	| copy text some alphanum (emit text) in-word
	| newline (emit <br>) not-in-word
	| #"\" copy char [
		  "\" | "`" | "*" | "_" | "{" | "}" | "[" | "]" | "(" | ")"
		| "#" | "=" | "+" | "-" | "." | "!" | "^"" | "'"
	] (emit char/1)
	| #"=" [
		  block (emit values) in-word
		| string (emit values) in-word
		| copy char number "." (
			char: load char all [char > 31 char < 65536 emit char]
		) in-word
		| "b " (emit <b>)
		| "b." (emit </b>)
		| "i " (emit <i>)
		| "i." (emit </i>)
		| "u " (emit <u>)
		| "u." (emit </u>)
		; | "d " (emit <dfn>)
		; | "d." (emit </dfn>)
		| "q " (emit <q>)
		| "q." (emit </q>)
		| "r " (emit <code>)
		| "r." (emit </code>)
		| "x " (emit <del>)
		| "x." (emit </del>)
		| "w " (emit <var>)
		| "w." (emit </var>)
		| "n " (emit <ins>)
		| "n." (emit </ins>)
		| "h " (emit <ins>)
		| "h." (emit </ins>)
		| "c " (emit <cite>)
		| "c." (emit </cite>)
		| "." (emit </>)
	]
	| #"(" [
		in-word
		  "c)" (emit 169)
		| "r)" (emit 174)
		| "o)" (emit 176)
		| "tm)" (emit 8482)
		| "e)" (emit 8364)
		| (emit copy "(") not-in-word
	]
	; | #"[" copy char number "]" (emit reduce ['link to-issue char])
	| #"[" (emit <sb>)
	| "]" (emit </sb>) opt [paren (emit values)] in-word
	| #"*" [
		  "**" (emit/after <strong> </strong>)
		| "*" (emit/after <b> </b>)
		| (emit/after <i> </i>)
	]
	; | #"<" ["i>" (emit <i>) | "/i>" (emit </i>) | "b>" (emit <b>) | "/b>" (emit </b>)]
	| #"<" (emit #"<") | #">" (emit #">") | #"&" (emit #"&")
	; | #"~" (emit/after <code> </code>)
	; | #"*" (emit/after <b> </b>)
	| #"`" copy text literal #"`" (emit-code text) in-word
	| #"'" (emit/after <apos> </apos>) in-word
	| #"^"" (emit/after <quot> </quot>) in-word
	| #"." ".." (emit 8230) in-word
	| #"-" ["--" (emit 8212) | "-" (emit 8211)] in-word
	| copy char ascii (emit char) in-word
	| copy char ucs (emit to integer! char/1) in-word ; Rebol 3
	| copy char utf-8 (emit get-ucs-code char) in-word ; Rebol 2
	| extended (emit "[???]")
	| skip
]