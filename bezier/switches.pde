
class Switch {
  private Vector2D pos;
  private PImage nowImg;
  private Action aOn, aOff;

  Switch(Vector2D pos, Action aOn, Action aOff) {
    this.pos = pos;
    this.aOn = aOn;
    this.aOff = aOff;
  }
  Vector2D getPos() {
    return pos;
  }
  void toggleState() {
    if (sOn == nowImg) {
      nowImg = sOff;
      aOff.execute();
    } else {
      nowImg = sOn;
      aOn.execute();
    }
  }
  void paint() {
    image(nowImg, (float)pos.x, (float)pos.y);
  }
}

class YitSwitch {
  Vector2D size, pos;
  boolean toggle = true, labeled = false;
  String label;

  YitSwitch() {
    this.pos = new Vector2D(random(0, width), random(0, height));
  }
  YitSwitch(Vector2D pos) {
    this.pos = pos;
    this.size= new Vector2D(sOn.width, sOn.height);
  }
  YitSwitch(Vector2D pos, float scale) {
    this.pos = pos;
    this.size = new Vector2D(sOn.width, sOn.height).scale(scale);
  }
  YitSwitch(Vector2D pos, float scale, String label) {
    this.pos = pos;
    this.size = new Vector2D(sOn.width, sOn.height).scale(scale);
    this.labeled=true;
    this.label = label;
  }

  void paint() {
    fill(0);
    textSize(15);
    if (labeled) text(label, (float)pos.x+75, (float)pos.y+25);
    if (toggle) {
      image(sOn, (float)pos.x, (float)pos.y, (float)size.x, (float)size.y);
    } else {
      image(sOff, (float)pos.x, (float)pos.y, (float)size.x, (float)size.y);
    }
  }

  boolean getState() {
    return toggle;
  }

  void toggleState() {
    toggle=!toggle;
  }

  boolean contains(Vector2D pos2) {
    return pos2.x>pos.x&&pos2.y>pos.y&&pos2.x<pos.x+size.x&&pos2.y<pos.y+size.y;
  }
}


@FunctionalInterface
  public interface Action {
  void execute();
}

class YitButton {
  public Vector2D pos,size;
  String label;
  long downTime = 0;
  Action action;
  YitButton(Vector2D pos, String label, Action action) {
    this.label = label;
    this.pos = pos;
    this.size = new Vector2D(100,100);
    this.action = action;
  }
  YitButton(Vector2D pos, Vector2D size, String label, Action action) {
    this.pos = pos; 
    this.size = size;
    this.label = label;
    this.action = action;
  }
  
  void paint() {
    if (state()) {
      //image(bOff,(float)pos.x,(float)pos.y,(float)size.x,(float)size.y);
    } else {
      //image(bOn,(float)pos.x,(float)pos.y,(float)size.x,(float)size.y);
      
    }
  }
  boolean state() {
    return downTime > System.currentTimeMillis()-1000;
  }
  
  void push() {
    downTime = System.currentTimeMillis(); 
    action.execute();
  }
}
