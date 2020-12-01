int[][] grid;
float gridW;
float gridH;

ArrayList<PVector> snake;
PVector dir;
float nextSnakeMove;
float snakeMoveTime;
float originalSnakeSpeed;
int snakeStartSize;
int piecesToAdd;
int howManyIAdd;

boolean started = false;
boolean paused;
boolean lost;
boolean zen = false;

String hackedName = "Ronald McDonald";
String[] startBoostHack = { "SpeedyGonzales", "Ron Is Cool 721" };
String[] blockedUserIDs = { "18" };
int startHackGoal = 75;


float[] outlineSettings = { 0, 1, 2 };
int outlineSetting = 1;

int score;
int highscore = 0;
int zenhighscore = 0;
int scoreToLevelUp;
int level;

color headColor = #007FFF;
color tailColor = #FF0000;
color foodColor = #00FF00;
color backColor = #FFFFFF;

String username = 'test_user';
String userID = '1';

PVector food;

PVector channel;
boolean channeling;

float scaleO;

void setup() {
    float winwid = window.innerWidth * 2/3.5;
    winwid = 60*round(winwid/60);
    size(winwid, winwid * 2/3);
    
    scaleO = winwid / 700;
    
    grid = new int[60][];
    for (r = 0; r < grid.length; r++) {
        int[] newC = new int[40];
        grid[r] = newC;
        for (c = 0; c < grid[r].length; c++) {
            grid[r][c] = 0;
        }
    }
    gridW = width / grid.length;
    gridH = height / grid[0].length;
    
    snakeStartSize = 5;
    
    howManyIAdd = 5;

    originalSnakeSpeed = 0.075;
    
    channel = new PVector(1, 0); 
    channeling = false;
    
    scoreToLevelUp = 5;

    if (localStorage.getItem("bestScore")) {
        highscore = localStorage.getItem("bestScore");
    }

    if (localStorage.getItem("bestZenScore")) {
        zenhighscore = localStorage.getItem("bestZenScore");
    }

    if (localStorage.getItem("outlineSetting")) {
        outlineSetting = localStorage.getItem("outlineSetting");
    }


    loadColors();

    //displayLeaderboard('snake_score');

    //dealWithUser();

    for (String s : blockedUserIDs) {
        if (userID.equals(s)) {
            alert("You have been banned for bad behavior. As such, you may not access Snake. Triggering crash....");
            crash();
            break; 
        }
    }

    

    //updateHighscores();

    restart();
}

void crash() {
    crash();
}

void restart() {
    snake = new ArrayList<PVector>();
    for (i = 0; i < snakeStartSize; i++) {
        snake.add(new PVector(10, 10 + snakeStartSize - i));
    }

    piecesToAdd = 0;

    paused = false;
    lost = false;

    snakeMoveTime = originalSnakeSpeed;
    nextSnakeMove = elapsedTime() + snakeMoveTime;

    dir = new PVector(0, 1);

    score = 0;
    level = 1;

    moveFood();
}

void dealWithUser() {
    if (localStorage.getItem("userID")) {
        //username = localStorage.getItem("username");
        userID = localStorage.getItem("userID");
    } else {
        localStorage.removeItem("userServerConfirmed");
        if (!setNewName()) {
            return null;
        }
    }

    if (!localStorage.getItem("userPass")) {
        if (!setNewPass()) {
            logOut(true);
            return null;
        }
    }
    
    if (!localStorage.getItem("userServerConfirmed")) {
        String[] serverCheck = checkUser(username, localStorage.getItem("userPass"));
        if (serverCheck[0] == "confirmed") {
            localStorage.setItem("userID", serverCheck[1]);
            userID = localStorage.getItem("userID");
            localStorage.removeItem("username");
            uploadScore(userID, highscore, "snake_score");
            uploadScore(userID, zenhighscore, "snake_zen_score");
            localStorage.setItem("userServerConfirmed", true);
            alert("Successfully authorized user.");
        } else {
            alert(serverCheck[1]);
            logOut();
        }
    } else {
        loadNameWithID();
    }
}

void loadNameWithID() {
    String[] serverResponse = retrieveName(userID);

    if (serverResponse[0] == "confirmed") {
        username = serverResponse[1];
    } else if (serverResponse[0] == "deleted") {
        logOut();
    }
}

