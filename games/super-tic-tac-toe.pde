Array[] tab;
Array[] wonBoards;

int player;
int winner;

color[] playerCols = { color(255, 0, 0), color(0, 0, 255) };
String[] playerNames = { "x", "o" };

float cw;
float ch;

PVector allowedBoardMin;
PVector allowedBoardMax;

void setup() {
    float winwid = window.innerWidth / 2;
    float winhei = window.innerHeight * 0.8;
    float winsiz = min(winwid, winhei);
    size(winsiz, winsiz);
    
    
    tab = new Array[3];
    wonBoards = new Array[3];
    for (r = 0; r < 3; r++) {
        tab[r] = new Array[3];
        wonBoards[r] = new int[3];
        for (c = 0; c < 3; c++) {
            tab[r][c] = new Array[3];
            wonBoards[r][c] = 0;
            for (rr = 0; rr < 3; rr++) {
                tab[r][c][rr] = new int[3];
                for (cc = 0; cc < 3; cc++) {
                    tab[r][c][rr][cc] = 0;
                }
            }
        }
    }
    
    cw = (width / 3) * 0.9;
    ch = (height / 3) * 0.9;
    
    player = 1;
    winner = 0;
    
    allowedBoardMin = new PVector(0, 0);
    allowedBoardMax = new PVector(2, 2);
}

void playMove(int r, int c, int rr, int cc) {
    tab[r][c][rr][cc] = player;
    
    if (player == 1) {
        player = 2;
    } else {
        player = 1;
    }
    
    checkForWin();
    
    allowedBoardMin = new PVector(rr, cc);
    allowedBoardMax = new PVector(rr, cc);
    
    if (isFull(tab[rr][cc]) || isWon(rr, cc)) {
        allowedBoardMin = new PVector(0, 0);
        allowedBoardMax = new PVector(2, 2);
    }
}

void checkForWin() {
    lockWonBoards();

    for (check = 1; check <= 2; check ++) {
        if ((wonBoards[0][0] == check && wonBoards[0][1] == check && wonBoards[0][2] == check) || // 1st row
            (wonBoards[1][0] == check && wonBoards[1][1] == check && wonBoards[1][2] == check) || // 2nd row
            (wonBoards[2][0] == check && wonBoards[2][1] == check && wonBoards[2][2] == check) || // 3rd row
            (wonBoards[0][0] == check && wonBoards[1][0] == check && wonBoards[2][0] == check) || // 1st col.
            (wonBoards[0][1] == check && wonBoards[1][1] == check && wonBoards[2][1] == check) || // 2nd col.
            (wonBoards[0][2] == check && wonBoards[1][2] == check && wonBoards[2][2] == check) || // 3rd col.
            (wonBoards[0][0] == check && wonBoards[1][1] == check && wonBoards[2][2] == check) || // Diagonal
            (wonBoards[2][0] == check && wonBoards[1][1] == check && wonBoards[0][2] == check)) { //   Diagonal   
                    
                winner = check;
        }
    }
}

boolean hasWon(int[][] board, int ptoc) {
    if (board[0][0] == ptoc && board[0][1] == ptoc && board[0][2] == ptoc || // 1st row
        board[1][0] == ptoc && board[1][1] == ptoc && board[1][2] == ptoc || // 2nd row
        board[2][0] == ptoc && board[2][1] == ptoc && board[2][2] == ptoc || // 3rd row
        board[0][0] == ptoc && board[1][0] == ptoc && board[2][0] == ptoc || // 1st col.
        board[0][1] == ptoc && board[1][1] == ptoc && board[2][1] == ptoc || // 2nd col.
        board[0][2] == ptoc && board[1][2] == ptoc && board[2][2] == ptoc || // 3rd col.
        board[0][0] == ptoc && board[1][1] == ptoc && board[2][2] == ptoc || // Diagonal         
        board[2][0] == ptoc && board[1][1] == ptoc && board[0][2] == ptoc) { //   Diagonal 

        return true;

    } else {
        return false;
    }
}

boolean isWon(int r, int c) {
    return (wonBoards[r][c] != 0);
}

