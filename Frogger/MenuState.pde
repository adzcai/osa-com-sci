public class MenuState implements GameState { // The main menu

  private int selection = 0; // The index of the choice being hovered
  private TextBox title, subtitle;
  private TextBox[] choices;
  private float border;

  private final String instructions = "Get the frog home\nDon't get hit by the cars\nUse the arrow keys to move\nPress enter to select";
  private boolean displayHelp = false;

  public void init() {
    String[] levelNames = assets.listLevelNames(); // A list of all the levels
    choices = new TextBox[levelNames.length + 2]; // + 1 for the help button, + 1 for the level selector
    border = height / (choices.length + 6); // 6: 1 above the title, 1 at the bottom, 3 for height of title
    
    // Initializing the different labels and BUTTONS
    title = new TextBox(0, border, width, border * 2, "Frogger");
    subtitle = new TextBox(0, border * 3, width, border, "by Alexander Cai");
    for (int i = 0; i < levelNames.length; i++)
      choices[i] = new TextBox(0, border * (5 + i), width, border, levelNames[i]);
    
    // The remaining two choices are for the help and the level creator
    choices[levelNames.length] = new TextBox(0, border * (5 + levelNames.length), width, border, "Help");
    choices[levelNames.length + 1] = new TextBox(0, border * (6 + levelNames.length), width, border, "Level Creator");
  }

  public void show() {
    background(0);
    title.show();
    subtitle.show();
    for (TextBox b : choices) b.show();
    choices[selection].showHover();

    if (displayHelp) {
      background(0);
      assets.drawCenteredText(instructions);
    }
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
        if (displayHelp) displayHelp = false; // If the instructions are being displayed, we toggle them off
        else if (choices[selection].getText().equals("Help")) displayHelp = true;
        else if (choices[selection].getText().equals("Level Creator")) loadState(LEVELCREATOR);
        else loadLevel("levels/" + choices[selection].getText() + ".csv");
    }

    selection = constrain(selection, 0, choices.length - 1); // A valid TextBox must be selected
  }
  
}
