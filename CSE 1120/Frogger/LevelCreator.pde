// It's similar to a level, but not enough for making it a subclass to be useful
public class LevelCreator implements GameState {

  // Buttons and things
  private String[] laneModifiers = { "numObstacles", "len", "spacing", "speed" };
  private Button[] laneModButtons = new Button[laneModifiers.length];
  private Button help, newLane, save;
  private Button[] laneTypeSelectors;

  // Variables to manage selection
  private int selectionLevel = 0; // 0: nothing is selected, 1: a lane or the new lane button is selected, 2: a lane mod button is selected
  private int selectedLane = 0;
  private int selectedSubButton = 0;

  // Storing the actual level
  private int numLanes = 12;
  private ArrayList<Lane> lanes = new ArrayList<Lane>();
  private Table level;

  private float tileSize;

  // For letting the user type in their level's name
  private boolean saving = false;
  private StringBuilder levelName = new StringBuilder();
  
  private boolean showHelp = false;

  public void init() {
    level = new Table();
    level.addColumn("laneType");
    level.addColumn("obstacleType");
    level.addColumn("numObstacles");
    level.addColumn("len");
    level.addColumn("spacing");
    level.addColumn("speed");

    tileSize = height / numLanes; // The default height for a lane

    Rectangle rect = new Rectangle(0, 0, width / 3, tileSize, color(255, 0, 0));
    help = new Button(rect, "new lane");
    rect.x += width / 3;
    newLane = new Button(rect, "new lane");
    rect.x += width / 3;
    save = new Button(rect, "save");
    
    laneTypeSelectors = new Button[assets.getNumLanes()];
    
    float colW = width / 2 / assets.getNumLanes();
    float leftMostX = (width - colW * assets.getNumLanes()) / 2;
    int counter = 0;
    for (String type : assets.laneColors.keySet()) {
      Rectangle r = new Rectangle(leftMostX + colW * counter, 0, colW, tileSize, assets.getLaneColor(type));
      laneTypeSelectors[counter] = new Button(r, type);
      counter++;
    }
    
    for (int i = 0; i < laneModifiers.length; i++) { // The buttons that allow the user to change a lane's properties
      assets.defaultFont(height / 8);
      Rectangle r = new Rectangle(i * width / laneModifiers.length, 0, width / laneModifiers.length, tileSize, color(0, 128));
      laneModButtons[i] = new Button(r, laneModifiers[i]);
    }

    newLane("destination", "home", 5, 1, 2, 0); // add the destination lane, since each level needs one
  }
  
  public void update() {}

  // We return out to show that each case is essentially a separate block
  public void show() {
    background(0);
    if (saving) { // If the player is typing in their level name
      String prompt = "What would you like to call your level?";
      assets.defaultFont(height / 8); // This gives us the number of lines
      text(prompt, 0, 0, width, height / 2);
      text(levelName.toString(), 0, height / 2, width, height / 2);
      return;
    }
    
    if (showHelp) {
      assets.defaultFont(height / 16);
      text("Press h to show help or close it, r to reset, and s to save. Use enter/return to select.", 0, 0, width, height);
      return;
    }
    
    for (int i = 0; i < lanes.size(); i++) {
      lanes.get(i).show(); // Draw the lanes
      if (selectedLane == i && selectionLevel == 0) lanes.get(i).showHover();
    }
    
    // The buttons
    help.show();
    newLane.show();
    save.show();

    if (settingsSelected() && selectionLevel == 0) newLane.showHover();

    if (selectionLevel < 1) return; // The rest of this function deals with the next level of selection, the sub-buttons

    for (int i = 0; i < numSubButtons(); i++) { // We show the lane type selectors if the new lane button is hovered, else we show the lane mod buttons
      Rectangle curr = (settingsSelected() ? laneTypeSelectors : laneModButtons)[i];
      curr.show();
      if (i == selectedSubButton) {
        if (selectionLevel == 1)
          curr.showHover();
        else if (selectionLevel == 2) { // A sub-button is selected, we go up or down
          String col = laneModifiers[selectedSubButton]; // The property we're changing
          fill(0, 255, 0, 192); // Draw a green triangle on top
          triangle(curr.x, curr.y + curr.h / 2, curr.x + curr.w / 2, curr.y, curr.x + curr.w, curr.y + curr.h / 2);
          fill(255, 0, 0, 192);
          triangle(curr.x, curr.y + curr.h / 2, curr.x + curr.w / 2, curr.y + curr.h, curr.x + curr.w, curr.y + curr.h / 2);

          Button valueLabeled = new Button(curr, getValue(level.getRow(selectedLane), col).toString());
          valueLabeled.show();
        }
      }
    } 
  }

