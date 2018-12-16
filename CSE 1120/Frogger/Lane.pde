// This class stores information for each lane, or row
class Lane extends Rectangle {

  Obstacle[] obstacles;
  int type; // e.x. SAFETY, LOG or CAR

  // Besides index and level, we load in the variables from a csv file (table)
  Lane(int index, Level level, int t, int numObstacles, int len, float spacing, float speed) {
    // The lane stretches across the screen, one tile high
    super(level.x, level.y + index * level.grid, level.w, level.grid, laneColors[t]);
    type = t;
    
    // This determines the leftmost x for the obstacles
    float offset = type == DESTINATION ? level.grid * len / 2 : random(0, level.w / 4);
    obstacles = new Obstacle[numObstacles]; // We initialize the array of obstacles
    
    for (int i = 0; i < numObstacles; i++) {
      // We initialize the obstacles using this lane, the starting x and y, the width
      // (determined by the specified length in tiles), the height (the tile size of the level),
      obstacles[i] = new Obstacle(this, offset + (level.w * spacing) * i, y, level.grid * len, level.grid, speed, type); // the sprite based on the obstacle's type (set as a constant in Frogger.pde), and the speed
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
