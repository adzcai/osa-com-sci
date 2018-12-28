public class Assets {

  public PFont arcadeFont;
  public color[] laneColors;
  
  public PImage[] sprites;
  public PImage[] dest;
  public PImage[][] frog;
  public PImage[] death;

  public Assets(int w, int h) {
    arcadeFont = createFont("arcade.ttf", h / 8); // We load in the arcade font, in the data folder

    // We could have initialized these at the beginning,
    // but doing it in Assets makes it more centralized and clear and allows us to use the constants
    // we declared earlier
    laneColors = new color[NUMROADTYPES];
    laneColors[SAFETY] = color(0, 255, 0);
    laneColors[ROAD] = color(0);
    laneColors[STREAM] = color(0, 0, 255);
    laneColors[DESTINATION] = color(0, 255, 0);

    frog = new PImage[2][]; // Up and sideways
    frog[0] = loadSpriteSheet("sprites/frogfd.png", 12, 14);
    frog[1] = loadSpriteSheet("sprites/frogside.png", 14, 12);
    death = loadSpriteSheet("sprites/death.png", 16, 16);
    dest = loadSpriteSheet("sprites/dest.png", 16, 16);

    sprites = new PImage[NUMOBSTACLETYPES];
    sprites[CAR] = loadImage("sprites/car.png");
    sprites[LOG] = loadImage("sprites/log.png");
    sprites[HOME] = new PImage(16, 16); // Just an empty image
    sprites[ALLIGATOR] = loadImage("sprites/alligator.png");
  }

  public Lane[] loadLanes(String path) {
    Table data = loadTable(path, "header"); // We load the data from the table
    Lane[] lanes = new Lane[data.getRowCount()]; // We initialize an array of lanes. Each row in the table corresponds to a lane
    
    int counter = 0;
    for (TableRow row : data.rows()) { // For each of the rows
      // We add the lane specified by the data to the lanes array
      lanes[counter] = new Lane(counter,
        row.getInt("type"),
        row.getInt("numObstacles"),
        row.getInt("len"),
        row.getFloat("spacing"),
        row.getFloat("speed"));
      counter++;
    }
    return lanes;
  }

  public PImage[] loadSpriteSheet(String path, int w, int h) {
    PImage img = loadImage(path);
    int numFrames = img.width / w;

    PImage[] ret = new PImage[numFrames]; // Initialize the array to be returned as the result
    for (int i = 0; i < numFrames; i++) // For each of the frames,
      ret[i] = img.get(i * w, 0, w, h); // we crop the corresponding w * h image from the spritesheet

    return ret;
  }

}
