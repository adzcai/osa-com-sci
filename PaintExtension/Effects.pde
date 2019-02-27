PVector gravity = new PVector(0, 9.8);
float speedScale = 1;

HashMap<String, Command> hotkeys = new HashMap<String, Command>();

// We initialize different hotkeys
void initHotkeys() {
  hotkeys.put("randomBrightness", new Command('b', "Randomize brightness"));
  hotkeys.put("clear", new Command('c', "Clear points", false) {
    public void onPress() {
      points.clear();
      background(WHITE);
      canvas.show();
    }
  });
  hotkeys.put("darkMode", new Command('d', "Dark mode"));
  hotkeys.put("gravity", new Command('g', "Apply gravity"));
  hotkeys.put("randomHue", new Command('h', "Randomize hue"));
  hotkeys.put("randomMovement", new Command('m', "Randomize Movement"));
  hotkeys.put("resetMovement", new Command('q', "Reset Movement", false) {
    public void onPress() {
      for (int i = 0; i < points.size(); i++) {
        Point p = points.get(i);
        points.set(i, new Point(p.pos.x, p.pos.y, p.dim, p.colour));
      }
    }
  });
  hotkeys.put("randomSize", new Command('r', "Randomize size"));
  hotkeys.put("randomSaturation", new Command('s', "Randomize saturation"));
  hotkeys.put("autoclick", new Command('t', "Toggle auto-click") {
    @Override
    public String description() {
      return super.description() + " (" + str(autoClickSpeed) + ")";
    }
  });
  hotkeys.put("motion", new Command(' ', "Apply physics"));
  
  hotkeys.put("incSpeed", new Command('=', "Speed all up") {
    public void onPress() { speedScale *= 1.0625; }
  });
  hotkeys.put("decSpeed", new Command('-', "Speed all down") {
    public void onPress() { if (speedScale > 0) speedScale /= 1.0625; }
  });
  
  hotkeys.get("motion").enabled = true;
  hotkeys.get("randomBrightness").enabled = true;
  
  // Lambdas would have made this easier but from what I can gather Processing doesn't fully
  // support Java 8
  hotkeys.put("incAutoClick", new Command(UP, "Speed up auto-click", false) {
    public void onPress() { autoClickSpeed++; }
  });
  hotkeys.put("decAutoClick", new Command(DOWN, "Slow down auto-click", false) {
    public void onPress() { if (autoClickSpeed > 0) autoClickSpeed--; }
  });
  hotkeys.put("incDotSize", new Command(RIGHT, "Increase dot size", false) {
    @Override
    public void onPress() { if (dotSize < borderH * 2) dotSize++; }
    
    @Override
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

public class Point {
  PVector pos, velocity, accel;
  float dim;
  color colour;
  
  public Point(float x, float y, float d, color c) {
    pos = new PVector(x, y);
    velocity = new PVector(0, 0);
    accel = new PVector(0, 0);
    dim = d;
    colour = c;
  }
  
  // Called every frame, draws the point
  public void show() {
    fill(colour);
    noStroke();
    ellipse(pos.x, pos.y, dim, dim);
  }
  
  public void update() {
    if (!hotkeys.get("motion").enabled) return;
    pos.add(velocity.mult(speedScale));
    checkBoundaries();
    
    println(speedScale);
    
    if (hotkeys.get("gravity").enabled) velocity.add(gravity);
    if (hotkeys.get("randomMovement").enabled) velocity.add(PVector.random2D());;
  }
  
  // If it goes beyond the canvas bounds, we flip the velocity and move the ball to the boundary.
  private void checkBoundaries() {
    if (pos.x < canvas.x) {
      velocity.x *= -1;
      pos.x = canvas.x;
    } else if (pos.x > canvas.x + canvas.w) {
      velocity.x *= -1;
      pos.x = canvas.x + canvas.w;
    }
    
    if (pos.y < canvas.y) {
      velocity.y *= -1;
      pos.y = canvas.y;
    } else if (pos.y > canvas.y + canvas.h) {
      // If it hits the ground we absorb a small bit of the energy
      velocity.y *= -0.95;
      pos.y = canvas.y + canvas.h;
    }
  }
}
