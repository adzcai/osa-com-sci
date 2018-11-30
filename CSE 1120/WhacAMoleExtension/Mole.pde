class Mole {
  boolean visible;
  PVector pos;
  float r;
  
  float maxY;
  
  float speed;
  Hole hole;
  
  int direction;
  int startFrame, upFrame, downFrame, endFrame;
  float upTime;
  float spacing;
  
  PShape shape;
  
  Mole(Hole hole_) {
    hole = hole_;
    pos = new PVector(hole.pos.x, 0, hole.pos.y);
    visible = false;
    speed = hole.r * 4 / frameRate;
    
    // We want the mole to stay up for a second, and appear every 2 seconds
    startFrame = upFrame = downFrame = endFrame = 0;
    upTime = frameRate * 8;
    spacing = random(frameRate * 10); // We have a great range for the initial frameRate so that hopefully they start springing up
    // apart from each other
    
    r = hole.r * 2 / 3;
    maxY = -r * 2;
    
    // We create the shape of the mole-- basically a stretched out sausage made of a square with a circle on two opposite ends
    shape = createShape(GROUP);
    PShape head = createShape(SPHERE, r * 2);
    shape.addChild(head);
    PShape body = cylinder(24, r * 2, r * 3);
    shape.addChild(body);
    PShape tail = createShape(SPHERE, r * 2);
    tail.translate(0, r * 3);
    shape.addChild(tail);
    shape.setFill(BROWN);
    
    float whiskerLen = r * 2 / 3;
    stroke(WHITE);
    for (int i = 0; i < 3; i++) {
      float theta = (i-1) * PI / 6;
      PShape whiskerL = createShape(LINE, whiskerLen * cos(theta), whiskerLen * sin(theta), 0, 0);
      PShape whiskerR = createShape(LINE, whiskerLen * cos(theta + PI), whiskerLen * sin(theta + PI), 0, 0);
      shape.addChild(whiskerL);
      shape.addChild(whiskerR);
    }
    noStroke();
    
    PShape nose = createShape(ELLIPSE, 0, 0, r / 2, r / 2);
    nose.setFill(PINK);
    shape.addChild(nose);
  }
  
  void update() {
    if (!visible) { // If the mole is currently "underground"
      if (frameCount - endFrame >= spacing) { // If enough time has passed since it went down
        visible = true; // Make it visible
        direction = -1; // We make it start going up
        startFrame = frameCount; // Record the current frame
        spacing = random(frameRate * 2, frameRate * 6); // We set the spacing to a new random number of seconds between 6 and 8
      }
    } else { // The mole is above ground
      // If the mole has been up for long enough, we start moving it down
      if (upFrame > startFrame && frameCount - upFrame >= upTime) direction = 1;
      
      // We move the mole depending on its direction
      if (direction == -1) {
        pos.y -= speed;
        if (pos.y <= maxY) { // If the mole reaches the top
          pos.y = maxY; // We set it to the top so that it does not go past
          direction = 0; // Stop it from moving
          upFrame = frameCount; // Record the current frame
        }
      } else if (direction == 1) {
        pos.y += speed;
        if (pos.y >= r) { // If the mole has retreated back into the hole
          visible = false; // We set its visibility to false
          direction = 0; // We stop it from moving
          endFrame = frameCount; // And record the current frame
        }
      }
    }
  }
  
  void show() {
    if (!visible) return;
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    shape(shape);
    popMatrix();
  }
  
  boolean contains(float x, float y, float z) {
    println("pos.x - r", pos.x - r, "x", x, "pos.x + r", pos.x + r);
    println("pos.y - r", pos.y - r, "y", y, "pos.y", pos.y);
    println("pos.z - r", pos.z - r, "z", z, "pos.z + r", pos.z + r);
    return pos.x - r < x && x < pos.x + r &&
      pos.y - r < y && y < pos.y &&
      pos.z - r < z && z < pos.z + r;
  }
}
