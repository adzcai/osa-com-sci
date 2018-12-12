// This class stores information for each lane, or row
class Lane extends Rectangle {

  Obstacle[] obstacles;
  int type; // e.x. SAFETY, LOG or CAR

  // Besides index and level, we load in the variables from a csv file (table)
  Lane(int index, Level level, int t, int numObstacles, int len, float spacing, float speed) {
    super(level.x, level.y + index * level.grid, level.w, level.grid, LANECOLORS[t]); // The lane stretches across the screen, one tile high
    type = t;
    
    // This determines the leftmost x for the obstacles
    float offset = type == DESTINATION ? level.grid * len / 2 : random(0, level.w / 4);
    obstacles = new Obstacle[numObstacles]; // We initialize the array of obstacles
    
    // We initialize the obstacles using this lane, the starting x and y, the width (determined by the specified length in tiles),
    // the heighed (the tile size of the level), the color based on the obstacles's type (set as a constant in Frogger.pde), and the speed
    for (int i = 0; i < numObstacles; i++)
      obstacles[i] = new Obstacle(this, offset + (level.w * spacing) * i, y, level.grid * len, level.grid, OBSTACLECOLORS[type], speed);
    
    // We randomly choose a square to put the alligator in
    if (type == DESTINATION) obstacles[int(random(numObstacles))].alligator = true;
  }
  
  // We check for the frog's intersection with the obstacles
  void check(Frog frog) {
    boolean ok = false; // This is only used if the type is LOG, but we need to initialize it here anyways.
    // We set the frog's ok-ness to false as a default, then set it to true if he lands on a log (phew!)
    
    for (Obstacle o : obstacles) { // We loop through the obstacles in the lane
      if (!frog.intersects(o)) continue; // We return if the frog doesn't intersect it
      
      switch (type) { // Remember, type is the type of the lane and determines what obstacles are on it
      case CAR: // If the frog hits a car, he dies and we reset
        currentLevel.lives -= 1;
        currentLevel.reset();
        break;
        
      case LOG: // He lands on a log, he's ok and we attach to it
        ok = true;
        frog.attach(o);
        break;
        
      case DESTINATION: // If he reaches one of the home points
        if (o.col == REACHED) currentLevel.reset(); // If he has already reached it, we just restart without consequences
        o.col = REACHED; // Constant initialized in Frogger.PDE
        currentLevel.reset();
        currentLevel.points += 50 + 5 * currentLevel.elapsed;
        
        boolean allReached = true;
        for (Obstacle endPoint : obstacles) allReached = allReached && (endPoint.col == REACHED);
        if (allReached) {
          currentLevel.points += 1000;
          status = WON;
        }
      }
    }
    
    // The frog landed in the water
    if (type == LOG && !ok) {
      currentLevel.lives -= 1;
      currentLevel.reset();
    }
  }
  
  void show() {
    super.show(); // We draw the lane underneath. Each lane has a given color
    for (Obstacle o : obstacles) o.show(); // Draw each of the obstacles (currently, inherited from Rectangle)
  }

  void update() {
    for (Obstacle o : obstacles) o.update(); // We update each of the obstacles, the lane doesn't need to worry too much
  }
  
}
