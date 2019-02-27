// This class stores information about a solid board
class Board {
  // Keep track of the board's coordinates and dimensions
  // We store the position in a vector for easier physics manipulation.
  // The vector represents the leftmost, topmost point, midway through the depth of the box.
  PVector pos;
  float w, h, d;
  PShape obj, result;
  
  // Initialize it the same way we would a rect
  Board(float x, float y, float z, float w_, float h_, float d_) {
    pos = new PVector(x, y, z);
    w = w_;
    h = h_;
    d = d_;
    
    result = createShape(GROUP); // Create a group shape that we add...
    obj = createShape(); // The main loop
    PShape face1 = createShape(); // and the two faces to
    PShape face2 = createShape();
    
    float r = sqrt(pow(w/2, 2) + pow(d / 2, 2));
    float theta = PI / 2; // The angle that we rotate for each vertex
    
    obj.beginShape(TRIANGLE_STRIP);
    face1.beginShape();
    face2.beginShape();
    
    for (int i = 0; i < 4; i++) { // We draw each side by converting (theta, r) to Cartesian coordinates
      obj.vertex(r * cos(i * theta), 0, r * sin(i * theta));
      face1.vertex(r * cos(i * theta), 0, r * sin(i * theta));
      obj.vertex(r * cos(i * theta), h, r * sin(i * theta));
      face2.vertex(r * cos(i * theta), h, r * sin(i * theta));
    }
    
    // We connect it back to the beginning
    obj.vertex(r, 0, 0);
    obj.vertex(r, h, 0); 
    
    obj.endShape(CLOSE);
    face1.endShape(CLOSE);
    face2.endShape(CLOSE);
    
    result.addChild(obj);
    result.addChild(face1);
    result.addChild(face2);
  }
  
  // We simply draw a white rectangle wherever the board is
  void show() {
    fill(WHITE);
    rect(pos.x, pos.y, w, h);
    shape(result);
  }
  
  // A simple check to see if (x, y) is within this rectangle's boundaries
  boolean contains(PVector p) {
    return contains(p.x, p.y);
  }
  
  boolean contains(float x, float y) {
    return pos.x < x && x < pos.x + w && pos.y < y && y < pos.y + h;
  }
}

// A subclass that stores information about the player's paddle
class Paddle extends Board {
  PVector vel; // A vector to track how fast the paddle should move when the player presses the arrow keys
  
  // We don't need to accept any parameters, since we always want to start with the paddle
  // at the left of the screen and centered vertically
  Paddle() {
    super(0, height / 2 - height / 12, 0, width / 64, height / 6, height / 6);
    vel = new PVector(0, height / 64);
  }
  
  // Moves the paddle depending on the arrow keys that the user presses
  void update() {
    if (keyPressed && key == CODED) {
      // We cannot go up past the screen
      if (keyCode == UP && pos.y > 0) pos.sub(vel);
      // Or down past the screen
      else if (keyCode == DOWN && pos.y + h < height) pos.add(vel);
    }
  }
}

class Ball {
  PVector pos, vel;
  int r;
  color c;
  
  Ball() {
    r = min(width, height) / 64;
    pos = new PVector(width / 2, height / 2);
    
    // We set the angle to be inbetween 45 degrees and negative 45 degrees, facing the wall. r scales with the size of the board and seems to be a reasonable speed
    vel = PVector.fromAngle(random(PI / 4, -PI / 4)).setMag(r);
    c = WHITE;
  }
  
  void show() {
    fill(c);
    noStroke();
    ellipse(pos.x, pos.y, r, r);
  }
  
  // Called every frame as long as the game is playing, checks if the ball collides with anythin
  void update() {
    // If the leftmost point of the ball connects with the paddle
    if (paddle.contains(pos.x - r, pos.y)) {
      // First, we move the ball slightly so that it is on the paddle
      pos.x = paddle.pos.x + paddle.w + r;
      
      // Using some geometry, we find the heading of a vector that is based off both where the ball hits the paddle and the x value of the current velocity
      float heading = new PVector(-vel.x, pos.y - (paddle.pos.y + paddle.h / 2)).heading();
      
      // We flip the direction of x and add the heading mentioned above
      vel.x *= -1;
      vel.rotate(heading);
      
      // If it would cause the vel to point backwards, we simply set it to 80 degrees
      if (vel.heading() > PI/2)
        vel = PVector.fromAngle(radians(80)).setMag(vel.mag());
      if (vel.heading() < -PI/2)
        vel = PVector.fromAngle(radians(-80)).setMag(vel.mag());
        
      // The player scores a point whenever the paddle touches the ball
      points++;
      
      changeColoursIfEnabled();
    }
    
    // If the rightmost point of the ball goes past with the wall, we just flip the velocity horizontally
    if (pos.x + r > wall.pos.x) {
      vel.x *= -1;
      pos.x = wall.pos.x - r;
      changeColoursIfEnabled();
    }
    
    // We handle vertical collision similarly- if the topmost or bottommost point of the ball goes beyond the screen,
    // we set its dimensions so that it touches the edge of the screen, and flip the velocity vertically.
    if (pos.y - r < 0) {
      vel.y *= -1;
      pos.y = r;
    } else if (pos.y + r > height) {
      vel.y *= -1;
      pos.y = height - r;
    }
    
    // If the ball goes beyond the left edge of the screen (and the game isn't waiting to restart), the player has missed it.
    // We draw game over and restart the powerups
    if (pos.x - r <= 0 && resetTimer == -1) {
      resetTimer = frameCount;
      for (Powerup p : powerups) p.enabled = false;
      powerupsOnScreen.clear();
      paddle.h = height / 6;
    } else {
      pos.add(vel);
    };
  }
  
  // If the color
  void changeColoursIfEnabled() {
    for (Effect e : effects)
      if (e.desc.equals("Change color on bounce"))
        c = e.enabled ? color(random(255), random(255), random(255)) : WHITE;
  }
}
