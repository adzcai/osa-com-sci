class Hammer {
  PVector pos;
  float handleR, handleLen, headR, headLen;
  int direction;
  float angle, speed;
  PShape shape;
  
  // A pretty standard constructor where we initialize variables and the shape of the hammer
  Hammer() {
    pos = new PVector();
    handleR = width / 24;
    handleLen = handleR * 6; // the length is 4 times the radius
    speed = (PI / 2) / frameRate; // We cover PI / 2 (90 degrees) in one second
    angle = 0;
    
    shape = createShape(GROUP); // We create the shape of the hammer by combining two rectangles
    
    // The handle
    PShape handle = cylinder(24, handleR, handleLen);
    handle.translate(0, -handleLen * 3 / 4); // (0, 0) is 3 quarters of the way down the cylinder, in the center
    handle.setFill(BROWN);
    
    // And the head
    headR = handleR * 3 / 2; // It's thicker than the handle
    headLen = handleLen; // But not as long
    PShape head = cylinder(24, headR, headLen);
    head.setFill(BLACK);
    
    head.translate(0, -handleLen / 2); // We shift it so that the center of the head lines up with the top of the handle
    head.rotateX(-PI / 2);
    head.translate(0, -handleLen * 3 / 4);
    
    shape.addChild(handle);
    shape.addChild(head);
  }
  
  void update() {
    pos = new PVector(map(mouseX, 0, width, -width / 2, width / 2), -handleLen / 2, map(mouseY, 0, height, -height / 2, height / 2));
    
    if (direction == 1) {
      angle += speed;
      if (angle >= PI / 2) direction = -1;
    } else if (direction == -1) {
      angle -= speed;
      if (angle <= 0) direction = 0;
    }
    
    for (Hole h : holes) {
      float rad = sqrt(pow(handleLen * 3 / 4, 2) + pow(headLen / 2, 2)); // Pythagorean theorem to calculate the distance between the point where the user holds the handle and the tip of the head
      float theta = hammer.angle + atan((headLen / 2) / (handleLen * 3 / 4)) - PI / 2;
      float x = pos.x + rad * cos(theta);
      float z = pos.z + rad * sin(theta);
      
      if (direction == 1 && h.mole.contains(x, pos.y, z) && h.mole.direction < 1) {
        points += 1;
        h.mole.direction = 1;
        h.mole.shape.setFill(GREEN);
      }
    }
  }
  
  void show() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    rotateX(hammer.angle);
    shape(shape);
    popMatrix();
  }
}
