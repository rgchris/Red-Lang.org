var makeDoc = {
	nameSpace: "makedoc",
	onShiftEnter: {keepDefault:false, replaceWith:'\n\n'},
	onTab: {keepDefault:false, replaceWith:'    '},
	previewParserPath:   "/support/preview",
	markupSet:  [
		{name:'Bold', key:'B', closeWith:'=b\.', openWith:'=b '},
		{name:'Italic', key:'I', closeWith:'=i\.', openWith:'=i '},
		{name:'Link', key:'L', openWith:'\[', closeWith:'\](http://www.red-lang.org/)', placeHolder:'...linked text here...' },
		{name:'Highlight', key:'H', closeWith:'=h\.', openWith:'=h '},
		{name:'Strike', key:'S', closeWith:'=x\.', openWith:'=x '},
		{separator:'<br />'},
		{name:'Heading', key:'1', openWith:'\n\n===', closeWith:'\n', placeHolder:'Heading...'},
		{name:'Subheading', key:'2', openWith:'\n\n---', closeWith:'\n', placeHolder:'Subheading...'},
		{name:'Image', openWith:'\n\n=image ', closeWith:' "Description"\n', placeHolder:'http://', className:'topic'},
		{name:'List', key:'8', openWith:'\n\n*', closeWith:'\n'},
		{name:'List (numeric)', key:'3', openWith:'\n\n#', closeWith:'\n'},
		{name:'Quote', openWith:'\n\n\\quote\n\n', closeWith:'\n\n/quote(!( Attribution)!)\n', multiline: true, placeHolder:'Quote...'},
		{name:'PullQuote', openWith:'\n\n\\pullquote\n\n', closeWith:'\n\n/pullquote\n', multiline: true, placeHolder:'Quote...'},
	]
};

$.getScript('/assets/markitup/jquery.markitup.js').done(
	function(){
		$('.rmd textarea').markItUp(makeDoc);
	}
).fail(
	function(jqxhr, settings, exception){
		console.log(jqxhr);
		console.log(exception);
	}
);
