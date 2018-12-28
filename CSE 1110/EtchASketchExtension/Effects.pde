PVector gravity = new PVector(0, 9.8);
float speedScale = 1; // How much the speed gets affected

// Maps hotkeys to commands
HashMap<String, Command> hotkeys = new HashMap<String, Command>();

// We initialize different hotkeys (see below). The names are descriptive, so there is minor commenting.
// Also note that the methods need to be public in order to be visible from the main class
void initHotkeys() {
  // Clearing things
  hotkeys.put("clear", new Command(' ', "Clear all", false) {
    public void onPress() {
      lines.clear();
      background(WHITE);
      canvas.show();
    }
  });
  hotkeys.put("clearMotion", new Command('c', "Clear motion", false) {
    public void onPress() {
      for (int i = 0; i < lines.size(); i++) { // For each of the lines,
        Line l = lines.get(i);
        Line temp = new Line(); // We create a new line
        for (Point p : l.points)
          temp.addPoint(p.pos.x, p.pos.y, p.dim, p.col); // With the same points, without motion
          
        lines.set(i, temp); // Which we replace it with
      }
    }
  });
  hotkeys.put("darkMode", new Command('d', "Dark mode"));
  
  // Motion, and the speed of motion
  hotkeys.put("motion", new Command('p', "Apply physics"));
  hotkeys.get("motion").enabled = true;
  hotkeys.put("gravity", new Command('g', "Apply gravity"));
  hotkeys.put("randomMovement", new Command('m', "Randomize Movement"));
  hotkeys.put("incSpeed", new Command('=', "Speed all up") {
    public void onPress() { speedScale *= 1.0625; }
  });
  hotkeys.put("decSpeed", new Command('-', "Speed all down") {
    public void onPress() { if (speedScale > 0) speedScale /= 1.0625; }
  });
  
  // Dealing with the properties of the dot
  hotkeys.put("randomHue", new Command('h', "Randomize hue"));
  hotkeys.put("randomSaturation", new Command('s', "Randomize saturation"));
  hotkeys.put("randomBrightness", new Command('b', "Randomize brightness"));
  hotkeys.get("randomBrightness").enabled = true;
  hotkeys.put("randomSize", new Command('r', "Randomize size"));
  
  // Managing dot size
  hotkeys.put("incDotSize", new Command(RIGHT, "Increase dot size", false) {
    public void onPress() { if (dotSize < borderH * 2) dotSize++; }
    
    public String description() {
      return super.description() + " (" + str(dotSize) + ")";
    }
  });
  hotkeys.put("decDotSize", new Command(LEFT, "Decrease dot size", false) {
    public void onPress() { if (dotSize > 1) dotSize--; }
  });
}

public class Command {
  public boolean toggleable;
  public boolean enabled = false;
  
  public char hotkey;
  public boolean coded;
  public int code;
  
  public String desc;
  
  // Here we use function/constructor overloading, since it would be redundant
  // to introduce another parameter (coded or not)
  
  // Just with a hotkey and description
  public Command(char hk, String d) {
    this(hk, -1, d, true);
  }
  
  // With a key code and description
  public Command(int cd, String d) {
    this('\0', cd, d, false);
  }
  
  // With key code, description, and toggleable, sets hotkey to NUL
  public Command(int cd, String d, boolean t) {
    this('\0', cd, d, t);
  }
  
  // With hotkey, description, and toggleable, sets key code to -1
  public Command(char hk, String d, boolean t) {
    this(hk, -1, d, t);
  }
  
  // Determines whether it is coded or with a hotkey depending on which one
  // is -1 or NUL respectively, sets the properties
  public Command(char hk, int cd, String d, boolean t) {
    if (hk == '\0') {
      code = cd;
      coded = true;
    } else if (cd == -1) {
      hotkey = hk;
      coded = false;
    }
    
    desc = d;
    toggleable = t;
  }
  
  // Generally they simply toggle, if not it gets defined in the anonymous inner class above
  public void onPress() {
    enabled = !enabled;
  }
  
  public String description() {
    String result;
    
    // This is just to make sure each key gets displayed to the user correctly
    if (!coded) {
      result = hotkey == ' ' ? "SPACE" : Character.toString(hotkey);
    } else {
      switch (code) {
        case UP: result = "UP";        break;
        case DOWN: result = "DOWN";    break;
        case LEFT: result = "LEFT";    break;
        case RIGHT: result = "RIGHT";  break;
        default: result = "Error";
      }
    }
    result += ": " + desc;
    
    return result;
  }
}
