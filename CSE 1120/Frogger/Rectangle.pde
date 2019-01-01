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
    text(text, x, y, w, h);
  }

  protected float fontSizeToFitText(String text) { // Gives us the font size required to fit *text* in one line in the rectangle
    // These ratios will be the same no matter what the current size is, so we don't need to worry about that
    float textHeight = textAscent() + textDescent();
    float fontSizeToHeight = textAscent() / textHeight;
    float heightToFit = w * textHeight / textWidth("\t" + text); // Spaces for some padding
    float fontSize = heightToFit * fontSizeToHeight; // Since the number we pass to fontSize is the text ascent, we calculate it using its ratio to the total height
    
    textFont(assets.arcadeFont, fontSize); // We test it,
    textHeight = textAscent() + textDescent(); // and if it is too vertically tall,
    if (textHeight > h) // we need to fit using the height instead
      fontSize = h * fontSizeToHeight;
    
    return fontSize;
  }

  public String getText() { return text; }
  
}

public class PropButton extends Button {

  public PropButton(Rectangle r, String text) {
    super(r, text);
  }

  public void showHover(TableRow tableRow) {
    super.showHover();

    fill(0, 255, 0, 192); // Draw a green triangle on top
    triangle(x, y + h / 2, x + w / 2, y, x + w, y + h / 2);
    fill(255, 0, 0, 192); // and a red triangle pointing down
    triangle(x, y + h / 2, x + w / 2, y + h, x + w, y + h / 2);

    // We just do a little check for what type of number to get
    String val = str((text.equals("numObstacles") || text.equals("len")) ? tableRow.getInt(text) : tableRow.getFloat(text));
    assets.defaultFont(fontSizeToFitText(val));
    text(val, x, y, w, h);
  }

  private void changeValue(TableRow tr, int dir) {
    if (text.equals("numObstacles") || text.equals("len"))
      tr.setInt(text, tr.getInt(text) + dir);
    else 
      tr.setFloat(text, tr.getFloat(text) + 0.1 * dir);
  }

}
