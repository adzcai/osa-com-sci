// In the main file, we keep the code simple, declaring a few constants and the current level.
// I decided to start using access modifiers in other files (private, public, etc.)
// to make sure that the code is secure.
// Also, to follow the retro style, the mouse is not used at all.

Assets assets;
boolean paused = false;

void setup() {
  size(640, 550);
  noSmooth(); // For that retro pixelated effect
  frameRate(60);
  
  assets = new Assets(width, height); // See Assets.pde; loads in images from the data folder
  loadState(MENUSTATE);
}

void draw() {
  if (paused) assets.drawCenteredText("Game paused");
  else getState().update();
  getState().show(); // We show the current level
}

void keyPressed() {
  if (key == ' ') paused = !paused; // The spacebar toggles pausing
  if (paused) return; // Don't respond to key presses when paused
  getState().handleInput(); // Otherwise we let the level handle it
}
