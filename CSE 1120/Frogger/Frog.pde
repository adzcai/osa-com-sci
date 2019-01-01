// This class stores information about the frog, which we implement as a subclass of Rectangle
// to track its hitbox, and its intersects() function.
// Note: death.play() is basically our way of saying die()
public class Frog extends Rectangle {

  private Level level;
  private Obstacle attached = null; // The object, usually a log, that we are attached to
  
  private boolean dead = false;
  private int animFinishedMillis = -1;
  private int deathWaitTime = 500;
  
  private Animation anim;
  private int dir; // The direction the frog is jumping, used for the animation

  // ===== INITIALIZING THE FROG =====

  public Frog(Level level, float x, float y, float s) {
    super(x, y, s, s); // The frog is a square
    this.level = level;

    anim = new Animation(100, assets.getSpritesheet("frog")); // The vertical jumping
    dir = 0;
  }

  // ===== DRAWING THE FROG =====

  public void show() {
    // We show the frog if he's alive, or the death otherwise
    image(anim.getCurrentFrame(), x, y, w, h);
  }

  // ===== UPDATING THE FROG =====

  public void update() {
    if (dead) {
      if (animFinishedMillis >= 0 && (millis() - animFinishedMillis > deathWaitTime)) // If *deathWaitTime* milliseconds have passed since the death animation finished
        level.reset(-1); // We reset the level with a lost life
        
      anim.update(); // Update the death animation
      if (animFinishedMillis < 0 && anim.isFinished()) animFinishedMillis = millis(); // If the animation just finished, we set *animFinishedMillis* to now
      return;
    }
    
    // If the frog is attached to an object, we move it together with the object
    if (attached != null) x += attached.speed;
    if (!onScreen(x, y)) { // The frog has ridden a log off the screen
      die();
      return; // He's died so we don't update
    }

    for (Obstacle o : getCurrLane().obstacles) // We check for the frog's intersection with each of the obstacles in the lane
      if (intersects(o)) o.collide(this);
    
    // If the frog landed in the water and he's not riding anything
    if (getCurrLane().isType("river") && attached == null) die();

    // We update the jump animation
    if (dir != 0) anim.update();
  }
  
  private void die() {
    if (dead) return; // Don't want him dying if he's already dead
    dead = true;
    anim = new Animation(defaultAnimationSpeed, assets.getSpritesheet("death")); // Change to the death animation
    anim.play();
  }

  public void attach(Obstacle o) { attached = o; }

  // Triggered by user key presses, we move in terms of the tile size
  public void move(int dir) {
    if (dead) return; // Can't move if he's dead
    
    // We get a vertical and horizontal value for the frog to move using fancy ternary operators
    int dx = dir == RIGHT ? 1 : (dir == LEFT ? -1 : 0);
    int dy = dir == UP ? -1 : (dir == DOWN ? 1 : 0);
    
    float nextx = x + dx * level.tileSize;
    float nexty = y + dy * level.tileSize;
    
    // If the move would cause him to move past the screen, we return out of the function
    if (!onScreen(nextx, nexty)) return;
    
    // We know that it will remain on the screen now, so we can move it.
    x = nextx;
    y = nexty;
    this.dir = dir;
    attach(null); // If it's currently attached to a log, we un-attach it 
    
    if (dy < 0) level.incPoints(10); // 10 points if it goes up
    anim.play();
  }

  // ===== TESTERS AND GETTERS =====

  private boolean onScreen(float xc, float yc) { // Test if a coordinate keeps the frog on the screen.
    // Essentially, we test that xc is equal to xc when bounded by one pixel within the level, and the same for yc.
    return xc == constrain(xc, level.x - w + 1, level.x + level.w - 1) &&
      yc == constrain(yc, level.y - h + 1, level.y + level.h - 1);
  }
  // Dividing by the grid size gives us the number of lanes above the frog,
  // which is the same as the index of the frog's lane.
  private Lane getCurrLane() {
    int laneIndex = int(y / level.tileSize); 
    return level.lanes[laneIndex];
  }
  
}
