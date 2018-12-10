class Lane extends Rectangle {

  Obstacle[] obstacles;
  int type; // e.x. SAFETY, LOG or CAR

  Lane(int index, int t, int numObstacles, int len, float spacing, float speed) {
    super(0, index*grid, width, grid); // The lane stretches across the screen, one tile high
    type = t;
    
    if (type == SAFETY) {
      obstacles = new Obstacle[0];
      col = color(0, 255, 0);
      return;
    }
    
    if (type == LOG) {
      col = color(0, 0, 255);
    }
    
    obstacles = new Obstacle[numObstacles]; // We initialize the array of obstacles
    
    float offset = random(0, 200);
    for (int i = 0; i < numObstacles; i++) // We initialize the obstacles 
      obstacles[i] = new Obstacle(offset + spacing * i, index*grid, grid*len, grid, speed);
  }

  void check(Frog frog) {
    if (type == CAR) { // If the frog hits a car, the game resets
      for (Obstacle o : obstacles)
        if (frog.intersects(o))
          resetGame();
    } else if (type == LOG) {
      boolean ok = false; // We set the frog's ok-ness to false as a default, then set it to true if he lands on a log (phew!)
      for (Obstacle o : obstacles) {
        if (frog.intersects(o)) {
          ok = true;
          frog.attach(o);
        }
      }
      if (!ok) resetGame();
    }
  }

  void run() {
    // We draw a rectangle with this lane's colour
    fill(col);
    rect(x, y, w, h);
    for (Obstacle o : obstacles) {
      o.show();
      o.update();
    }
  }
  
}
