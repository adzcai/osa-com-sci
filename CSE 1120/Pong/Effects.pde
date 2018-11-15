// We initialize a variety of effects that the player can toggle on the home screen
void initEffects() {
  effects.add(new Effect("Streak") {
    PVector pBallPos = null;
    
    @Override
    public void update() {
      if (!enabled) return;
      
      // If the previous ball position hasn't been initialized, we do so
      if (pBallPos == null) pBallPos = ball.pos;
      
      // We draw a white line between the ball and its previous position
      stroke(ball.c);
      line(ball.pos.x, ball.pos.y, pBallPos.x, pBallPos.y);
      
      // We set the trail far behind the ball
      pBallPos = new PVector(ball.pos.x - 3 * ball.vel.x, ball.pos.y - 3 * ball.vel.y);
    }
  });
  
  // This effect creates powerup icons at certain intervals when turned on
  effects.add(new Effect("Powerups") {
    float[] timers;
    
    @Override
    public void update() {
      // If the timers are not initialized, we simply set them all to 0
      if (timers == null) {
        timers = new float[powerups.size()];
        for (int i = 0; i < timers.length; i++)
          timers[i] = 0;
      }

      if (!enabled) { // We remove all the icons if the effect is disabled
        powerupsOnScreen.clear();
      } else { // Otherwise, we create powerupicons of a certain type based on the powerup's rarity
        for (int i = 0; i < powerups.size(); i++) {
          if (frameCount - timers[i] > powerups.get(i).rarity) {
            powerupsOnScreen.add(new PowerupIcon(powerups.get(i), width, random(height)));
            timers[i] = frameCount;
          }
        }
      }
    }
  });
  
  // See GameElements.pde line 126
  effects.add(new Effect("Change color on bounce"));
}

// A simple class, most of the bulk is in the bodies of the anonymous subclasses
class Effect {
  String desc;
  boolean enabled;
  
  Effect(String desc_) {
    desc = desc_;
    enabled = false;
  }
  
  // Called if the effect is enabled
  void update() {}
}
