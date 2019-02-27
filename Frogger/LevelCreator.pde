// It's similar to a level, but not enough for making it a subclass to be useful
public class LevelCreator implements GameState {

  // Buttons and things
  private String[] cols = { "laneType", "obstacleType", "numObstacles", "len", "spacing", "speed" };
  private PropTextBox[] laneProps = new PropTextBox[cols.length];
  private String[] settingStrs = { "new lane", "help", "main menu", "reload lanes", "save" };
  private TextBox[] settings = new TextBox[settingStrs.length];
  private TextBox[] laneTypeSelectors; // These are the buttons to choose from when selecting a new lane
  private String help = "Use the arrow keys to navigate\n" +
    "Press enter to select\n" +
    "Press backspace to delete a lane or go back\n" + 
    "Select reload lanes to see your changes\n" + 
    "Press save to save your level";

  // Variables to manage selection
  private int depth = 0;
  private final int NUMDEPTHS = 3, LANES = 0, BUTTONS = 1, SUBBUTTONS = 2;
  private int[] selection = new int[NUMDEPTHS];

  // Storing the actual level
  private int numLanes = 12;
  private ArrayList<Lane> lanes = new ArrayList<Lane>();
  private Table level = new Table();

  private float tileSize;

  // For letting the user type in their level's name
  private TextBox prompt;
  private boolean saving = false;
  private StringBuilder levelName = new StringBuilder();
  
  private String warning = "";
  private int warningMillis = -1;
  private int warnDuration = 1000;

  // ===== INITIALIZING THE LEVEL CREATOR =====

  public void init() {
    for (String col : cols) level.addColumn(col); // Create the table to store the data, with the proper columns
    tileSize = height / numLanes; // The default height for a lane
    
    // Initialize the buttons that allow the user to change a lane's properties
    float w = width / cols.length;
    for (int i = 0; i < cols.length; i++)
      laneProps[i] = new PropTextBox(i * w, 0, w, tileSize, color(0, 128), cols[i]);
      
    // Initialize the setting buttons, at the bottom
    w = width / settings.length;
    for (int i = 0; i < settingStrs.length; i++)
      settings[i] = new TextBox(i * w, 0, w, tileSize, color(255, 0, 0), settingStrs[i]);
    
    laneTypeSelectors = new TextBox[assets.getNumLanes() - 1]; // Initialize the array; -1 because we can't choose the destination lane
    w = width / settings.length / (assets.getNumLanes() - 1); // We divide up one of the buttons into the lanes
    int counter = 0;
    for (String type : assets.laneTypes) {
      if (type.equals("destination")) continue; // We don't want to show a destination button
      laneTypeSelectors[counter] = new TextBox(w * counter, 0, w, tileSize, assets.getLaneColor(type), type);
      counter++;
    }
    
    prompt = new TextBox(0, 0, width, height / 2, "What would you like to call your level?");
      
    newLane("destination", "home", 5, 1, 2, 0); // add the destination lane, since each level needs one
  }

  // ===== DRAWING THE LEVEL CREATOR =====

  // We return out to show that each case is essentially a separate block
  public void show() {
    background(0); // clear the screen

    if (saving) { // If the player is typing in their level name
      prompt.show();
      text(levelName.toString(), 0, height / 2, width, height / 2); // Write what has currently been inputted by the user
      return;
    }
    
    for (Lane l : lanes) l.show(); // Draw the lanes
    for (TextBox b : settings) b.show(); // Draw the setting buttons
      
    switch (depth) { // We draw special things based on what we have currently selected
    case LANES:
      if (settingsSelected()) // If the settings are hovered,
        for (TextBox b : settings) b.showHover(); // we highlight them
      else
        ((Lane) getSelection()).showHover(); // Otherwise we highlight the hovered lane
      break;
      
    case BUTTONS:
      showButtons();
      ((TextBox) getSelection()).showHover();
      break;
      
    case SUBBUTTONS: // This is either the lane type selectors, or the user is adjusting a lane property
      showButtons();
      if (settingsSelected()) {
        for (TextBox l : laneTypeSelectors) l.show();
        ((TextBox) getSelection()).showHover();
      } else
        ((PropTextBox) getSelection()).showHover(level.getRow(selection[LANES]));
      break;
    }

    if (warningMillis > 0) { // If a warning is being shown
      assets.drawCenteredText(warning); // We do, and
      if (millis() - warningMillis >= warnDuration) // if enough time has passed since we started displaying the warning
        warningMillis = -1; // we stop showing it
    }
  }

