
class Line {
  ArrayList<Point> points;
  
  Line() {
    points = new ArrayList<Point>();
  }
  
  void show() {
    if (points.size() < 1) return; // If there are no points in the line, return
    
    for (int i = 1; i < points.size(); i++) {
      Point p = points.get(i);
      stroke(p.col);
      strokeWeight(p.dim);
      Point prev = points.get(i - 1);
      line(prev.pos.x, prev.pos.y, p.pos.x, p.pos.y);
    }
  }
  
  void update() {
    for (Point p : points) p.update();
  }
  
  void addPoint(float x, float y, float d, color c) {
    points.add(new Point(x, y, d, c));
  }
}
