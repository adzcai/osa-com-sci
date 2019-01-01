// It's similar to a level, but not enough for making it a subclass to be useful
public class LevelCreator implements GameState {

  // Buttons and things
  private String[] cols = { "laneType", "obstacleType", "numObstacles", "len", "spacing", "speed" };
  private PropButton[] laneProps = new PropButton[cols.length];
  private String[] settingStrs = { "new lane", "reload lanes", "save" };
  private Button[] settings = new Button[settingStrs.length];
  private Button[] laneTypeSelectors; // These are the buttons to choose from when selecting a new lane

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
  private boolean saving = false;
  private StringBuilder levelName = new StringBuilder();
  
  private String warning = "";
  private int warningMillis = -1;
  private int warningDuration = 1000;

  // ===== INITIALIZING THE LEVEL CREATOR =====

  public void init() {
    for (String col : cols) level.addColumn(col); // Create the table to store the data, with the proper columns
    tileSize = height / numLanes; // The default height for a lane
    initLaneTypeSelectors();
    initLanePropButtons();
    initSettingButtons();
    newLane("destination", "home", 5, 1, 2, 0); // add the destination lane, since each level needs one
  }
  
  private void initLaneTypeSelectors() {
    laneTypeSelectors = new Button[assets.getNumLanes() - 1]; // Initialize the array; -1 because we can't choose the destination lane
    float w = width / settings.length / (assets.getNumLanes() - 1); // We divide up one of the buttons into the lanes
    int counter = 0;
    for (String type : assets.laneTypes) {
      if (type.equals("destination")) continue; // We don't want to show a destination button
      Rectangle r = new Rectangle(w * counter, 0, w, tileSize, assets.getLaneColor(type));
      laneTypeSelectors[counter] = new Button(r, type);
      counter++;
    }
  }
  
  private void initLanePropButtons() {
    float w = width / cols.length;
    for (int i = 0; i < cols.length; i++) // The buttons that allow the user to change a lane's properties
      laneProps[i] = new PropButton(new Rectangle(i * w, 0, w, tileSize, color(0, 128)), cols[i]);
  }
  
  private void initSettingButtons() {
    float colW = width / settings.length;
    for (int i = 0; i < settingStrs.length; i++) // Initialize the setting buttons, at the bottom
      settings[i] = new Button(new Rectangle(i * colW, 0,colW, tileSize, color(255, 0, 0)), settingStrs[i]);
  }

  // ===== DRAWING THE LEVEL CREATOR =====

  // We return out to show that each case is essentially a separate block
  public void show() {
    background(0); // clear the screen
    
    if (warningMillis > 0) {
      assets.drawCenteredText(warning);
      if (millis() - warningMillis >= warningDuration) // if enough time has passed since we started displaying the warning
        warningMillis = -1; // we stop showing it
    }

    if (saving) { // If the player is typing in their level name
      String prompt = "What would you like to call your level?";
      assets.defaultFont(height / 8); // This gives us the number of lines
      text(prompt, 0, 0, width, height / 2);
      text(levelName.toString(), 0, height / 2, width, height / 2);
      return;
    }
    
    for (Lane l : lanes) l.show(); // Draw the lanes
    for (Button b : settings) b.show(); // Draw the setting buttons
    
      
    switch (depth) {
    case LANES:
      Lane selectedLane = (Lane) getSelection();
      if (selectedLane == null) // If the settings are hovered,
        for (Button b : settings) b.showHover(); // we highlight them
      else
        selectedLane.showHover(); // Otherwise we highlight the hovered lane
      break;
      
    case BUTTONS:
      showButtons();
      ((Button) getSelection()).showHover();
      break;
      
    case SUBBUTTONS:
      showButtons();
      if (settingsSelected()) {
        for (Button l : laneTypeSelectors) l.show();
        ((Button) getSelection()).showHover();
      } else
        ((PropButton) getSelection()).showHover(level.getRow(selection[LANES]));
      break;
    }
  }

  private void showButtons() {
    for (int i = 0; i < numButtons(); i++) // If the settings are selected, we show the settings, otherwise the lane properties
      (settingsSelected() ? settings : laneProps)[i].show();
  }

