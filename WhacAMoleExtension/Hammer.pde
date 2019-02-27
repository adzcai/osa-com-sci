// A class to store information about the hammer
class Hammer {
  PVector pos;
  float handleR, handleLen, headR, headLen;
  int direction;
  float angle, speed;
  PShape shape;
  
  // A pretty standard constructor where we initialize variables and the shape of the hammer
  Hammer() {
    pos = new PVector();
    speed = (PI / 2) / frameRate; // We cover PI / 2 (90 degrees) per second
    angle = 0; // Set the starting angle to 0
    shape = createShape(GROUP); // We create the shape of the hammer by combining two rectangles
    
    handleR = width / 24;
    handleLen = handleR * 6; // the length is 4 times the radius
    PShape handle = cylinder(24, handleR, handleLen); // A vertical cylinder; the center of the top face is at (0, 0)
    handle.translate(0, -handleLen * 3 / 4); // Now, (0, 0) is 3 quarters of the way down the cylinder, in the center
    handle.setFill(BROWN); // Wooden handle
    
    // Add the head of the hammer
    headR = handleR * 3 / 2; // It's thicker than the handle
    headLen = handleLen; // But not as long
    PShape head = cylinder(24, headR, headLen);
    head.translate(0, -handleLen / 2); // We center the head at (0, 0) so that the rotation doesn't move it
    head.rotateX(-PI / 2); // Make it horizontal
    head.translate(0, -handleLen * 3 / 4); //  We shift it so that the center of the head lines up with the top of the handle
    head.setFill(BLACK);
    
    shape.addChild(handle);
    shape.addChild(head); // And our shape is fully finished
  }
  
  void update() {
    // We map the mouseX and mouseY to range across the width and height of the game box respectively
    pos = new PVector(map(mouseX, 0, width, -width / 2, width / 2), -handleLen / 2, map(mouseY, 0, height, -height / 2, height / 2));
    
    if (direction == 1) { // Moving downwards
      angle += speed; // We continue swinging it
      if (angle >= PI / 2) direction = -1; // If we go past 90 degrees, we reverse direction
    } else if (direction == -1) { // Moving upwards
      angle -= speed;
      if (angle <= 0) direction = 0; // If we have fully recovered, we stop swinging
    }
    
    for (Hole h : holes) { // This loop tests each of the holes if the tip of the hammer has hit it
      float rad = sqrt(pow(handleLen * 3 / 4, 2) + pow(headLen / 2, 2)); // Pythagorean theorem to calculate the distance between the point where the user holds the handle and the tip of the head
      float theta = hammer.angle + atan((headLen / 2) / (handleLen * 3 / 4));
      float y = pos.y - rad * cos(theta);
      float z = pos.z - rad * sin(theta);
      
      // Instead of only testing one point (which I did earlier and was inaccurate), we test four points around the top of the handle
      boolean hit = h.mole.contains(pos.x - headR, y, z) || h.mole.contains(pos.x + headR, y, z) || h.mole.contains(pos.x, y, z + headR) || h.mole.contains(pos.x, y, z - headR);
      
      if (direction == 1 && hit && h.mole.direction < 1) { // If the hammer is swinging down and the mole isn't going down
        points += 1; // We give the player a point
        direction = -1; // Make the hammer recoil
        h.mole.direction = 1; // And send the mole down
      }
    }
  }
  
  // We use some simple transformations and draw the hammer where it's supposed to be, with a quarter from the bottom on the cursor
  void show() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    rotateX(hammer.angle);
    shape(shape);
    popMatrix();
  }
}
