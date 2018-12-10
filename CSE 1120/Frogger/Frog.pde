// This class stores information about the frog, which we implement as a subclass of Rectangle
// to track its hitbox, and its intersects() function.
class Frog extends Rectangle {

  Obstacle attached = null; // The object, usually a log, that we are attached to

  Frog(float x, float y, float s) {
    super(x, y, s, s); // The frog is a square
    col = color(0, 255, 0, 200); // We make it green with a slight alpha
  }

  void attach(Obstacle log) {
    attached = log;
  }

  void update() {
    // If the frog is attached to an object, we move it together with the object
    if (attached != null)
      x += attached.speed;

    // Make sure the x does not go off the screen either way
    x = constrain(x, 0, width-w);
  }

  void move(float dx, float dy) {
    // We move in terms of the tile size
    x += dx * grid;
    y += dy * grid;
    attach(null);
  }
  
}
