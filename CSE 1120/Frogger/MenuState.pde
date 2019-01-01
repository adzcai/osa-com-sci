public class MenuState implements GameState { // The main menu

  private int selection = 0;
  private Button[] choices;
  Button title, subtitle;
  private float border;

  public void init() {
    String[] levelNames = assets.listLevelNames();
    choices = new Button[levelNames.length + 1];
    border = height / (choices.length + 6);
    
    assets.defaultFont(border * textAscent() / (textAscent() + textDescent())); // This ensures that the total text height is equal to the border
    
    title = new Button(new Rectangle(0, border, width, border * 2), "Frogger");
    subtitle = new Button(new Rectangle(0, border * 3, width, border), "by Alexander Cai");
    for (int i = 0; i < levelNames.length; i++)
      choices[i] = new Button(new Rectangle(0, border * (5 + i), width, border), levelNames[i]);
    
    choices[levelNames.length] = new Button(new Rectangle(0, border * (5 + levelNames.length), width, border), "Level Creator");
  }

  public void show() {
    background(0);
    title.show();
    subtitle.show();
    for (Button b : choices) b.show();
    choices[selection].showHover();
  }

  public void update() {} // Everything we need to do is handled below

  public void handleInput() {
    if ((keyCode == RIGHT || keyCode == DOWN) && selection < choices.length - 1) selection++;
    if ((keyCode == LEFT || keyCode == UP) && selection > 0) selection--;
    if (keyCode == RETURN || keyCode == ENTER) {
      if (choices[selection].getText().equals("Level Creator")) loadState(LEVELCREATOR);
      else loadLevel("levels/" + choices[selection] + ".csv");
    }
  }
  
}
