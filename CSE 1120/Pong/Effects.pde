void initEffects() {
  effects.add(new Effect("Streak") {
    PVector pBallPos = null;
    
    @Override
    public void update() {
      if (!enabled) return;
      
      // If the previous ball position hasn't been initialized, we do so
      if (pBallPos == null) pBallPos = ball.pos;
      
      // We draw a white line between the ball and its previous position
      stroke(WHITE);
      line(ball.pos.x, ball.pos.y, pBallPos.x, pBallPos.y);
      
      // We set the trail far behind the ball
      pBallPos = new PVector(ball.pos.x - 3 * ball.vel.x, ball.pos.y - 3 * ball.vel.y);
    }
  });
  
  effects.add(new Effect("Change color on bounce"));
}

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
