/*
Assignment 1 - Big Piano

Legendary actor Tom Hanks has won two Academy Awards for Best Actor in a Leading Role
(Philadelphia and Forrest Gump).  What may not be well known is that he received his
first nomination in this category for his work in the 1988 movie Big. Big is a movie
where Tom Hanks character Josh Baskin, a young boy, makes a wish “to be big” and is
then aged to adulthood overnight. In one of the movie’s most memorable moments is where
Josh visits the FAO Schwartz and plays a walking piano with the owner played by Robert
Laggio.  

https://www.youtube.com/watch?v=CF7-rz9nIn4

Program (75%) Create a program that makes the window look like a piano keyboard with a
maximum of 6 keys. When the user moves the mouse across the keyboard the different keys
should appear to light up (or get brighter). Include comments describing what different
sections of code do and good coding practices.

Extension (15%) Add sound to your piano. Add some additional features and creativity of
your own

Description (10%)  Present your program to your teacher and answer questions about the
code and overall program. 
*/


// We import the sound library and declare variables and initialize constants
import processing.sound.*;

// Whether or not to enable the extension
boolean extension = true;

// We initialize the colors as constants for later clarity
color BLACK = color(0);
color GREY = color(128);
color WHITE = color(255);

// A constant string of notes for referencing things like indices, half steps, etc
String[] NOTES = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
// We start the piano with different notes depending on whether or not the extension is enabled
String[] startingNotes;

// We initialize arraylists for different types of keys
ArrayList<PianoKey> whiteKeys = new ArrayList<PianoKey>();
ArrayList<PianoKey> blackKeys = new ArrayList<PianoKey>();
ArrayList<PianoKey> allKeys = new ArrayList<PianoKey>();

// Variables for making a sine wave sound more like a piano
float attackTime = 0.001;
float sustainTime = 0.004;
float sustainLevel = 0.2;
float releaseTime = 1;
Env env;

// Tracks whether to add a note that is sharp or flat
int adjust = 0;

// We setup the program and initialize several variables
void setup() {
  size(640, 480);
  smooth();
  frameRate(120);
  
  startingNotes = extension ?
    new String[] {"C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5"} :
    new String[] {"C4", "D4", "E4", "F4", "G4"};
    
  colorMode(HSB, startingNotes.length, 100, 100);
  
  // We initialize a key for each of the starting notes, and add it to the corresponding arraylist
  for (int i = 0; i < startingNotes.length; i++) {
    PianoKey toAdd = new PianoKey(startingNotes[i], new SinOsc(this), i);
    (startingNotes[i].length() == 2 ? whiteKeys : blackKeys).add(toAdd);
  }
  
  // See below; it was a lot of code to put in setup
  initKeyPositions();
  
  // We add all white keys and black keys to allKeys
  allKeys.addAll(whiteKeys);
  allKeys.addAll(blackKeys);
  
  // And finally initialize the env
  env = new Env(this);
}

void draw() {
  // We update and show all the keys
  for (PianoKey k : allKeys) {
    k.update();
    k.show();
  }
  
  // All the code below concerns the square on top, which is exclusive to the extension
  if (!extension) return;
  
  // We fill the rectangle with a color depending on if it is being held, and then draw the rectangle
  color rectColor = 0, textColor = 0;
  switch(adjust) {
    case 0:
      rectColor = GREY;
      textColor = WHITE;
      break;
    case 1:
      rectColor = WHITE;
      textColor = BLACK;
      break;
    case -1:
      rectColor = BLACK;
      textColor = WHITE;
      break;
  }
  
  fill(rectColor);
  rect(0, 0, width, height / 8);
  
  // We make string of the notes that are currently playing, and draw that in the top box
  String playing = "";
  for (PianoKey k : allKeys)
    if (k.playing) playing += k.noteName + " ";
  
  fill(textColor);
  textAlign(CENTER, CENTER);
  text(playing, width / 2, height / 16);
}

void keyPressed() {
  // We only handle key presses if the extension is on
  if (!extension) return;
  
  // If up or down is pressed, we adjust the sharpness or flatness of the next few keyPresses
  if (key == CODED) {
    if (keyCode == UP && adjust < 1)
      adjust++;
    else if (keyCode == DOWN && adjust > -1)
      adjust--;
  } else if (key == ' ') {
    for (PianoKey k : allKeys) k.inChord = false;
  } else {
    // We get the associated piano key from the char that is pressed
    PianoKey k = getKeyFromChar(key);
    
    // If the user presses an invalid key, return
    if (k == null) return;
    
    // We let the key know that it is being pressed, and if shift is being held- if it is, key will be uppercase
    k.pressed(Character.isUpperCase(key));
  }
}

