// A generic class to store the coordinates, dimensions, and color of a rectangle,
// along with functions to draw itself and check for intersections with other rectangles
public class Rectangle {
  
  public float x, y, w, h; // These should be private but I'm too lazy to change all the usages
  protected color col;

  // If no color is passed we just set it to alpha
  public Rectangle(float x, float y, float w, float h) {
    this(x, y, w, h, color(0, 0, 0, 255));
  }

  // A pretty generic constructor. We use object oriented programming to improve clarity,
  // so "this" simply represents the instance of Rectangle that is being created.
  public Rectangle(float x, float y, float w, float h, color col) {
    this.x = x;
    this.w = w;
    this.y = y;
    this.h = h;
    this.col = col;
  }

  public boolean intersects(Rectangle other) {
    // We test if the left side of the box doesn't exceed the right side of the other box, etc. for all 4 sides
    return !(x >= other.x + other.w ||
      x + w <= other.x ||
      y >= other.y + other.h ||
      y + h <= other.y);
  }
  
  public void show() {
    // Simply fill with the colour and draw the rectangle
    fill(col);
    rect(x, y, w, h);
  }
  
}
