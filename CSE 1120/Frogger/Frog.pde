// This class stores information about the frog, which we implement as a subclass of Rectangle
// to track its hitbox, and its intersects() function.
class Frog extends Rectangle {

  Level level;
  Obstacle attached = null; // The object, usually a log, that we are attached to
  PImage sprite;

  Frog(Level level, float x, float y, float s) {
    super(x, y, s, s); // The frog is a square, with a slightly transparent green color
    this.level = level;
    sprite = sprites[FROG];
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

    int laneIndex = int(y / level.grid); // Dividing by the grid size gives us the number of lanes above the frog, which is the same as the index of the frog's lane.
    Lane currLane = level.lanes[laneIndex];

    // We check for the frog's intersection with the obstacles
    boolean ok = false; // This is only used if the type is LOG, but we need to initialize it here anyways.
    // We set the frog's ok-ness to false as a default, then set it to true if he lands on a log (phew!)
    
    for (Obstacle o : currLane.obstacles) { // We loop through the obstacles in the lane
      if (!intersects(o)) continue; // We return if the frog doesn't intersect it

      switch (currLane.type) { // Remember, type is the type of the lane and determines what obstacles are on it
      case CAR: // If the frog hits a car, he dies and we reset
        level.reset(-1);
        break;
        
      case LOG: // He lands on a log, he's ok and we attach to it
        ok = true;
        attach(o);
        break;
        
      case DESTINATION: // If he reaches one of the home points
        if (o.status == HOSTILE) { // If he reaches an alligator, he loses a life
          level.reset(-1);
          return;
        } else if (o.status == REACHED) { // If he has already reached it, we just restart without consequences
          level.reset();
          return;
        }

        o.status = REACHED; // The frog reaches the tile, so we change its color, inc the level's points
        level.incPoints( 50 + 5 * level.elapsed);
        level.reset();
        
        boolean allReached = true;
        // We test each obstacle if it has been reached
        for (Obstacle endPoint : currLane.obstacles) allReached = allReached && (endPoint.status == REACHED);
        if (allReached) {
          level.incPoints(1000);
          status = WON;
        }
      }
    }
    
    // The frog landed in the water
    if (currLane.type == LOG && !ok)
      level.reset(-1);
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
    
    if (dy < 0) level.incPoints(10); // 10 points if it goes up
  }

  void show() {
    image(sprite, x, y, w, h);
  }
  
  boolean onScreen(float xc, float yc) { // Test if a coordinate keeps the frog on the screen.
    // Essentially, we test that xc is equal to xc when bounded by one pixel within the level, and the same for yc.
    return xc == constrain(xc, level.x - w + 1, level.x + level.w - 1) &&
      yc == constrain(yc, level.y - h + 1, level.y + level.h - 1);
  }
  
}
