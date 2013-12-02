REBOL [
    Title: "Test Protocol"
    Date: 15-Aug-2006
    Author: "Christopher Ross-Gill"
	Comments: {Kudos: http://www.rebolforces.com/articles/protocols/}
]

print: func [data][probe reform data]

flag-defs: [
	         1 read
	         2 write
	         4 append
	         8 new
	        16 #[none]
	        32 binary
	        64 lines
	       128 part
	       256 with
	       512 open
	      1024 closed
	      2048 no-wait
	      4096 #[none]
	      8192 #[none]
	     16384 #[none]
	     32768 allow
	     65536 mode
	    131072 #[none]
	    262144 #[none]
	    524288 direct
	   1048576 custom
	   2097152 #[none]
	   4194304 pass-thru
	   8388608 #[none]
	  16777216 #[none]
	  33554432 skip
	  67108864 #[none]
	 134217728 #[none]
	 268435456 allow-read
	 536870912 allow-write
	1073741824 allow-execute
]

get-all-flags: func [port /local out][
	out: copy []
	foreach flag [
		1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768
		65536 131072 262144 524288 1048576 2097152 4194304 8388608
		16777216 33554432 67108864 134217728 268435456 536870912 1073741824
	][
		if flag = (port/state/flags and flag) [
			append out any [select flag-defs flag flag]
		]
	]
	out
]

dialect: context [fax: text: data: none]

test-handler: context [
	count: 0

	port-flags: system/standard/port-flags/pass-thru
	print-flags: func [port][
		foreach flag get-all-flags port [print ["    FLAG:" form flag]]
	]

	init: func [port spec][print ["INIT:" count: count + 1] false]

	query: func [port][
		print "QUERY"
		print-flags port
		port/status: true
	]

	open: func [port binary string direct no-wait lines part sz wth eol mode args custom params skp len][
		print "OPEN"

		with port/state [
			;-- Say how big we are
			tail: 3
			index: 0

			;-- Take our flags and merge
			;   them into the port/state/flags ( Voodoo )
			outBuffer: [1 2 3]
			flags: flags or port-flags
		]

		print-flags port
	]

	copy: func [port][
		print "COPY"
		print-flags port
		none
	]

	select: func [port locator part range only case any with wild skip size][
		print ["SELECT" either block? locator [join ["SOME"] locator][mold locator]]
		print ['part part 'range range 'only only 'case case 'any any 'with with 'wild wild 'skip skip 'size size]
		print-flags port
		[]
	]

	close: func [port][
		print "CLOSE"
		print-flags port
	]

	read: func [port][
		print "READ"
		print-flags port
		random 1000
	]

	write: func [port data][
		print "WRITE"
		print-flags port
	]

	find: func [port params][
		print ["FIND:" mold params]
		port/state/custom: mold params
		print-flags port
		random 1000
	]

	pick: func [port][
		print ["PICK:" port/state/index]
		print-flags port
		port/state/index ** 2
	]

	insert: func [port data][
		data: make dialect data
		print ["INSERT data:" mold data]
		; probe port/state
		print-flags port
	]

	change: func [port data][
		print ["CHANGE data:" mold data]
		print-flags port
		random 1000
	]

	remove: func [port][
		print "REMOVE"
		print ['length port/state/tail 'index port/state/index 'scope port/state/num]
		print-flags port
		random 1000
	]

	update: func [port][
		print "UPDATE"
		print-flags port
		random 1000
	]

	sort: func [port case skip size compare comparator part length all reverse][
		print "SORT"
		print ['skip size 'compare mold :comparator]
		print-flags port
		random 1000
	]

	get-modes: func [port modes][
		print "GET-MODES"
		print-flags port
	]

	set-modes: func [port modes][
		print "SET-MODES"
		print-flags port
	]
]

add-protocol test 0 test-handler