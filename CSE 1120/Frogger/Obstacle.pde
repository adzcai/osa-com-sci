public class Obstacle extends Rectangle {
  
  private String type;
  private float minX, maxX;
  private float speed;
  
  private PImage img;
  private Animation anim; // This is only for the reached destinations

  // We initialize the obstacle like a rectangle, plus a speed variable and its lane, which we use to calculate its min and max x values
  public Obstacle(Lane lane, float x, float y, float w, float h, float s, String type) {
    super(x, y, w, h);

    minX = lane.x - w - lane.h; // Since the height of the lane is equal to the level's grid
    maxX = lane.x + lane.w + lane.h;

    speed = s;
    setType(type);
  }

  public void update() {
    if (assets.isSpritesheet(type)) { // If we show an animation, not a sprite, we keep looping through it
      if (!anim.isPlaying()) anim.play();
      anim.update();
    }
    
    x += speed; // Adjust the position according to the velocity
    if (speed > 0 && x > maxX) // If it's moving to the right and passes past the screen...
      x = minX; // we reset it to behind the screen
    else if (speed < 0 && x < minX) // If it's going left and passes past the screen...
      x = maxX; // we reset it to the right of the screen
  }

  public void show() { // If this obstacle has an animation, we get its current frame, otherwise it's just its image
    image(assets.isSpritesheet(type) ? anim.getCurrentFrame() : img, x, y, w, h);
  }

  // The return value of this function tells the code whether or not to stop checking the remaining obstacles
  public boolean collide(Frog frog) {
    switch (type) {
    case "snake":
    case "car":
    case "truck":
    case "racecar1":
    case "racecar2":
    case "racecar3": 
    case "alligator":
    case "homealligator":
      // If the frog hits one of these obstacles, he dies and we reset
      frog.die();
      break;
    
    case "log":
    case "longlog":
    case "turtle": // He lands on a log, we attach to it
      frog.attach(this);
      break;
    
    case "ladybug":
      frog.level.incPoints(200); // 200 points for reaching a tile with a ladybug
    case "home": // If he reaches one of the home points (note it hasn't been reached or alligator-ed)
      setType("reached"); // The frog reaches the tile, so we change its type, inc the level's points
      frog.level.incPoints(int(50 + frog.level.remainingTime / 2)); // 50 points for reaching an end tile, plus half per remaining second
      return true; // We return true since the frog should only be able to reach one tile at a time
    
    case "reached": // We just reset if he reaches a tile that's been reached
      frog.level.reset(0);
      break;
    }

    return false; // For any of the types besides an empty destination, multiple collisions should be fine
  }

  public boolean isType(String type) { return this.type.equals(type); }
  public void setType(String type) {
    this.type = type;
    if (assets.isSpritesheet(type)) { // If the new type has an animation, we create one from assets
      int speed = defaultAnimationSpeed;
      if (isType("home")) speed = 3 * 1000; // The home frogs open their mouths every 3 seconds
      anim = new Animation(speed, assets.getSpritesheet(type));
    } else img = assets.getSprite(type); // Otherwise we just get the sprite
  }
  
}
