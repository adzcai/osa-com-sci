final int NUMSLIDES = 12;
final float LERPAMT = 0.1; // The fraction of the distance between the current position and the next, causing a sliding effect

PImage[] timeline = new PImage[NUMSLIDES]; // Array where we store the images of the slides
int imgW = 0, imgH = 0; // Width and height of each image
int currentSlide = 0; // Index of the current slide
int dir = 0; // The direction the slide is moving, using the keyCodes of the arrow keys

PVector slidePos = new PVector();
PVector dest = new PVector(); // Where the current slide is going
PVector catchPoint = new PVector(5, 5); // The distance between slidePos and dest such that they're close enough to switch to the next slide

void setup() { // We set up the application and load in our images
  size(720, 405); // These are the original dimensions of the images exported by PowerPoint
  imageMode(CORNER);
  frameRate(60);
  smooth();
  noStroke();
  
  // For each of the slides, we load it into its corresponding position in the timeline[] array
  for (int i = 0; i < NUMSLIDES; i++)
    timeline[i] = loadImage("Slide" + (i + 1) + ".png"); // We increase by 1 because PowerPoint exports its slides using a 1-based index
    
  imgW = timeline[0].width;
  imgH = timeline[0].height;
}

void draw() {
  if (dir != 0) // If the slide is moving
    slidePos = PVector.lerp(slidePos, dest, LERPAMT); // We move the slidePos towards dest
  if (abs(slidePos.x - dest.x) < catchPoint.x && abs(slidePos.y - dest.y) < catchPoint.y) // if the current slide's position approaches the destination position
    finishAnimation(); // We stop moving
  
  // Draw the current frame and next frame, subtracting the dest vector since it points in the opposite direction
  image(timeline[currentSlide], slidePos.x, slidePos.y, width, height); // Draw the current frame of the timeline
  image(timeline[nextSlideIndex()], slidePos.x - dest.x, slidePos.y - dest.y, width, height);
}

void keyPressed() {
  // We skip the rest if the key pressed is not coded (i.e. is a character key) or if the slide is already moving;
  if (key != CODED || dir != 0) return;
  
  dir = keyCode; // We set the direction to the keyCode first...
  
  if (keyCode == UP && currentSlide > 0)
    dest = new PVector(0, imgH);
  else if (keyCode == LEFT && currentSlide > 0)
    dest = new PVector(imgW, 0);
  else if (keyCode == DOWN && currentSlide < NUMSLIDES - 1)
    dest = new PVector(0, -imgH);
  else if (keyCode == RIGHT && currentSlide < NUMSLIDES - 1)
    dest = new PVector(-imgW, 0);
  else // If none of the arrow keys are actually pressed
    dir = 0;
}

void finishAnimation() {
  currentSlide = nextSlideIndex();
  dir = 0;
  dest = new PVector();
  slidePos = new PVector();
}

int nextSlideIndex() { // Gets the next slide's index based on the current direction
  if (dir == UP || dir == LEFT) return currentSlide - 1;
  else if (dir == RIGHT || dir == DOWN) return currentSlide + 1;
  else return currentSlide;
}
