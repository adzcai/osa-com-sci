class Board {
  PVector pos;
  int w, h;
  
  Board(int x_, int y_, int w_, int h_) {
    pos = new PVector(x_, y_);
    w = w_;
    h = h_;
  }
  
  void show() {
    fill(WHITE);
    rect(pos.x, pos.y, w, h);
  }
  
  boolean contains(float x, float y) {
    return pos.x < x && x < pos.x + w && pos.y < y && y < pos.y + h;
  }
}

class Paddle extends Board {
  PVector vel;
  
  Paddle() {
    super(0, height * 7 / 16, width / 64, height / 6);
    vel = new PVector(0, height / 64);
  }
  
  void update() {
    if (keyPressed && key == CODED) {
      if (keyCode == UP && pos.y > 0) pos.sub(vel);
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
    vel = PVector.fromAngle(random(PI / 4, -PI / 4)).setMag(r); // It scales with the size of the board
  }
  
  void show() {
    fill(WHITE);
    ellipse(pos.x, pos.y, r, r);
  }
  
  void update() {
    if (paddle.contains(pos.x - r, pos.y)) {
      vel.add(new PVector(pos.x - r - paddle.pos.x * 2, pos.y - (paddle.pos.y + paddle.h / 2))).setMag(r);
      pos.x = paddle.pos.x + paddle.w + r;
      points++;
    }
    
    if (wall.contains(pos.x + r, pos.y)) {
      vel.x *= -1;
      pos.x = wall.pos.x - r;
    }
    
    if (pos.y < 0) {
      vel.y *= -1;
      pos.y = 0;
    } else if (pos.y > height) {
      // If it hits the ground we absorb a small bit of the energy
      vel.y *= -1;
      pos.y = height;
    }
    
    if (pos.x <= 0) {
      pause();
    } else {
      pos.add(vel);
    }
  }
}