void logOut(boolean dontRetry) {
    username = '';
    localStorage.removeItem("userID");
    localStorage.removeItem("userPass");
    localStorage.removeItem("userServerConfirmed");
    localStorage.removeItem("bestScore");
    localStorage.removeItem("bestZenScore");
    highscore = 0;
    zenhighscore = 0;

    if (dontRetry != true) {
        dealWithUser();
    }
}

void updateHighscores() {
    //uploadScore(userID, highscore, "snake_score");
    //uploadScore(userID, zenhighscore, "snake_zen_score");
    if (userID) {
        setHighscore(retrieveScore(userID, "snake_score"), true);
        setZenHighscore(retrieveScore(userID, "snake_zen_score"), true);
    }
}

void loadColors() {
    if (localStorage.getItem("headColor")) {
        headColor = colorFromHexString(localStorage.getItem("headColor"));
    }
    if (localStorage.getItem("tailColor")) {
        tailColor = colorFromHexString(localStorage.getItem("tailColor"));
    }
    if (localStorage.getItem("foodColor")) {
        foodColor = colorFromHexString(localStorage.getItem("foodColor"));
    } 
    if (localStorage.getItem("backColor")) {
        backColor = colorFromHexString(localStorage.getItem("backColor"));
    }
}

void setNewName(boolean cb) {
    String message = "Please select a username.";
    String name = prompt(message, "");

    if (name == null || name == '') {
        return false;
    } else {
        if (!cb) {
            storeNewName(name);
        } else {
            updateName(userID, name);
        }
        return true;
    }
}

void setNewPass(boolean repeat) {
    String message = "Please set a password, or enter your existing password if you've already created an account with this username.";
    if (repeat) {
         message = "Your password cannot be blank.";
    }
    String pass = prompt(message, "");

    if (pass == null) {
        return false;
    } else if (pass == '') {
        setNewPass(true);
    } else {
        localStorage.setItem("userPass", hex_md5(pass));
        return true;
    }
}

void storeNewName(String name) {
    //localStorage.setItem("username", name);
    username = name;
}

void lose() {
   lost = true; 

   //highscore handling
   int high = highscore;
   if (zen) {
       high = zenhighscore;
   }

   if (score > high) {
       alert("You beat your old high score by " + (score - high) + " points!");
       if (!zen) {
           setHighscore(score);
        } else {
           setZenHighscore(score);
        }
   }
}

void setHighscore(int score, boolean no_upload) {
    highscore = score;
    localStorage.setItem("bestScore", highscore);
    if (no_upload != true) {
        //uploadScore(userID, score, "snake_score");
    }
}

void setZenHighscore(int score, boolean no_upload) {
    zenhighscore = score;
    localStorage.setItem("bestZenScore", zenhighscore);
    if (no_upload != true) {
        //uploadScore(userID, score, "snake_zen_score");
    }
}

void moveFood() {
		food = new PVector(round(random(1, grid.length - 2)), round(random(1, grid[0].length - 2)));

		for (s = 0; s < snake.size(); s++) {
        if ( snake.get(s).x == food.x & snake.get(s).y == food.y ) {
        		moveFood();
        		break;
        }
      
    }
}

void addSnakePiece() {
    piecesToAdd += howManyIAdd;
}

void eatFood() {
    addSnakePiece();
    moveFood();
    score += 1;
    if (score % scoreToLevelUp == 0 && !zen) {
        nextLevel();
    }
}

float elapsedTime() {
    return millis() / 1000;
}

void nextLevel() {
    closeChannel();
    snakeMoveTime = snakeMoveTime * 0.85;
    level += 1;
}

void zenTime() {
		zen = true;
		snakeMoveTime = originalSnakeSpeed;
}

void openChannel() {
    channeling = true;
    channel = new PVector(11, 17);
}

void closeChannel() {
    channeling = false;
    channel = new PVector(1, 0); 
}

