/*
Course Project - Frogger

Frogger is a 1981 arcade game developed by Konami. The game starts with five frogs. These
are counted as the player's lives, and losing them results in the end of the game, or
"game over." The only player control is the 4 direction joystick used to navigate the
frog; each push in a direction causes the frog to hop once in that direction. 

The objective of the game is to guide each frog to one of the designated spaces at the
top of the screen, also known as "frog homes." The frog starts at the bottom of the 
screen, which contains a road with motor vehicles, which in various versions include 
cars, trucks, buses, dune buggies, bulldozers, vans, taxis, bicyclists and motorcycles,
speeding along it horizontally. The player must guide the frog between opposing lanes of
traffic to avoid becoming roadkill, which results in a loss of one life. After the road, 
this is a median strip where the player must prepare to navigate the river. The upper 
portion of the screen consists of a river with logs, alligators, and turtles, all moving
horizontally across the screen. By jumping on swiftly moving logs and the backs of turtles
and alligators the player can guide their frog to safety. While navigating the river, the 
player must also avoid the open mouths of alligators, snakes, and otters. The very top of
the screen contains five "frog homes," which are the destinations for each frog. The 
player must avoid alligators sticking out of the five "frog homes," but may catch bugs or
escort a lady frog which appear periodically for bonuses.

When all five frogs are directed home, the game progresses to the next level with 
increased difficulty. The player has 30 seconds to guide each frog into one of the homes;
this timer resets whenever a life is lost or a frog reaches home safely.
Every forward step scores 10 points, and every frog arriving safely home scores 50 
points. 10 points are also awarded per each unused ​1⁄2 second of time. When all five 
frogs reach home to end the level the player earns 1,000 points. 
https://www.youtube.com/watch?v=pTftp4Cam5k

Program (65%) Create a program that emulates the first level of this game. Please see the
video above for a better idea of game play. Do not worry about bonuses or a variation in 
size of the objects going across (basically each row has the same object moving across 
at random intervals). Do not worry about the animation of the frog.  Include comments
describing what different sections of code do and good coding practices. 

Extension (25%) Enhance this game including better presentation, challenge and creativity. Consider multiple levels and possible bonuses. Add some additional features and creativity of your own.

Description (10%)  Present your program to your teacher and answer questions about the 
code and overall program. 
*/

// We use variables to store the position of the frog
Frog frog;
Lane[] lanes;

int SAFETY = 0;
int CAR = 1;
int LOG = 2;

float grid = 50;

void resetGame() {
  frog = new Frog(width/2-grid/2, height-grid, grid);
  frog.attach(null);
}

void setup() {
  size(500, 550);
  //frog = new Frog(width/2-grid/2, height-grid, grid);
  resetGame();
  lanes = loadLanes("level1.csv");
}

void draw() {
  background(0); // We start with a black background
  for (Lane lane : lanes)
    lane.run();
  int laneIndex = int(frog.y / grid);
  lanes[laneIndex].check(frog);
  frog.update();
  frog.show();
}

void keyPressed() {
  int h = keyCode == RIGHT ? 1 : (keyCode == LEFT ? -1 : 0);
  int v = keyCode == UP ? -1 : (keyCode == DOWN ? 1 : 0);
  frog.move(h, v);
}

Lane[] loadLanes(String path) {
  Table data = loadTable(path, "header"); // We load the data from the table
  Lane[] lanes = new Lane[data.getRowCount()];
  
  int counter = 0;
  for (TableRow row : data.rows()) { // For each of the rows
    lanes[counter] = new Lane(counter, row.getInt("type"), row.getInt("numObstacles"), row.getInt("len"), row.getFloat("spacing"), row.getFloat("speed"));
    counter++;
  }
  return lanes;
}