  private void showButtons() {
    for (int i = 0; i < numButtons(); i++) // If the settings are selected, we show the settings, otherwise the lane properties
      (settingsSelected() ? settings : laneProps)[i].show();
  }

  // ===== UPDATING THE LEVEL CREATOR =====

  public void update() { // We update the locations of the rectangles so that they're where they're supposed to be, even if they aren't shown
    for (Lane l : lanes) l.update(); // Update the lanes
    for (PropTextBox b : laneProps) b.y = selection[LANES] * tileSize;
    for (TextBox b : settings) b.y = lanes.size() * tileSize;
    for (TextBox b : laneTypeSelectors) b.y = lanes.size() * tileSize;
  }

  // ===== USER INPUT =====

  public void handleInput() { // Big function! This state has a lot of user interaction, and we use a switch statement to test many different keys
    if (saving) { // If the user is typing in their level's name
      handleSaving();
      return; // We don't want to respond to keys when the user is typing in the name
    }
    
    int dir; // The direction to move the selection
    switch (keyCode) {
    case UP:
    case DOWN:
      dir = keyCode == UP ? -1 : 1; // 1 going up, -1 going down
      if (depth == SUBBUTTONS && !settingsSelected()) // If a lane property is selected
        if (destLaneSelected())
          warnUser("You can't edit the destination lane", 1000);
        else // Note we switch the dir: up should mean +1
          ((PropTextBox) getSelection()).changeValue(level.getRow(selection[LANES]), -dir);
      else // Otherwise we move up and down the lanes
        moveSelection(LANES, dir);
      break;

    case LEFT: // If left or right is pressed,
    case RIGHT: 
      dir = keyCode == LEFT ? -1 : 1; // (-1 going left, 1 going right)
      if (depth == BUTTONS) // if we are moving between the buttons, we move the selection,
        moveSelection(BUTTONS, dir);
      else if (depth == SUBBUTTONS && settingsSelected()) // as well as if we are choosing a lane type
        moveSelection(SUBBUTTONS, dir);
      break;

    case ENTER:
    case RETURN:
      if (warningMillis > 0) // If a warning is being shown
        warningMillis = -1;
      
        
      else if (depth == LANES)
        depth++; // We go in a depth level
      
      else if (depth == SUBBUTTONS) {
        if (!settingsSelected()) // If we are currently editing a setting and press enter, we go back a depth level
          depth--;
        else // The new lane button is the only setting button with sub-buttons,
          newLane(((TextBox) getSelection()).getText()); // so we create a new lane with the type specified by the text of the selected sub-button
      }
      
      else if (depth == BUTTONS) { // These are the buttons in the settings
        if (settingsSelected()) {
          String selectedText = ((TextBox) getSelection()).getText();
          
          if (selectedText.equals("new lane"))
            depth++;
          
          else if (selectedText.equals("help"))
            warnUser(help, 7 * 1000); // Show the help for 7 seconds
          
          else if (selectedText.equals("reload lanes")) {
            for (int i = 0; i < level.getRowCount(); i++) { // For each row in the table,
              TableRow tr = level.getRow(i);
              lanes.set(i, new Lane(i, tr)); // we create a new lane with the data from that row
              lanes.get(i).init(0, 0, width, tileSize);
            }
          }
          
          else if (selectedText.equals("main menu"))
            loadState(MENUSTATE);
          
          else if (selectedText.equals("save")) { // If the user clicks the save button
            if (level.getRowCount() < 8)
              warnUser("There must be at least 8 lanes", 1000);
            // The last lane in the level has to be a safety lane
            else if (!level.getRow(level.getRowCount() - 1).getString("laneType").equals("safety"))
              warnUser("The spawn lane must be safe", 1000);
            else saving = true;
          }
        } else // A lane prop button is selected
          depth++;
      }
      break;
    
    case BACKSPACE:
    case DELETE:
      if (depth == LANES && !settingsSelected()) {
        if (destLaneSelected())
          warnUser("You can't delete the destination lane", 1000);
        else {
          lanes.remove(selection[LANES]); // A normal lane is selected, so we can delete it
          level.removeRow(selection[LANES]); // and remove it from the table
        }
      }
      
      else
        depth--; // If a lane or sub-button is selected, we simply go up
    }
  }
  
