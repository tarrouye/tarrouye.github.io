color[] tileColors = { color(85,98,112), color(255,107,107), color(78,205,196), color(199,244,100), color(121,189,154,180) };

int gridSize;
int tileSize;

int[] tileRadiusOptions = { 15, 90 };
int tileRadiusChoice = 1;

boolean menu = true;

int[] gridSizeChoices = { 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24 };

int[][] board;
boolean[][] locked;

boolean completed = false;
boolean won = false;
String toastMessage = "Testing"; 

String tooManyAdjacent = "No more than two adjacent tiles of the same color are allowed.";
String needEqualNum = "Rows and columns must have an equal number of each color.";
String noRepeats = "No two rows or columns can be the same.";
String winMessage = "Nice work! You did it!\nClick anywhere to start a new game.";
String startMessage = "Solve the puzzle!";

void setup() {
    float winwid = window.innerWidth / 2;
    float winhei = window.innerHeight * 0.8;
    float winsiz = min(winwid, winhei);
    size(winsiz, winsiz);
    
    textAlign(LEFT, TOP);
    rectMode(CENTER, CENTER);
}

// starts a new game with the specified grid size
void newGame(int gs) {
    createBoard(gs);
    if (!starterBoard(5000)) {
        newGame(gs);
        return null;
    }
    
    completed = false;
    won = false;
    
    toastMessage = startMessage;
}

// creates a square 'board' using a two-dimensional array
// gs = Grid Size (rows and colums)
void createBoard(int gs) {
    gridSize = gs;
    tileSize = width / (gs + 1); // divide the screen into one extra section to have a half section as a buffer on each side
    
    board = new int[gs][gs];
    locked = new int[gs][gs];

    for (int c = 0; c < board.length; c++) {
        for (int r = 0; r < board[0].length; r++) {
            board[c][r] = 0;
            locked[c][r] = true;
        }
    }
}

// fills the board with the initial tiles
boolean starterBoard(int recursions) {
    for (int c = 0; c < board.length; c++) {
        for (int r = 0; r < board[0].length; r++) {
            int newTile = randomInt(1, 2);
            int altTile = flipTile(newTile);
            
            // no three adjacent in a row/column
            if (r > 1 && (board[c][r - 1] == newTile && board[c][r - 2] == newTile)) {
                newTile = altTile;
            }
            
            if (c > 1 && board[c - 1][r] == newTile && board[c - 2][r] == newTile) {
                newTile = altTile;
            }
            
            // half and half each color
            if (colCount(c, newTile) > colCount(c, altTile)) {
                newTile = altTile;
            }
            
            if (rowCount(r, newTile) > rowCount(r, altTile)) {
                newTile = altTile;
            }
            
            board[c][r] = newTile;
        }
    }
    
    if (checkSolution() == false) {
        if (recursions > 0) {
            return starterBoard(recursions - 1);
        } else {
            return false;
        }
    } else {
        // clear 3/4 of the board
        int toClear = (gridSize * gridSize) * (3/4);
        int cleared = 0;
        
        while (cleared < toClear) {
            int rc = randomInt(0, gridSize - 1);
            int rr = randomInt(0, gridSize - 1);
            
            if (board[rc][rr] != 0) {
                board[rc][rr] = 0;
                locked[rc][rr] = false;
                cleared += 1;
            }
        }
        
        return true;
    }
}

// flips the tile
void flipTile(int current) {
    if (current == 1) {
        return 2;
    } else {
        return 1;
    }
}

// returns the number of instances of (check) in column (c)
int colCount(int c, int check) {
    int num = 0;
    
    for (int r = 0; r < board[0].length; r++) {
        if (board[c][r] == check) {
            num += 1;
        }
    }
    
    return num;
}

// returns the number of instances of (check) in row (r)
int rowCount(int r, int check) {
    int num = 0;
    
    for (int c = 0; c < board.length; c++) {
        if (board[c][r] == check) {
            num += 1;
        }
    }
    
    return num;
}

