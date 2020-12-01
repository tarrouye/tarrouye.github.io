int tileW, tileH;

int[][] tiles = new int[5][4];

color[] colours = { color(0), color(0, 127, 255), color(0, 255, 127), color(255, 10, 10) };

int scrollY;
int scrollSpeed;
int startingSpeed = 5;
int speedIncrease = 0.0075;
int maxSpeed = 25;

boolean started = false;
boolean lost = false;
boolean lostClicked = false;
int score = 0;
int highscore = 0;

String username = '';
String userID;

void setup() {
    float winwid = window.innerWidth / 2;
    float winhei = window.innerHeight * 0.8;
    float winsiz = min(winwid, winhei);
    size(winsiz * (5/8), winsiz);

    textAlign(CENTER, CENTER);
    
    tileW = width / 4;
    tileH = height / 4;

    if (localStorage.getItem("highscore")) {
        highscore = localStorage.getItem("highscore");
    }

    //displayLeaderboard('piano_score');

    //dealWithUser();

    //updateHighscores();
    
    resetGame();
}

// All highscore / leaderboard stuff

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
            uploadScore(userID, highscore, "piano_score");
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
    localStorage.removeItem("highscore");
    highscore = 0;

    if (dontRetry != true) {
        dealWithUser();
    }
}

