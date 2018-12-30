// It's similar to a level, but not enough for making it a subclass to be useful
public class LevelCreator implements GameState {

  private String[] laneModifiers = {
    "incNumObstacles", "decNumObstacles",
    "incLen", "decLen",
    "incSpacing", "decSpacing",
    "incSpeed", "decSpeed" };
  private Button[] laneModButtons = new Button[laneModifiers.length];
  
  private float selectedLane = 0;
  private Button newLaneButton;
  private Rectangle[] laneTypeSelectors;

  private int numLanes = 12;
  private ArrayList<Lane> lanes = new ArrayList<Lane>();
  private Table level;

  private float tileSize;

  private boolean saving = false;
  private StringBuilder levelName = new StringBuilder();
  
  private boolean showHelp = false;
  
  private int warningMillis = -1;
  private int warningDuration = 2 * 1000;

  public void init() {
    level = new Table();
    level.addColumn("type");
    level.addColumn("numObstacles");
    level.addColumn("len");
    level.addColumn("spacing");
    level.addColumn("speed");

    tileSize = height / numLanes; // The default height for a lane
    Rectangle rect = new Rectangle(width * 7 / 16, 0, width / 8, tileSize, color(255, 0, 0));
    newLaneButton = new Button(rect, "New lane");

    float colW = newLaneButton.w / NUMLANETYPES;
    laneTypeSelectors = new Rectangle[NUMLANETYPES];
    for (int i = 0; i < NUMLANETYPES; i++)
      laneTypeSelectors[i] = new Rectangle(newLaneButton.x + colW * i, newLaneButton.y, colW, newLaneButton.h, assets.laneColors[i]);
    
    for (int i = 0; i < laneModifiers.length; i++) {
      assets.defaultFont(height / 8);
      Rectangle r = new Rectangle(i * width / laneModifiers.length, 0, width / laneModifiers.length, tileSize);
      laneModButtons[i] = new Button(r, laneModifiers[i]);
    }
  }
  
  public void update() {}

  // We return out to show that each case is essentially a separate block
  public void show() {
    background(0);
    if (warningMillis >= 0) {
      drawCenteredText("You must have a destination lane!");
      if (millis() - warningMillis >= warningDuration) warningMillis = -1;
      return;
    }
    
    if (showHelp) {
      assets.defaultFont(height / 16);
      text("Press h to toggle help on and off, 1 to 4 to add a lane of the respective type, r to reset, and s to save.\n" +
        "When hovering a lane, press + to add more obstacles, - to get rid of an obstacle, , to lower speed, . to up speed", 0, 0, width, height);
      return;
    }
    
    for (int i = 0; i < lanes.size(); i++) {
      lanes.get(i).show(); // Draw the lanes
      if (selectedLane == i) {
      }
    }
    
    if (newLaneButtonSelected()) newLaneButton.show();
    for (Rectangle r : laneTypeSelectors)
        r.show();
    
    if (saving) { // If the player is typing in their level name
      String prompt = "What would you like to call your level?";
      assets.defaultFont(height / 8); // This gives us the number of lines
      text(prompt, 0, 0, width, height / 2);
      text(levelName.toString(), 0, height / 2, width, height / 2);
    }
  }

  public void handleInput() {
    if (saving) { // If the user is typing in their level's name
      if (keyCode == BACKSPACE || keyCode == DELETE) {
        if (levelName.length() == 0) // If they backspace with no characters left, we go back
          saving = false;
        else
          levelName.deleteCharAt(levelName.length() - 1);
      } else if (key != '.') { // If they don't press enter/return, 
        levelName.append(key); // we add the pressed key if it is valid
      }
      return; // We don't want to respond to keys when the user is typing in the name
    }
    
    if (keyCode == ENTER || keyCode == RETURN) select();
    else if (key == 'h') showHelp = !showHelp;
    else if (key == 'n') newLane(SAFETY);
    else if (key == 'r') level.clearRows();
    else if (key == 's') {
      boolean destLaneExists = false;
      for (Lane l : lanes) if (l.type == DESTINATION) destLaneExists = true;
      if (!destLaneExists)
        warningMillis = millis();
      else saving = true;
    }
  }
  
  private void select() {
    if (saving) {
      saveTable(level, "data/levels/" + levelName + ".csv"); // We save the table under data/levels as a .csv file
      loadState(MENUSTATE); // And return to the menu
      return;
    }
  }

  private void newLane(int type) { // If only a type is passed, we init the lane with 1 obstacle with length 1, 2 apart and with a speed of 2
    newLane(type, 1, 1, 2, 2);
  }

  private void newLane(int type, int numObstacles, float len, float spacing, float speed) {
    newLaneButton.y += tileSize;
    for (Rectangle r : laneTypeSelectors) r.y += tileSize;
    
    int index = lanes.size();
    lanes.add(new Lane(index, type, numObstacles, len, spacing, speed));
    lanes.get(index).setBounds(0, 0, width, tileSize);
    
    TableRow lane = level.addRow();
    lane.setInt("type", type);
    lane.setInt("numObstacles", numObstacles);
    lane.setFloat("len", len);
    lane.setFloat("spacing", spacing);
    lane.setFloat("speed", speed);
  }
  
  private boolean newLaneButtonSelected() {
    return selectedLane == lanes.size();
  }

}

public class Button extends Rectangle { // Just something that the user can click on

  private float fontSize;
  private String text;
  
  public Button(Rectangle r, String text) {
    // We set the coords and dimensions of the button to the provided rectangle
    super(r.x, r.y, r.w, r.h, r.col);
    this.text = text;
    float ratio = (textAscent() + textDescent()) / textWidth(text);
    fontSize = w * ratio;
  }
  
  public void show() {
    super.show();
    assets.defaultFont(fontSize);
    text(text, x, y, w, h);
  }
  
  public void onPress() {
    
  }
  
}
