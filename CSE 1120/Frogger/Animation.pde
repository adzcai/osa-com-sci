// ===== DONE =====

public class Animation { // self-explanatory
	
	private boolean playing = false;
  private boolean finished = false;
	private int index;
	private PImage[] frames;

  private float speed; // How often to change the frame, in milliseconds
  private int timer;
  private int lastTime; // The last millisecond that the animation was updated
	
	public Animation(float speed, PImage[] frames) {
		this.speed = speed;
		this.frames = frames;
    index = 0;
    timer = 0;
	}

	public void play() {
		index = 0;
		timer = 0;
    resume();
	}

  public void pause() {
    playing = false;
  }

  public void resume() {
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
	
  public boolean isPlaying() { return playing; }
	public int getIndex() { return index; }
	public PImage getCurrentFrame() { return frames[index]; }
	public int getLastTime() { return lastTime; }
  public boolean isFinished() { return finished; }

}
