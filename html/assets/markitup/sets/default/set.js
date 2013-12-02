// ----------------------------------------------------------------------------
// markItUp!
// ----------------------------------------------------------------------------
// Copyright (C) 2011 Jay Salvat
// http://markitup.jaysalvat.com/
// ----------------------------------------------------------------------------
// Html tags
// http://en.wikipedia.org/wiki/html
// ----------------------------------------------------------------------------
// Basic set. Feel free to add more tags
// ----------------------------------------------------------------------------
var mySettings = {
	onShiftEnter:  	{keepDefault:false, replaceWith:'<br />\n'},
	onCtrlEnter:  	{keepDefault:false, openWith:'\n<p>', closeWith:'</p>'},
	onTab:    		{keepDefault:false, replaceWith:'    '},
	markupSet:  [ 	
		{name:'Bold', key:'B', openWith:'(!(<strong>|!|<b>)!)', closeWith:'(!(</strong>|!|</b>)!)' },
		{name:'Italic', key:'I', openWith:'(!(<em>|!|<i>)!)', closeWith:'(!(</em>|!|</i>)!)'  },
		{name:'Stroke through', key:'S', openWith:'<del>', closeWith:'</del>' },
		{separator:'---------------' },
		{name:'Bulleted List', openWith:'    <li>', closeWith:'</li>', multiline:true, openBlockWith:'<ul>\n', closeBlockWith:'\n</ul>'},
		{name:'Numeric List', openWith:'    <li>', closeWith:'</li>', multiline:true, openBlockWith:'<ol>\n', closeBlockWith:'\n</ol>'},
		{separator:'---------------' },
		{name:'Picture', key:'P', replaceWith:'<img src="[![Source:!:http://]!]" alt="[![Alternative text]!]" />' },
		{name:'Link', key:'L', openWith:'<a href="[![Link:!:http://]!]"(!( title="[![Title]!]")!)>', closeWith:'</a>', placeHolder:'Your text to link...' },
		{separator:'---------------' },
		{name:'Clean', className:'clean', replaceWith:function(markitup) { return markitup.selection.replace(/<(.*?)>/g, "") } },		
		{name:'Preview', className:'preview',  call:'preview'}
	]
}

var makeDoc = {
	nameSpace: "MakeDoc",
	onShiftEnter: {keepDefault:false, replaceWith:'\n\n'},
	onTab: {keepDefault:false, replaceWith:'    '},
    previewParserPath:   "/support/preview",
	markupSet:  [
		{name:'Bold', key:'B', closeWith:'=b\.', openWith:'=b '},
		{name:'Italic', key:'I', closeWith:'=i\.', openWith:'=i '},
		{name:'Link', key:'L', openWith:'=\[link http://en.hojanueva.com/ \"', closeWith:'\"\]', placeHolder:'...linked text here...' },
		{name:'Highlight', key:'H', closeWith:'=h\.', openWith:'=h '},
		{name:'Strike', key:'S', closeWith:'=x\.', openWith:'=x '},
		{separator:'<br />'},
		{name:'Heading', key:'1', openWith:'\n\n===', closeWith:'\n', placeHolder:'Heading...'},
		{name:'Subheading', key:'2', openWith:'\n\n---', closeWith:'\n', placeHolder:'Subheading...'},
		{name:'Place', openWith:'\n\n=place ', closeWith:'\n', placeHolder:'Place\(s\)', className:'place'},
		{name:'Topic', openWith:'\n\n=topic ', closeWith:'\n', placeHolder:'Topic\(s\)', className:'topic'},
		{name:'Image', openWith:'\n\n=image ', placeHolder:'http://', closeWith:' \"Alternate Text\"\n'},
		{separator:'<br />' },
		{name:'List', openWith:'\n\n*', closeWith:'\n'},
		{name:'List (numeric)', openWith:'\n\n#', closeWith:'\n'},
		{name:'Quote', key:'Q', openWith:'\n\n\\quote\n\n', closeWith:'\n\n/quote(!( Attribution)!)\n', multiline: true, placeHolder:'Quote...'},
		{name:'PullQuote', key:'P', openWith:'\n\n\\pullquote\n\n', closeWith:'\n\n/pullquote\n', multiline: true, placeHolder:'Quote...'},
	]
}
