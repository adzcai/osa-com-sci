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

int hits = 0;
int mins = 0;

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
  hammer.update();
  for (Hole h : holes) h.update();
  
  background(LIGHT_BLUE);
  for (Hole h : holes) h.show();
  hammer.show();
}

void mousePressed() {
  hammer.direction = 1;
}

class Hammer {
  float w, len, cornerR;
  int direction;
  float angle, speed;
  PShape shape;
  
  Hammer() {
    shape = createShape(GROUP);
  
    w = width / 32;
    len = w * 4;
    cornerR = width / 128;
    
    PShape handle = createShape(RECT, -w / 2, -len + w / 2, w, len, cornerR);
    handle.setFill(BROWN);
    shape.addChild(handle);
    
    PShape head = createShape(RECT, -w, -len + w, w * 2, w, cornerR);
    head.setFill(BLACK);
    shape.addChild(head);
    
    speed = PI / 2 / frameRate;
    angle = 0;
  }
  
  void update() {
    if (direction == 1) {
      angle += speed;
      if (angle >= PI / 2) direction = -1;
    } else if (direction == -1) {
      angle -= speed;
      if (angle <= 0) direction = 0;
    }
  }
  
  void show() {
    pushMatrix();
    translate(mouseX, mouseY);
    rotate(hammer.angle);
    shape(shape);
    popMatrix();
  }
}

class Hole {
  PVector pos;
  float diameter;
  Mole mole;
  
  Hole(float x, float y) {
    pos = new PVector(x, y);
    diameter = width / 8;
    mole = new Mole(this);
  }
  
  void update() {
    mole.update();
  }
  
  void show() {
    fill(BLACK);
    ellipse(pos.x, pos.y, diameter, diameter);
    mole.show();
  }
}

class Mole {
  boolean visible;
  PVector pos;
  
  float speed;
  Hole hole;
  
  int direction;
  int startFrame, upFrame, downFrame, endFrame;
  float upTime;
  float spacing;
  
  PShape shape;
  
  Mole(Hole hole_) {
    hole = hole_;
    pos = new PVector(hole.pos.x, hole.pos.y + hole.diameter / 2);
    visible = false;
    speed = hole.diameter * 2 / frameRate;
    
    // We want the mole to stay up for a second, and appear every 2 seconds
    startFrame = upFrame = downFrame = endFrame = 0;
    upTime = frameRate * 2;
    spacing = frameRate * 8;
    
    float r = width / 48;
    
    shape = createShape(GROUP);
    PShape head = createShape(ELLIPSE, 0, 0, r * 2, r * 2);
    PShape body = createShape(RECT, -r, 0, r * 2, r * 2);
    PShape tail = createShape(ELLIPSE, 0, r * 2, r * 2, r * 2);
    
    shape.addChild(head);
    shape.addChild(body);
    shape.addChild(tail);
    
    shape.setFill(BROWN);
  }
  
  void update() {
    println(startFrame, upFrame, downFrame, endFrame);
    if (frameCount - endFrame >= spacing) { // If enough time has passed since it went down
      visible = true; // Make it visible
      direction = -1; // We make it start going up
      startFrame = frameCount; // Record the current frame
    }
    
    // If the mole has been up for long enough, we start moving it down
    if (upFrame > startFrame && frameCount - upFrame >= upTime) direction = 1;
    
    if (direction == -1) {
      pos.y -= speed;
      if (pos.y <= hole.pos.y - hole.diameter / 2) { // If the mole reaches the top
        pos.y = hole.pos.y - hole.diameter / 2; // We set it to the top so that it does not go past
        direction = 0; // Stop it from moving
        upFrame = frameCount; // Record the current frame
      }
    } else if (direction == 1) {
      pos.y += speed;
      if (pos.y >= hole.pos.y + hole.diameter / 2) { // If the mole has retreated back into the hole
        visible = false; // We set its visibility to false
        direction = 0; // We stop it from moving
        endFrame = frameCount; // And record the current frame
      }
    }
  }
  
  void show() {
    if (!visible) return;
    translate(pos.x, pos.y);
    shape(shape);
  }
}
