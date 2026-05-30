var web_names = ["mirror-draw", "number-rush", "ladderman", "snake", "piano-tiles", "takuzu", "super-tic-tac-toe", "gradient-puzzle", "five-doors"];

const instructions = {
  "mirror-draw": "Use the mouse to draw on the canvas.",
  "number-rush": "Click the numbers in ascending order as fast as you can before time runs out.",
  "ladderman": "Use the A and D keys to move and climb ladders while avoiding hazards.",
  "snake": "Use WASD or arrow keys to steer the snake to collect food and grow.",
  "piano-tiles": "Hit the black tiles as they scroll down the screen. Don't miss! Keybinds: ASDF or ASKL from left to right, or click/tap the tiles.",
  "takuzu": "Click tiles to change their color. No more than two adjacent same-colored tiles allowed.",
  "super-tic-tac-toe": "Click squares to place your mark. Win the mini boards to conquer the main board.",
  "five-doors": "Use the arrow keys to reach the correct portal.",
  "gradient-puzzle": "Swap tiles to form a smooth color gradient across the board."
};

var canvas_ref;

function onActiv() {
    canvas_ref = document.getElementById("pjs_canv");
	populateGamesList();
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
	}
	
	loadSketch(0); // Defaults to mirror-draw
}

function humanizeFileName(str) {
	var pieces = str.split("-");
	var output = '';
	pieces.forEach(function(word) {
		output += word.charAt(0).toUpperCase() + word.slice(1) + ' ';
	});
	
	return output.substring(0, output.length - 1);
}

function populateGamesList() {
	var wHTML = '';
	
	web_names.forEach(function(name, i) {
		wHTML += ("<button class='game-btn' onclick='loadSketch(" + i + ")'>" + humanizeFileName(name) + "</button>");
	});
	
	document.getElementById('games-list').innerHTML = wHTML;
}

function loadSketch(x) {
	unloadSketch();
	
    var name = web_names[x];
    document.getElementById("gameTitle").innerText = humanizeFileName(name);
    document.getElementById("gameInstructions").innerText = instructions[name];
    window.location.hash = name;
    
    var btns = document.querySelectorAll('.game-btn');
    btns.forEach(function(btn) { btn.classList.remove('active'); });
    if (btns[x]) { btns[x].classList.add('active'); }

	Processing.loadSketchFromSources(canvas_ref, new Array(name + '.pde'));
}

function unloadSketch() {
	var pjs = Processing.getInstanceById('pjs_canv');
	if (typeof pjs != "undefined") {
		pjs.exit();
	}
}