void updateHighscores() {
    //uploadScore(userID, highscore, "piano_score");
    if (userID) {
        setHighscore(retrieveScore(userID, "piano_score"), true);
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

void setHighscore(int score, boolean no_upload) {
    highscore = score;
    localStorage.setItem("highscore", highscore);
    if (no_upload != true) {
        //uploadScore(userID, score, "piano_score");
    }
}

// </end> All highscore shit

void resetGame() {
    setupTiles();
    
    scrollY = 0;
    scrollSpeed = 0;
    
    score = 0;
    lost = false;
    lostClicked = false;
}

void setupTiles() {
    for (int r = 0; r < tiles.length; r++) {
        randomInRow(r);
    }
}

void randomInRow(int r) {
    int rand = (int) (Math.random() * (tiles[0].length));
    for (int c = 0; c < tiles[r].length; c++) {
        if (c == rand) {
            tiles[r][c] = 1;
        } else {
            tiles[r][c] = 0;
        }
    }
}

void start() {
    started = true;
}

void lose() {
    lost = true;
    if (score > highscore) {
        setHighscore(score);
    }
}


void draw() {
    background(255);
    
    if (!started) {
        drawStart();
    } else if (!lost) {
        drawGame();
    } else {
        drawLost();
    }
}

void drawStart() {
    fill(colours[1]);
    textSize(width / 12);
    text("Welcome to Piano Tiles\n\nClick to begin", width / 2, height / 2);
}

void drawGame() {
    drawTiles();

    fill(colours[1]);
    textSize(width / 4);
    float tY = textWidth("00") / 3;
    text(score, width / 2, tY);
    tY *= 2;

    fill(colours[2]);
    if (score > highscore) {
        fill(colours[3]);
    }
    textSize(width / 16);
    tY += textWidth("00") / 3;
    text(highscore, width / 2, tY);
    tY = height - textWidth("00") / 3;
    fill(colours[1]);
    text(scrollSpeed, width / 2, tY);
        
    scrollTiles();
}

void drawTiles() {
    int y = scrollY - tileH;
    for (int r = 0; r < tiles.length; r++) {
        int x = 0;
        for (int c = 0; c < tiles[r].length; c++) {
            if (tiles[r][c] == 1) {
                fill(0);
            } else if (tiles[r][c] == 2) {
                fill(180);
            } else {
                fill(255);
            }
            
            rect(x, y, tileW, tileH);
            
            x += tileW;
        }
        y += tileH;
    }
}

void scrollTiles() {
    if (scrollSpeed > 0) {
        scrollY += scrollSpeed;
        scrollSpeed = Math.min(maxSpeed, scrollSpeed + speedIncrease);
    }

    if (scrollY >= tileH) {
        if (clicked(tiles.length - 1)) {
            for (int r = tiles.length - 1; r > 0; r--) {
                for (int c = 0; c < tiles[r].length; c++) {
                    tiles[r][c] = tiles[r - 1][c];
                }
            }
            randomInRow(0);
            scrollY = 0;
        } else {
            lose();
        }
    }
}

boolean clicked(int r) {
    for (int c = 0; c < tiles[r].length; c++) {
        if (tiles[r][c] == 2)
            return true;
    }
    
    return false;
}

void drawLost() {
    fill(colours[1]);
    textSize(width / 10);
    text("You lost\nYour score: " + score + "\nYour highscore: " + highscore + "\n\nClick to start over", width / 2, height / 2);
    
    textSize(width / 20);
    if (lostClicked) {
        text("Click again to confirm", width / 2, height * 3/4);
    }
}

void mousePressed() {
    if (!started) {
        touchStart(mouseX, mouseY);
    } else if (!lost) {
        touchBoard(mouseX, mouseY);
    } else {
        touchLost(mouseX, mouseY);
    }
}

/*void touchEnd(TouchEvent event) {
    int x = event.touches[0].clientX;
    int y = event.touches[0].clientY;

    lose();

    if (!lost) {
        touchBoard(x, y);
    } else {
        touchLost(x, y);
    }
}*/

void touchStart(int touchX, int touchY) {
    start();
}

void touchBoard(int touchX, int touchY) {
    int y = scrollY - tileH;
    for (int r = 0; r < tiles.length; r++) {
        int x = 0;
        for (int c = 0; c < tiles[r].length; c++) {
            if (touchX > x && touchX < x + tileW && touchY > y && touchY < y + tileH) {
                if (tiles[r][c] == 0) {
                    lose();
                } else if (tiles[r][c] == 1) {
                    tagTile(tiles[r], c);
                    //scrollY = tileH;
                }
            }
            
            x += tileW;
        }
        y += tileH;
    }
}

void touchLost(int touchX, int touchY) {
    if (lostClicked) {
        resetGame();
    } else {
        lostClicked = true;
    }
}		

int[] lastUnfilledRow() {
    int[] unfilled = tiles[tiles.length - 1];
    for (int r = tiles.length - 1; r > 0; r--) {
        for (int c : tiles[r]) {
            if (c == 2) {
                unfilled = tiles[r - 1];
            }
        }
    }

    return unfilled;
}

void keyPressed() {
    if (!lost) {
        tileKeyboard();
    } else {
        lostKeyboard();
    }
}	

void tileKeyboard() {
    int[] lastRow = lastUnfilledRow();
    if (key == 'a' || key == 'A') {
        if (lastRow[0] == 1) {
            tagTile(lastRow, 0);
        } else if (lastRow[0] == 0) {
            lose();
        }
    } else if ((key == 's' || key == 'S')) {
       if (lastRow[1] == 1) {
            tagTile(lastRow, 1);
        } else if (lastRow[1] == 0) {
            lose();
        }
    } else if ((key == 'd' || key == 'D' || key == 'k' || key == 'K')) {
        if (lastRow[2] == 1) {
            tagTile(lastRow, 2);
        } else if (lastRow[2] == 0) {
            lose();
        }
    } else if ((key == 'f' || key == 'F' || key == 'l' || key == 'L')) {
        if (lastRow[3] == 1) {
            tagTile(lastRow, 3);
        } else if (lastRow[3] == 0) {
            lose();
        }
    }
}

void tagTile(int[] row, int col) {
    row[col] = 2;
    score += 1;

    if (scrollSpeed == 0) {
        scrollSpeed = startingSpeed;
    }
}

void lostKeyboard() {
    if (lostClicked) {
        resetGame();
    } else {
        lostClicked = true;
    }
}					