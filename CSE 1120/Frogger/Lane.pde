// This class stores information for each lane, or row
public class Lane extends Rectangle {

  private int index;
  private int type; // e.x. SAFETY, LOG or CAR

  private Obstacle[] obstacles;
  private int obstacleLength;
  private float obstacleSpacing;
  private float obstacleSpeed;

  // Besides index, we load in the variables from a csv file (table)
  public Lane(int index, int type, int numObstacles, int len, float spacing, float speed) {
    super(0, 0, 0, 0);
    this.index = index;
    this.type = type;
    col = assets.laneColors[type];

    obstacles = new Obstacle[numObstacles]; // We initialize the array of obstacles
    obstacleLength = len;
    obstacleSpacing = spacing;
    obstacleSpeed = speed;
  }
  
  public void show() {
    super.show(); // We draw the lane underneath. Each lane has a given color
    for (Obstacle o : obstacles) o.show(); // Draw each of the obstacles (currently, inherited from Rectangle)
  }

  public void update() {
    // We update each of the obstacles, the lane doesn't need to worry too much
    for (Obstacle o : obstacles) o.update();
  }

  public void setBounds(Level level) {
    x = level.x;
    y = level.y + index * level.tileHeight;
    w = level.w;
    h = level.tileHeight;

    // This determines the leftmost x for the obstacles. If it's the destination lane, we want the obstacles
    // to be spaced evenly, else we make it random
    float offset = type == DESTINATION ? level.tileWidth * obstacleLength / 2 : random(level.tileWidth / 4);
    
    for (int i = 0; i < obstacles.length; i++)
      // We initialize the obstacles using this lane, the starting x and y, the width
      // (determined by the specified length in tiles), the height (the tile size of the level),
      // the sprite based on the obstacle's type (set as a constant in Frogger.pde), and the speed
      obstacles[i] = new Obstacle(this,
        offset + (level.tileWidth * obstacleSpacing) * i, y, level.tileWidth * obstacleLength, level.tileHeight,
        obstacleSpeed, type); 
  }
  
}
