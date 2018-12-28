public interface GameState {
  public void init();
  public void update();
  public void show();
  public void handleInput();
}

public class Menu implements GameState {

  private int selection = 0;
  private String[] choices = { "Level 1", "Level 2" };

  public void init() {}
  public void update() {}

  public void show() {
    textAlign(CENTER, CENTER);
    textFont(assets.arcadeFont, height / 8);
    text("FROGGER", width / 2, height / 3);
    
    textFont(assets.arcadeFont, height / 12);
    text("By Alexander Cai\nPress any key to begin", width / 2, height / 2);

    int y = height / 2;
    float textHeight = textAscent() + textDescent();

    for (int i = 0; i < choices.length; i++) {
      // If it is selected, we hightlight in yellow. Otherwise, we highlight in green if it is enabled and red if it is not
      fill(selection == i ? color(255, 255, 0) : 255);
      text(choices[i], width / 2, y);
      y += textHeight;
    }
  }

  public void handleInput() {
    if (keyCode == RIGHT && selection < choices.length - 1) selection++;
    if (keyCode == LEFT && selection > 0) selection--;
    if (keyCode == RETURN || keyCode == ENTER) {
      if (choices[selection].equals("Level 1")) loadState(LEVEL1);
      else if (choices[selection].equals("Level 2")) loadState(LEVEL2);
    }
  }
  
}