void lockWonBoards() {
    for (check = 1; check <= 2; check ++) {
        for (r = 0; r < 3; r++) {
            for (c = 0; c < 3; c++) {
                if (hasWon(tab[r][c], check) == true && wonBoards[r][c] == 0) {
                    wonBoards[r][c] = check;
                }
            }
        }
    }
}

boolean isFull(int[][] board) {
   for (r = 0; r < 3; r++) {
        for (c = 0; c < 3; c++) {
           if (board[r][c] == 0) {
               return false; 
           }
        }
   }
   
   return true;
}

void draw() {
    background(255);
    
    stroke(0);
    fill(0);
    
    strokeWeight(4);
    line(0, height / 3, width, height / 3); line(0, height * 2/3, width, height * 2/3);
    line(width / 3, 0, width / 3, height); line(width * 2/3, 0, width * 2/3, height);
    
    strokeWeight(2);
    
    textAlign(CENTER, CENTER);
    
    for (r = 0; r < 3; r++) {
        float cx = (r * (width / (3))) + ((width / 3) / 2);
        
        for (c = 0; c < 3; c++) {
            float cy = (c * (height / 3)) + ((height / 3) / 2);
            
            int wonThisBoard = 0;
            stroke(0);
            if (wonBoards[r][c] != 0) {
                wonThisBoard = wonBoards[r][c];
                stroke(playerCols[wonThisBoard - 1]);
            }
            
            if (allowedBoardMin.x <= r & allowedBoardMax.x >= r & allowedBoardMin.y <= c & allowedBoardMax.y >= c & !isWon(r, c)) {
              stroke(0, 255, 0);
            }
            
            
            for (rr = 0; rr < 3; rr++) {
                if (rr > 0) {
                    float nx = (cx - cw/2) +  (rr * (cw / 3));
                    line(nx, cy - ch/2, nx, cy + ch/2);
                }
                
                
                for (cc = 0; cc < 3; cc++) {
                    if (rr > 0) {
                        float ny = (cy - ch/2) +  (rr * (ch / 3));
                        line(cx - cw/2, ny, cx + cw/2, ny);
                    }
                
                
                   float ccx = (cx - cw / 2) + (rr * (cw / 3)) + (cw / 6);  
                   float ccy = (cy - ch / 2) + (cc * (ch / 3)) + (cw / 6);
                   
                   int sel = tab[r][c][rr][cc];
                   if (sel > 0) {
                        
                        pushStyle();
                        fill(playerCols[sel - 1]);
                        if (wonThisBoard > 0) {
                            fill(playerCols[wonThisBoard - 1]);
                        }
                        
                        noStroke();
                        //ellipse(ccx, ccy, cw / 6, ch / 6);
                        
                        textSize(cw / 12);
                        //fill(0);
                        text(playerNames[sel - 1], ccx, ccy);
                        popStyle();
                   }
                }
            }
        }
    }
    
    if (winner > 0) {
        fill(0, 0, 0, 100);
        noStroke();
        rect(0, 0, width, height);
        
        fill(playerCols[winner - 1]);
        textSize(width / 8);
        text(playerNames[winner - 1] + " wins\nTap to play again.", width / 2, height / 2);
    }
}

void mousePressed() {
    if (winner > 0) {
      setup();
    } else {
      float ccw = cw / 3;
      float cch = ch / 3;
      
      for (r = allowedBoardMin.x; r <= allowedBoardMax.x; r++) {
          float cx = (r * (width / (3))) + ((width / 3) / 2);
          
          for (c = allowedBoardMin.y; c <= allowedBoardMax.y; c++) {
              float cy = (c * (height / 3)) + ((height / 3) / 2);
              
              for (rr = 0; rr < 3; rr++) {
                  for (cc = 0; cc < 3; cc++) {
                     float ccx = (cx - cw / 2) + (rr * (cw / 3)) + (cw / 6);  
                     float ccy = (cy - ch / 2) + (cc * (ch / 3)) + (ch / 6);
                     
                     
                      if (mouseX > ccx - ccw / 2 & mouseX < ccx + ccw / 2 & mouseY > ccy - cch / 2 & mouseY < ccy + cch / 2 & tab[r][c][rr][cc] == 0 & !isWon(r, c)) {
                          playMove(r, c, rr, cc);
                          return null;
                      }
                  }
              }
          }
      }
    } 
}	