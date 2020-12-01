	float limit;
int scoreadd;
int found;
boolean done;
float startTime;
float totalTime;
String totalTimeS;

List<Integer> tab;

void setup() {
    float winwid = window.innerWidth / 2;
    float winhei = window.innerHeight * 0.8;
    float winsiz = min(winwid, winhei);
    size(winsiz * 0.9, winsiz);

    limit = 20.0;
    scoreadd = 1;
    found = 1;
    done = false;
    startTime = elapsedTime();
    totalTime = 0.0;
    
    create(100);
}

float elapsedTime() {
    return millis() / 1000;
}

void create(int schmiz) {
    tab = new ArrayList<Integer>();
    // fill table with numbers
    for (z=1; z<=schmiz; z++) {
        tab.add(z);
    }
    // shuffle the board
    for (z=1; z<=schmiz; z++) {
        int n = round(random(0, schmiz+1-z));
        tab.add(tab.get(n));
        tab.remove(n);
    }
    findTime = elapsedTime() + limit;
}

void draw() {
    float diff = findTime - elapsedTime();
    float amnt = min(1, diff / limit);
    color backcol = color(255 - 255*amnt, 180*amnt, 255*amnt, 255);
    color oBCol = color(255*amnt, 255 - 180*amnt, 255 - 255*amnt, 255);
    background(backcol);
    float fS = width / 30;
    textSize(fS);
    textAlign(CENTER, CENTER);

    fill(255);
    if (done) {
        text("Total time:  " + totalTimeS, width / 2, height / 2 + fS);
        text("Tap to play again", width / 2, height / 2 - fS);
    } else {
        totalTime = elapsedTime() - startTime;

        int count = 0;
        int minS = min(width, height);
        int rsize = minS / sqrt(tab.size());
        float lw = width / 2 - minS / 2;
	float lh = height / 2 - minS / 2;
        for (x = 0; x <= sqrt(tab.size()) - 1; x++) {
            for (y = 0; y <= sqrt(tab.size()) - 1; y++) {
                fill(255);
		color fC = color(0);
                if (tab.get(count) < found) {
                    fill(backcol);
		    fC = oBCol;
                }
                float nx = lw + x * rsize;
		float ny = lh + y * rsize;
                rect(nx, ny, rsize, rsize);
                fill(fC);
                text(tab.get(count), nx + rsize / 2, ny + rsize / 2);
		count = count + 1;
            }
        }

        text("Time left: " + round(diff), width / 2, fS);
        long csecond = round((totalTime) % 60);
        long cminute = round((totalTime / 60) % 60);
        long chour = round((totalTime / (60 * 60)) % 24);
        
        totalTimeS = nf(cminute, 2) + ":" + nf(csecond, 2);
        if (chour > 0) {
            totalTimeS = nf(chour, 2) + ":" + totalTimeS;
        }
        text("Total time: " + totalTimeS, width / 2, height - fS);
        if (diff <= 0) {
            create(100);
            found = round(max(found - 1, 1));
        }
        textSize(width / 2); 
        fill(0, 0, 0, 127);
        text(found, width / 2, height / 2);
    }
}

void mousePressed() {
        if (done) {
            setup();
            return null;
        }

        int minS = min(width, height);
        int xOT = floor((mouseX - ((width - minS) / 2)) / (minS / sqrt(tab.size()))) + 1;
        int yOT = floor((mouseY - ((height - minS) / 2)) / (minS / sqrt(tab.size()))) + 1;
        
        if (xOT >= 1 & xOT <= sqrt(tab.size()) & yOT >= 1 & yOT <= sqrt(tab.size())) {
            if (tab.get((yOT-1) + (xOT-1)*sqrt(tab.size())) == found) { 
                found = found + 1;
                findTime = min(findTime + scoreadd, elapsedTime() + limit);
            } else if (found > 1) {
                found = found - 1;
            }

            if (found > tab.size()) {
                totalTime = elapsedTime() - startTime;
                done = true;
            }
        }
}