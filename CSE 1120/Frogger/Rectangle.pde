class Rectangle {
  float x, y, w, h;
  color col;

  Rectangle(float x, float y, float w, float h) {
    this.x = x;
    this.w = w;
    this.y = y;
    this.h = h;
    
    col = color(200); // default value
  }
  
  void setColor(color c) {
    col = c;
  }

  boolean intersects(Rectangle other) {
    return !(x >= other.x + other.w ||
      x + w <= other.x ||
      y >= other.y + other.h ||
      y + h <= other.y);
  }
  
  void show() {
    fill(col);
    rect(x, y, w, h);
  }
}
