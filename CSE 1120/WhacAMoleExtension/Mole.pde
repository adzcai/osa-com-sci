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
    hole = hole_; // Each mole needs a hole
    pos = new PVector(hole.pos.x, 0, hole.pos.y); // Sorry for the inconsistency, but we create a three dimensional vector with the hole's position
    visible = false; // They all begin off the screen
    speed = hole.r * 4 / frameRate; // The speed it goes up and down should be quite fast: in this case, about a quarter of a second
    
    // We initialize the variables that are to track its state
    startFrame = upFrame = downFrame = endFrame = 0;
    upTime = frameRate * 8; // The amount of time that the mole stays up for
    spacing = random(frameRate * 10); // We have a great range for the initial frameRate so that hopefully they start springing up apart from each other
    
    r = hole.r / 3; // The mole's radius is a third of its hole's
    maxY = -r * 2; // The maximum height that the m ole can pop up is just its head and a part of its body
    
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
    
    float whiskerLen = r * 2 / 3; // We give it whiskers
    stroke(WHITE);
    for (int i = 0; i < 3; i++) {
      float theta = (i-1) * PI / 6;
      PShape whiskerL = createShape(LINE, whiskerLen * cos(theta), whiskerLen * sin(theta), 0, 0);
      PShape whiskerR = createShape(LINE, whiskerLen * cos(theta + PI), whiskerLen * sin(theta + PI), 0, 0);
      whiskerL.translate(0, 0, r);
      whiskerR.translate(0, 0, r);
      shape.addChild(whiskerL);
      shape.addChild(whiskerR);
    }
    noStroke();
    
    PShape nose = createShape(SPHERE, r / 2);
    nose.translate(0, 0, r);
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
    return pos.x - r < x && x < pos.x + r &&
      pos.y - r < y && y < pos.y &&
      pos.z - r < z && z < pos.z + r;
  }
}