void moveSnake() {
    if (!paused & started & !lost) {
        PVector lastpiece = snake.get(0);
            
        boolean disappear = false;
        
        int nextX = snake.get(0).x + dir.x;
        int nextY = snake.get(0).y + dir.y;
        if (nextX >= channel.x & nextX <= channel.y) {
            if (nextY < 0) {
                nextY = grid[0].length - 1;
                disappear = true;
            } else if (nextY >= grid[0].length) {
                nextY = 0;
                disappear = true;
            }
        }
        
        snake.set(0, new PVector(nextX, nextY));
            
        for (s = 1; s < snake.size(); s++) {
            PVector lastpieceP = snake.get(s);
            snake.set(s, lastpiece);
            lastpiece = lastpieceP;
        }
        if (piecesToAdd > 0) {
            snake.add(lastpiece);
            piecesToAdd -= 1;
        }
        
        if (disappear == true & snake.size() > snakeStartSize) {
            snake.remove(0);
        } else if (disappear == false & snake.size() == snakeStartSize & channeling) {
            nextLevel();
        }
        
        nextSnakeMove = elapsedTime() + snakeMoveTime;
		}
}

void pauseGame(boolean val) {
    if (started) {
        paused = !paused;
        if (val != null) {
            paused = val;
        }
    }
}

void setAColor(String col, String id) {
    localStorage.setItem(id, col);
    loadColors();
}

color colorFromHexString(String col) {
    return color( unhex(col.substring(1,3)),
                  unhex(col.substring(3,5)),
                  unhex(col.substring(5,7)) );
}

String colorToHexString(color col) {
    return "#" + hex(col, 6);
}

color complementaryColor(color original) {
    float R = red(original);
    float G = green(original);
    float B = blue(original);
    float minRGB = min(R,min(G,B));
    float maxRGB = max(R,max(G,B));
    float minPlusMax = minRGB + maxRGB;
    color complement = color(minPlusMax-R, minPlusMax-G, minPlusMax-B);
    
    return complement;
}

color inverseColor(color original) {
    float R = red(original);
    float G = green(original);
    float B = blue(original);
    color inverse = color(255 - R, 255 - G, 255 - B);

    return inverse;
}

void draw() {
    background(backColor);
    
    strokeWeight(outlineSettings[outlineSetting] * scaleO);
    stroke(inverseColor(backColor));
    if (outlineSettings[outlineSetting] == 0) {
         noStroke();
    }

    //draw board
    rectMode(CENTER, CENTER);
    float x = gridW / 2;
    for (r = 0; r < grid.length; r++) {
        float y = gridH / 2;
        
        for (c = 0; c < grid[r].length; c++) {
            boolean noneed = true;
            
            if (r >= channel.x & r <= channel.y) {
                fill(255, 255, 0);
                noneed = false;
            }
            
            
            for (s = 0; s < snake.size(); s++) {
                if (r == snake.get(s).x & c == snake.get(s).y) {
                    float colAmnt = (s / (snake.size() - 1));
                    color nCol = lerpColor(headColor, tailColor, colAmnt);
                    fill(red(nCol), green(nCol), blue(nCol), 200);
                    fill(nCol);
                    noneed = false;
                }
            }
            
            if (r == food.x & c == food.y & !channeling) { //hide food if channel is open
                color nCol = foodColor;
                fill(red(nCol), green(nCol), blue(nCol), 200);   
                fill(nCol);             
                noneed = false;
            }
            
            if (!noneed) {
                rect(x, y, gridW, gridH);
            }
        
            y += gridH;
        }
        
        x += gridW;
    }


    boolean startHack = false;
    boolean wallHacks = false;

    /* no hacks today
    
    
    //hunt for food
    if (username == hackedName) {
        dir.x = 0;
        dir.y = 0;

        if (food.x < snake.get(0).x) {
            dir.x = -1;
        } else if (food.x > snake.get(0).x) {
            dir.x = 1;
        }
        if (food.y < snake.get(0).y) {
            dir.y = -1;
        } else if (food.y > snake.get(0).y) {
            dir.y = 1;
        }
    }

    //check if hacker
    for (n = 0; n < startBoostHack.length; n++) {
        if (username == startBoostHack[n]) {
            startHack = true;
            wallHacks = true;
        }
    }
    if (username == hackedName) {
        wallHacks = true;
    }

    
    
    if ((username == hackedName || startHack == true) && score <= startHackGoal) {
        eatFood();
    }
   
    */
    
    

    //move snake
    if (elapsedTime() > nextSnakeMove) {
        moveSnake();
    }
    
    //check if eated food
    for (s = 0; s < snake.size(); s++) {
		  	if (snake.get(s).x == food.x & snake.get(s).y == food.y & !channeling) {
		        eatFood();
                        break;
		    }
		
        PVector mesnake = snake.get(s);
        
        for (ss = 0; ss < snake.size(); ss++) {
            PVector yousnake = snake.get(ss);
            
            if (s != ss & mesnake.x == yousnake.x & mesnake.y == yousnake.y) {
                if (!wallHacks) {
                    lose();
                }
            }
        }
        
        if (mesnake.x < 0 || mesnake.x >= grid.length || mesnake.y < 0 || mesnake.y >= grid[0].length) {
            if (!(mesnake.x >= channel.x & mesnake.x <= channel.y)) {
                lose();
            }
        }
    }

    //draw score or paused
    fill(inverseColor(backColor));
    if (paused == true) {
        textSize(height / 4);
        textAlign(CENTER, CENTER);
        text("paused", width / 2, height / 2);
    }
        
    if (lost) {
        textSize(height / 20);
        textAlign(CENTER, CENTER);
        String currentStat = "off";
        int high = highscore;
        if (zen) {
              currentStat = "on";
              high = zenhighscore;
        }
        text("Press space to play again with current settings.\nPress 'z' to toggle Zen Mode for next round.  (Currently " + currentStat + ")", width / 2, height / 4);
        text("Your score was: " + score + "\nYour highscore for this mode is: " + high, width / 2, height * 3/4);
    } else {
        textSize(height / 35);
        textAlign(LEFT, TOP);
        if (!zen) {
        	text("Score: " + score + "\nLevel: " + level, 0, 0);
        } else {
        	text("Score: " + score + "\nZen Mode", 0,0);
        }
    }
    
    if (!started) {
         textSize(height / 35); 
         textAlign(CENTER, CENTER);
         text("Press any key to start.", width / 2, height / 4);
    }

    textAlign(LEFT, TOP);
    textSize(height / 35);
    text(username, width - textWidth(username), 0);

    text((int(frameRate) + " fps"), width - textWidth("60 fps"), height - height/35);
}

