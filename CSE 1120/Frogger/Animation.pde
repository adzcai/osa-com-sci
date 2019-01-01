final int defaultAnimationSpeed = 500;

public class Animation { // self-explanatory
	
	private boolean playing = false;
  private boolean finished = false;
	private int index = 0;
	private PImage[] frames;

  private int speed; // How often to change the frame, in milliseconds
  private int timer = 0;
  private int lastTime; // The last millisecond that the animation was updated
	
	public Animation(int speed, PImage[] frames) {
		this.speed = speed;
		this.frames = frames;
	}

	public void play() { // Starts/resets the animation
		index = 0;
		timer = 0;
    lastTime = millis();
    playing = true;
	}
	
	public void update() {
    if (!playing) return; // We don't want to update if the animation isn't playing
		timer += millis() - lastTime; // Add the elapsed time to the timer
		lastTime = millis();
		
		if (timer > speed) nextFrame();
	}

  private void nextFrame() {
    index++; // We increment the index
    timer = 0; // and reset the timer
    if (index == frames.length - 1) {
      playing = false;
      finished = true;
    }
  }
	
  // Getting useful information about the animation
  public boolean isPlaying() { return playing; }
  public boolean isFinished() { return finished; }
	public int getIndex() { return index; }
  public int getNumFrames() { return frames.length; }
  public int getElapsedFrames() { return speed * index + timer; }
  public int getDuration() { return frames.length * timer; }
	public PImage getCurrentFrame() { return frames[index]; }

}
