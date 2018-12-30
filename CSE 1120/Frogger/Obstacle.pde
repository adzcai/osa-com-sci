public class Obstacle extends Rectangle {
  
  private int type;
  private float minX, maxX;
  private float speed;
  
  private PImage img;

  // We initialize the obstacle like a rectangle, plus a speed variable
  public Obstacle(Lane lane, float x, float y, float w, float h, float s, int t) {
    super(x, y, w, h);

    minX = lane.x - w - lane.h; // Since the height of the lane is equal to the level's grid
    maxX = lane.x + lane.w + lane.h;

    speed = s;
    setType(t);
  }

  public void update() {
    x += speed; // Adjust the position according to the velocity
    if (speed > 0 && x > maxX) // If it's moving to the right and passes past the screen...
      x = minX; // we reset it to behind the screen
    else if (speed < 0 && x < minX) // If it's going left and passes past the screen...
      x = maxX; // we reset it to the right of the screen
  }

  public void show() {
    image(img, x, y, w, h);
  }

  public void collide(Frog frog) {
    switch (type) {
    case CAR: // If the frog hits a car, he dies and we reset
      frog.die(); break;
    
    case LOG: // He lands on a log, he's ok and we attach to it
      frog.attach(this); break;
    
    case HOME: // If he reaches one of the home points (note it hasn't been reached or alligator-ed)
      setType(REACHED); // The frog reaches the tile, so we change its type, inc the level's points
      frog.level.incPoints(int(50 + frog.level.remainingTime / 2)); // 50 points for reaching an end tile, plus half per remaining second
      break;
    
    case REACHED: // We just reset if he reaches a tile that's been reached
      frog.level.reset(0); break;
      
    case ALLIGATOR:
      frog.die(); break;
    }
  }

  public void setType(int type) {
    this.type = type;
    img = assets.sprites[type];
  }
  
}
