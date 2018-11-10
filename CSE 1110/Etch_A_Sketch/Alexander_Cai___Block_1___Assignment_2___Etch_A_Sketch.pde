/*
Assignment 2 - Etch-a-Sketch

An Etch A Sketch was a popular toy in 1960’s and 70’s. It had a thick, flat gray screen
in a red plastic frame. There are two white knobs on the front of the frame in the lower
corners. Twisting the knobs moved a stylus that displaces aluminum powder on the back of
the screen, leaving a solid line. The knobs create lineographic images. The left control
moves the stylus horizontally, and the right one moves it vertically. It was inducted
into the National Toy Hall of Fame in 1998.

Program (75%) Create a program that creates a white window that is 1000 by 800 pixels.
The program should allow the user to sketch a drawing in black based on the movement of
their mouse. It should also allow the user to erase their entire work base on pushing the
space bar. Include comments describing what different sections of code do and good coding
practices. 

Extension (15%) Rewrite your code so that when the user presses the mouse the pen is down
and makes a mark but when it is released it does not make a mark on the screen. Add some
additional features and creativity of your own.

Interview (10%)  Present your program to your teacher and answer questions about the code
and overall program. 
*/

boolean extension = true;

int prevMouseX = -1;
int prevMouseY = -1;

int hue;

void setup() {
  size(1000, 800);
  background(255);
  fill(255);
  strokeWeight(5);
  stroke(0);
  frameRate(60);
  colorMode(HSB);
}

void draw() {
  // Here, we check that the space key is being pressed. If it is, we fill the entire
  // screen with white.
  if (keyPressed && key == ' ') {
    noStroke();
    rect(0, 0, width, height);
    stroke(0);
  }
  
  // If the previous mouse coordinates have not been initialized, they are set to the
  // current mouse coordinates.
  if (prevMouseX <= 0 || prevMouseY <= 0) {
    prevMouseX = mouseX;
    prevMouseY = mouseY;
  }
  
  // If the extension is on and the mouse isn't pressed, don't draw
  if (extension && !mousePressed) {
    prevMouseX = prevMouseY = -1;
    return;
  }
  
  // We draw a line between the current mouse coordinates and the previous mouse
  // coordinates, with the current color if the extension is enabled.
  if (extension) stroke(hue, 255, 255);
  line(prevMouseX, prevMouseY, mouseX, mouseY);
  prevMouseX = mouseX;
  prevMouseY = mouseY;
  // We also change the color if the extension is enabled
  if (extension) hue = (hue + 1) % 255;
}
