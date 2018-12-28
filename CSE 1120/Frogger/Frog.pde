// This class stores information about the frog, which we implement as a subclass of Rectangle
// to track its hitbox, and its intersects() function.
class Frog extends Rectangle {

  Level level;
  Obstacle attached = null; // The object, usually a log, that we are attached to
  
  Animation death, jump;
  int dir; // The direction the frog is jumping, used for the animation

  Frog(Level level, float x, float y, float s) {
    super(x, y, s, s); // The frog is a square, with a slightly transparent green color
    this.level = level;

    death = new Animation(int(frameRate / 4), assets.death);
    jump = new Animation(int(frameRate / 16), assets.frog[0]); // The vertical jumping
    dir = 0;
  }

  void update() {
    if (death.getIndex() > 0) { // He has recently died
      // If it has been at least a second since the frog died
      if (millis() - death.getLastTime() > 1000) level.reset(-1);
      return; // We don't want to keep updating 
    }

    // If the frog is attached to an object, we move it together with the object
    if (attached != null) x += attached.speed;
    if (!onScreen(x, y)) { // The frog has ridden a log off the screen
      death.start();
      return; // He's died so we don't update
    }

    // We check for the frog's intersection with the obstacles
    for (Obstacle o : getCurrLane().obstacles) // We loop through the obstacles in the lane
      if (intersects(o)) o.collide(this);
    
    // The frog landed in the water
    if (getCurrLane().type == LOG && attached == null) death.start();

    // We update the jump animation
    if (dir != 0) jump.update();
  }

  void show() {
    // We show the frog if he's alive, or the death otherwise
    if (justDied()) {
      image(death.getCurrentFrame(), x, y, w, h);
    } else {
      image(assets.frog[0][0], x, y, w, h);
    }
  }

  void attach(Obstacle log) {
    attached = log;
  }

  // Triggered by user key presses, we move in terms of the tile size
  void move(int dir) {
    // We get a vertical and horizontal value for the frog to move
    int dx = dir == RIGHT ? 1 : (dir == LEFT ? -1 : 0);
    int dy = dir == UP ? -1 : (dir == DOWN ? 1 : 0);
    
    float nextx = x + dx * level.tileWidth;
    float nexty = y + dy * level.tileHeight;
    
    // If the move would cause him to move past the screen, we return out of the function
    if (!onScreen(nextx, nexty)) return;
    
    // We know that it will remain on the screen now, so we can move it.
    x = nextx;
    y = nexty;
    this.dir = dir;
    attach(null); // If it's currently attached to a log, we un-attach it 
    
    if (dy < 0) level.incPoints(10); // 10 points if it goes up
  }

  boolean onScreen(float xc, float yc) { // Test if a coordinate keeps the frog on the screen.
    // Essentially, we test that xc is equal to xc when bounded by one pixel within the level, and the same for yc.
    return xc == constrain(xc, level.x - w + 1, level.x + level.w - 1) &&
      yc == constrain(yc, level.y - h + 1, level.y + level.h - 1);
  }

  // Dividing by the grid size gives us the number of lanes above the frog,
  // which is the same as the index of the frog's lane.
  Lane getCurrLane() {
    int laneIndex = int(y / level.tileHeight); 
    return level.lanes[laneIndex];
  }

  boolean justDied() {
    return death.playing;
  }
  
}
