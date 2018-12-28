// Stores the information about a certain point in a line
class Point {
  PVector pos, velocity, accel;
  float dim; // The diameter of the point
  color col;
  
  Point(float x, float y, float d, color c) {
    pos = new PVector(x, y);
    velocity = new PVector(0, 0);
    accel = new PVector(0, 0);
    dim = d;
    col = c;
  }
  
  void update() {
    if (!hotkeys.get("motion").enabled) return;
    pos.add(velocity.mult(speedScale));
    checkBoundaries();
    
    println(speedScale);
    
    if (hotkeys.get("gravity").enabled) velocity.add(gravity);
    if (hotkeys.get("randomMovement").enabled) velocity.add(PVector.random2D());;
  }
  
  // If it goes beyond the canvas bounds, we flip the velocity and move the ball to the boundary.
  void checkBoundaries() {
    if (pos.x < canvas.x) {
      velocity.x *= -1;
      pos.x = canvas.x;
    } else if (pos.x > canvas.x + canvas.w) {
      velocity.x *= -1;
      pos.x = canvas.x + canvas.w;
    }
    
    if (pos.y < canvas.y) {
      velocity.y *= -1;
      pos.y = canvas.y;
    } else if (pos.y > canvas.y + canvas.h) {
      // If it hits the ground we absorb a small bit of the energy
      velocity.y *= -0.95;
      pos.y = canvas.y + canvas.h;
    }
  }
}
