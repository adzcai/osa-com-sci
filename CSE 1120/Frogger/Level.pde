// The level itself also has a box, representing the box that the lanes and frog itself remain in.
public abstract class Level extends Rectangle implements GameState {
  
  private Frog frog;
  private Lane[] lanes;
  
  private float tileWidth, tileHeight;
  private int lives;
  private int points;
  private int startTime, remainingTime;

  private float xOffset, yOffset;
  
  private final int gameTime = 30 * 1000; // 30 seconds
  private final float alligatorChance = 0.5;

  public Level(float x, float y, float w, float h, float tileWidth, float tileHeight, String map) { // We initialize the level like a rectangle,
    // except also with the path to the csv file containing the data for the map
    super(x, y, w, h, color(0));
    this.tileWidth = tileWidth;
    this.tileHeight = tileHeight;
    
    lanes = assets.loadLanes(map);
    for (Lane lane : lanes) lane.setBounds(this);

    lives = 3;
    points = 0;
    xOffset = 0;
    yOffset = 0;
  }
  
  public void init() { reset(0); }
  
  public void update() {
    for (Lane lane : lanes) lane.update(); // We update all of the lanes in the level
    frog.update(); // This just moves the frog if it is attached to a log
    centerOn(frog);
    
    remainingTime = (gameTime - millis() + startTime) / 1000; // Update the remainingTime
    if (remainingTime <= 0) reset(-1); // If they player has run out of time, they lose a life
  }
  
  public void show() {
		int firstRow = int(max(0, yOffset / tileHeight));
		int lastRow = int(min(height, (yOffset + h) / tileHeight + 1));
    int firstCol = int(max(0, xOffset / tileWidth));
		int lastCol = int(min(width, (xOffset + w) / tileWidth + 1));
		
		for (int r = firstRow; r < min(lastRow, lanes.length); r++) {
			for (int c = firstCol; c < lastCol; c++) {
        pushMatrix();
        // We translate based on the offset and draw the lane
        translate(c * tileWidth - xOffset, r * tileHeight - yOffset);
				lanes[r].show();
        popMatrix();
      }
    }

    frog.show(); // and the frog
    showInfo(); // and the info
  }

  public void handleInput() {
    getLevel().frog.move(keyCode);
  }

  private void showInfo() {
    fill(0); // We draw a black rectangle filling the remainder of the screen to the right of the level
    rect(x + w, y, width - x - w, h);

    // We tell the users about their lives, points, and remaining time
    fill(255);
    textAlign(CENTER, CENTER);
    textFont(assets.arcadeFont, height / 16);
    text("Lives\n" + lives +
      "\nPoints\n" + points +
      "\nTime\n" + remainingTime, x + w, y, width - x - w, h);
  }

  public void reset(int dLives) {
    lives += dLives;
    if (lives < 0) { // If he dies
      drawCenteredText("Game over" +
        "!\nYour Score " + points +
        "\nPress any key to restart");
      paused = true;
      return; // Don't want to finish resetting when the frog dies
    }
    
    // We create a new frog at the center of the screen, one grid above the bottom, and one grid in sidelength
    frog = new Frog(this, (w - tileWidth) / 2, h - tileWidth, tileHeight);
    startTime = millis();
    if (random(1) <= alligatorChance) generateAlligator();
  }

  private void generateAlligator() {
    ArrayList<Integer> possibleDests = new ArrayList<Integer>(getDestLane().obstacles.length); // We store the ones that haven't been reached in an ArrayList for dynamic size

    for (int i = 0; i < getDestLane().obstacles.length; i++) {
      if (getDestLane().obstacles[i].type == REACHED) continue; // Ignore the ones that have been reached

      getDestLane().obstacles[i].type = DESTINATION;
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

  private void checkBounds() {
    xOffset = constrain(xOffset, 0, w);
    yOffset = constrain(yOffset, 0, h);
  }

  private void centerOn(Rectangle r) {
    xOffset = (r.x + r.w / 2) - w / 2;
    yOffset = (h - y) / 2;
  }
  
}

// ===============
// LEVELS
// ===============

public class StartScreen extends Level {

  public StartScreen() {
    super(0, 0, width, height, width * 4 / 5 / 16, height / 11, "levels/startscreen.csv");
    setLives(9999);
  }

  public void update() {
    super.update();
    if (random(1) <= 0.1) { // 10% chance of moving the frog
      int d = 0;
      switch (int(random(4))) {
        case 0: d = UP; break;
        case 1: d = DOWN; break;
        case 2: d = LEFT; break;
        case 3: d = RIGHT; break;
      }
      getLevel().frog.move(d);
    }
  }

  public void show() {
    super.show();
    textAlign(CENTER, CENTER);
    textFont(assets.arcadeFont, height / 8);
    text("FROGGER", width / 2, height / 3);
    
    textFont(assets.arcadeFont, height / 12);
    text("By Alexander Cai", width / 2, height / 2);
    text("Press any key to begin", width / 2, height * 2 / 3);
  }

  public void handleInput() { // No matter what key is pressed, we just load level 1
    // We don't call super.handleInput here
    loadState(LEVEL1);
  }

}

public class Level1 extends Level {
  public Level1() {
    super(0, 0, width * 4 / 5, height, width * 4 / 5 / 16, height / 11, "levels/level1.csv");
  }
}

public class Level2 extends Level {
  public Level2() {
    super(0, 0, width * 4 / 5, height, width * 4 / 5 / 16, height / 11, "levels/level2.csv");
  }
}
