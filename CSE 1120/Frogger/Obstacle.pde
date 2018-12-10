// Adds minor funcitonality onto the Rectangle class
class Obstacle extends Rectangle {
  
  float speed;

  Obstacle(float x, float y, float w, float h, float s) {
    super(x, y, w, h);
    speed = s;
  }

  void update() {
    x = x + speed;
    if (speed > 0 && x > width + grid) // If it's moving to the right and passes past the screen
      x = -w - grid; // we reset it to behind the screen
    else if (speed < 0 && x < -w - grid) // If it's going left
      x = width + grid;
  }
  
}
