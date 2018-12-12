// Adds minor functionality onto the Rectangle class
class Obstacle extends Rectangle {
  
  float minX, maxX;
  float speed;
  boolean alligator = false; // For the destination squares

  // We initialize the obstacle like a rectangle, plus a speed variable
  Obstacle(Lane lane, float x, float y, float w, float h, color c, float s) {
    super(x, y, w, h, c);
    minX = lane.x - w - lane.h; // Since the height of the lane is equal to the level's grid
    maxX = lane.x + lane.w + lane.h;
    speed = s;
  }

  void update() {
    x += speed; // Adjust the position according to the velocity
    if (speed > 0 && x > maxX) // If it's moving to the right and passes past the screen...
      x = minX; // we reset it to behind the screen
    else if (speed < 0 && x < minX) // If it's going left and passes past the screen...
      x = maxX; // we reset it to the right of the screen
  }
  
}
