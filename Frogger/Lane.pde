// This class stores information for each lane, or row
public class Lane extends Rectangle {

  private int index;
  private String type, obstacleType;
  private Obstacle[] obstacles;
  private float obstacleLength, obstacleSpacing, obstacleSpeed;

  // ===== INITIALIZING THE LANE =====

  // We can construct a lane using a table row (see LevelCreator) by passing the data inside the row into the main constructor
  public Lane(int index, TableRow tr) {
    this(index, tr.getString("laneType"), tr.getString("obstacleType"), tr.getInt("numObstacles"), tr.getInt("len"), tr.getFloat("spacing"), tr.getFloat("speed"));
  }

  // Besides index, we load in the variables from a csv file (table)
  public Lane(int index, String type, String obstacleType, int numObstacles, float len, float spacing, float speed) {
    super(0, 0, 0, 0); // We don't want to initialize anything just yet
    this.index = index;
    this.type = type;
    this.obstacleType = obstacleType;
    col = assets.getLaneColor(type); // Color of the lane
    
    obstacles = new Obstacle[numObstacles]; // We initialize the array of obstacles
    obstacleLength = len;
    obstacleSpacing = spacing;
    obstacleSpeed = speed;
  }

  public void init(float x, float y, float w, float h) {
    this.x = x;
    this.y = y + index * h;
    this.w = w;
    this.h = h;

    // This determines the leftmost x for the obstacles. If it's the destination lane, we want the obstacles
    // to be spaced evenly, else we make it random
    float offset = type.equals("destination") ? w / 11 : random(w);
    
    if (type.equals("destination")) // The "obstacles" in the destination lanes are the home, there's always 5 of them spaced evenly apart at the top of the level
      for (int i = 0; i < obstacles.length; i++)
        obstacles[i] = new Obstacle(this,
          (2 * i + 1) * w / 11, 0, h * obstacleLength, h,
          0, "home"); 
    else 
      for (int i = 0; i < obstacles.length; i++) // We initialize each obstacle
        obstacles[i] = new Obstacle(this, // Using the lane's coordinates and the specified properties
          offset + (h * obstacleSpacing) * i, this.y, h * obstacleLength, h,
          obstacleSpeed, obstacleType); 
  }
  
  // ===== DRAWING THE LANE =====

  public void show() {
    super.show(); // We draw the lane underneath. Each lane has a given color
    for (Obstacle o : obstacles) o.show(); // Draw each of the obstacles
  }

  // ===== UPDATING THE LANE =====

  public void update() {
    // We update each of the obstacles, the lane doesn't need to worry too much
    for (Obstacle o : obstacles) o.update();
  }
  
  // ===== GETTERS AND SETTERS =====

  public boolean isType(String t) { return type.equals(t); }
  public int getNumObstacles() { return obstacles.length; }
  public Obstacle getObstacle(int i) { return obstacles[i]; }
  public void setObstacleType(int i, String t) { obstacles[i].setType(t); }
  
}
