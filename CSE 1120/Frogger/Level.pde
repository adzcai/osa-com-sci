void loadLevel(String map) { // Sets the current state to a new level using a map
  states[currentState] = null; // Unload the current state //<>// //<>//
  currentState = LEVEL; // Say that we're on a level
  states[LEVEL] = new Level(map); // Initialize the level
  getState().init();
}

String[] listLevelNames() { // Lists the levels located under data/levels
  String[] files = new File(sketchPath() + "/data/levels").list(); // by listing the files in the directory,
  ArrayList<String> ret = new ArrayList<String>(files.length); // (arraylist for dynamic size)

  for (String file : files) {
    String[] nameAndExt = split(file, "."); // (We get the name and extension by separating the file by the dot)
    if (nameAndExt[1].equals("csv")) ret.add(nameAndExt[0]); // and checking if it is a csv file
  }

  return ret.toArray(new String[ret.size()]); // return the file names
}

// The level itself also has a box, representing the box that the lanes and frog itself remain in.
public class Level extends Rectangle implements GameState {
  
  protected Frog frog;
  private Lane[] lanes;
  
  private float tileSize;
  private int lives;
  private int points;
  private int startTime, remainingTime, wonTime = -1;
  
  private final int gameTime = 30 * 1000, wonWait = 3 * 1000; // 30 seconds and 1 second respectively
  private final float alligatorChance = 0.5;

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
    for (Lane lane : lanes) lane.setBounds(x, y, w, tileSize);
  }
  
  public void init() { reset(0); }
  
  public void update() {
    if (wonTime < 0 && allDestsReached()) { // If the player has not yet won, and reaches all the destinations,
      incPoints(1000); // A thousand points
      wonTime = millis();
    }
    
    if (wonTime >= 0) {
      // If it has been *wonTime* milliseconds since the player won, we load the menu state
      if (millis() - wonTime >= wonWait) loadState(MENUSTATE);
      return;
    }
    
    for (Lane lane : lanes) lane.update(); // We update all of the lanes in the level
    frog.update(); // This just moves the frog if it is attached to a log
    
    remainingTime = (gameTime - millis() + startTime) / 1000; // Update the remainingTime
    if (remainingTime <= 0) reset(-1); // If they player has run out of time, they lose a life
  }
  
  public void show() {
    if (wonTime >= 0) {
      drawCenteredText("Game over" +
        "!\nYour Score " + points);
      return;
    }
		for (Lane lane : lanes) lane.show(); // Displaying the level
    frog.show(); // and the frog
    showInfo(); // and the info
  }

  public void handleInput() {
    if (wonTime < 0) frog.move(keyCode);
  }

  private void showInfo() {
    fill(0); // We draw a black rectangle filling the remainder of the screen to the right of the level
    rect(x + w, y, width - x - w, h);

    // We tell the users about their lives, points, and remaining time
    assets.defaultFont(height / 16);
    text("Lives\n" + lives +
      "\nPoints\n" + points +
      "\nTime\n" + remainingTime, x + w, y, width - x - w, h);
  }

  public void reset(int dLives) {
    lives += dLives;
    if (lives < 0) { // If he dies
      wonTime = millis();
      return; // Don't want to finish resetting when the frog dies
    }
    
    // We create a new frog at the center of the screen, one grid above the bottom, and one grid in sidelength
    frog = new Frog(this, (w - tileSize) / 2, h - tileSize, tileSize);
    startTime = millis();
    if (random(1) <= alligatorChance) generateAlligator();
  }

  private void generateAlligator() {
    int numDests = getDestLane().obstacles.length;
    ArrayList<Integer> possibleDests = new ArrayList<Integer>(numDests); // We store the ones that haven't been reached in an ArrayList for dynamic size

    for (int i = 0; i < numDests; i++) {
      if (getDestLane().obstacles[i].type == REACHED) continue; // Ignore the ones that have been reached

      getDestLane().obstacles[i].setType(DESTINATION);
      possibleDests.add(i); // If it has not been reached we add it to the list of possible destinations
    }

    if (possibleDests.size() <= 1) return; // The frog needs SOMEwhere to go
    
    int ind = possibleDests.get(int(random(possibleDests.size()))); // choose a random destination
    getDestLane().obstacles[ind].setType(ALLIGATOR);
  }

  private boolean allDestsReached() {
    boolean allReached = true;
      // We test each obstacle if it has been reached
      for (Obstacle endPoint : getDestLane().obstacles)
        allReached = allReached && (endPoint.type == REACHED);
    return allReached;
  }

  public Lane getDestLane() {
    for (Lane lane : lanes)
      if (lane.type == DESTINATION)
        return lane;
    return null;
  }

  public int getLives() { return lives; }
  public void setLives(int lives) { this.lives = lives; }
  public void incPoints(int k) { points += k; }
  
}
