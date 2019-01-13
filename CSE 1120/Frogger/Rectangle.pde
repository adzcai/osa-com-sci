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

public class TextBox extends Rectangle { // Just something that the user can click on

  protected String text;
  private float fontSize;
  
  public TextBox(float x, float y, float w, float h, String text) { // Same as above, if no color is passed we default to alpha
    this(x, y, w, h, color(0, 255), text);
  }

  public TextBox(float x, float y, float w, float h, color col, String text) {
    // We set the coords and dimensions of the button to the provided rectangle
    super(x, y, w, h, col);
    this.text = text;
    fontSize = fontSizeToFitText(text);
  }
  
  public void show() {
    super.show();
    assets.defaultFont(fontSize);
    text(text, x + w / 2, y + h / 2);
  }

  protected float fontSizeToFitText(String text) { // Gives us the font size required to fit *text* in one line in the rectangle
    textSize(12);
    float ascentToTotal = textAscent() / (textAscent() + textDescent());
    // We multiply the width and the height by 7/8 for a bit of padding
    float minW = (w * 7 / 8) * textAscent() / textWidth(text);
    float minH = (h * 7 / 8) * ascentToTotal;
    return min(minW, minH); // We don't want the text to overflow in either dimension, so we choose the smaller one
  }

  public String getText() { return text; }
  public void setText(String text) {
    this.text = text;
    fontSize = fontSizeToFitText(text);
  }
  
}

// A subclass of button that manages a specific property of a lane
public class PropTextBox extends TextBox {

  public PropTextBox(float x, float y, float w, float h, color col, String text) {
    super(x, y, w, h, col, text);
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
    int index; // We need to initialize it here to prevent a "duplicate local variable"
    switch (text) {
      case "laneType": // The ways these two are handled are similar
        index = assets.indexOf(tr.getString(text), assets.laneTypes); // We get the index of the button's current value in the array
        tr.setString(text, assets.laneTypes[constrain(index + dir, 0, assets.laneTypes.length - 2)]); // Constrain the selection to prevent array index out of bounds, and minus the destination lane
        tr.setString("obstacleType", assets.getObstaclesOfLane(tr.getString(text))[0]); // Set the obstacle to the lane's default obstacle
        break;

      case "obstacleType":
        String[] allowedObstacles = assets.getObstaclesOfLane(tr.getString("laneType")); // We just need to check which array to check
        index = assets.indexOf(tr.getString(text), allowedObstacles);
        tr.setString(text, allowedObstacles[constrain(index + dir, 0, allowedObstacles.length - 1)]); // Constrain the selection to prevent array index out of bounds
        break;

      case "numObstacles":
      case "len":
        tr.setInt(text, constrain(tr.getInt(text) + dir, 0, 12)); // Only from 0 to 12 obstacles allowed
        break;

      case "spacing":
      case "speed":
        tr.setFloat(text, constrain(tr.getFloat(text) + 0.1 * dir, 0, 8)); // Spacing and speed go up to 8
    }
  }

}