  // ===== UPDATING THE LEVEL CREATOR =====

  public void update() { // We update the locations of the rectangles so that they're where they're supposed to be, even if they aren't shown
    for (Lane l : lanes) l.update(); // Update the lanes
    for (PropButton b : laneProps) b.y = selection[LANES] * tileSize;
    for (Button b : settings) b.y = lanes.size() * tileSize;
    for (Button b : laneTypeSelectors) b.y = lanes.size() * tileSize;
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
        // We change the property of the lane; 1 going up, -1 going down
        // We need to reverse it from dir, which determines the way the selection moves
        ((PropButton) getSelection()).changeValue(level.getRow(selection[LANES]), -dir);
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
      if (depth == SUBBUTTONS) {
        if (!settingsSelected()) // If we are currently editing a setting and press enter, we go back a depth level
          depth--;
        else // The new lane button is the only setting button with sub-buttons,
          newLane(((Button) getSelection()).getText()); // so we create a new lane with the type specified by the text of the selected sub-button
      }
      
      else if (depth == BUTTONS && ((Button) getSelection()).getText().equals("reload lanes")) { // If the user clicks the reload lanes button
        for (int i = 0; i < level.getRowCount(); i++) { // For each row in the table,
          TableRow tr = level.getRow(i);
          lanes.set(i, new Lane(i, tr)); // we create a new lane with the data from that row
          lanes.get(i).init(0, 0, width, tileSize);
        }
      }
      
      else if (depth == BUTTONS && ((Button) getSelection()).getText().equals("save")) { // If the user clicks the save button
        if (level.getRowCount() < 8)
          warnUser("There must be at least 8 lanes");
        // The last lane in the level has to be a safety lane
        else if (!level.getRow(level.getRowCount() - 1).getString("laneType").equals("safety"))
          warnUser("The spawn lane must be safe");
        else saving = true;
      }
      
      else if (depth == LANES && !settingsSelected() && ((Lane) getSelection()).isType("destination")) // We can't edit the destination lane
        warnUser("You can't edit the destination lane");
        
      else
        depth++; // We go in a depth level
      break;
    
    case BACKSPACE:
    case DELETE:
      if (depth == LANES) {
        if (((Lane) getSelection()).isType("destination")) // Can't delete the testination lane; if it is tried, we go back to the menu
          loadState(MENUSTATE);
        else if (!settingsSelected())
          lanes.remove(selection[LANES]); // A normal lane is selected, so we can delete it
      } else
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
      if (key != '.') // If they don't press enter/return, we add the pressed key if it is valid
        levelName.append(key);
    }
  }

  private void warnUser(String text) {
    warning = text;
    warningMillis = millis();
  }

  private void moveSelection(int depth, int dir) {
    selection[depth] += dir;
    
    // Makes sure something valid is selected
    selection[LANES] = constrain(selection[LANES], 0, lanes.size());
    selection[BUTTONS] = constrain(selection[BUTTONS], 0, numButtons() - 1);
    selection[SUBBUTTONS] = constrain(selection[SUBBUTTONS], 0, assets.laneTypes.length - 2);
  }

  private void newLane(String type) { // If only a type is passed, we init the lane with 1 obstacle with length 1, 2 apart and with a speed of 2
    newLane(type, assets.getDefaultObstacleByLane(type), 1, 1, 2, 2);
  }

  private void newLane(String type, String obstacleType, int numObstacles, float len, float spacing, float speed) {
    if (level.getRowCount() == numLanes) { // If the max number of lanes has been reached
      warnUser("That's too many lanes! Click save to save");
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
  private int numButtons() {
    return settingsSelected() ? settings.length : cols.length;
  }
  // Here we use a that can return any object, depending on the current depth
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
      if (settingsSelected() && selection[BUTTONS] == 0) // The new lane button is selected
        return laneTypeSelectors[selection[SUBBUTTONS]];
      else
        return laneProps[selection[BUTTONS]];
    default:
      return null;
    }
  }

}
