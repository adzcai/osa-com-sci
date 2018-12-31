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
  private String text;
  
  public Button(Rectangle r, String text) {
    // We set the coords and dimensions of the button to the provided rectangle
    super(r.x, r.y, r.w, r.h, r.col);
    this.text = text;
    // The ratio will be the same no matter what font size it currently is; heightToFit uses it to calculate what font size will make the text fit inside the button
    float textHeight = textAscent() + textDescent();
    float fontSizeToHeight = textAscent() / textHeight;
    float heightToFit = w * textHeight / textWidth("\t" + text); // Spaces for some padding
    fontSize = heightToFit * fontSizeToHeight; // Since the number we pass to fontSize is the text ascent, we calculate it using its ratio to the total height
    
    textFont(assets.arcadeFont, fontSize);
    textHeight = textAscent() + textDescent();
    if (textHeight > h) // We need to fit using the height instead
      fontSize = h * fontSizeToHeight;
  }
  
  public void show() {
    super.show();
    assets.defaultFont(fontSize);
    text(text, x, y, w, h);
  }

  public String getText() { return text; }
  
}

public class PropButton extends Button {
  private int intVal;
  private float floatVal;

  public PropButton(Rectangle r, String text) {
    super(r, text);
  }

  public String getValAsString() {
    return 
  }
}
