// The level itself also has a box, representing the box that the lanes and frog itself remain in
public class Level extends Rectangle implements GameState {
  
  protected Frog frog;
  private Lane[] lanes;
  
  private TextBox livesTextBox, pointsTextBox, timeTextBox, gameOver;
  
  private float tileSize;
  private int lives;
  private int points;
  private int startTime, remainingTime, wonTime = -1;
  
  private final int GAMETIME = 30 * 1000; // The user has 30 seconds to get the frog home
  private final int WONWAIT = 3 * 1000; // We show the game over message for one second 
  private final float ALLIGATORCHANCE = 0.5; // Half chance of spawning an alligator each reset
  private final float LADYBUGCHANCE = 0.3; // About one third chance of a ladybug each reset

  // ===== INITIALIZING THE LEVEL =====

  public Level(String map) { // default constructor with just the map
    this(0, 0, width * 4 / 5, height, map);
  }

  public Level(float x, float y, float w, float h, String map) { // We initialize the level like a rectangle,
    // except also with the path to the csv file containing the data for the map
    super(x, y, w, h, color(0));
    lives = 3;
    points = 0;
    
    lanes = assets.loadLanes(map);
    tileSize = height / lanes.length;
    for (Lane lane : lanes) lane.init(x, y, w, tileSize);
    
    float spacing = h / 7;
    livesTextBox = new TextBox(x + w, y + spacing, width - x - w, spacing, "Lives: " + lives);
    pointsTextBox = new TextBox(x + w, y + spacing * 3, width - x - w, spacing, "Points: " + points);
    timeTextBox = new TextBox(x + w, y + spacing * 5, width - x - w, spacing, "Time: " + GAMETIME);
    gameOver = new TextBox(0, 0, width, height / 2, "Game over!");
  }
  
  public void init() { reset(0); }

  // Changes number of lives if passed, creates a new frog and possibly generates an alligator
  public void reset(int dLives) {
    lives += dLives;
    livesTextBox.setText("Lives: " + lives);

    if (lives <= 0) { // If he dies
      wonTime = millis();
      return; // Don't want to finish resetting when the frog dies
    }
    
    // We create a new frog at the center of the screen, one grid above the bottom, and one grid in sidelength
    frog = new Frog(this, (w - tileSize) / 2, h - tileSize, tileSize);
    startTime = millis();
    
    // Resetting the destinations/generating an alligator
    int numDests = 5;
    ArrayList<Integer> possibleDests = new ArrayList<Integer>(numDests); // We store the ones that haven't been reached in an ArrayList for dynamic size

    // Here we reset the destination lane
    for (int i = 0; i < numDests; i++) {
      if (getDestLane().getObstacle(i).isType("reached")) continue; // Ignore the ones that have been reached

      getDestLane().setObstacleType(i, "home"); // Set the unreached ones to home
      possibleDests.add(i); // If it has not been reached we add it to the list of possible destinations
    }
    
    int ind;
    // If the probability that an alligator is generated is chosen and there are at least two remaining destinations, we generate one
    if (random(1) <= ALLIGATORCHANCE && possibleDests.size() > 1) {
      ind = possibleDests.get(int(random(possibleDests.size()))); // choose a random destination (ack lots of end brackets I know)
      getDestLane().setObstacleType(ind, "alligator");
      possibleDests.remove(new Integer(ind)); // We need to make a new integer (an object, not primitive) with the same value so that it removes by value and not index
    }
    
    if (random(1) <= LADYBUGCHANCE && possibleDests.size() > 0) { // If there is still a space left and the ladyBugChance is met, we create a ladybug as well
      ind = possibleDests.get(int(random(possibleDests.size())));
      getDestLane().setObstacleType(ind, "ladybug");
    }
  }

  // ===== DRAWING THE LEVEL =====

  public void show() {
    background(0);
    if (wonTime >= 0) {
      gameOver.show();
      new TextBox(0, height / 2, width, height / 2, "Your Score: " + points).show();
      return;
    }
		for (Lane lane : lanes) lane.show(); // Displaying the level
    frog.show(); // and the frog
    
    // We tell the users about their lives, points, and remaining time
    
    fill(0);
    rect(x + w, y, width - x - w, h); // We draw a black rectangle behind the buttons to cover up the obstacles that run of the edge
    livesTextBox.show();
    pointsTextBox.show();
    timeTextBox.show();
  }

  // ===== UPDATING THE LEVEL =====
  
  public void update() {
    if (wonTime < 0 && allDestsReached()) { // If the player has not yet won, and reaches all the destinations,
      incPoints(1000); // A thousand points
      wonTime = millis();
    }
    
    if (wonTime >= 0) {
      // If it has been *wonTime* milliseconds since the player won, we load the menu state
      if (millis() - wonTime >= WONWAIT) loadState(MENUSTATE);
      return;
    }
    
    for (Lane lane : lanes) lane.update(); // We update all of the lanes in the level
    frog.update(); // This just moves the frog if it is attached to a log
    
    remainingTime = (GAMETIME - millis() + startTime) / 1000; // Update the remainingTime
    if (remainingTime <= 0) reset(-1); // If they player has run out of time, they lose a life

    // Update the status boxes
    pointsTextBox.setText("Points: " + points);
    timeTextBox.setText("Time: " + remainingTime);
  }

  public void handleInput() {
    if (wonTime < 0) frog.move(keyCode);
    else // The level just ended, we just skip to the main menu
      loadState(MENUSTATE);
  }

  // ===== GETTERS AND SETTERS =====

  private boolean allDestsReached() {
    boolean allReached = true;
      // We test each obstacle if it has been reached
      for (Obstacle endPoint : getDestLane().obstacles)
        allReached = allReached && (endPoint.isType("reached"));
    return allReached;
  }
  public Lane getDestLane() { // Get this level's destination lane
    for (Lane lane : lanes)
      if (lane.isType("destination"))
        return lane;
    return null;
  }
  public int getLives() { return lives; }
  public void setLives(int lives) { this.lives = lives; }
  public void incPoints(int k) { points += k; }
  
}
