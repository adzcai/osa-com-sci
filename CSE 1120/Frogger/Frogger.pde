// In the main file, we keep the code simple, declaring a few constants and the current level.

// These are constants for the different types of lanes and obstacles, which we put together for clarity
public static final int NUMROADTYPES = 4,
  SAFETY = 0,
  ROAD = 1,
  STREAM = 2,
  DESTINATION = 3;

// These are constants for the different game statuses

public static final int NUMSTATES = 4,
  STARTSCREEN = 0,
  LEVEL1 = 1,
  LEVEL2 = 2,
  MENUSTATE = 3;

// Constants for the different types of obstacles
public static final int NUMOBSTACLETYPES = 5,
  CAR = 0,
  LOG = 1,
  HOME = 2,
  ALLIGATOR = 3,
  REACHED = 4;

Assets assets;

boolean paused = false;
GameState[] states;

int currentState;

void setup() {
  size(640, 550);
  assets = new Assets(width, height);

  states = new GameState[NUMSTATES];
  states[STARTSCREEN] = new StartScreen();
  states[LEVEL1] = new Level1();
  states[LEVEL2] = new Level2();

  // Start the startscreen in the background
  currentState = STARTSCREEN;
  getLevel().reset(0);
}

void draw() {
  // Then, if the game is starting, we draw the title text on top and occasionally randomly move the frog
  if (paused) drawCenteredText("Game paused");
  else getLevel().update();
  getLevel().show();
}

void keyPressed() {
  if (key == ' ') paused = !paused;
  getLevel().handleInput();
}

public void drawCenteredText(String str) {
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(assets.arcadeFont, height / 8);
  text(str, 0, 0, width, height);
}

public Level getLevel() {
  return (Level) states[currentState];
}

public void loadState(int state) {
  currentState = state;
  getLevel().init();
}
