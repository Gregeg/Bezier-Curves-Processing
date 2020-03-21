class YitSwitch extends YitIO {
  boolean toggle = true, labeled = false;
  String label;

  YitSwitch() {
    this.size= new Vector2D(sOn.width, sOn.height).scale(.5);
  }
  YitSwitch(String label) {
    this.size = new Vector2D(sOn.width, sOn.height).scale(.5);
    labeled = true;
    this.label = label;
  }
  YitSwitch(float scale, String label) {
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
  boolean state() {
    return toggle;
  }

  void toggleState() {
    toggle=!toggle;
  }
}
class YitButton extends YitIO {
  String label;
  String secondLine = null;
  long downTime = 0;
  boolean endOfPush = true;
  YitButton(String label) {
    this.label = label;
    this.size = new Vector2D(sOn.width, sOn.height).scale(.5);
  }
  YitButton(Vector2D size, String label) {
    this.size = size;
    this.label = label;
  }
  YitButton(String label, String secondLine) {
    this.size = new Vector2D(sOn.width, sOn.height).scale(.5);
    this.label = label;
    this.secondLine = secondLine;
  }
  void paint() {
    fill(0);
    if (secondLine != null) {
      text(secondLine, (float)pos.x+75, (float)pos.y+35); 
      text(label, (float)pos.x+75, (float)pos.y+15);
    } else text(label, (float)pos.x+75, (float)pos.y+25);
    stroke(0);
    if (!state()) {
      image(bOff,(float)pos.x,(float)pos.y,(float)size.x,(float)size.y);
      //fill(255, 0, 0);
      //rect((float)pos.x, (float)pos.y, (float)size.x, (float)size.y);
    } else {
      image(bOn,(float)pos.x,(float)pos.y,(float)size.x,(float)size.y);
      //fill(255, 150, 0);
      //rect((float)pos.x, (float)pos.y, (float)size.x, (float)size.y);
    }
  }

  boolean state() {
    return downTime > System.currentTimeMillis()-350;
  }

  void toggleState() {
    push();
  }
  void push() {
    downTime = System.currentTimeMillis();
  }
}
ArrayList<YitIO> io = new ArrayList<YitIO>();
Vector2D MENU_LOCATION = new Vector2D(10, 60);

abstract class YitIO {
  Vector2D pos, size;
  private static final int SPACING = 50;

  YitIO() {
    pos = MENU_LOCATION.add(new Vector2D(0, SPACING*io.size()));
    io.add(this);
  }

  boolean contains(Vector2D pos2) {
    return pos2.x>pos.x&&pos2.y>pos.y&&pos2.x<pos.x+size.x&&pos2.y<pos.y+size.y;
  }
  abstract boolean state();
  abstract void paint();
  abstract void toggleState();
}

// number based on order added starting with 0
YitIO getIO(int ind) {
  return io.get(ind);
}

void paintIO() {
  strokeWeight(1);
  for (int i = 0; i < io.size(); i++)
    io.get(i).paint();
}

void checkIO() {
  Vector2D mouse = mouse();
  for (int i = 0; i < io.size(); i++) if (io.get(i).contains(mouse)) {
    io.get(i).toggleState();
    pushed = true;
  }
}
