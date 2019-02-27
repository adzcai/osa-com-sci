// These are constants for the different game statuses
public static final int NUMSTATES = 3,
  MENUSTATE = 0,
  LEVELCREATOR = 1,
  LEVEL = 2;

GameState[] states = new GameState[NUMSTATES];
int currentState = MENUSTATE;

public interface GameState { // An interface used to represent the unique states that the game can be in
  public void init();
  public void show();
  public void update();
  public void handleInput();
}

void loadState(int state) { // Loads a state
  states[currentState] = null; // Unload the current state
  currentState = state; // and change to the new one
  switch (state) {
    case MENUSTATE: states[state] = new MenuState(); break;
    case LEVELCREATOR: states[state] = new LevelCreator(); break;
    case LEVEL: break; // We don't do anything here
    default: assets.drawCenteredText("Error: no state found");
  }
  getState().init();
}

void loadLevel(String map) { // Sets the current state to a new level using a map
  states[currentState] = null; // Unload the current state
  currentState = LEVEL; // Say that we're on a level
  states[LEVEL] = new Level(map); // Initialize the level
  getState().init();
}

GameState getState() {
  return states[currentState];
}