void keyPressed() {
    if (!paused) {
        if (((dir.y == 0 && movementKey().y != 0) || (dir.x == 0 && movementKey().x != 0)) && (movementKey().x != 0 || movementKey().y != 0)) {
             dir = movementKey();
        }

        if (dir.x != 0 || dir.y != 0) {
            moveSnake();
        }
    }
    
    if (key == ' ') {
        pauseGame();
        
        if (lost == true) {
           restart(); 
        }
    }
    
    started = true;
    if (key == 'z' || key == 'Z') {
        if (zen & lost) {
            zen = false;
            restart();
        } else {
            zenTime();
            if (lost) {
                restart();
            }
        } 
    }

    if (key == 'f' || key == 'F') {
        outlineSetting += 1;
        if (outlineSetting >= outlineSettings.length) {
            outlineSetting = 0;
        }
        localStorage.setItem("outlineSetting", outlineSetting)
    }
}

PVector movementKey() {
	PVector returnVector = new PVector(0, 0);
	if (key == CODED) {
		if (keyCode == UP) {
			returnVector.x = 0;
			returnVector.y = -1;
		} else if (keyCode == DOWN) {
			returnVector.x = 0;
			returnVector.y = 1;
		} else if (keyCode == RIGHT) {
			returnVector.x = 1;
			returnVector.y = 0;
		} else if (keyCode == LEFT) {
			returnVector.x = -1;
			returnVector.y = 0;
		}
	} else if (key == 'w' || key == 'W' || key == 'i' || key == 'I' || (key == '9' && dir.x == 1) || (key == '0' && dir.x == -1)) {
		returnVector.x = 0;
		returnVector.y = -1;
	} else if (key == 's' || key == 'S' || key == 'k' || key == 'K' || (key == '9' && dir.x == -1) || (key == '0' && dir.x == 1)) {
		returnVector.x = 0;
		returnVector.y = 1;
	} else if (key == 'd' || key == 'D' || key == 'l' || key == 'L' || (key == '9' && dir.y == 1) || (key == '0' && dir.y == -1)) {
		returnVector.x = 1;
		returnVector.y = 0;
	} else if (key == 'a' || key == 'A' || key == 'j' || key == 'J' || (key == '9' && dir.y == -1) || (key == '0' && dir.y == 1)) {
		returnVector.x = -1;
		returnVector.y = 0;
	}

	return returnVector;
}							