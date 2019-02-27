// This class stores information about a solid board
class Board {
  // Keep track of the board's coordinates and dimensions
  // We store the position in a vector for easier physics manipulation
  PVector pos;
  int w, h;
  
  // Initialize it the same way we would a rect
  Board(int x_, int y_, int w_, int h_) {
    pos = new PVector(x_, y_);
    w = w_;
    h = h_;
  }
  
  // We simply draw a white rectangle wherever the board is
  void show() {
    fill(WHITE);
    rect(pos.x, pos.y, w, h);
  }
  
  // A simple check to see if (x, y) is within this rectangle's boundaries
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
    super(0, height * 7 / 16, width / 64, height / 6);
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
  
  Ball() {
    r = min(width, height) / 64;
    pos = new PVector(width / 2, height / 2);
    
    // We set the angle to be inbetween 45 degrees and negative 45 degrees, facing the wall. r scales with the size of the board and seems to be a reasonable speed
    vel = PVector.fromAngle(random(PI / 4, -PI / 4)).setMag(r);
  }
  
  void show() {
    fill(WHITE);
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
      if (abs(vel.heading()) > PI/2)
        vel = PVector.fromAngle(radians(80)).setMag(r);
        
      // The player scores a point whenever the paddle touches the ball
      points++;
    }
    
    // If the rightmost point of the ball connects with the wall, we just flip the velocity horizontally
    if (wall.contains(pos.x + r, pos.y)) {
      vel.x *= -1;
      pos.x = wall.pos.x - r;
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
    
    // If the ball goes beyond the left edge of the screen (and the game isn't waiting to restart), the player has missed it and we pause
    if (pos.x - r <= 0 && resetTimer == -1) {
      fill(WHITE);
      text("GAME OVER", width / 2, height / 2);
      resetTimer = frameCount;
    } else {
      pos.add(vel);
    }
  }
  
  //PVector getCorner(int direction) {
  //  float x, y;
    
  //  switch (direction) {
  //    case UP:
  //      x = pos.x;
  //      y = pos.y - r;
  //      break;
  //    case RIGHT:
  //      x = pos.x + r;
  //      y = pos.y;
  //      break;
  //    case DOWN:
  //      x = pos.x;
  //      y = pos.y + r;
  //      break;
  //    case LEFT:
  //      x = pos.x - r;
  //      y = pos.y;
  //      break;
  //    default:
  //      throw new Error("Invalid direction passed");
  //  }
    
  //  return new PVector(x, y);
  //}
}
