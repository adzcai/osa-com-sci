public class Obstacle extends Rectangle {
  
  private String type;
  private float minX, maxX;
  private float speed;
  
  private PImage img;
  private Animation anim; // This is only for the reached destinations

  // We initialize the obstacle like a rectangle, plus a speed variable
  public Obstacle(Lane lane, float x, float y, float w, float h, float s, String type) {
    super(x, y, w, h);

    minX = lane.x - w - lane.h; // Since the height of the lane is equal to the level's grid
    maxX = lane.x + lane.w + lane.h;

    speed = s;
    setType(type);
    println("type: "+type);
    println("img: "+img);
    println("anim: "+anim);
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

  public void show() {
    println(type);
    println(assets.isSpritesheet(type));
    println(anim);
    println(img);
    image(assets.isSpritesheet(type) ? anim.getCurrentFrame() : img, x, y, w, h);
  }

  public void collide(Frog frog) {
    switch (type) {
    case "car":
    case "racecar1":
    case "racecar2":
    case "racecar3": // If the frog hits one of these obstacles, he dies and we reset
    case "alligator":
    case "homealligator":
      frog.die(); break;
    
    case "log":
    case "longlog":
    case "turtle": // He lands on a log, he's ok and we attach to it
      frog.attach(this); break;
    
    case "home": // If he reaches one of the home points (note it hasn't been reached or alligator-ed)
      setType("reached"); // The frog reaches the tile, so we change its type, inc the level's points
      frog.level.incPoints(int(50 + frog.level.remainingTime / 2)); // 50 points for reaching an end tile, plus half per remaining second
      break;
    
    case "reached": // We just reset if he reaches a tile that's been reached
      frog.level.reset(0); break;
    }
  }

  public boolean isType(String type) { return this.type.equals(type); }
  public void setType(String type) {
    this.type = type;
    if (assets.isSpritesheet(type)) {
      int speed = defaultAnimationSpeed;
      if (isType("home")) speed = 1000; // We don't want the home frogs to look maniacal
      anim = new Animation(speed, assets.getSpritesheet(type));
    } else img = assets.getSprite(type);
  }
  
}
