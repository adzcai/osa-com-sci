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

color BLACK = color(0);
color GREY = color(128);
color WHITE = color(255);

String[] startingNotes;
String[] notes = {"A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"};

ArrayList<PianoKey> whiteKeys = new ArrayList<PianoKey>();
ArrayList<PianoKey> blackKeys = new ArrayList<PianoKey>();
ArrayList<PianoKey> allKeys = new ArrayList<PianoKey>();

PianoKey hoveredKey = null;

int adjust = 0;

void setup() {
  size(640, 480);
  smooth();
  frameRate(120);
  
  startingNotes = extension ?
    new String[] {"C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A5", "A#5", "B5", "C5"} :
    new String[] {"C4", "D4", "E4", "F4", "G4"};
  
  colorMode(HSB, startingNotes.length, 100, 100);
  PianoKey toAdd;
  for (int i = 0; i < startingNotes.length; i++) {
    toAdd = new PianoKey(startingNotes[i], new SinOsc(this), i);
    (startingNotes[i].length() == 2 ? whiteKeys : blackKeys).add(toAdd);
  }
  
  float topY = extension ? height / 8 : 0;
  float wKeyWidth = width / whiteKeys.size();
  float bKeyWidth = wKeyWidth * 2 / 3;
  float wKeyHeight = height - topY;
  float bKeyHeight = wKeyHeight * 2 / 3;
  
  int wKeyCounter = 0;
  int bKeyCounter = 0;
  
  for (int i = 0; i < startingNotes.length; i++) {
    if (startingNotes[i].length() == 2) { // White
      whiteKeys.get(wKeyCounter).setPos(wKeyCounter * wKeyWidth, topY, wKeyWidth, wKeyHeight);
      wKeyCounter++;
    } else { // Black
      blackKeys.get(bKeyCounter).setPos(wKeyCounter * wKeyWidth - bKeyWidth / 2, topY, bKeyWidth, bKeyHeight);
      bKeyCounter++;
    }
  }
  
  allKeys.addAll(whiteKeys);
  allKeys.addAll(blackKeys);
}

void draw() {
  updateHoveredKey();
  
  for (PianoKey k : allKeys) {
    k.update();
    k.show();
  }
  
  if (!extension) return;
  
  // The next few lines show the notes that are currently being played
  fill(adjust == 0 ? GREY : (adjust == 1 ? WHITE : BLACK));
  rect(0, 0, width, height / 8);
  
  String playing = "";
  for (PianoKey k : allKeys)
    if (k.playing) playing += k.ansi + " ";
  
  fill(adjust < 1 ? WHITE : BLACK);
  textAlign(CENTER, CENTER);
  text(playing, width / 2, height / 16);
}

void keyPressed() {
  if (!extension) return;
  
  if (key == CODED) {
    if (keyCode == UP && adjust < 1)
      adjust++;
    else if (keyCode == DOWN && adjust > -1)
      adjust--;
  } else if (key == ' ') {
    for (PianoKey k : allKeys) k.inChord = false;
  } else {
    // We get the ansi and key from the char that is pressed
    PianoKey k = getKeyFromChar(key);
    
    // If the user presses an invalid key, return
    if (k == null) return;
    
    // We let the key know that it is being pressed, and if shift is being held
    k.pressed(Character.isUpperCase(key));
  }
}

// If it gets released, we stop playing
void keyReleased() {
  PianoKey k = getKeyFromChar(key);
  
  if (k == null) return;
  k.released();
}


PianoKey getKeyFromChar(char c) {
  String ansi = Character.toString(c).toUpperCase();
    
  // Sharp or flat
  if (adjust == 1) ansi = notes[(noteIndex(ansi) + 1) % notes.length];
  else if (adjust == -1) ansi = notes[(noteIndex(ansi) - 1 + notes.length) % notes.length];
  
  // If the key pressed is not a valid note, return
  if (noteIndex(ansi) == -1) return null;
  
  // This tests for which octave the key should be in; if it does not exist in the lower octave,
  // do the higher octave
  if (getKeyFromANSI(ansi + "4") == null) ansi += "5";
  else ansi += "4";
  
  return getKeyFromANSI(ansi);
}


PianoKey getKeyFromANSI(String ansi) {
  for (PianoKey k : allKeys)
    if (k.ansi.equals(ansi))
      return k;
  return null;
}

// We check the white keys first, and then the black keys, because they overlap and the black keys are on top
void updateHoveredKey() {
  hoveredKey = null;
  for (PianoKey k : whiteKeys)
    if (k.hovered()) hoveredKey = k;
  for (PianoKey k : blackKeys)
    if (k.hovered()) hoveredKey = k;
}

float frequency(String ansi) {
  int octave = int(ansi.charAt(ansi.length() - 1)) - 48;
  int note = -1;
    for (int i = 0; i < notes.length; i++)
      if (notes[i].equals(ansi.substring(0, ansi.length() - 1).toUpperCase()))
        note = i;
  return pow(2, (octave * 12 + note) / 12.0) * 27.5;
}

int noteIndex(String note) {
  for (int i = 0; i < notes.length; i++)
    if (notes[i].equals(note)) return i;
  return -1;
}
