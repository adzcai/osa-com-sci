class Hammer {
  float w, len, cornerR;
  int direction;
  float angle, speed;
  PShape shape;
  
  // A pretty standard constructor where we initialize variables and the shape of the hammer
  Hammer() {
    w = width / 24;
    len = w * 4;
    cornerR = w / 8;
    speed = PI / 2 / frameRate;
    angle = 0;
    
    shape = createShape(GROUP); // We create the shape of the hammer by combining two rectangles
    
    // The handle
    PShape handle = createShape();
    
    // 24 is the number of sides we use to make a realistic triangle
    float theta = 2 * PI / 24;
    handle.beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < 25; i++) {
      float x = cos(i * theta) * w;
      float y = sin(i * theta) * w;
      handle.vertex(x, y, len);
      handle.vertex(x, y, -len);
    }
    handle.endShape(CLOSE); 
    
    // And the head
    PShape head = createShape(RECT, -w, -len + w, w * 2, w, cornerR);
    head.setFill(BLACK);
    shape.addChild(head);
  }
  
  void update() {
    if (direction == 1) {
      angle += speed;
      if (angle >= PI / 2) direction = -1;
    } else if (direction == -1) {
      angle -= speed;
      if (angle <= 0) direction = 0;
    }
    
    for (Hole h : holes) {
      float r = sqrt(pow(len - w, 2) + pow(w, 2));
      float theta = hammer.angle + atan(w / (len - w)) - PI/2;
      float x = mouseX + r * cos(theta);
      float y = mouseY + r * sin(theta);
      
      if (direction == 1 && h.mole.contains(x, y) && h.mole.direction < 1) {
        points += 1;
        h.mole.direction = 1;
      }
    }
  }
  
  void show() {
    pushMatrix();
    translate(mouseX, mouseY);
    rotate(hammer.angle);
    shape(shape);
    popMatrix();
  }
}

class Hole {
  PVector pos;
  float r;
  Mole mole;
  PShape coverShape;
  
  Hole(float x, float y) {
    pos = new PVector(x, y);
    r = width / 16;
    mole = new Mole(this);
    
    // We create a shape that covers up the bottom of the mole
    coverShape = createShape();
    coverShape.beginShape();
    coverShape.fill(BG_COLOR);
    coverShape.noStroke();
    coverShape.vertex(pos.x - r, pos.y + mole.r * 6);
    for (float theta = PI; theta >= 0; theta -= PI / 16) {
      coverShape.vertex(pos.x + r * cos(theta), pos.y + r * sin(theta));
    }
    coverShape.vertex(pos.x + r, pos.y + mole.r * 6);
    coverShape.endShape(CLOSE);
  }
  
  void update() {
    mole.update();
  }
  
  void show() {
    fill(BLACK);
    ellipse(pos.x, pos.y, r * 2, r * 2);
    mole.show();
    shape(coverShape);
  }
}

class Mole {
  boolean visible;
  PVector pos;
  float r;
  
  float speed;
  Hole hole;
  
  int direction;
  int startFrame, upFrame, downFrame, endFrame;
  float upTime;
  float spacing;
  
  PShape shape;
  
  Mole(Hole hole_) {
    hole = hole_;
    pos = new PVector(hole.pos.x, hole.pos.y + hole.r);
    visible = false;
    speed = hole.r * 4 / frameRate;
    
    // We want the mole to stay up for a second, and appear every 2 seconds
    startFrame = upFrame = downFrame = endFrame = 0;
    upTime = frameRate * 8;
    spacing = random(frameRate * 10); // We have a great range for the initial frameRate so that hopefully they start springing up
    // apart from each other
    
    r = hole.r * 2 / 3;
    
    // We create the shape of the mole-- basically a stretched out sausage made of a square with a circle on two opposite ends
    shape = createShape(GROUP);
    PShape head = createShape(ELLIPSE, 0, 0, r * 2, r * 2);
    shape.addChild(head);
    PShape body = createShape(RECT, -r, 0, r * 2, r * 3);
    shape.addChild(body);
    PShape tail = createShape(ELLIPSE, 0, r * 3, r * 2, r * 2);
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
        if (pos.y <= hole.pos.y - hole.r) { // If the mole reaches the top
          pos.y = hole.pos.y - hole.r; // We set it to the top so that it does not go past
          direction = 0; // Stop it from moving
          upFrame = frameCount; // Record the current frame
        }
      } else if (direction == 1) {
        pos.y += speed;
        if (pos.y >= hole.pos.y + hole.r) { // If the mole has retreated back into the hole
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
    translate(pos.x, pos.y);
    shape(shape);
    popMatrix();
  }
  
  boolean contains(float x, float y) {
    return pos.x - r < x && x < pos.x + r &&
      pos.y - r < y && y < pos.y;
  }
}
