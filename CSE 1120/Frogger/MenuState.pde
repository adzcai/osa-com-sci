public class MenuState implements GameState { // The main menu

  private int selection = 0;
  private String titleText = "FROGGER\n" + 
      "By Alexander Cai\n" + 
      "Press any key to begin";
  private String[] choices;
  private float titleSize, choicesSize, titleHeight, choicesHeight;
  private float border;

  public void init() {
    titleSize = height / 12;
    choicesSize = height / 16;
    
    textFont(assets.arcadeFont, titleSize);
    titleHeight = (textAscent() + textDescent()) * 3;
    
    textFont(assets.arcadeFont, choicesSize);
    choicesHeight = textAscent() + textDescent();

    String[] levelNames = listLevelNames();
    choices = new String[levelNames.length + 1];
    for (int i = 0; i < levelNames.length; i++) choices[i] = levelNames[i];
    choices[levelNames.length] = "Level Creator";

    border = (height - titleHeight - choicesHeight * choices.length) / 3;
  }

  public void update() {}

  public void show() {
    pushMatrix();
    background(0);
    textAlign(CENTER, TOP);
    textFont(assets.arcadeFont, titleSize);
    
    translate(width / 2, border);
    fill(255);
    text(titleText, 0, 0);
    
    translate(0, titleHeight + border);
    textFont(assets.arcadeFont, choicesSize);
    for (int i = 0; i < choices.length; i++) {
      // If it is selected, we hightlight in yellow. Otherwise, we highlight in white
      fill(selection == i ? color(255, 255, 0) : 255);
      text(choices[i], 0, 0);
      translate(0, choicesHeight);
    }
    popMatrix();
  }

  public void handleInput() {
    if ((keyCode == RIGHT || keyCode == DOWN) && selection < choices.length - 1) selection++;
    if ((keyCode == LEFT || keyCode == UP) && selection > 0) selection--;
    if (keyCode == RETURN || keyCode == ENTER) {
      if (choices[selection].equals("Level Creator")) loadState(LEVELCREATOR);
      else loadLevel("levels/" + choices[selection] + ".csv");
    }
  }
  
}
