REBOL [
	Title: "Photos"
	Date: 20-Jul-2013
	Author: "Christopher Ross-Gill"
]

url: http://flickr.com/photos/

photos: copy []

fetch: has [cache][
	either all [
		exists? cache: wrt://space/photos/photos.r
		0:5 > difference now modified? cache
	][
		photos: any [load cache []]
	][
		require/args %mashup/flickr.r settings/connections/(oauth:flickr.com)

		photos: new-line/all collect [
			photos: flickr/get "flickr.photos.search" [
				tags: "RedLang"
				extras: "description,date_taken,owner_name,url_sq,url_t,url_s,url_m,url_n,url_z,url_c"
			]

			foreach photo photos/photos/photo [
				if photo/ispublic = 1 [
					keep/only new-line/all reduce [
						to issue! photo/id
						photo/title
						photo/description
						photo/owner
						photo/ownername
						as date! photo/datetaken
						as url! photo/url_sq
						as url! any [get in photo 'url_c get in photo 'url_z get in photo 'url_m]
						to pair! reduce [
							as integer! any [get in photo 'width_c get in photo 'width_z get in photo 'height_m]
							as integer! any [get in photo 'height_c get in photo 'height_z get in photo 'height_m]
						]
					] false
				]
			]
		] true

		sort/compare photos func [a b][a/6 < b/6]

		save/all cache photos
	]
]

each: func [code [block!]][
	foreach photo photos :code
]