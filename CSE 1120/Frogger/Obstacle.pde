// Adds minor functionality onto the Rectangle class
class Obstacle extends Rectangle {
  
  Lane lane;
  float minX, maxX;
  float speed;
  PImage sprite;
  int status;

  // We initialize the obstacle like a rectangle, plus a speed variable
  Obstacle(Lane lane, float x, float y, float w, float h, float s, int type) {
    super(x, y, w, h);
    this.lane = lane;
    minX = lane.x - w - lane.h; // Since the height of the lane is equal to the level's grid
    maxX = lane.x + lane.w + lane.h;
    speed = s;
    
    sprite = sprites[type];
    status = hostilities[type];
  }

  void update() {
    x += speed; // Adjust the position according to the velocity
    if (speed > 0 && x > maxX) // If it's moving to the right and passes past the screen...
      x = minX; // we reset it to behind the screen
    else if (speed < 0 && x < minX) // If it's going left and passes past the screen...
      x = maxX; // we reset it to the right of the screen
  }

  void show() {
    image(sprite, x, y, w, h);
  }
  
}
