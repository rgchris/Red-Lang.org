REBOL [
	Title: "Reflective HELP Functions"
	Exports: [source help ?]
]

source: func [
	"Prints the source code for a word." 
	'word [word!]
][
	prin join word ": "
	if not value? word [print "undefined" exit]
	either any [native? get word op? get word action? get word][
		print ["native" mold third get word]
	][print mold get word]
]

dump-obj: func [
	"Returns a block of information about an object." 
	obj [object!] 
	/match "Include only those that match a string or datatype" pat 
	/local clip-str form-val form-pad words vals str wild
][
	clip-str: func [str] [
		trim/lines str 
		if (length? str) > 50 [str: append copy/part str 50 "..."] 
		str
	] 
	form-val: func [val] [
		if any-block? :val [return reform ["length:" length? val]] 
		if image? :val [return reform ["size:" val/size]] 
		if any-function? :val [
			val: third :val 
			if block? val/1 [val: next val] 
			return clip-str either string? val/1 [copy val/1] [mold val]
		] 
		if object? :val [val: next first val] 
		clip-str mold :val
	] 
	form-pad: func [val size] [
		val: form val 
		insert/dup tail val #" " size - length? val 
		val
	] 
	words: first obj 
	vals: next second obj 
	obj: copy [] 
	wild: all [string? pat find pat "*"] 
	foreach word next words [
		type: type?/word pick vals 1 
		str: form word 
		if any [
			not match 
			all [
				not unset? pick vals 1 
				either string? :pat [
					either wild [
						tail? any [find/any/match str pat pat]
					] [
						find str pat
					]
				] [
					all [
						datatype? get :pat 
						type = :pat
					]
				]
			]
		] [
			str: form-pad word 15 
			append str #" " 
			append str form-pad type 10 - ((length? str) - 15) 
			append obj reform [
				"  " str 
				if type <> 'unset! [form-val pick vals 1] 
				newline
			]
		] 
		vals: next vals
	] 
	obj
]

?: help: func [
	"Prints information about words and values." 
	'word [any-type!] 
	/local value args item type-name refmode types attrs rtype
][
	if unset? get/any 'word [exit]
	if all [word? :word not value? :word] [word: mold :word]
	if any [string? :word all [word? :word datatype? get :word]][
		types: dump-obj/match system/words :word
		sort types
		if not empty? types [
			print ["Found these words:" newline types]
			exit
		]
		print ["No information on" word "(word has no value)"] 
		exit
	] 
	type-name: func [value] [
		value: mold type? :value 
		clear back tail value 
		join either find "aeiou" first value ["an "] ["a "] value
	] 
	if not any [word? :word path? :word] [
		print [mold :word "is" type-name :word] 
		exit
	] 
	value: either path? :word [first reduce reduce [word]] [get :word] 
	if not any-function? :value [
		prin [uppercase mold word "is" type-name :value "of value: "] 
		print either object? value [print "" dump-obj value] [mold :value] 
		exit
	] 
	args: third :value 
	prin "USAGE:^/^-" 
	if not op? :value [prin append uppercase mold word " "] 
	while [not tail? args] [
		item: first args 
		if :item = /local [break] 
		if any [all [any-word? :item not set-word? :item] refinement? :item] [
			prin append mold :item " " 
			if op? :value [prin append uppercase mold word " " value: none]
		] 
		args: next args
	] 
	print "" 
	args: head args 
	value: get word 
	print "^/DESCRIPTION:" 
	either string? pick args 1 [
		print [tab first args newline tab uppercase mold word "is" type-name :value "value."] 
		args: next args
	][
		print "^-(undocumented)"
	] 
	if block? pick args 1 [
		attrs: first args 
		args: next args
	] 
	if tail? args [exit] 
	while [not tail? args] [
		item: first args 
		args: next args 
		if :item = /local [break] 
		either not refinement? :item [
			all [set-word? :item :item = to-set-word 'return block? first args rtype: first args] 
			if none? refmode [
				print "^/ARGUMENTS:" 
				refmode: 'args
			]
		] [
			if refmode <> 'refs [
				print "^/REFINEMENTS:" 
				refmode: 'refs
			]
		] 
		either refinement? :item [
			prin [tab mold item] 
			if string? pick args 1 [prin [" --" first args] args: next args] 
			print ""
		] [
			if all [any-word? :item not set-word? :item] [
				if refmode = 'refs [prin tab] 
				prin [tab :item "-- "] 
				types: if block? pick args 1 [args: next args first back args] 
				if string? pick args 1 [prin [first args ""] args: next args] 
				if not types [types: 'any] 
				prin rejoin ["(Type: " types ")"] 
				print ""
			]
		]
	] 
	if rtype [print ["^/RETURNS:^/^-" rtype]]
	if attrs [
		print "^/(SPECIAL ATTRIBUTES)" 
		while [not tail? attrs] [
			value: first attrs 
			attrs: next attrs 
			if any-word? value [
				prin [tab value] 
				if string? pick attrs 1 [
					prin [" -- " first attrs] 
					attrs: next attrs
				] 
				print ""
			]
		]
	] 
	exit
]
