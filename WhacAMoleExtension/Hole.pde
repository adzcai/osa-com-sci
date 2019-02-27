// We store information about each hole
class Hole {
  PVector pos;
  float r;
  Mole mole;
  
  Hole(float x, float y) { // The hole is passed an x and y value, even though the y really represents the z.
    pos = new PVector(x, y);
    r = width / 12; // We set its radius to a fraction of the width
    mole = new Mole(this); // And initialize the mole associated with this hole
  }
  
  // Not much a hole can do besides contain a mole
  void update() {
    mole.update();
  }
  
  void show() {
    // We do a few translations to draw the hole at its given position, hovering a little above the box to be visible
    pushMatrix();
    fill(BLACK);
    rotateX(PI / 2);
    translate(pos.x, pos.y, 1);
    ellipse(0, 0, r * 2, r * 2);
    popMatrix();
    
    mole.show();
  }
}
