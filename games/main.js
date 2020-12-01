var web_names = ["mirror-draw", "number-rush", "ladderman", "snake", "piano-tiles", "takuzu", "super-tic-tac-toe", "five-doors", "gradient-puzzle"];
var ios_names = ["Fysuzzles", "Clumsy Boxing", "Clumsy Surfing", "30 Balls"];
var ios_urls = ["https://apps.apple.com/us/app/fysuzzles/id977471507", "https://apps.apple.com/us/app/clumsy-boxing/id950897022", "https://apps.apple.com/us/app/clumsy-surfing/id1207489768", "https://apps.apple.com/us/app/30-balls/id891167202"];

var canvas_ref = document.createElement('canvas');
canvas_ref.setAttribute("id", "pjs_canv");
document.body.appendChild(canvas_ref);


function onActiv() {
	populateDropdowns();
	checkUrlParam();
}

function checkUrlParam() {
	var params = window.location.href.split('#');
	var i = 0;
	if (params.length > 1) {
		for (let name of web_names) {
			if (name == params[1]) {
				loadSketch(i);
				return;
			}
			i++;
		}
		
		/*
		for (let name of ios_names) {
			console.log(name + ' ' + params[1]);
		}*/
	}
	
	loadSketch(0);
}

function humanizeFileName(str) {
	var pieces = str.split("-");
	var output = '';
	pieces.forEach(function(word) {
		output += word.charAt(0).toUpperCase() + word.slice(1) + ' ';
	});
	
	return output.substring(0, output.length - 1);
}

function populateDropdowns() {
	var wHTML = '', iHTML = '';
	
	web_names.forEach(function(name, i) {
		wHTML += ("<p onclick='loadSketch(" + i + ")'>" + humanizeFileName(name) + "</p>");
	});
	
	ios_names.forEach(function(name, i) {
		iHTML += ("<p onclick='loadiOS(" + i + ")'>" + name + "</p>");
	});
	
	document.getElementById('webDropdown').innerHTML = wHTML;
	document.getElementById('iosDropdown').innerHTML = iHTML;
}

function loadSketch(x) {
	unloadSketch();
	
	Processing.loadSketchFromSources(canvas_ref, new Array(web_names[x] + '.pde'));
}

function unloadSketch() {
	var pjs = Processing.getInstanceById('pjs_canv');
	if (typeof pjs != "undefined") {
		pjs.exit();
	}
}

function loadiOS(x) {
	window.open(ios_urls[x], "_self");
}