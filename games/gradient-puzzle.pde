List<Integer> puzzle;
float pieceSize;

color[] cols;

boolean scrambled;
int selected;

boolean won;
boolean menu;

int[] gridSizeChoices = { 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 100 };

void setup() {
    float winwid = window.innerWidth / 2;
    float winhei = window.innerHeight * 0.8;
    float winsiz = min(winwid, winhei);
    size(winsiz, winsiz);
    
    rectMode(CENTER, CENTER);
    textAlign(CENTER, CENTER);
    
    setColors(color(255, 0, 0), color(0, 0, 255));
    reset();
}

void reset() {
    menu = true;
    scrambled = false;
    selected = -1;
    won = false;
}

void setColors(color c1, color c2) {
    cols = { c1, c2 };
}

void buildPuzzle(int bs) {
    pieceSize = (float) width / (float) bs;
    
    puzzle = new ArrayList<Integer>();
    for (z = 0; z < bs * bs; z++) {
        puzzle.add(z);
    }
}

void scramblePuzzle() {
    // shuffle the board
    for (z = 1; z <= puzzle.size(); z++) {
        int n = round(random(0, puzzle.size() + 1 - z));
        puzzle.add(puzzle.get(n));
        puzzle.remove(n);
    }
    
    scrambled = true;
}

void checkForWin() {
    boolean w = true;
    for (int i = 1; i < puzzle.size(); i++) {
        if (puzzle.get(i) < puzzle.get(i - 1)) {
            w = false;
            break;
        }
    }
    
    won = w;
}

void draw() {
    background(255);
    
    if (menu) {
        pushStyle();
        menuDraw();
        popStyle();
    } else {
        gameDraw();
    }

    fill(255); noStroke();
    ellipse(mouseX, mouseY, 20, 20);
}

void menuDraw() {
    fill(0); textSize(width / 30); textAlign(LEFT, TOP);
    text("Select a difficulty:", 0, 0);
    
    int perLine = 4;
    int bSize = min(width / (perLine * 1.5), height / (gridSizeChoices.length / perLine));
    int y = height / ((gridSizeChoices.length / perLine) * 2);
    for (int i = 0; i < gridSizeChoices.length; i++) {
        int x = (width / (perLine + 1)) * ((i % perLine) + 1);
        if (i >= perLine && i % perLine == 0) { y += height / (gridSizeChoices.length / perLine); }
        
        fill(0, 255, 0); noStroke();
        rect(x, y, bSize, bSize, 10);
        
        fill(0); textAlign(CENTER, CENTER);
        text(gridSizeChoices[i] + " x " + gridSizeChoices[i], x, y);
    }
}

void gameDraw() {
    int count = 0;
    float y = pieceSize / 2.0;
    for (int r = 0; r < sqrt(puzzle.size()); r++) {
        float x = pieceSize / 2.0;
        for (int c = 0; c < sqrt(puzzle.size()); c++) {
            fill(lerpColor(cols[0], cols[1], puzzle.get(count) / (puzzle.size() - 1))); noStroke();
            rect(x, y, pieceSize, pieceSize);
            
            if (selected == count) {
                fill(0, 255, 0);
                ellipse(x, y, pieceSize / 4, pieceSize / 4);
            }
            
            fill(0);
            //text(puzzle.get(count), x, y);
            
            x += pieceSize;
            count += 1;
        }
        y += pieceSize;
    }
    
    // Overlay text for some messages
    String txt = "";
    if (!scrambled) {
        txt = "Click to shuffle the puzzle.";
    }
    if (won) {
        txt = "You won.\nClick to reset.";
    }
    textSize(width / 12);
    text(txt, width / 2, height / 2);
}

// handles a click
void mouseReleased() {
    if (menu) {
        menuTouch();
    } else if (!won) {
        gameTouch();
    } else {
        reset();
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
            buildPuzzle(gridSizeChoices[i]);
            menu = false;
        }
    }
}

void gameTouch() {
    if (!scrambled) {
        scramblePuzzle();
    } else {
        int c = (int) ((float) mouseX / ((float) width / (float) sqrt(puzzle.size())));
        int r = (int) (mouseY / (height / sqrt(puzzle.size())));
        
        int n = c + sqrt(puzzle.size()) * r;
        
        if (selected > 0) {
            int old = puzzle.get(n);
            puzzle.set(n, puzzle.get(selected));
            puzzle.set(selected, old);
        
            checkForWin();
            
            selected = -1;
        } else {
            selected = n;
        }
    }
}