  // When the user is typing in a name for their level, we do this instead of checking for which buttons are pressed
  private void handleSaving() {
    switch (key) {
    case ENTER:
    case RETURN:
      saveTable(level, "data/levels/" + levelName + ".csv"); // We save the table under data/levels as a .csv file
      loadState(MENUSTATE); // And return to the menu
      break;

    case BACKSPACE:
    case DELETE:
      if (levelName.length() == 0) // If they backspace with no characters left, we go back
        saving = false;
      else
        levelName.deleteCharAt(levelName.length() - 1); // Delete the last character
      break;
    
    default:
      if ((key >= 'a' && key <= 'z') || (key >= 'A' && key <= 'Z') || (key >= '0' && key <= '9')) // If they don't press enter/return, we add the pressed key if it is valid
        levelName.append(key);
    }
  }
  
  private void warnUser(String text, int duration) {
    warning = text;
    warningMillis = millis();
    warnDuration = duration;
  }

  private void moveSelection(int depth, int dir) {
    selection[depth] += dir;
    
    // Makes sure something valid is selected
    selection[LANES] = constrain(selection[LANES], 0, lanes.size());
    selection[BUTTONS] = constrain(selection[BUTTONS], 0, numButtons() - 1);
    selection[SUBBUTTONS] = constrain(selection[SUBBUTTONS], 0, assets.laneTypes.length - 2);
  }

  private void newLane(String type) { // If only a type is passed, we init the lane with no obstacles if it is a safety lane, otherwise 1 obstacle with length 1, 2 apart and with a speed of 2
    newLane(type, assets.getObstaclesOfLane(type)[0], type.equals("safety") ? 0 : 1, 1, 2, 2);
  }

  private void newLane(String type, String obstacleType, int numObstacles, float len, float spacing, float speed) {
    if (level.getRowCount() == numLanes - 1) { // If the max number of lanes has been reached
      warnUser("That's too many lanes\nClick save to save", 1000);
      return;
    }
    
    int index = lanes.size();
    // We create a lane using the given info
    lanes.add(new Lane(index, type, obstacleType, numObstacles, len, spacing, speed));
    lanes.get(index).init(0, 0, width, tileSize);
    
    TableRow lane = level.addRow(); // We add a new row to the table with the data for the game
    lane.setString("laneType", type);
    lane.setString("obstacleType", obstacleType);
    lane.setInt("numObstacles", numObstacles);
    lane.setFloat("len", len);
    lane.setFloat("spacing", spacing);
    lane.setFloat("speed", speed);

    depth = LANES; // Go back to lane selection
  }

  // ===== TESTERS AND GETTERS ===== 
  
  private boolean settingsSelected() {
    return selection[LANES] == lanes.size();
  }
  private boolean destLaneSelected() {
    return lanes.get(selection[LANES]).isType("destination");
  }
  private int numButtons() {
    return settingsSelected() ? settings.length : cols.length;
  }
  // Here we use a that can return any object, depending on the current depth. It gets casted to whatever we need to use
  private Object getSelection() {
    switch (depth) {
    case LANES:
      if (!settingsSelected())
        return lanes.get(selection[LANES]);
      else
        return null;
    case BUTTONS:
      if (settingsSelected())
        return settings[selection[BUTTONS]];
      else
        return laneProps[selection[BUTTONS]];
    case SUBBUTTONS: 
      if (settingsSelected() && selection[BUTTONS] == 0) // The new lane TextBox is selected
        return laneTypeSelectors[selection[SUBBUTTONS]];
      else
        return laneProps[selection[BUTTONS]];
    default:
      return null;
    }
  }

}
