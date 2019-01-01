// It's similar to a level, but not enough for making it a subclass to be useful
public class LevelCreator implements GameState {

  // Buttons and things
  private String[] cols = { "laneType", "obstacleType", "numObstacles", "len", "spacing", "speed" };
  private PropButton[] laneProps = new PropButton[cols.length];
  private String[] settingStrs = { "new lane", "save" };
  private Button[] settings = new Button[settingStrs.length];
  private Button[] laneTypeSelectors;

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

  public void init() {
    for (String col : cols) level.addColumn(col); // Create the table to store the data, with the proper columns
    tileSize = height / numLanes; // The default height for a lane
    initLaneTypeSelectors();
    initLanePropButtons();
    initSettingButtons();
    newLane("destination", "home", 5, 1, 2, 0); // add the destination lane, since each level needs one
  }
  
  private void initLaneTypeSelectors() {
    laneTypeSelectors = new Button[assets.getNumLanes()]; // These are the buttons to choose from when selecting a new lane
    float w = width / settings.length / assets.getNumLanes(); // We divide up one of the buttons into the lanes
    int counter = 0;
    for (String type : assets.laneTypes) { // The keySet of assets.laneColors is just the names of the different types of lanes
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
  
  public void update() { // We update the locations of the rectangles so that they're where they're supposed to be, even if they aren't shown
    for (PropButton b : laneProps) b.y = selection[LANES] * tileSize;
    for (Button b : settings) b.y = lanes.size() * tileSize;
    for (Button b : laneTypeSelectors) b.y = lanes.size() * tileSize;
  }

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
    
    for (Lane l : lanes) l.show(); // Draw the lanes
    for (Button b : settings) b.show(); // Draw the setting buttons
    for (int i = 0; i < numButtons(); i++) // If the settings are selected, we show the settings, otherwise the lane properties
      (settingsSelected() ? settings : laneProps)[i].show();
      
    switch (depth) {
    case LANES:
      Lane selectedLane = (Lane) getSelection();
      if (selectedLane == null) // If the settings are hovered,
        for (Button b : settings) b.showHover(); // we highlight them
      else
        selectedLane.showHover(); // Otherwise we highlight the hovered lane
      break;
      
    case BUTTONS:
      ((Button) getSelection()).showHover();
      break;
      
    case SUBBUTTONS:
      if (settingsSelected()) {
        for (Button l : laneTypeSelectors) l.show();
        ((Button) getSelection()).showHover();
      } else
        ((PropButton) getSelection()).showHover(level.getRow(selection[LANES]));
      break;
    }

    // for (Button l : laneTypeSelectors) l.show();
  }

  public void handleInput() { // Big function! This state has a lot of user interaction, and we use a switch statement to test many different keys
    if (saving) { // If the user is typing in their level's name
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
      return; // We don't want to respond to keys when the user is typing in the name
    }
    
    int dir; // The direction to move the selection
    switch (keyCode) {
    case UP:
    case DOWN:
      dir = keyCode == UP ? -1 : 1; // 1 going up, -1 going down
      if (depth == SUBBUTTONS) // If a lane property is selected
        // We change the property of the lane; 1 going up, -1 going down
        // We need to reverse it from dir, which determines the way the selection moves
        ((PropButton) getSelection()).changeValue(level.getRow(selection[LANES]), -dir);
      else
        moveSelection(LANES, dir);
      break;

    case LEFT:
    case RIGHT:
      dir = keyCode == LEFT ? -1 : 1; // -1 going left, 1 going right
      if (depth == BUTTONS)
        moveSelection(BUTTONS, dir);
      else if (depth == SUBBUTTONS && settingsSelected()) // If we are choosing a lane type
        moveSelection(SUBBUTTONS, dir);
      break;

    case ENTER:
    case RETURN:
      if (depth == SUBBUTTONS) { // If we are currently editing a setting and press enter, we go back a depth level
        if (!settingsSelected())
          depth--;
        else // If the new lane button is being hovered and we press enter
          newLane(((Button) getSelection()).getText()); // We create a new lane with the type specified by the text of the selected sub-button
      } else
        depth++;
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

  private void moveSelection(int depth, int dir) {
    selection[depth] += dir;
    
    // Makes sure something valid is selected
    selection[LANES] = constrain(selection[LANES], 0, lanes.size());
    selection[BUTTONS] = constrain(selection[BUTTONS], 0, numButtons() - 1);
    selection[SUBBUTTONS] = constrain(selection[SUBBUTTONS], 0, assets.laneTypes.length - 1);
  }

  private void newLane(String type) { // If only a type is passed, we init the lane with 1 obstacle with length 1, 2 apart and with a speed of 2
    newLane(type, assets.getDefaultObstacleByLane(type), 1, 1, 2, 2);
  }

  private void newLane(String type, String obstacleType, int numObstacles, float len, float spacing, float speed) {
    int index = lanes.size();
    // We create a lane using the given info
    lanes.add(new Lane(index, type, obstacleType, numObstacles, len, spacing, speed));
    lanes.get(index).setBounds(0, 0, width, tileSize);
    
    TableRow lane = level.addRow(); // We add a new row to the table with the data for the game
    lane.setString("laneType", type);
    lane.setString("obstacleType", obstacleType);
    lane.setInt("numObstacles", numObstacles);
    lane.setFloat("len", len);
    lane.setFloat("spacing", spacing);
    lane.setFloat("speed", speed);

    depth = LANES; // Go back to lane selection
  }
  
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
