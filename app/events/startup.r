REBOL [
	Title: "QM Environment"
	Type: 'event
]

session: user: none

; ; purge sessions
; foreach session select sessions [expired?][session/destroy]
select sessions [purge]

; ; initialize sessions
unless all [
	session: as tuple! get-cookie "ssn"
	session: select sessions session
][
	session: select sessions 'new
	session/set 'address request/remote-addr
	set-cookie "ssn" session/as-cookie
]

; ; initialize users
unless use [user-key][
	all [
		user: get-cookie "usr"
		set [user user-key] parse user "/"
		user: select users user
		user/valid-key? user-key
	]
][
	clear-cookie "usr"
	user: select users 'new
]

session/set 'user user/id
session/store

;
; ; role shortcuts
owner?: user/owner?
moderator?: user/moderator?
editor?: user/editor?
guru?: user/guru?
author?: user/author?
blogger?: user/blogger?
developer?: user/developer?
pending?: user/pending?
target?: none

analytics?: true

background: 'indigo