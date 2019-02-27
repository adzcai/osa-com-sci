// In the main file, we keep the code simple, declaring a few constants and the current level.
// There are a lot of other files with various classes, game states, etc., which are clearly labeled.
// I decided to start using access modifiers in other files (private, public, etc.) to make sure that the code is secure. Constants are declared with final.
// Also, to follow the retro style, the mouse is not used at all.

Assets assets;
boolean paused = false;

void setup() {
  size(640, 550);
  noSmooth(); // For the pixelated effect
  noStroke(); // Don't want borders showing up around the rectangles
  frameRate(60);
  
  assets = new Assets(); // See Assets.pde; loads in images from the data folder
  loadState(MENUSTATE);
}

void draw() {
  if (!paused) getState().update(); // Update current state if the game isn't paused
  getState().show(); // and always show it
  if (paused) assets.drawCenteredText("Game paused");
}

void keyPressed() {
  if (key == ' ') paused = !paused; // The spacebar toggles pausing
  if (paused) return; // Don't respond to key presses when paused
  getState().handleInput(); // Otherwise we let the current state handle it
}
