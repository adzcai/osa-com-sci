// A generic class to store the coordinates, dimensions, and color of a rectangle,
// along with functions to draw itself and check for intersections with other rectangles
public class Rectangle {
  
  public float x, y, w, h; // These should be private but I'm too lazy to change all the usages
  protected color col;

  // If no color is passed we just set it to alpha
  public Rectangle(float x, float y, float w, float h) {
    this(x, y, w, h, color(0, 255));
  }

  // A pretty generic constructor. We use object oriented programming to improve clarity,
  // so "this" simply represents the instance of Rectangle that is being created.
  public Rectangle(float x, float y, float w, float h, color col) {
    this.x = x;
    this.w = w;
    this.y = y;
    this.h = h;
    this.col = col;
  }

  public boolean intersects(Rectangle other) {
    // We test if the left side of the box doesn't exceed the right side of the other box, etc. for all 4 sides
    return !(x >= other.x + other.w ||
      x + w <= other.x ||
      y >= other.y + other.h ||
      y + h <= other.y);
  }
  
  public void show() {
    // Simply fill with the colour and draw the rectangle
    fill(col);
    rect(x, y, w, h);
  }

  public void showHover() {
    fill(255, 128);
    rect(x, y, w, h);
  }
  
}

public class Button extends Rectangle { // Just something that the user can click on

  private float fontSize;
  protected String text;
  
  public Button(Rectangle r, String text) {
    // We set the coords and dimensions of the button to the provided rectangle
    super(r.x, r.y, r.w, r.h, r.col);
    this.text = text;
    // The ratio will be the same no matter what font size it currently is; heightToFit uses it to calculate what font size will make the text fit inside the button
    fontSize = fontSizeToFitText(text);
  }
  
  public void show() {
    super.show();
    assets.defaultFont(fontSize);
    text(text, x + w / 2, y + h / 2);
  }

  protected float fontSizeToFitText(String text) { // Gives us the font size required to fit *text* in one line in the rectangle
    float minW = w * textAscent() / textWidth(text); // Spaces for some padding
    float minH = h * textAscent() / (textAscent() + textDescent());
    
    return min(minW, minH);
  }

  public String getText() { return text; }
  
}

public class PropButton extends Button {

  public PropButton(Rectangle r, String text) {
    super(r, text);
  }

  public void showHover(TableRow tr) {
    super.showHover();

    fill(0, 255, 0, 192); // Draw a green triangle on top
    triangle(x, y + h / 2, x + w / 2, y, x + w, y + h / 2);
    fill(255, 0, 0, 192); // and a red triangle pointing down
    triangle(x, y + h / 2, x + w / 2, y + h, x + w, y + h / 2);

    // We just do a little check for what type of number to get
    String val = "";
    switch (text) {
      case "laneType":
      case "obstacleType":
        val = tr.getString(text);
        break;

      case "numObstacles":
      case "len":
        val = str(tr.getInt(text));
        break;

      case "spacing":
      case "speed":
        val = str(tr.getFloat(text));
    }

    assets.defaultFont(fontSizeToFitText(val));
    text(val, x, y, w, h);
  }

  private void changeValue(TableRow tr, int dir) {
    switch (text) {
      case "laneType":
      case "obstacleType":
        String[] arr = text.equals("laneType") ? assets.laneTypes : assets.obstacleTypes;
        int index = assets.indexOf(tr.getString(text), arr); // We get the index of the button's current value in the array
        // We set this button's text to the next value in the array. We need to constrain to prevent it from going out of bounds
        tr.setString(text, arr[constrain(index + dir, 0, arr.length - 1)]);
        break;

      case "numObstacles":
      case "len":
        tr.setInt(text, tr.getInt(text) + dir);
        break;
      case "spacing":
      case "speed":
        tr.setFloat(text, tr.getFloat(text) + 0.1 * dir);
        break;
    }
  }

}
