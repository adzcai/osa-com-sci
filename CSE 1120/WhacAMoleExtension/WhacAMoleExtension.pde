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

// Variables to track the state of the game
int points = 0; // 1 minute =  60 seconds = 60 * 1000 milliseconds
int numMillis = 60 * 1000;
int resetMillis = 0;
int remainingSeconds = 0;
int millisPaused = 0;

// We set up the screen, drawing a square window
void setup() {
  size(640, 640, P3D);
  noStroke();
  ellipseMode(CENTER);
  textAlign(CENTER, CENTER);
  frameRate(60);
  
  titleFont = createFont("Arial", height / 32);
  labelFont = createFont("Arial", height / 64);
  
  // We initialize the arraylist of holes, making sure that the balls are spaced evenly along the width, and alternating the height
  holes = new ArrayList<Hole>(numHoles);
  for (int i = 0; i < numHoles; i++)
    holes.add(new Hole(width / (numHoles + 1) * (i + 1), i % 2 == 0 ? height / 3 : height * 2 / 3));
  hammer = new Hammer();
}

// Every frame, we update all of the holes (and the moles inside them), the hammer, and then show them
void draw() {
  background(BG_COLOR);
  if (paused) {
    textFont(titleFont);
    text("Whac-A-Mole!\nby Alexander Cai\nPress SPACE to continue.\nYour points: " + points, width / 2, height / 2);
    return;
  }
  
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
}

void keyPressed() {
  if (key == ' ') {
    if (paused) unpause();
    else pause();
  }
}

void mousePressed() {
  hammer.direction = 1; // We swing the hammer downwards
}

void pause() {
  millisPaused = millis();
  paused = true;
}

void unpause() {
  if (remainingSeconds <= 0) points = 0; // If time has ran out, we reset the state of the game
  resetMillis += millis() - millisPaused;
  paused = false;
}
