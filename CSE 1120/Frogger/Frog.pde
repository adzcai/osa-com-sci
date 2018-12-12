// This class stores information about the frog, which we implement as a subclass of Rectangle
// to track its hitbox, and its intersects() function.
class Frog extends Rectangle {

  Level level;
  Obstacle attached = null; // The object, usually a log, that we are attached to

  Frog(Level level, float x, float y, float s) {
    super(x, y, s, s, color(0, 255, 0, 200)); // The frog is a square, with a slightly transparent green color
    this.level = level;
  }

  void attach(Obstacle log) {
    attached = log;
  }

  void update() {
    // If the frog is attached to an object, we move it together with the object
    if (attached != null) x += attached.speed;
    if (!onScreen(x, y)) { // The frog has ridden a log off the screen
      level.lives -= 1;
      level.reset();
    }
  }

  // Triggered by user key presses, we move in terms of the tile size
  void move(float dx, float dy) {
    float nextx = x + dx * level.grid;
    float nexty = y + dy * level.grid;
    
    // If the move would cause him to move past the screen, we return out of the function
    if (!onScreen(nextx, nexty)) return;
    
    // We know that it will remain on the screen now, so we can move it.
    x = nextx;
    y = nexty;
    attach(null); // If it's currently attached to a log, we un-attach it 
    
    if (dy < 0) level.points += 10; // 10 points if it goes up
  }
  
  boolean onScreen(float xc, float yc) { // Test if a coordinate keeps the frog on the screen.
    // Essentially, we test that xc is equal to xc when bounded by one pixel within the level, and the same for yc.
    return xc == constrain(xc, level.x - w + 1, level.x + level.w - 1) &&
      yc == constrain(yc, level.y - h + 1, level.y + level.h - 1);
  }
  
}
