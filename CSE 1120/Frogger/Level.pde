// The level itself also has a box, representing the box that the lanes and frog itself remain in.
class Level extends Rectangle {
  
  Frog frog;
  Lane[] lanes;
  
  float grid;
  int lives;
  int points;
  int startTime, elapsed;
  int deadFrame;
  
  final int gameTime = 30 * 1000; // 30 seconds

  Level(float x, float y, float w, float h, String map) { // We initialize the level like a rectangle,
    // except also with the path to the csv file containing the data for the map
    super(x, y, w, h, color(0));
    lanes = loadLanes(map);
    lives = 3;
    points = 0;
    reset();
  }
  
  void reset() {
    // We create a new frog at the center of the screen, one grid above the bottom, and one grid in sidelength
    frog = new Frog(this, (w - grid) / 2, h - grid, grid);
    startTime = millis();
  }
  
  void update() {
    for (Lane lane : lanes) lane.update(); // We update all of the lanes in the level
      
    int laneIndex = int(frog.y / grid); // Dividing by the grid size gives us the number of lanes above the frog, which is the same as the index of the frog's lane.
    lanes[laneIndex].check(frog); // We check the lane that the frog is in for collisions with the obstacles
    frog.update(); // This just moves the frog if it is attached to a log
    
    elapsed = (gameTime - millis() + startTime) / 1000; // Update the elapsed time
    
    if (elapsed <= 0) lives -= 1; // If they player has run out of time, they lose a life
    
    if (lives <= 0) status = DIED; // If the player runs out of lives, we change the status to say that they have recently died
  }
  
  void show() {
    for (Lane lane : lanes) lane.show(); // We show each of the lanes
    frog.show(); // and the frog
    showInfo(); // and the info
  }
  
  void showInfo() { // We draw a black rectangle filling the remainder of the screen to the right of the level
    fill(0);
    rect(x + w, y, width - x - w, h);
    fill(255);
    textAlign(CENTER, CENTER);
    textFont(ARCADEFONT, height / 16);
    text("Lives\n" + lives +
      "\nPoints\n" + points +
      "\nTime\n" + elapsed, x + w, y, width - x - w, h);
  }
  
  Lane[] loadLanes(String path) {
    Table data = loadTable(path, "header"); // We load the data from the table
    Lane[] lanes = new Lane[data.getRowCount()]; // We initialize an array of lanes. Each row in the table corresponds to a lane
    grid = h / lanes.length;
    
    int counter = 0;
    for (TableRow row : data.rows()) { // For each of the rows
      // We add the lane specified by the data to the lanes array
      lanes[counter] = new Lane(counter, this, row.getInt("type"), row.getInt("numObstacles"), row.getInt("len"), row.getFloat("spacing"), row.getFloat("speed"));
      counter++;
    }
    return lanes;
  }
  
}
