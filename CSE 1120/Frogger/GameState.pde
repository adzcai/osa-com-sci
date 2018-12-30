// These are constants for the different game statuses
public static final int NUMSTATES = 3,
  MENUSTATE = 0,
  LEVELCREATOR = 1,
  LEVEL = 2;

GameState[] states = new GameState[NUMSTATES];
int currentState = MENUSTATE;

public interface GameState {
  public void init();
  public void update();
  public void show();
  public void handleInput();
}

void loadState(int state) {
  states[currentState] = null; // Unload the current state
  currentState = state; // and change to the new one
  switch (state) {
    case MENUSTATE: states[state] = new MenuState(); break;
    case LEVELCREATOR: states[state] = new LevelCreator(); break;
    case LEVEL: break;
    default: drawCenteredText("Error: no state found");
  }
  getState().init();
}

GameState getState() {
  return states[currentState];
}
