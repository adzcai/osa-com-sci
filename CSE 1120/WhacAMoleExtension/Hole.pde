class Hole {
  PVector pos;
  float r;
  Mole mole;
  
  Hole(float x, float y) {
    pos = new PVector(x, y);
    r = width / 16;
    mole = new Mole(this);
  }
  
  // Not much a hole can do besides contain a mole
  void update() {
    mole.update();
  }
  
  void show() {
    pushMatrix();
    fill(BLACK);
    rotateX(PI / 2);
    translate(pos.x, pos.y - height / 64);
    ellipse(0, 0, r * 2, r * 2);
    popMatrix();
    
    mole.show();
  }
}
