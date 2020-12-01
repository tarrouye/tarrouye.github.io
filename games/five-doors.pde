boolean showLevel;
boolean gameOver;

int xSize;
int ySize;

int maxLevel;
int portals;
int level;

int tx;
int ty;

PVector player;
PVector dir;

ArrayList tab;

PImage coin;
PImage specialBlock;
PImage brick;
PImage guy;

void setup() {
    float winwid = window.innerWidth / 2;
    float winhei = window.innerHeight * 0.8;
    float winsiz = min(winwid, winhei);
    size(winsiz, winsiz);
    
    coin = loadImage("https://upload.wikimedia.org/wikipedia/commons/0/0a/George_Washington_Presidential_$1_Coin_obverse.png", "png");
    specialBlock = loadImage("http://clipartsign.com/upload/2016/02/15/top-door-clip-art-at-images-for.png", "png");
    brick = loadImage("http://images.all-free-download.com/images/graphiclarge/isometric_brick_tile_clip_art_23503.jpg", "jpg");
    guy = loadImage("https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Smiley.svg/2000px-Smiley.svg.png", "png");

    textSize(30);
    fill(255);
    showLevel = false;
    gameOver = false;
    rectMode(CENTER);
    //imageMode(CENTER);
    textAlign(CENTER, CENTER);
    xSize = 10;
    ySize = 10;
    
    maxLevel = 25;
    portals = 5;
    level = 0;
    tx = 0;
    ty = 0;
    player = new PVector(0,0);
    dir = new PVector(0,0);
    tab = new ArrayList<ArrayList>();
    for (z = 0; z < maxLevel; z++) {
        tab[z] = new ArrayList<ArrayList>();
        for (x=0; x < xSize; x++) {
            tab[z][x] = new ArrayList<PVector>();
            for (y=0; y < ySize; y++) {
                tab[z][x][y] = new PVector(0,0);
            }
        }
        int cnt = 0;
        while (cnt < portals) {
            int xx = round(random(1, xSize-2));
            int yy = round(random(1, ySize-2));
            if (tab[z][xx][yy].x == 0) {
                cnt += 1; 
                if (cnt == 3) {
                    tab[z][xx][yy] = new PVector(1,z+1);  
                } else {
                    tab[z][xx][yy] = new PVector(1, round(random(z))); 
                }
            }
        }
    }
}

void draw() {
    background(255);

    if (gameOver) {
        image(coin, width/2, height/2 + 200, 200, 200);
        int tsw = textWidth("You won!");
        text("You won!", width/2 - tsw/2, height/2 - 200);
    
    } else {
        int wOb = width/xSize;
        int hOb = height/ySize;
      for (x=0; x < xSize; x++) {
          for (y=0; y < ySize; y++) {
                  image(brick,x*wOb,y*hOb, wOb, hOb);
                  fill(0, 0, 0, 50);
                  //noStroke(0);
                  rect(x*wOb + wOb/2, y*hOb + hOb/2, wOb, hOb);
                if (tab[level][x][y].x==1) {
                    image(specialBlock,x*wOb,y*hOb, (specialBlock.width / specialBlock.height) * hOb, hOb);
                } 
                
          }
      }
      image(guy,player.x*wOb,player.y*hOb, wOb, hOb);
      
      textSize(width / 2); 
        fill(0, 0, 0, 127);
        text(level, width / 2, height / 2);
    }
}

void keyPressed() {
        dir = movementKey();

        PVector temp = new PVector(player.x + dir.x, player.y + dir.y);
        if (temp.x>=0 & temp.x<=xSize-1 & temp.y>=0 & temp.y<=ySize-1) {
            player = temp;     
            if (tab[level][player.x][player.y].x == 1) {
                level = tab[level][player.x][player.y].y;
                if (level > maxLevel - 1) {
                    gameOver=true;
                }
            }
        }
}

void mousePressed() {
        if (gameOver) {
            setup();
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
	} else if (key == 'w' || key == 'W' || (key == '9' && dir.x == 1) || (key == '0' && dir.x == -1)) {
		returnVector.x = 0;
		returnVector.y = -1;
	} else if (key == 's' || key == 'S' || (key == '9' && dir.x == -1) || (key == '0' && dir.x == 1)) {
		returnVector.x = 0;
		returnVector.y = 1;
	} else if (key == 'd' || key == 'D' || (key == '9' && dir.y == 1) || (key == '0' && dir.y == -1)) {
		returnVector.x = 1;
		returnVector.y = 0;
	} else if (key == 'a' || key == 'A' || (key == '9' && dir.y == -1) || (key == '0' && dir.y == 1)) {
		returnVector.x = -1;
		returnVector.y = 0;
	}

	return returnVector;
}	