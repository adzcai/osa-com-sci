void initPowerups() {
  powerups.add(new Powerup("Grow paddle", "redmushroom.png", width / 32, width / 32, 5) {
    @Override
    public void update() {
      if (enabled)
        paddle.h = height / 4;
      else
        paddle.h = height / 6;
    }
  });
  
  powerups.add(new Powerup("Speed up", "speedup.png", width / 32, width / 32, 10) {
    @Override
    public void update() {
      if (enabled) // We simply speed up the ball
        ball.vel.setMag(ball.r * 2);
      else
        ball.vel.setMag(ball.r);
    }
  });
  
  powerups.add(new Powerup("Slow down", "slowdown.png", width / 32, width / 32, 10) {
    @Override
    public void update() {
      if (enabled) { // We simply speed up the ball
        ball.vel.setMag(ball.r / 2);
        getPowerupByName("Speed up").enabled = false;
      } else
        ball.vel.setMag(ball.r);
    }
  });
}

Powerup getPowerupByName(String name) {
  for (Powerup p : powerups)
    if (p.desc.equals(name))
      return p;
  return null;
}

// These powerups should be sent out by the wall. Anonymous subclasses are enabled
class Powerup extends Effect {
  float w, h;
  
  String imgPath;
  PImage img;
  
  float rarity; // A measure of how often the powerup is given
  
  Powerup(String desc_, String imgPath_, float w_, float h_, float rarity_) {
    super(desc_);
    
    w = w_;
    h = h_;
    
    imgPath = imgPath_;
    img = loadImage(imgPath);
    
    rarity = rarity_ * frameRate;
  }
}

class PowerupIcon extends Powerup {
  PVector pos, vel;
  
  PowerupIcon(Powerup p, float x_, float y_) {
    super(p.desc, p.imgPath, p.w, p.h, p.rarity);
    
    pos = new PVector(x_, y_);
    
    // We set the velocity to a random horizontal speed so that it takes 2 to 5 seconds, with no vertical speed
    vel = new PVector(-random(width / (5 * frameRate), width / (2 * frameRate)), 0);
  }
  
  // We draw the powerup's image at a certain point
  void show() {
    image(img, pos.x, pos.y, w, h);
  }
}
