// This class stores information for each lane, or row
public class Lane extends Rectangle {

  private int index;
  private int type; // see Assets.pde

  private Obstacle[] obstacles;
  private float obstacleLength;
  private float obstacleSpacing;
  private float obstacleSpeed;

  // Besides index, we load in the variables from a csv file (table)
  public Lane(int index, int type, int numObstacles, float len, float spacing, float speed) {
    super(0, 0, 0, 0); // We don't want to initialize anything just yet
    this.index = index;
    this.type = type;
    col = assets.laneColors[type]; // Color of the lane

    obstacles = new Obstacle[numObstacles]; // We initialize the array of obstacles
    obstacleLength = len;
    obstacleSpacing = spacing;
    obstacleSpeed = speed;
  }
  
  public void show() {
    super.show(); // We draw the lane underneath. Each lane has a given color
    for (Obstacle o : obstacles) o.show(); // Draw each of the obstacles
  }

  public void update() {
    // We update each of the obstacles, the lane doesn't need to worry too much
    for (Obstacle o : obstacles) o.update();
  }

  public void setBounds(float x, float y, float w, float h) {
    this.x = x;
    this.y = y + index * h;
    this.w = w;
    this.h = h;

    // This determines the leftmost x for the obstacles. If it's the destination lane, we want the obstacles
    // to be spaced evenly, else we make it random
    float offset = type == DESTINATION ? h * obstacleLength / 2 : random(h / 4);
    
    for (int i = 0; i < obstacles.length; i++)
      // We initialize the obstacles using this lane, the starting x and y, the width
      // (determined by the specified length in tiles), the height (the tile size of the level),
      // the sprite based on the obstacle's type (set as a constant in Frogger.pde), and the speed
      obstacles[i] = new Obstacle(this,
        offset + (h * obstacleSpacing) * i, this.y, h * obstacleLength, h,
        obstacleSpeed, type); 
  }
  
}
