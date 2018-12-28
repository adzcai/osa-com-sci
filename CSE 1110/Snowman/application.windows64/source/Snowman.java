import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Snowman extends PApplet {

/*
Assignment 1 - Snowman

Do you remember back when you were in elementary school? You might have had to draw a picture representing the weather.
Imagine it is a nice winter day.  The sun is shining, the birds singing and there is snow on the ground.
Your assignment is to create a program that draws a snowman on a warm winter day similar to the painting on the right.

Program (75%) Create a program that sketches a white snowman with a a blue sky, green tree.
Include a corn cob pipe and a button nose, and two eyes made of coal.
Finally include the old silk hat that brings him to life.
You decide on the size of the background but make sure it is enough for the entire image.
Include comments describing what different sections of code do and good coding practices.

Extension (15%) Rewrite your code so that the center of the hat follows the mouse around the screen.
Add some additional features and creativity of your own.

Interview (10%) Present your program to your teacher and answer questions about the code and overall program.
*/

// We declare all of the variables at the top, where they can all be easily found, putting constants in all caps.
// Since draw() is called multiple times, by doing this we also make sure the computer is not continually declaring new variables,
// thus increasing the speed of the program.

// If this value is true, it will add all of the extensions into the program
boolean extension = true;

// Here I use a ternary operator for brevity
String dim = extension ? P3D : P2D;

int BLACK = color(0);
int WHITE = color(255);
int RED = color(255, 0, 0);
int GREEN = color(0, 255, 0);
int LIGHTBLUE = color(96, 96, 255);
int YELLOW = color(255, 255, 0);
int BROWN = color(128, 64, 0);

// The position of the sky colour between light blue and red
float inter = pow(2, -3);
float sunsetRate = 1.25f;

// We use polar coordinates so that it rotates through the sky
float sunTheta = -PI / 8;
float sunR;
float sunDiameter;

float snowmanCenterX;
float snowballCenterY;
float snowballR;
float snowballRatio = 1.25f;

float treeCenterX;
float treeTopY, actualTreeTopY = -1;
float baseWidth, baseH;
int numTriangles = 5;
int numDecorations = 5;
boolean flashLights = false;

float baseScale = 0.8f;

float hatColour = 32;
float hatX, hatY;

int[][] orbColours = new int[numTriangles][numDecorations];
float[][] orbXs = new float[numTriangles][numDecorations];

int flashTimer = 0;

public void setup() {
  
  
  if (extension) noStroke();
  frameRate(30);
  
  sunR = width * 3 / 4;
  sunDiameter = height / 4;
  
  treeCenterX = width / 4;
  baseWidth = width / 4;
  
  if (extension) {
    generateOrbColours();
    generateOrbCoords();
  }
}

/**
 * I try to keep the draw method simple so that people who read my code
 * have a general idea of what it does before going into the individual
 * functions.
 */
public void draw() {
  rectMode(CENTER);
  ellipseMode(CENTER);
  background(lerpColor(LIGHTBLUE, RED, inter));
  if (extension) {
    // Here we use the pythagorean theorem to calculate the z, or
    // How far the camera is from the physical screen
    float z = sqrt(pow(width / 2, 2) - pow(mouseX - width / 2, 2));
    camera(mouseX, mouseY, z, width/2, height/2, 0, 0, 1, 0);
  }
  
  drawSun();
  drawGround();
  drawSnowman();
  
  // If at least 5 frames have passed since the last time the lights flashed,
  // we change the colours of the lights and set the timer to the current frame count
  if (flashLights && (frameCount > (flashTimer + 5))) {
    generateOrbColours();
    flashTimer = frameCount;
  }
  
  drawTree();
  drawHat();
  saveFrame("original.png");
}

/**
 * Toggles whether or not the lights are flashing.
 */
public void mousePressed() {
  flashLights = !flashLights;
}

/**
 * Handles the ways different keys are pressed. Left and right move the sun.
 */
public void keyPressed() {
  if (!extension) return;
  if (key == CODED) {
    if (keyCode == LEFT && sunTheta >= (-PI / 2)) {
      sunTheta -= 0.05f;
      inter /= sunsetRate;
    } else if (keyCode == RIGHT && sunTheta <= (PI / 8)) {
      sunTheta += 0.05f;
      inter *= sunsetRate;
    }
  }
}

/**
 * Generates random colours for each of the lights.
 */
public void generateOrbColours() {
  for (int i = 0; i < numTriangles; i++)
    for (int j = 0; j < numDecorations; j++)
      orbColours[i][j] = color(random(255), random(255), random(255));
}

/**
 * Generates random positions along the bottom of each triangle of each tree
 */
public void generateOrbCoords() {
  for (int i = 0; i < numTriangles; i++) {
    for (int j = 0; j < numDecorations; j++)
      orbXs[i][j] = random(baseWidth) - baseWidth / 2;
    baseWidth *= baseScale;
  }
}

public void drawGround() {
  fill(WHITE);
  if (extension) {
    rectMode(CENTER);
    pushMatrix();
    translate(width / 2, height * 3 / 4);
    rotateX(PI / 2);
    rect(0, 0, width, width);
    popMatrix();
  } else {
    rectMode(CORNER);
    rect(0, height * 2 / 3, width, height / 3);
  }
}

/**
 * We move the origin to the leftmost point on the ground, which the sun orbits around.
 * Then we convert the polar coordinates (which are easier to rotate with) to
 * cartesian coordinates (which are easier for the computer to draw), draw the sun and a little
 * halo around it, and finally move the origin back to where it was.
 */
public void drawSun() {
  pushMatrix();
  translate(0, height * 2 / 3);
  float x = sunR * cos(sunTheta);
  float y = sunR * sin(sunTheta);
  
  if (extension) {
    // We make the sun give off light from inside the sun, but slightly towards the screen to give
    // an impression of depth. Then we shade the entire scene according to the time of day.
    pointLight(255, 255, 128, x, y, -width / 4 + sunDiameter / 2);
    ambientLight(-y/2, -y/2, -y/2, 0, 1, -1);
  } else {
    noStroke();
    // This draws the halo around the sun. There's not an easy way to do this in 3D
    float alpha = 0;
    for (float r = sunDiameter * 2; r > sunDiameter; r -= sunDiameter / 128) {
      fill(255, 191, 128, alpha);
      ellipse(x, y, r, r);
      alpha += 0.1f;
    }
    stroke(0);
  }
  
  fill(YELLOW);
  if (extension) {
    // We draw the sun slightly behind so that it doesn't overlap with the tree or the snowman
    translate(x, y, -width / 4);
    sphere(sunDiameter / 2);
  } else {
    ellipse(x, y, sunDiameter, sunDiameter);
  }
  popMatrix();
}

public void drawSnowman() {
  // This block draws the snowman by drawing the first circle on the ground, and
  // decreasing the radius as you draw the higher circles.
  fill(WHITE);
  snowmanCenterX = width * 3 / 4;
  snowballCenterY = height * 2 / 3;
  snowballR = height / 8;
  for (int i = 0; i < 3; i++) {
    if (extension) {
      pushMatrix();
      translate(snowmanCenterX, snowballCenterY);
      sphere(snowballR);
      popMatrix();
    } else {
      ellipse(snowmanCenterX, snowballCenterY, 2 * snowballR, 2 * snowballR);
    }
    snowballCenterY -= snowballR;
    snowballR /= snowballRatio;
  }
  
  // Now we reset snowballCenterY to the actual center of the snowball so that we have an accurate
  // reference point for the rest of the face, which we then draw. We also reverse the last division of r so that snowballR
  // is the radius of the top ball.
  snowballR *= snowballRatio;
  snowballCenterY += snowballR;
  
  // Then we give him a corn cob pipe...
  fill(BROWN);
  if (extension) {
    stroke(BROWN);
    pushMatrix();
    
    translate(snowmanCenterX, snowballCenterY);
    rotateY(PI/8);
    translate(0, 0, snowballR);
    drawRectPrism();
    translate(0, 0, snowballR * 5 / 4);
    rotateX(PI / 2);
    drawRectPrism();
    
    popMatrix();
    noStroke();
  } else {
    rectMode(CORNER);
    rect(snowmanCenterX - snowballR, snowballCenterY + snowballR * 2 / 5, snowballR, snowballR / 5); // horizontal part
    rect(snowmanCenterX - snowballR * 5 / 4, snowballCenterY, snowballR / 4, snowballR * 3 / 5); // vertical part
  }
  
  // and a button nose...
  fill(RED);
  if (extension) {
    pushMatrix();
    translate(snowmanCenterX, snowballCenterY, snowballR);
    sphere(snowballR / 4);
    popMatrix();
  } else {
    ellipse(snowmanCenterX, snowballCenterY, snowballR / 4, snowballR / 4);
  }
  
  // and two eyes made out of coal
  fill(BLACK);
  if (extension) {
    pushMatrix();
    translate(snowmanCenterX, snowballCenterY);
    rotateX(PI / 8);
    
    pushMatrix();
    rotateY(PI / 8);
    translate(0, 0, snowballR);
    sphere(snowballR / 8);
    popMatrix();
    
    pushMatrix();
    rotateY(-PI / 8);
    translate(0, 0, snowballR);
    sphere(snowballR / 8);
    popMatrix();
    popMatrix();
  } else { 
    ellipse(snowmanCenterX - snowballR / 3, snowballCenterY - snowballR / 4, snowballR / 8, snowballR / 8);
    ellipse(snowmanCenterX + snowballR / 3, snowballCenterY - snowballR / 4, snowballR / 8, snowballR / 8);
  }
  
  // Since h is now at the topmost point of the snowman, we can use it to
  // get the base of the hat.
  if (!extension) {
    hatX = snowmanCenterX;
    hatY = snowballCenterY;
  } else {
    hatX = mouseX;
    hatY = mouseY + snowballR;
  }
}

public void drawTree() {
  fill(BROWN);
  treeTopY = height / 8;
  
  // We only draw the trunk if the actual y of the top of the tree has been initialized.
  if (actualTreeTopY > 0) {
    if (extension)
      pyramid(treeCenterX, height * 3 / 4, width / 16, -actualTreeTopY);
    else
      triangle(width * 7 / 32, height * 3 / 4, treeCenterX, actualTreeTopY, width * 9 / 32, height * 3 / 4);
  }
  // We draw the triangles by drawing one, then scaling the size and height smaller.
  // The top point of the triangle is halfway between its base and TreeTopY, which is why
  // we later need to initialize the actual top of the tree
  baseH = height * 5 / 8;
  baseWidth = width / 4;
  for (int i = 0; i < numTriangles; i++) {
    fill(GREEN);
    if (extension) {
      pyramid(treeCenterX, baseH, baseWidth, treeTopY - baseH);
    } else {
      // Here I separate each coordinate on a different line for easier readability
      triangle(treeCenterX - baseWidth / 2, baseH,
             treeCenterX, (baseH + treeTopY) / 2,
             treeCenterX + baseWidth / 2, baseH);
    }
    if (extension) drawDecorations(i);
    baseH *= baseScale;
    baseWidth *= baseScale;
  }
  
  // To get the actual top of the tree if it is not initialized, we simply move the base
  // back down one triangle and add the height of that triangle.
  if (actualTreeTopY < 0) {
    baseH /= baseScale;
    actualTreeTopY = treeTopY + (baseH - treeTopY / 2);
  }
}

public void drawHat() {
  rectMode(CORNER);
  fill(hatColour);
  ellipse(hatX, hatY - snowballR, snowballR * 2, snowballR / 2);
  rect(hatX - snowballR * 2 / 3, hatY - snowballR * 2, snowballR * 4 / 3, snowballR);
  ellipse(hatX, hatY - snowballR * 2, snowballR * 4 / 3, snowballR / 2);
}

/**
 * Draws the decorations for a given triangle on the tree
 */
public void drawDecorations(int triNum) {
  for (int i = 0; i < numDecorations; i++) {
    fill(orbColours[triNum][i]);
    if (extension) {
      for (int j = 0; j < 4; j++) {
        pushMatrix();
        translate(treeCenterX, baseH);
        rotateY(PI * j / 2);
        translate(orbXs[triNum][i], 0, baseWidth / 2);
        sphere(baseWidth * 32 / height);
        // Poo, you can only create up to 8 lights
        // pointLight(red(orbColours[triNum][i]), blue(orbColours[triNum][i]), green(orbColours[triNum][i]), 0, 0, 0);
        popMatrix();
      }
    } else {
      ellipse(treeCenterX + orbXs[triNum][i], baseH, baseWidth * 32 / height, baseWidth * 32 / height);
    }
  }
}

/**
 * This function draws a rectangular prism by zigzagging along vertices on the opposite bases
 */
public void drawRectPrism() {
  beginShape(TRIANGLE_STRIP);
  vertex(-snowballR / 10, -snowballR / 10, 0);
  vertex(-snowballR / 10, -snowballR / 10, snowballR * 5 / 4);
  vertex(snowballR / 10, -snowballR / 10, 0);
  vertex(snowballR / 10, -snowballR / 10, snowballR * 5 / 4);
  vertex(snowballR / 10, snowballR / 10, 0);
  vertex(snowballR / 10, snowballR / 10, snowballR * 5 / 4);
  vertex(-snowballR / 10, snowballR / 10, 0);
  vertex(-snowballR / 10, snowballR / 10, snowballR * 5 / 4);
  // I don't know why passing CLOSE to endShape doesn't connect the first and last vertices like it should,
  // so I manually do it here
  vertex(-snowballR / 10, -snowballR / 10, 0);
  vertex(-snowballR / 10, -snowballR / 10, snowballR * 5 / 4);
  endShape(CLOSE);
}

/**
 * We draw a pyramid with a given x and y of the base, sidelength, and height
 * by drawing each face individually
 */
public void pyramid(float x, float y, float s, float h) {
  float left = x - s/2;
  float right = x + s/2;
  float top = -s/2;
  float bottom = s/2;
  
  stroke(0);
  
  beginShape(TRIANGLES);
  vertex(left, y, bottom);
  vertex(left, y, top);
  vertex(x, y + h, 0);
  
  vertex(left, y, top);
  vertex(right, y, top);
  vertex(x, y + h, 0);
  
  vertex(right, y, top);
  vertex(right, y, bottom);
  vertex(x, y + h, 0);
  
  vertex(right, y, bottom);
  vertex(left, y, bottom);
  vertex(x, y + h, 0);
  endShape(CLOSE);
  
  noStroke();
}
  public void settings() {  size(640, 480, dim);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Snowman" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
