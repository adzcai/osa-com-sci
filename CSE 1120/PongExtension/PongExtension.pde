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

import java.util.Iterator;

int resetTimer; // Keeps track of the frame that the player "dies" so that we can wait for a second before resuming
boolean paused;
int points; // Incremented whenever the ball hits the paddle

// We declare the variables that are going to be used to store information about the game
Board wall;
Paddle paddle;
Ball ball;

// Fonts and strings for displaying the menu
PFont titleFont;
PFont labelFont;
ArrayList<Effect> effects;
int selection;

// Powerups
ArrayList<Powerup> powerups;
ArrayList<PowerupIcon> powerupsOnScreen;

// We initialize colours as constants before setup to avoid ambiguity
color WHITE = color(255);
color BLACK = color(0);
color YELLOW = color(255, 255, 0);
color RED = color(255, 0, 0);
color GREEN = color(0, 0, 255);

// At the start, we simply set up the game and initialize variables
void setup() {
  size(640, 480, P3D);
  frameRate(60);
  
  imageMode(CENTER);
  textAlign(CENTER, CENTER);
  
  noStroke();
  smooth();
  background(BLACK);
  
  // We extend the wall past the top and bottom of the screen so that the ball cannot escape through the corners
  // and initialize the objects we will use in the game
  wall = new Board(width * 63 / 64, -height / 4, 0, width / 64, height * 3 / 2, height * 3 / 2);
  paddle = new Paddle();
  ball = new Ball();
  
  titleFont = createFont("Arial", min(width, height) / 16, true);
  labelFont = createFont("Arial", min(width, height) / 24, true);
  
  effects = new ArrayList<Effect>();
  powerups = new ArrayList<Powerup>();
  powerupsOnScreen = new ArrayList<PowerupIcon>();
  
  // See Effects.pde and Powerups.pde
  initEffects();
  initPowerups();
  
  // We begin with the game paused to show the menu
  paused = true;
  points = 0;
  resetTimer = -1;
}

void draw() {
  float z = sqrt(pow(width / 2, 2) - pow(mouseX - width / 2, 2));
  camera(mouseX, mouseY, z, width/2, height/2, 0, 0, 1, 0);
    
  if (paused) {
    showMenu();
  } else {
    background(BLACK);
    
    // We update all of the game's components before drawing each frame
    update();
    
    fill(WHITE);
    textFont(titleFont);
    text(points, width / 2, height / 8);
    
    wall.show();
    paddle.show();
    ball.show();
  }
}

void keyPressed() {
  if (key == ' ') paused = !paused;
  
  if (paused && key == CODED) {
    if (keyCode == UP && selection > 0)
      // If the user presses the up button, we move the selection up, and vice versa
        selection--;
    if (keyCode == DOWN && selection < effects.size() - 1)
        selection++;
  } else if (key == ENTER || key == RETURN) {
    // We toggle the selected effect
    effects.get(selection).enabled = !effects.get(selection).enabled;
  }
}

void showMenu() {
  fill(WHITE);
  textFont(titleFont);
  text("Pong", width / 2, height / 4);
  
  textFont(labelFont);
  text("By Alex Cai\n" +
    "Press space to pause/resume", width / 2, height / 3);
  
  int y = height / 2;
  float textHeight = textAscent() + textDescent();
  for (int i = 0; i < effects.size(); i++) {
    // If it is selected, we hightlight in yellow. Otherwise, we highlight in green if it is enabled and red if it is not
    if (selection == i) fill(YELLOW);
    else fill(effects.get(i).enabled ? GREEN : RED);
    
    text(effects.get(i).desc, width / 2, y);
    y += textHeight;
  }
}

void update() {
  // We know the game is not paused, so we test to see if the player has recently died and we should resume it yet (after 1 second)
  // If we do, we simply reset the ball and set playing to true
  if (resetTimer >= 0) {
    if (frameCount > resetTimer + frameRate) {
      ball = new Ball();
      resetTimer = -1;
    } else {
      fill(WHITE);
      textFont(titleFont);
      text("GAME OVER", width / 2, height / 2);
    }
  } else {
    // We update the components. Remember above, this is only called as long as the game is not paused.
    ball.update();
    paddle.update();
    for (Effect e : effects) e.update();
    
    Iterator itr = powerupsOnScreen.iterator();
    while (itr.hasNext()) { // We use an iterator to be able to remove items more efficiently
      PowerupIcon pi = (PowerupIcon) itr.next();
      pi.show();
      pi.pos.add(pi.vel);
      
      if (pi.pos.x < 0)
        itr.remove();
      else if (paddle.contains(pi.pos)) // The player catches the icon
        for (Powerup p : powerups)
          if (p.desc == pi.desc) p.update();
    }
  }
}
