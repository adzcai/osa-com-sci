// In the main file, we keep the code simple, declaring a few constants and the current level.

// These are constants for the different types of lanes
final int SAFETY = 0;
final int CAR = 1;
final int LOG = 2;
final int DESTINATION = 3;

// These are constants for the different game statuses
final int STARTING = 0;
final int RUNNING = 1;
final int PAUSED = 2;
final int WON = 3;
final int DIED = 4;

final color[] LANECOLORS = {
  color(0, 255, 0),
  color(0),
  color(0, 0, 255),
  color(0, 255, 0)
};
final color[] OBSTACLECOLORS = {
  0,
  color(100),
  color(165, 42, 42),
  color(64, 128, 64)
};
final color REACHED = color(0, 64, 0);

PFont ARCADEFONT;

Level currentLevel;
int status = STARTING;

void setup() {
  size(640, 550);
  ARCADEFONT = createFont("arcade.ttf", height / 8); // We load in the arcade font, in the data folder
  currentLevel = new Level(0, 0, width, height, "startscreen.csv"); // Start off the game with a level in the background
  currentLevel.lives = 9999; // For the starting level
}

void draw() {
  // Then, if the game is starting, we draw the title text on top and occasionally randomly move the frog
  switch (status) {
  case STARTING:
    currentLevel.update();
    currentLevel.show();
    
    if (random(1) <= 0.1) { // 10% chance of moving the frog
      int h = int(random(3)) - 1; // Randomly choose a direction: -1, 0, 1
      int v = h != 0 ? 0 : int(random(3)) - 1; // If the frog moves horizontally, we don't move it vertically, and vice versa
      currentLevel.frog.move(h, v);
    }
    
    textAlign(CENTER, CENTER);
    textFont(ARCADEFONT, height / 8);
    text("FROGGER", width / 2, height / 3);
    
    textFont(ARCADEFONT, height / 12);
    text("By Alexander Cai", width / 2, height / 2);
    text("Press any key to begin", width / 2, height * 2 / 3);
    break;
  
  case RUNNING:
    currentLevel.update();
    currentLevel.show();
    break;
  
  case PAUSED:
    currentLevel.show();
    drawCenteredText("Game paused");
    break;
  
  // Whether the game is starting or running, we run the level in the background first
  case WON:
  case DIED:
    drawCenteredText("You " + (status == WON ? "won" : "lost") + "!\nYour Score " + currentLevel.points + "\nPress any key to restart");
    break;
  
  default:
    background(0);
  }
}

void keyPressed() {
  switch (status) {
  case STARTING: // If the game is showing the start screen
  case WON: // the user just won,
  case DIED: // or the user just died,
  // and the user presses a key, we change the status of the game and initialize the first level
    currentLevel = new Level(0, 0, width * 4 / 5, height, "level1.csv");
    status = RUNNING;
    break;
    
  case PAUSED:
    status = RUNNING;
    break;
  
  case RUNNING: 
    if (key == ' ') {
      status = PAUSED;
      break;
    }
    
    // If the game is running, we get a vertical and horizontal value for the frog to move,
    // and pass that to the frog's move method
    int h = keyCode == RIGHT ? 1 : (keyCode == LEFT ? -1 : 0);
    int v = keyCode == UP ? -1 : (keyCode == DOWN ? 1 : 0);
    currentLevel.frog.move(h, v);
  } // We don't need a break at the end since it's the last case, and we don't care about a default case
}

void drawCenteredText(String str) {
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(ARCADEFONT, height / 8);
  text(str, 0, 0, width, height);
}
