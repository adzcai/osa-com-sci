class PianoKey {
  float x, y, w, h; // store the position of the key
  
  // Store information about the sound
  SinOsc so;
  String noteName;
  float freq;
  
  boolean inChord = false;
  
  int hue, saturation, brightness; // keep track of the color
  
  boolean white; // stores if the key is black or white
  boolean playing = false;
  boolean pressed = false;
  
  PianoKey(String noteName_, SinOsc so_, int hue_) {
    noteName = noteName_;
    white = noteName.length() == 2;
    so = so_;
    
    hue = hue_;
    saturation = white ? 0 : 100;
    brightness = white ? 100 : 0;
    
    freq = frequency(noteName);
    so.freq(freq);
    so.amp(0.5);
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
    
    // We write the noteName in a visible colour at the bottom of the key
    fill(white ? BLACK : WHITE);
    textAlign(CENTER, BOTTOM);
    text(noteName, x + w / 2, y + h);
  }
  
  void update() {
    // We play the note if the extension is enabled, and it is in a chord or if it is being pressed or clicked
    if (extension && inChord || (mousePressed && is(getHoveredKey())) || pressed) play();
    else pause();
    
    // If the note is playing or being hovered, we make it brighter, otherwise we fade it
    if (is(getHoveredKey()) || playing) reveal();
    else hide();
  }
  
  boolean is(PianoKey other) {
    // We check for equality with the noteNames
    if (other == null) return false;
    return noteName.equals(other.noteName);
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
    float volume = map(mouseY, height / 8, height, 0.25, 1);
    env.play(so, attackTime, sustainTime, volume, volume * 4);
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
