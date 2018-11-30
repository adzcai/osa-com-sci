/*
Assignment 3 - Whac-A-Mole

A typical Whac-A-Mole machine consists of a large, waist-level cabinet with five holes in
its top and a large, soft, black mallet. Each hole contains a single plastic mole and the
machinery necessary to move it up and down. Once the game starts, the moles will begin to
pop up from their holes at random. The object of the game is to force the individual 
moles back into their holes by hitting them directly on the head with the mallet, thereby
adding to the player's score. The more quickly this is done the higher the final score 
will be.

Program (75%) Create a program that emulates a typical Whac-A-Mole game. There should be
a clock counting down and a scoring system determining how many hits the user has. 
Include comments describing what different sections of code do and good coding practices. 

Extension (15%) Make the game more challenging by changing the location of the mole, 
changing the time the mole is visible, etc. Add some additional features and creativity
of your own.

Description (10%)  Present your program to your teacher and answer questions about the
code and overall program. 
*/

final color BG_COLOR = color(128, 128, 255);
final color BOX_COLOR = color(0, 255, 0);
final color GREEN = color(0, 255, 0);
final color PINK = color(255, 192, 203);
final color WHITE = color(255);
final color BLACK = color(0);
final color BROWN = color(165, 42, 42);

// When paused is true, we display the menu screen
boolean paused = true;

PFont titleFont;
PFont labelFont;

// We create an array storing the holes, of which there are 5, and keep track of data
// with other classes
int numHoles = 5;
ArrayList<Hole> holes;
Hammer hammer;
PShape gameBox;

// Variables to track the state of the game
int points = 0; // 1 minute =  60 seconds = 60 * 1000 milliseconds
int numMillis = 60 * 1000;
int resetMillis = 0;
int remainingSeconds = 0;
int millisPaused = 0;

float cameraY;
float cameraX;

// We set up the screen, drawing a square window
void setup() {
  size(640, 640, P3D);
  noStroke();
  ellipseMode(CENTER);
  textAlign(CENTER, CENTER);
  frameRate(60);
  
  titleFont = createFont("Arial", height / 16);
  labelFont = createFont("Arial", height / 32);
  
  // We initialize the arraylist of holes, making sure that the balls are spaced evenly along the width, and alternating the height
  holes = new ArrayList<Hole>(numHoles);
  for (int i = 0; i < numHoles; i++) {
    float x = -width / 2 + width / (numHoles + 1) * (i + 1);
    float z = i % 2 == 0 ? height / 4 : -height / 4;
    holes.add(new Hole(x, z));
  }
  hammer = new Hammer();
  gameBox = cylinder(4, sqrt(pow(width / 2, 2) + pow(height / 2, 2)), height / 2);
  gameBox.rotateY(PI / 4);
  
  cameraY = 0;
  cameraX = width / 2;
}

// We center the coordinate system on the center of the box
// Every frame, we update all of the holes (and the moles inside them), the hammer, and then show them
void draw() {
  camera(cameraX, cameraY, height / 2, width / 2, height / 2, 0, 0, 1, 0);
  lights();
  
  background(BG_COLOR);
  
  if (paused) {
    camera(width / 2, height / 2, width / 2, width/2, height/2, 0, 0, 1, 0);
    textFont(titleFont);
    text("Whac-A-Mole!\nby Alexander Cai\nPress SPACE to continue.\nYour points: " + points, width / 2, height / 2);
    return;
  }
  
  translate(width / 2, height / 2);
  shape(gameBox);
  
  for (Hole h : holes) h.update();
  hammer.update();
  
  for (Hole h : holes) h.show();
  hammer.show();
  
  // We display the points and the remaining time
  fill(BLACK);
  remainingSeconds = (numMillis - millis() + resetMillis) / 1000;
  textFont(labelFont);
  text(String.format("%d%n%02d:%02d", points, remainingSeconds / 60, remainingSeconds % 60), width / 2, height / 8);
  
  // If it is 0, we pause the game
  if (remainingSeconds <= 0) pause();
  
  if (keyPressed && key == CODED) {
    if (keyCode == LEFT) cameraX -= width / 16;
    if (keyCode == RIGHT) cameraX += width / 16; 
    if (keyCode == UP) cameraY -= height / 16;
    if (keyCode == DOWN) cameraY += height / 16;
  }
}

void keyPressed() {
  if (key == ' ') { // We pause/unpause the game
    if (paused) unpause();
    else pause();
  }
}

void mousePressed() {
  hammer.direction = 1; // We swing the hammer downwards
}

void pause() {
  millisPaused = millis(); // We track the number of milliseconds, so we can continue where we left off
  paused = true; // pause
}

void unpause() {
  if (remainingSeconds <= 0) points = 0; // If time has ran out, we reset the state of the game
  resetMillis += millis() - millisPaused; // We add the amount of time paused, so that the timer resumes where we left off
  paused = false; // unpause
}

PShape gameBox() {
  PShape s = createShape();
  s.setFill(BOX_COLOR);
  s.beginShape(QUAD_STRIP);
  s.vertex(-width / 2, -height / 2);
  s.vertex(width / 2, -height / 2);
  s.vertex(width / 2, height / 2);
  s.vertex(-width / 2, height / 2);
  s.vertex(-width / 2, -height / 2);
  
  for (Hole h : holes) {
    println("h.pos.x", h.pos.x, "h.pos.y", h.pos.y);
    s.beginContour();
    for (int i = 12; i >= 0; i--) {
      float theta = i * 2 * PI / 12;
      s.vertex(h.pos.x + h.r * cos(theta), h.pos.y + h.r * sin(theta));
      println(h.pos.x + h.r * cos(theta), h.pos.y + h.r * sin(theta));
    }
    s.endContour();
  }
  
  s.endShape();
  
  return s;
}

/**
 * @returns a PShape of a {sides}-sided prism of radius r and height h
 */
PShape cylinder(int sides, float r, float h) {
  PShape result = createShape(GROUP);
  float theta = 2 * PI / sides;
  PShape cyl = createShape();
  PShape face1 = createShape();
  PShape face2 = createShape();
  
  cyl.beginShape(TRIANGLE_STRIP);
  face1.beginShape();
  face2.beginShape();
  
  for (int i = 0; i < sides; i++) {
    cyl.vertex(r * cos(i * theta), 0, r * sin(i * theta));
    face1.vertex(r * cos(i * theta), 0, r * sin(i * theta));
    cyl.vertex(r * cos(i * theta), h, r * sin(i * theta));
    face2.vertex(r * cos(i * theta), h, r * sin(i * theta));
  }
  
  // We connect it back to the beginning
  cyl.vertex(r, 0, 0);
  cyl.vertex(r, h, 0); 
  
  cyl.endShape(CLOSE);
  face1.endShape(CLOSE);
  face2.endShape(CLOSE);
  
  result.addChild(cyl);
  result.addChild(face1);
  result.addChild(face2);
  return result;
}
