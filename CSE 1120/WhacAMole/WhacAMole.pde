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

color LIGHT_BLUE = color(128, 128, 255);
color BLACK = color(0);
color BROWN = color(165, 42, 42);

// We create an array storing the holes, of which there are 5, and keep track of data
// with other classes
int numHoles = 5;
ArrayList<Hole> holes;
Hammer hammer;

int points = 0; // 3 minutes = 3 * 60 seconds = 3 * 60 * 1000 milliseconds
int numMillis = 3 * 60 * 1000;

// We set up the screen, drawing a square window
void setup() {
  size(640, 640, P2D);
  noStroke();
  ellipseMode(CENTER);
  frameRate(60);
  
  // We initialize the arraylist of holes with the number of holes
  holes = new ArrayList<Hole>(numHoles);
  for (int i = 0; i < numHoles; i++)
    holes.add(new Hole(width / (numHoles + 1) * (i + 1), i % 2 == 0 ? height / 3 : height * 2 / 3));
  hammer = new Hammer();
}

void draw() {
  background(LIGHT_BLUE);
  
  for (Hole h : holes) h.update();
  hammer.update();
  
  for (Hole h : holes) h.show();
  hammer.show();
  
  fill(BLACK);
  int remainingSeconds = (numMillis - millis()) / 1000;
  text(String.format("%d%n%02d:%02d", points, remainingSeconds / 60, remainingSeconds % 60), width / 2, height / 8);
}

void mousePressed() {
  hammer.direction = 1; // We swing the hammer downwards
}