  public void handleInput() { // Big function! This state has a lot of user interaction, and we use a switch statement to test many different keys
    if (saving) { // If the user is typing in their level's name
      switch (key) {
      case ENTER: case RETURN:
        saveTable(level, "data/levels/" + levelName + ".csv"); // We save the table under data/levels as a .csv file
        loadState(MENUSTATE); // And return to the menu
        break;

      case BACKSPACE: case DELETE:
        if (levelName.length() == 0) // If they backspace with no characters left, we go back
            saving = false;
          else
            levelName.deleteCharAt(levelName.length() - 1);
        break;
      
      default:
        if (key != '.') // If they don't press enter/return, 
        levelName.append(key); // we add the pressed key if it is valid
      }
      return; // We don't want to respond to keys when the user is typing in the name
    }
    
    switch (key) {
    case CODED: // A nested switch statement to handle the arrow keys
      switch (keyCode) {
      case UP:
        if (selectionLevel == 2) {
          String col = laneModifiers[selectedSubButton];
          changeValue(level.getRow(selectedLane), col, colType(col).equals("integer") ? 1 : 0.1); // We increase by 1 if the property is integral, otherwise by 0.1
        } else if (selectedLane > 0)
          moveSelection(-1);
        break;

      case DOWN:
        if (selectionLevel == 2) {
          String col = laneModifiers[selectedSubButton];
          changeValue(level.getRow(selectedLane), col, colType(col).equals("integer") ? -1 : -0.1); // Same, decrementing
        } else if (selectedLane < lanes.size())
          moveSelection(1);
        break;

      case LEFT:
        if (selectionLevel == 1 && selectedSubButton > 0) selectedSubButton--;
        break;

      case RIGHT:
        if (selectionLevel == 1 && selectedSubButton < numSubButtons() - 1) selectedSubButton++;
        break;
      }
      break;

    case ENTER:
    case RETURN:
      if (selectionLevel == 1 && settingsSelected())
        newLane(laneTypeSelectors[selectedSubButton].getText()); // We create a new lane with the type specified by the text of the selected sub-button
      else if (selectionLevel == 2) selectionLevel--;
      else selectionLevel++;
      break;
    
    case BACKSPACE:
    case DELETE:
      if (selectionLevel == 0) // If a lane is being hovered
        if (lanes.get(selectedLane).isType("destination")) // Can't delete the testination lane; if it is tried, we go back to the menu
          loadState(MENUSTATE);
        else if (!settingsSelected())
          lanes.remove(selectedLane); // A normal lane is selected, so we can delete it
      else selectionLevel--; // If a lane or sub-button is selected, we simply go up
      break;
    
    case 'h':
      showHelp = !showHelp;
      break;
    case 'r':
      level.clearRows();
      break;
    case 's':
     saving = true;
     break;
    }
  }

  private void moveSelection(int dir) {
    selectedLane += dir;
    for (Button b : laneModButtons) // Move down all the lane mod buttons by the amount
      b.y += dir * tileSize;

    // Makes sure something valid is selected
    selectedSubButton = constrain(selectedSubButton, 0, numSubButtons());
  }

  private String colType(String col) { // gives the type of a column (this isn't SQL)
    switch (col) {
    case "laneType":
    case "obstacleType":
      return "string";
    case "numObstacles":
    case "len":
      return "integer";
    case "spacing":
    case "speed":
      return "float";
    default:
      return null;
    }
  }
  
  private Number getValue(TableRow row, String col) { // returns a flexible value
    if (colType(col).equals("integer")) return row.getInt(col);
    else if (colType(col).equals("float"))
      return row.getFloat(col);
    else 
      return null;
  }

  private void changeValue(TableRow row, String col, int amt) { // for integers
    row.setInt(col, row.getInt(col) + amt);
  }

  private void changeValue(TableRow row, String col, float amt) { // and floats
    row.setFloat(col, row.getFloat(col) + amt);
  }

  private void newLane(String type) { // If only a type is passed, we init the lane with 1 obstacle with length 1, 2 apart and with a speed of 2
    newLane(type, assets.getDefaultObstacleByLane(type), 1, 1, 2, 2);
  }

  private void newLane(String type, String obstacleType, int numObstacles, float len, float spacing, float speed) {
    newLane.y += tileSize;
    for (Rectangle r : laneTypeSelectors) r.y += tileSize;
    
    int index = lanes.size();
    lanes.add(new Lane(index, type, obstacleType, numObstacles, len, spacing, speed));
    lanes.get(index).setBounds(0, 0, width, tileSize);
    
    TableRow lane = level.addRow();
    lane.setString("laneType", type);
    lane.setString("obstacleType", obstacleType);
    lane.setInt("numObstacles", numObstacles);
    lane.setFloat("len", len);
    lane.setFloat("spacing", spacing);
    lane.setFloat("speed", speed);
  }
  
  private boolean settingsSelected() {
    return selectedLane == lanes.size();
  }

  private int numSubButtons() {
    return settingsSelected() ? assets.getNumLanes() : laneModifiers.length;
  }

}
