// In the main file, we keep the code simple, declaring a few constants and the current level.
// I decided to start using access modifiers in other files (private, public, etc.)
// to make sure that the code is secure

Assets assets;
float defaultAnimationSpeed;
boolean paused = false;

void setup() {
  size(640, 550);
  noSmooth(); // For that retro pixelated effect
  frameRate(60);
  
  assets = new Assets(width, height); // See Assets.pde; loads in images from the data folder
  defaultAnimationSpeed = frameRate * 10;
  loadState(MENUSTATE);
}

void draw() {
  if (paused) drawCenteredText("Game paused");
  else getState().update();
  getState().show(); // We show the current level
}

void keyPressed() {
  if (key == ' ') paused = !paused; // The spacebar toggles pausing
  if (paused) return; // Don't respond to key presses when paused
  getState().handleInput(); // Otherwise we let the level handle it
}

void drawCenteredText(String str) { // For titles and things
  fill(255);
  textAlign(CENTER, CENTER);
  textFont(assets.arcadeFont, height / 8);
  text(str, 0, 0, width, height);
}
