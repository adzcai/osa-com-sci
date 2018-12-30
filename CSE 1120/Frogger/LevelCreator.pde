
// It's similar to a level, but not enough for making it a subclass to be useful
public class LevelCreator implements GameState {

  private Rectangle newLaneButton;
  private Rectangle[] laneTypeSelectors;

  private ArrayList<Lane> lanes;
  private Table level;

  private float tileSize;

  private boolean saving = false;
  private String levelName = "";

  public void init() {
    lanes = new ArrayList<Lane>();
    level = new Table();
    level.addColumn("type");
    level.addColumn("numObstacles");
    level.addColumn("len");
    level.addColumn("spacing");
    level.addColumn("speed");

    tileSize = height / 12; // The default height for a lane
    textFont(assets.arcadeFont, tileSize);
    newLaneButton = new Rectangle((width - textWidth("New lane")) / 2, 0, textWidth(" New lane "), textAscent() + textDescent(), color(255, 0, 0));

    float colW = newLaneButton.w / NUMLANETYPES;
    laneTypeSelectors = new Rectangle[NUMLANETYPES];
    for (int i = 0; i < NUMLANETYPES; i++) {
      laneTypeSelectors[i] = new Rectangle(newLaneButton.x + colW * i, newLaneButton.y, colW, newLaneButton.h, assets.laneColors[i]);
    }
  }

  public void update() {
    if (mousePressed && newLaneButton.hovered())
      for (int i = 0; i < NUMLANETYPES; i++)
        if (laneTypeSelectors[i].hovered()) newLane(i);
  }

  public void show() {
    background(0);
    for (Lane l : lanes) l.show();
    showNewLaneButton();
    
    if (saving) {
      String prompt = "What would you like to call your level?";
      textFont(assets.arcadeFont, height / 8); // This gives us the number of lines
      textAlign(CENTER, CENTER);
      fill(255);
      text(prompt, 0, 0, width, height / 2);
      text(levelName, 0, height / 2, width, height / 2);
    }
  }

  public void handleInput() {
    if (saving) {
      if (keyCode == ENTER || keyCode == RETURN) {
        saveTable(level, "data/levels/" + levelName + ".csv");
        loadState(MENUSTATE);
        return;
      }
      levelName += key;
      return;
    }
    if (key == 'n') newLane(SAFETY);
    if (key == 's') saving = true;
  }

  private void showNewLaneButton() {
    if (newLaneButton.hovered()) {
      for (Rectangle r : laneTypeSelectors) r.show();
    } else {
      newLaneButton.show();
      textFont(assets.arcadeFont, tileSize);
      textAlign(CENTER, CENTER);
      fill(255);
      text("New lane", newLaneButton.x, newLaneButton.y, newLaneButton.w, newLaneButton.h);
    }
  }

  private void newLane(int type) {
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

}
