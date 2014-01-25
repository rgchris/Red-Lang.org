
var setShade = function(shade) {
	var len, newclasses, classes = document.body.className.split(' ');
	var shade = shade == 'light' ? 'light' : 'dark';
	var clears = shade == 'light' ? 'dark' : 'light';
	var newclasses = [];

	for (var i = 0, len = classes.length; i < len; ++i) {
		if (classes[i] !== clears) {
			newclasses.push(classes[i]);
		}
	}

	newclasses.push(shade);
	document.body.className = newclasses.join(' ')
	return shade;
}

var setCookie = function(name,value) {
	document.cookie = name + "=" + value + "; path=/";
}

document.addEventListener('keyup', function(event) {
	if(event.keyCode == 68) {
		setShade('dark');
		setCookie('shade','dark');
	}
	else if(event.keyCode == 76) {
		setShade('light');
		setCookie('shade','light');
	}
});

window.addEventListener('load', function () {
	var cookie, cookies = document.cookie.split(';');
	while (cookie = cookies.pop()) {
		if (cookie.trim().match(/shade=dark/)) {setShade('dark');}
		else if (cookie.trim().match(/shade=light/)) {setShade('light');}
	}
})