import java.util.Arrays;
import java.util.Comparator;

// A generic class for a rectangle
class Rect {
  public float x, y, w, h;
  
  public Rect(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  // General show function, usually overriden in subclasses
  public void show() {
    fill(hotkeys.get("darkMode").enabled ? BLACK : WHITE);
    stroke(BLACK);
    strokeWeight(borderW / 4.0);
    rect(x, y, w, h);
  }
  
  // Check if the mouse is within the rectangle's bounds
  public boolean hovered() {
    return mouseX >= x && mouseX <= x + w && 
      mouseY >= y && mouseY <= y + h;
  }
}

// The rectangle where we click to select a colour
class ColourSelector extends Rect {
  float sideLength;
  
  // A rectangle, we specify the coords and dimensions here
  ColourSelector() {
    super(borderW, borderH * 2, width / 4.0 - 2 * borderW, width / 4.0 - 2 * borderW);
    sideLength = width / 4.0 - 2 * borderW;
  }
  
  // Draws the square where the user will click to choose a colour
  public void show() {
    for (int i = 0; i < this.sideLength; i++) {
      for (int j = 0; j < this.sideLength; j++) {
        stroke(i, j, brightness);
        point(this.x + i, this.y + j);
      }
    }
  }
  
  public void update() {
    // If the mouse is on the colour selector, select the colour
    if (mousePressed && this.hovered()) {
      hue = mouseX - int(borderW);
      saturation = mouseY - int(borderH * 2);
    }
  }
}

class BrightnessSlider extends Rect {
  public BrightnessSlider() {
    super(0, 0, width, borderH);
  }
  
  // We draw a gradient from black to white from left to right
  public void show() {
    super.show();
    for (int i = 0; i < brightness; i++) {
      stroke(0, 0, i);
      line(i, 0, i, borderH);
    }
  }
  
  public void update() {
    // If the mouse is on the brightness slider, change the brightness
    if (mousePressed && hovered()) brightness = mouseX;
  }
}

class Data extends Rect {
  private PFont labelFont;
  
  // We draw it underneath the colour selector
  public Data() {
    super(borderW, borderH * 3 + colourSelector.sideLength, width / 4.0 - borderW * 2, height - borderH * 4 - colourSelector.sideLength);
    labelFont = createFont("Arial", (h / (hotkeys.size() + 1)) / 1.25);
  }
  
  public void show() {
    fill(WHITE);
    noStroke();
    rect(x, y, w, h);
    
    // We create an array of the hotkeys and sort them by their descriptions
    Command[] sorted = hotkeys.values().toArray(new Command[0]);
    Arrays.sort(sorted, new Comparator<Command>() {
      public int compare(Command c1, Command c2) {
        int c1Key = c1.hotkey == '\0' ? c1.code : c1.hotkey;
        int c2Key = c2.hotkey == '\0' ? c2.code : c2.hotkey;
        
        if (c1Key > c2Key) return 1;
        else if (c1Key < c2Key) return -1;
        else return 0;
      }
    });
    
    float textHeight = textAscent() + textDescent();
    float y = (height + borderH * 2 + colourSelector.sideLength - (hotkeys.size() + 1) * textHeight) / 2;
    
    textFont(labelFont);
    textAlign(CENTER, TOP);
    
    // Show the selected colour
    color currColor = color(hue, saturation, brightness);
    fill(hue, saturation, brightness);
    text("Selected colour: #" + hex(currColor).substring(2, 8), width / 8.0, y);
    y += textHeight;
    
    // Write the rest of the hotkeys below
    for (Command c : sorted) {
      // We use a ternary to indicate if it is on or off if it is toggleable
      if (c.toggleable) fill(c.enabled ? GREEN : RED);
      else fill(BLACK);
      
      text(c.description(), width / 8.0, y);
      y += textHeight;
    }
  }
}
