class PianoKey {
  float x, y, w, h; // store the position of the key
  
  // Store information about the sound
  SinOsc so;
  String ansi;
  float freq;
  
  boolean inChord = false;
  
  int hue, saturation, brightness; // keep track of the color
  
  boolean white; // stores if the key is black or white
  boolean playing = false;
  boolean pressed = false;
  
  PianoKey(String ansi_, SinOsc so_, int hue_) {
    ansi = ansi_;
    white = ansi.length() == 2;
    so = so_;
    
    hue = hue_;
    saturation = white ? 0 : 100;
    brightness = white ? 100 : 0;
    
    freq = frequency(ansi);
  }
  
  void setPos(float x_, float y_, float w_, float h_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
  }
  
  void show() {
    // We draw a rectangle with a black border and filled with the key's color
    stroke(BLACK);
    fill(hue, saturation, brightness);
    rect(x, y, w, h);
    
    // We write the ansi in a visible colour at the bottom of the key
    fill(white ? BLACK : WHITE);
    textAlign(CENTER, BOTTOM);
    text(ansi, x + w / 2, y + h);
  }
  
  void update() {
    // We play the note if the extension is enabled, and it is in a chord or if it is being pressed or clicked
    if (extension && inChord || (mousePressed && is(hoveredKey)) || pressed) play();
    else pause();
    
    if (is(hoveredKey) || playing) reveal();
    else hide();
  }
  
  boolean is(PianoKey other) {
    // We check for equality with the ansis
    if (other == null) return false;
    return ansi.equals(other.ansi);
  }
  
  void pressed(boolean shiftHeld) {
    pressed = true;
    inChord = shiftHeld;
  }
  
  void released() {
    pressed = false;
  }
  
  void reveal() {
    if (white && saturation < 100) saturation += 2;
    else if (!white && brightness < 100) brightness += 2;
  }
  
  void hide() {
    if (white && saturation > 0) saturation -= 2;
    else if (!white && brightness > 0) brightness -= 2;
  }
  
  void play() {
    if (!extension || playing) return; // We ignore the command if sound is off or key is already playing
    this.so.play(freq, 0.25);
    playing = true;
  }
  
  void pause() {
    if (!extension || !playing) return; // If it is already stopped or extension is not enabled, we ignore it
    so.stop();
    playing = false;
    inChord = false;
  }
  
  // Simple check to see if mouse is in rect
  boolean hovered() {
    return x < mouseX && mouseX < x + w && y < mouseY && mouseY < y + h;
  }
}
