// We declare variables at the top of our code, and never use hardcoded values,
// using ratios of the width and height instead
int dotSize;
float borderW, borderH;

int autoClickSpeed = 3;
int prevFrame = 0;

color WHITE = color(255);
color BLACK = color(0);
color RED = color(255, 0, 0);
color GREEN = color(0, 255, 0);
int hue, saturation, brightness;

Rect canvas;
ColourSelector colourSelector;
BrightnessSlider brightnessSlider;
Data data;

ArrayList<Point> points = new ArrayList<Point>();

// Note: the height must be at least a quarter of the width!
void setup() {
  size(1024, 640, P2D);
  
  // Although not entirely necessary, this makes sure that our program will run
  // similarly on most machines
  smooth();
  frameRate(120);
  
  // We initialize most of the variables here, using ratios
  dotSize = min(width, height) / 64;
  borderW = width / 64.0;
  borderH = height / 32.0;
  
  hue = 0;
  saturation = 0;
  brightness = width;
  
  initHotkeys();
  
  // Initialize all of our GUI elements
  canvas = new Rect(width / 4, borderH * 2, width * 3 / 4 - borderW, height - borderH * 3);
  colourSelector = new ColourSelector();
  brightnessSlider = new BrightnessSlider();
  data = new Data();
  
  // Here we set the environment variables for the remainder of the program
  colorMode(HSB, colourSelector.sideLength, colourSelector.sideLength, width);
  ellipseMode(CENTER);
  
  // Start with a white background
  background(WHITE);
}

void draw() {
  // We update once every frame
  update();
  
  // We show all of the individual components
  canvas.show();
  brightnessSlider.show();
  colourSelector.show();
  data.show();
  for (Point p : points)
    p.show();
}

void mousePressed() {
  // We draw a dot if the user clicks on the canvas
  if (!hotkeys.get("autoclick").enabled && canvas.hovered())
    drawDot();
}

void keyPressed() {
  for (Command c : hotkeys.values())
    // We check for both the hotkey and the key code
    if (key == c.hotkey || ((key == CODED) && c.coded && (keyCode == c.code)))
      c.onPress();
}

void update() {
  // We update all of the components
  brightnessSlider.update();
  colourSelector.update();
  for (Point p : points)
    p.update();
    
  if (mousePressed) {
    // If the mouse is on the canvas and enough frames have passed with autoclick turned on
    if (hotkeys.get("autoclick").enabled && canvas.hovered() && frameCount - prevFrame >= autoClickSpeed) {
      // We format the coordinates of the mouse into a string, which we print
      println(String.format("x: %d, y: %d", mouseX, mouseY));
      drawDot();
      prevFrame = frameCount;
    }
  }
}

void drawDot() {
  // Depending on whether the randomize hotkeys are enabled, we adjust the dot accordingly
  int size = hotkeys.get("randomSize").enabled ? int(random(1, borderH)) : dotSize;
  float h = hotkeys.get("randomHue").enabled ? random(colourSelector.sideLength) : hue;
  float s = hotkeys.get("randomSaturation").enabled ? random(colourSelector.sideLength) : saturation;
  float b = hotkeys.get("randomBrightness").enabled ? random(width) : brightness;
  
  points.add(new Point(mouseX, mouseY, size, color(h, s, b)));
}