// checks to see if the board is full, and if so if it meets all the rules and is (won)
boolean checkSolution() {
    // check if board is full
    for (int c = 0; c < board.length; c++) {
        for (int r = 0; r < board[0].length; r++) {
            if (board[c][r] == 0) {
                return false;    // if any tile is still blank, we can stop here because the board isnt full
            }
        }
    }
    
    toastMessage = "Completed";
    completed = true;
    
    // check that there are no more than two touching in a row/col
    for (int c = 0; c < board.length; c++) {
        for (int r = 0; r < board[0].length; r++) {
            int thisTile = board[c][r];
            if (thisTile != 0) {
                if ((c > 1 && (board[c - 1][r] == thisTile && board[c - 2][r] == thisTile)) || (c < gridSize - 2 && (board[c + 1][r] == thisTile && board[c + 2][r] == thisTile))) { // three peat in a column
                    toastMessage = tooManyAdjacent;
                    toastMessage += "\nColumn " + (c+1) + " contains the error.";
                    return false;
                }
                if ((r > 1 && (board[c][r - 1] == thisTile && board[c][r - 2] == thisTile)) || (r < gridSize - 2 && (board[c][r + 1] == thisTile && board[c][r + 2] == thisTile))) { // three peat in a row
                    toastMessage = tooManyAdjacent;
                    toastMessage += "\nRow " + (r+1) + " contains the error.";
                    return false;
                }
            }
        }
    }
    
    // check that rows and cols have equal numbers of each tile
    for (int c = 0; c < board.length; c++) {
        if (colCount(c, 1) != colCount(c, 2)) {
            toastMessage = needEqualNum;
            toastMessage += "\nColumn " + (c+1) + " contains the error.";
            return false;
        }
    }
    for (int r = 0; r < board[0].length; r++) {
        if (rowCount(r, 1) != rowCount(r, 2)) {
            toastMessage = needEqualNum;
            toastMessage += "\nRow " + (r+1) + " contains the error.";
            return false;
        }
    }
    
    // check that there are no repeated patterns
        // probably the filthiest possible way to do this but im tired dammit
    for (int c = 0; c < board.length; c++) {
        for (int sc = c + 1; sc < board.length; sc++) {
            boolean same = true;
            for (int r = 0; r < board[0].length; r++) {
                if (board[c][r] != board[sc][r]) {
                    same = false;
                }
            }
            
            if (same == true) {
                toastMessage = noRepeats;
                toastMessage += "\nColumns " + (c+1) + " and " + (sc+1) + " are the same.";
                return false;
            }
        }
    }
    for (int r = 0; r < board[0].length; r++) {
        for (int sr = r + 1; sr < board[0].length; sr++) {
            boolean same = true;
            for (int c = 0; c < board.length; c++) {
                if (board[c][r] != board[c][sr]) {
                    same = false;
                }
            }
            
            if (same == true) {
                toastMessage = noRepeats;
                toastMessage += "\nRows " + (r+1) + " and " + (sr+1) + " are the same.";
                return false;
            }
        }
    }
    
    toastMessage = "";
    won = true;
    
    return won;
}

void draw() {
    background(249,205,173);
    
    if (menu) {
        pushStyle();
        menuDraw();
        popStyle();
    } else {
        gameDraw();
    }
}

void menuDraw() {
    fill(0); textSize(28); textAlign(LEFT, TOP);
    text("Select a difficulty:", 0, 0);
    
    int perLine = 4;
    int bSize = min(width / (perLine * 1.5), height / (gridSizeChoices.length / perLine));
    int y = height / ((gridSizeChoices.length / perLine) * 2);
    for (int i = 0; i < gridSizeChoices.length; i++) {
        int x = (width / (perLine + 1)) * ((i % perLine) + 1);
        if (i >= perLine && i % perLine == 0) { y += height / (gridSizeChoices.length / perLine); }
        
        fill(tileColors[0]); noStroke();
        rect(x, y, bSize, bSize, tileRadiusOptions[tileRadiusChoice]);
        
        fill(0); textAlign(CENTER, CENTER);
        text(gridSizeChoices[i] + " x " + gridSizeChoices[i], x, y);
    }
}

void gameDraw() {
    drawBoard();

    if (won) {
        pushStyle();

        fill(tileColors[4]);
        rect(width / 2, height / 2, width, height);

        fill(0);
        textAlign(CENTER, CENTER);
        textSize(48);
        text(winMessage, width / 2, height / 2);

        popStyle();
    }
}

// displays the board
void drawBoard() {
    strokeWeight(2);

    int x = tileSize;
    for (int c = 0; c < board.length; c++) {
        int y = tileSize;
        
        for (int r = 0; r < board[0].length; r++) {
            fill( tileColors[board[c][r]] ); stroke(tileColors[0]);
            rect(x, y, tileSize * 0.9, tileSize * 0.9, tileRadiusOptions[tileRadiusChoice]);
            
            if (locked[c][r] == true) {
                fill(tileColors[3]); noStroke();
                ellipse(x, y, tileSize  / 6, tileSize / 6);
            }
            
            y += tileSize;
        }
        
        x += tileSize;
    }
    
    fill(0); textSize(16);
    text(toastMessage, 0, 0);
}

// handles a click
void mouseReleased() {
    if (menu) {
        menuTouch();
    } else {
        gameTouch();
    }
}

void menuTouch() {
    int perLine = 4;
    int bSize = min(width / (perLine * 1.5), height / (gridSizeChoices.length / perLine));
    int y = height / ((gridSizeChoices.length / perLine) * 2);
    for (int i = 0; i < gridSizeChoices.length; i++) {
        int x = (width / (perLine + 1)) * ((i % perLine) + 1);
        if (i >= perLine && i % perLine == 0) { y += height / (gridSizeChoices.length / perLine); }
        
        if (mouseX > x - bSize / 2 && mouseX < x + bSize / 2 && mouseY > y - bSize / 2 && mouseY < y + bSize / 2) {
            newGame(gridSizeChoices[i]);
            menu = false;
        }
    }
}

void gameTouch() {
    if (won) {
        menu = true;
        return null;
    }

    int x = tileSize / 2;
    int y = tileSize / 2;
    
    for (int c = 0; c < board.length; c++) {
        for (int r = 0; r < board[0].length; r++) {
            if (mouseX > x && mouseX < x + tileSize && mouseY > y && mouseY < y + tileSize && locked[c][r] == false) {
                board[c][r] += 1;
                if (board[c][r] > 2) {
                    board[c][r] = 0;
                }
                
                checkSolution();
            }
            
            y += tileSize;
        }
        
        x += tileSize;
        y = tileSize / 2;
    }
}


// helper function to generate random integer within limits
int randomInt(int min, int max) {
    return min + (int)(random() * ((max - min) + 1));
}							