// If a key gets released, we let the associated piano key know
void keyReleased() {
  PianoKey k = getKeyFromChar(key);
  
  if (k == null) return;
  k.released();
}

// Setup complete, now we begin declaring the functions that were used

// Initializes the positions of the keys
void initKeyPositions() {
  float topY = extension ? height / 8 : 0; // If the extension is enabled, we have an extra space on top and the keys don't take up the whole height
  float wKeyWidth = width / whiteKeys.size(); // We divide up the width of the screen into the number of white keys
  float bKeyWidth = wKeyWidth * 2 / 3; // The width of a black key is 2/3 of the width of a white key
  float wKeyHeight = height - topY; // The height of the white key is simply whatever isn't covered up by the top
  float bKeyHeight = wKeyHeight * 2 / 3; // The height of a black key is 2/3 of the height of a white key
  
  // We count the number of black and white keys separately to make drawing the black keys on top easier
  int wKeyCounter = 0;
  int bKeyCounter = 0;
  
  // For each of the starting notes, we assign the position to the associated key based on whether it is black or white
  for (int i = 0; i < startingNotes.length; i++) {
    if (startingNotes[i].length() == 2) { // White
      whiteKeys.get(wKeyCounter).setPos(wKeyCounter * wKeyWidth, topY, wKeyWidth, wKeyHeight);
      wKeyCounter++;
    } else { // Black
      blackKeys.get(bKeyCounter).setPos(wKeyCounter * wKeyWidth - bKeyWidth / 2, topY, bKeyWidth, bKeyHeight);
      bKeyCounter++;
    }
  }
}

// This function updates which key is hovered
PianoKey getHoveredKey() {
  // We check the white keys first, and then the black keys, because they overlap and the black keys are on top
  PianoKey hoveredKey = null;
  for (PianoKey k : whiteKeys)
    if (k.hovered()) hoveredKey = k;
  for (PianoKey k : blackKeys)
    if (k.hovered()) hoveredKey = k;
    
  return hoveredKey;
}

// We get a key from a character based on whether
PianoKey getKeyFromChar(char c) {
  // We initialize the noteName by making it uppercase
  String noteName = Character.toString(c).toUpperCase();
    
  // Sharp or flat
  if (adjust == 1) noteName = NOTES[(noteIndex(noteName) + 1) % NOTES.length];
  else if (adjust == -1) noteName = NOTES[(noteIndex(noteName) - 1 + NOTES.length) % NOTES.length];
  
  // If the key pressed is not a valid note, return
  if (noteIndex(noteName) == -1) return null;
  
  // This tests for which octave the key should be in; if it does not exist in the lower octave,
  // do the higher octave
  if (getKeyFromNoteName(noteName + "4") == null) noteName += "5";
  else noteName += "4";
  
  return getKeyFromNoteName(noteName);
}


PianoKey getKeyFromNoteName(String noteName) {
  for (PianoKey k : allKeys)
    if (k.noteName.equals(noteName))
      return k;
  return null;
}

// Gets the frequency from an noteName. The theory behind this is that in even tempering, an octave goes from frequency F to frequency 2F.
// There are 12 keys in an octave and they form a geometric sequence, hence even tempering- it works no matter what key we are in.
// Thus, the ratio of the frequencies of two adjacent tones is the 12th root of 2, which we use later on.
float frequency(String noteName) {
  // We take the character at the end of the note, and convert it into an int weirdly since there isn't a nice parseInt function
  int octave = Integer.parseInt(noteName.substring(noteName.length() - 1));
  int noteInd = noteIndex(noteName.substring(0, noteName.length() - 1));
  
  int midi = (octave + 1) * 12 + noteInd;
  
  // We take the distance in half steps between any note and A4 (440 Hz, a tuning default), and raise the 12th root of 2 to the power of that, multiplied by 440, to get our frequency.
  return pow(2, (midi - 69) / 12.0) * 440;
}

// Gets the index of the string of a note- not the noteName- in the NOTES array
int noteIndex(String note) {
  for (int i = 0; i < NOTES.length; i++)
    if (NOTES[i].equals(note)) return i;
  return -1;
}
