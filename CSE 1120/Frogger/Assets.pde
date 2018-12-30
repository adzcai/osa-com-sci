// These are constants for the different types of lanes and obstacles, which we put together for clarity
// The numbers don't really matter, except that they must be unique
public static final int NUMLANETYPES = 4, NUMSPRITES = 11,
  SAFETY = 0,
  ROAD = 1, CAR = 0, TRUCK = 1, RACECAR1 = 2, RACECAR2 = 3, RACECAR3 = 4,
  STREAM = 2, TURTLE = 5, ALLIGATOR = 6, LOG = 7, LONGLOG = 8,
  DESTINATION = 3, HOME = 9, HOMEALLIGATOR = 10, REACHED = 11;

// Stores all the images and Assets, etc. loaded from the data folder
public class Assets {

  public PFont arcadeFont;
  public color[] laneColors;
  
  private HashMap<String, PImage> sprites;
  private HashMap<String, PImage[]> spritesheets;

  public Assets(int w, int h) {
    arcadeFont = createFont("arcade.ttf", h / 8); // We load in the arcade font, in the data folder

    // We could have initialized these at the beginning,
    // but doing it in Assets makes it more centralized and clear and allows us to use the constants
    // we declared earlier
    laneColors = new color[NUMLANETYPES];
    laneColors[SAFETY] = color(0, 255, 0);
    laneColors[ROAD] = color(0);
    laneColors[STREAM] = color(0, 0, 255);
    laneColors[DESTINATION] = color(0, 255, 0);

    sprites = new HashMap<String, PImage>();
    spritesheets = new HashMap<String, PImage[]>();
    
    // We loop through all the files in the sprites folder
    String[] spriteNames = new File(sketchPath() + "/data/sprites").list();
    for (String name : spriteNames)
      // We get the name minus the extension, and load it into sprites
      sprites.put(name.split(".")[0], loadImage("sprites/" + name));
    
    // We can't really do the same for the spritesheets because they aren't all the same size
    spritesheets.put("snake", loadSpritesheet("sname", 30, 11));
    spritesheets.put("turtle", loadSpritesheet("turtle", 15, 11));
    spritesheets.put("reached", loadSpritesheet("reached", 16, 16));
    spritesheets.put("frog", loadSpritesheet("frog", 12, 14));
    spritesheets.put("death", loadSpritesheet("death", 16, 16));
  }

  private Lane[] loadLanes(String path) {
    Table data = loadTable(path, "header"); // We load the data from the table
    if (data == null) return new Lane[0];

    Lane[] lanes = new Lane[data.getRowCount()]; // We initialize an array of lanes. Each row in the table corresponds to a lane
    
    int counter = 0;
    for (TableRow row : data.rows()) { // For each of the rows
      // We add the lane specified by the data to the lanes array
      lanes[counter] = new Lane(counter,
        row.getInt("type"),
        row.getInt("numObstacles"),
        row.getFloat("len"),
        row.getFloat("spacing"),
        row.getFloat("speed"));
      counter++;
    }
    return lanes;
  }

  private PImage[] loadSpritesheet(String path, int w, int h) {
    PImage img = loadImage("spritesheets/" + path + ".png");
    int numFrames = img.width / w;
    PImage[] ret = new PImage[numFrames]; // Initialize the array to be returned as the result
    for (int i = 0; i < numFrames; i++) // For each of the frames,
      ret[i] = img.get(i * w, 0, w, h); // we crop the corresponding w * h image from the spritesheet
    return ret;
  }
  
  public void defaultFont(float size) {
    textFont(arcadeFont, size);
    textAlign(CENTER, CENTER);
    fill(255);
  }
  
  public boolean isSpritesheet(String name) {
    if (name.equals("turtle") ||
      name.equals("reached") ||
      name.equals("frog") ||
      name.equals("death")) return true;
    else return false;
  }
  
  public PImage getSprite(String name) { return sprites.get(name); }
  public PImage[] getSpritesheet(String name) { return spritesheets.get(name); }

}
