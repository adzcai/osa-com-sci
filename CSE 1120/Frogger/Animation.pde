public class Animation {
	
	private boolean playing = false;
	private int index;
	private PImage[] frames;

  private int speed, timer, lastTime; // The last millisecond that the animation was updated
	
	public Animation(int speed, PImage[] frames){
		this.speed = speed;
		this.frames = frames;
	}

	public void start() {
		reset();
		play();
	}

	public void reset() {
		index = 0;
		timer = 0;
		lastTime = millis();
	}

	public void play() { playing = true; }
	public void pause() { playing = false; }
	
	public void update() {
		if (!playing) return; // We don't update if the animation isn't playing
		timer += millis() - lastTime;
		lastTime = millis();
		
		if (timer > speed) {
			index = index + 1 % frames.length; // We increment the index
			timer = 0; // and reset the timer
		}
	}
	
	public int getIndex() { return index; }
	public PImage getCurrentFrame() { return frames[index]; }
	public int getLastTime() { return lastTime; }

}
