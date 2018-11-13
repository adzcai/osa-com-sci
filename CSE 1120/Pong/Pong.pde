/*
Assignment 2 - Pong

Pong is one of the earliest arcade video games. It is a table tennis sports game
featuring simple two-dimensional graphics. The game was originally manufactured by
Atari, which released it in 1972. The player controls an in-game paddle by moving it
vertically across the left or right side of the screen. They can compete against another
player or the computer. Players use the paddles to hit a ball back and forth. As with
most tennis and table tennis practice often involves an athlete hitting a ball against a
barrier or wall.
https://www.youtube.com/watch?v=fiShX2pTz9A

Program (75%) Create a program that emulates a training session for the game Pong.
There should be one panel controlled by a player using the Up and Down arrows and a ball
that bounces off the far wall and comes back to them. Create a scoring system where the 
player is awarded a point for each time they play the ball. Include comments describing
what different sections of code do and good coding practices.

Extension (15%) Make the game more challenging by changing the speed of the ball, 
changing the size of the paddle, etc. Add some additional features and creativity of your
own.

Description (10%)  Present your program to your teacher and answer questions about the 
code and overall program. 
*/

boolean extension = false; // Whether or not to enable the extension

int resetTimer; // Keeps track of the frame that the player "dies" so that we can wait for a second before resuming
boolean paused;

int points; // Incremented whenever the ball hits the paddle

// We declare the variables that are going to be used to store information about the game
Board wall;
Paddle paddle;
Ball ball;

// We initialize colours as constants before setup to avoid ambiguity
color WHITE = color(255);
color BLACK = color(0);

// At the start, we simply set up the game and initialize variables
void setup() {
  size(640, 480, P2D);
  textAlign(CENTER, CENTER);
  noStroke();
  frameRate(60);
  smooth();
  
  // We extend the wall past the top and bottom of the screen so that the ball cannot escape through the corners
  // and initialize the objects we will use in the game
  wall = new Board(width * 63 / 64, -height / 4, width / 64, height * 5 / 4);
  paddle = new Paddle();
  ball = new Ball();
  
  paused = false;
  points = 0;
  resetTimer = -1;
}

void draw() {
  // TODO: set up a menu screen
  if (paused) {
    return;
  }
  
  // We update all of the game's components before drawing each frame
  update();
  
  // We draw all of the components
  background(BLACK);
  text(points, width / 2, height / 8);
  wall.show();
  paddle.show();
  ball.show();
}

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  }
}

void update() {
  // We know the game is paused, so we test to see if we should resume it yet (after 1 second)
  // If we do, we simply reset the ball and set playing to true
  if (resetTimer >= 0 && frameCount > resetTimer + frameRate) {
    ball = new Ball();
    resetTimer = -1;
  } else {
    // We update the components. Remember above, this is only called as long as the game is not paused.
    ball.update();
    paddle.update();
  }
}
