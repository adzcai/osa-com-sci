// We declare variables at the top of our code, and never use hardcoded values,
// using ratios of the width and height instead
int dotSize;
float borderW, borderH;

// We initialize a few constants using RGB here, since we switch to HSB in setup
color WHITE = color(255);
color BLACK = color(0);
color RED = color(255, 0, 0);
color GREEN = color(0, 255, 0);
int hue, saturation, brightness;

// Different sections of the screen
Rect canvas;
ColourSelector colourSelector;
BrightnessSlider brightnessSlider;
Data data;

ArrayList<Line> lines;

// Note: the height must be at least a quarter of the width!
void setup() {
  size(1024, 640, P2D);
  
  // We initialize most of the variables here, using ratios instead of hardcoded values
  dotSize = min(width, height) / 64;
  borderW = width / 64.0;
  borderH = height / 32.0;
  
  // Initial colors
  hue = 0;
  saturation = 0;
  brightness = width;
  
  initHotkeys();
  
  // Initialize all of our GUI elements
  canvas = new Rect(width / 4, borderH * 2, width * 3 / 4 - borderW, height - borderH * 3);
  colourSelector = new ColourSelector();
  brightnessSlider = new BrightnessSlider();
  data = new Data();
  
  lines = new ArrayList<Line>(); // Initialize the arraylist of lines
  
  // Here we set the environment variables for the remainder of the program
  smooth();
  frameRate(120);
  colorMode(HSB, colourSelector.sideLength, colourSelector.sideLength, width);
  ellipseMode(CENTER);
}

void draw() {
  // We update once every frame
  update();
  
  // We show all of the individual components on a white background
  background(WHITE);
  canvas.show();
  brightnessSlider.show();
  colourSelector.show();
  data.show();
  for (Line l : lines) l.show();
}

void mousePressed() {
  // When the mouse gets pressed, we start a new line
  if (canvas.hovered())
    lines.add(new Line());
}

void keyPressed() {
  for (Command c : hotkeys.values())
    // We check for both the hotkey and the key code, based on the command's requirements
    if (key == c.hotkey || ((key == CODED) && c.coded && (keyCode == c.code)))
      c.onPress();
}

void update() {
  // We update all of the components
  brightnessSlider.update();
  colourSelector.update();
  for (Line l : lines) l.update();
  
  if (mousePressed && canvas.hovered()) {
    // We format the coordinates of the mouse into a string, which we print
    println(String.format("x: %d, y: %d", mouseX, mouseY));
    addToCurrLine();
  }
}

void addToCurrLine() {
  // Depending on whether the randomize hotkeys are enabled, we adjust the dot accordingly
  int size = hotkeys.get("randomSize").enabled ? int(random(1, borderH)) : dotSize;
  float h = hotkeys.get("randomHue").enabled ? random(colourSelector.sideLength) : hue;
  float s = hotkeys.get("randomSaturation").enabled ? random(colourSelector.sideLength) : saturation;
  float b = hotkeys.get("randomBrightness").enabled ? random(width) : brightness;
  
  getCurrLine().addPoint(mouseX, mouseY, size, color(h, s, b));
}

Line getCurrLine() {
  return lines.get(lines.size() - 1);
}
