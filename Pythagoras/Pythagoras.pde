/*
The Pythagorean theorem is a relationship between the sides in a right triangle. A right
triangle is a triangle where one of the three angles is an 90-degree angle. In a right
triangle the sides are called legs and hypotenuse. 

Program (75%) Create a program that creates a black window that is 800 by 800 pixels. The
program should draw a triangle that has a base 120 pixels in length and a height that is
90 pixels in length.  Choose a colour that makes the triangle standout. Determine the
length of the hypotenuse and display it to the screen. Allow the user to be able to
expand the triangle by moving the mouse horizontally or vertically (you choose).
The lengths of the sides should correspond with the movement of the mouse. Include
comments describing what different sections of code do and good coding practices. 

Extension (15%) Rewrite your code so that they user can expand the triangle both
horizontally and vertically.  Add some additional features and creativity of your own

Interview (10%)  Present your program to your teacher and answer questions about the code
and overall program. 
*/

// The extension 
boolean extension = true;

// Here we name constants using all caps, which is a common practice, and define them
color BLACK = color(0);
color WHITE = color(255);
color RED = color(255, 0, 0);
color GREEN = color(0, 255, 0);
color BLUE = color(0, 0, 255);

PFont labelFont;

float DEFAULTWIDTH = 120;
float DEFAULTHEIGHT = 90;

// We declare all the variables at the top of our code
float hypotenuse;
float triW, triH;
float theta;

// We set the framerate and smoothness to ensure that the program runs the same
// on all platforms
void setup() {
  size(800, 800, P2D);
  frameRate(60);
  smooth();
  
  labelFont = createFont("Arial", width / 32);
  textFont(labelFont);
}

void draw() {
  background(BLACK);
  fill(WHITE);
  stroke(WHITE);
  
  if (extension) { // We map the coordinates of the mouse to the width and height of the screen
    triW = map(mouseX, 0, width, DEFAULTWIDTH, width);
    triH = map(mouseY, 0, height, DEFAULTHEIGHT, height);
    explainColours(); // Explain the colours in the top left corner
  } else { // We only listen to the mouseX and adjust the height using similar triangles
    triW = map(mouseX, 0, width, DEFAULTWIDTH, width);
    triH = DEFAULTHEIGHT * triW / DEFAULTWIDTH;
  }
  
  // This translation centers the plane on the top left vertex of the triangle,
  // making the coordinates more intuitive
  translate((width - triW) / 2, (height - triH) / 2);
  
  fill(WHITE);
  triangle(0, 0, 0, triH, triW, triH);
  drawLabels(); // Labels the vertices and lengths
  
  if (extension) drawTriangleLines();
}

void explainColours() {
  textAlign(LEFT, TOP);
  float h = (labelFont.ascent() + labelFont.descent()) * labelFont.getSize();
  fill(RED);
  text("medians", width / 64, height / 64);
  fill(GREEN);
  text("angle bisectors", width / 64, height / 64 + h);
  fill(BLUE);
  text("perpendicular bisectors", width / 64, height / 64 + h * 2);
}

void drawLabels() {
  fill(WHITE);
  
  // Label the vertices
  textAlign(CENTER, BOTTOM);
  text('A', 0, 0);
  textAlign(RIGHT, BOTTOM);
  text('B', 0, triH);
  textAlign(LEFT, BOTTOM);
  text('C', triW, triH);
  
  // Label the sidelengths
  textAlign(RIGHT, BOTTOM);
  text(triH, 0, triH / 2);
  textAlign(CENTER, TOP);
  text(triW, triW / 2, triH);
  textAlign(LEFT, BOTTOM);
  text(hypotenuse(triW, triH), triW / 2, triH / 2);
  
  drawRightAngle(0, triH, 0);
}

void drawTriangleLines() {
  drawMedians();
  drawAngleBisectors();
  drawPerpendicularBisectors();
}

void drawMedians() {
  stroke(RED);
  fill(RED);
  line(0, 0, triW / 2, triH);
  line(0, triH, triW / 2, triH / 2);
  line(triW, triH, 0, triH / 2);
  
  textAlign(LEFT, BOTTOM);
  text('G', triW / 3, triH * 2 / 3);
}

void drawAngleBisectors() {
  stroke(GREEN);
  fill(GREEN);
  
  PVector ac = new PVector(triW, triH); // This is only used to calculate the angles
  
  theta = (PI/2 - ac.heading()) / 2;
  line(0, 0, triH * tan(theta), triH);
  
  // We do some math to calculate where the angle bisector of <ABC intersects AC
  float x = (triW * triH) / (triW + triH);
  line(0, triH, x, triH - x);
  
  line(triW, triH, 0, triH - tan(ac.heading() / 2) * triW);
  
  // I did a little bit of math to calculate where the angle bisectors intersect
  float intX = (triH * tan(theta))/(1+tan(theta));
  textAlign(LEFT, BOTTOM);
  text('I', intX, triH - intX);
  
  float d = getInradius() * 2;
  noFill();
  ellipse(intX, triH - intX, d, d);
}

void drawPerpendicularBisectors() {
  PVector hyp = new PVector(-triW, -triH);
  drawRightAngle(triW / 2, triH / 2, PI / 2 - hyp.heading());
  
  // To get the perpendicular, we cross it with a vector pointing towards the screen
  hyp = hyp.cross(new PVector(0, 0, 1));
  
  stroke(BLUE);
  float x = tan(PI / 2 - hyp.heading()) * triH / 2;
  if (abs(x) > (triW / 2))
    line(triW / 2, triH / 2, 0, triH / 2 - tan(hyp.heading()) * triW / 2);
  else
    line(triW / 2, triH / 2, triW / 2 + x, triH);
  
  // since it's a right triangle, the circumcenter is the midpoint of the hypotenuse
  // and we can avoid doing a lot more math
  line(0, triH / 2, triW / 2, triH / 2);
  drawRightAngle(0, triH / 2, 0);
  stroke(BLUE);
  
  line(triW / 2, triH, triW / 2, triH / 2);
  drawRightAngle(triW / 2, triH, 0);
  stroke(BLUE);
  
  float d = hypotenuse(triW, triH);
  noFill();
  ellipse(triW / 2, triH / 2, d, d);
  
  textAlign(LEFT, BOTTOM);
  fill(BLUE);
  text('O', triW / 2, triH / 2);
}

void drawRightAngle(float x, float y, float yangle) {
  float s = sqrt(triW * triH / 2) / 16;
  
  pushMatrix();
  noFill();
  stroke(BLACK);
  rectMode(CORNERS);
  
  // We do a few transformations to draw the square with its bottom left corner at (x, y)
  translate(x, y);
  rotate(-yangle - PI / 2);
  rect(0, 0, s, s);
  popMatrix();
}

float hypotenuse(float a, float b) {
  // simple Pythagorean theorem application
  return sqrt(pow(a, 2) + pow(b, 2));
}

float getInradius() {
  // We use A = rs = bh / 2 to calculate the inradius
  float area = triW * triH / 2;
  float semiP = (triW + triH + hypotenuse(triW, triH)) / 2;
  return area / semiP;
}
