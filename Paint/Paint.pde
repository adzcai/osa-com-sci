/*
Course Project - Paint by Dot

Pointillism is a technique of in which small, distinct dots of color are applied in
patterns to form an image.The technique relies on the ability of the eye and mind of
the viewer to blend the color spots into a fuller range of tones. Georges Seurat used
this technique in famous painting A Sunday Afternoon on the Island of La Grande Jatte. 

Program (65%) Create a program that creates allows the user to make their own
pointillism painting similar to the Seurat by using their mouse as a paint brush to
paint dots on a white screen (or canvas).  The colours should be randomly assigning
colour and the window size large enough to allow detail and expression. Print out the
location of the mouse (x and y coordinates). Include comments describing what different
sections of code do and good coding practices. 

Extension (25%) In a new file create a copy of your program and include different
functions for multiple colours including: red, green, and blue. The user should be able
to pick a colour and the computer should randomly assign a shade or tone to that colour.
Add some additional features and creativity of your own.

Description (10%)  Present your program to your teacher and answer questions about the
code and overall program. 
*/

// We declare variables at the top of our code, and never use hardcoded values,
// using ratios of the width and height instead
float dotSize;

void setup() {
  size(1024, 640, P2D);
  
  // Although not entirely necessary, this makes sure that our program will run
  // similarly on most machines
  smooth();
  frameRate(60);
  colorMode(RGB);
  
  // We make the dots an appropriate size
  dotSize = min(width, height) / 64;
  
  background(255);
}

// We do not actually need a draw function, as drawing should only occur when the user
// clicks, which is handled by mousePressed() below. However, the program does not run
// without a draw function, so we simply leave it empty.
void draw() {
  
}

void mousePressed() {
  // We format the coordinates of the mouse into a string, which we print
  println(String.format("x: %d, y: %d", mouseX, mouseY));
  
  // Choosing a random RGB color, then drawing an dot at the mouse with it
  color c = color(random(255), random(255), random(255));
  fill(c);
  ellipseMode(CENTER);
  ellipse(mouseX, mouseY, dotSize, dotSize);
}
