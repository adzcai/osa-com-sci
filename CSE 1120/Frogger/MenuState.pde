public class MenuState implements GameState { // The main menu

  private int selection = 0; // The index of the choice being hovered
  private Button title, subtitle;
  private Button[] choices;
  private float border;

  public void init() {
    String[] levelNames = assets.listLevelNames(); // A list of all the levels
    choices = new Button[levelNames.length + 1];
    border = height / (choices.length + 6);
    
    // Initializing the different labels and buttons
    title = new Button(0, border, width, border * 2, "Frogger");
    subtitle = new Button(0, border * 3, width, border, "by Alexander Cai");
    for (int i = 0; i < levelNames.length; i++)
      choices[i] = new Button(0, border * (5 + i), width, border, levelNames[i]);
    
    choices[levelNames.length] = new Button(0, border * (5 + levelNames.length), width, border, "Level Creator");
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
    switch (keyCode) {
      case RIGHT:
      case DOWN:
        selection++;
        break;

      case LEFT:
      case UP:
        selection--;
        break;

      case RETURN:
      case ENTER:
        if (choices[selection].getText().equals("Level Creator")) loadState(LEVELCREATOR);
        else loadLevel("levels/" + choices[selection].getText() + ".csv");
    }

    selection = constrain(selection, 0, choices.length - 1); // A valid button must be selected
  }
  
}
