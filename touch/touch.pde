class Line {
  float x1, x2, y1, y2;
  Line(float x1, float y1, float x2, float y2) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
  }

  void paint() {
    line(x1, y1, x2, y2);
  }
}

ArrayList<Line> path = new ArrayList();
float t;
PImage field;
void setup() {
  size(900, 525);
  t=0;
  field=loadImage("frcFieldCropped.png");
}

void draw() {
  image(field,0,0,width,height);
  strokeWeight(1);
  for (int i = 0; i < path.size(); i++) {
    path.get(i).paint();
  }
  if (path.size()>0) {
    t=(t+.01)%1;
    PVector spot = pointOnPathRaw(t);
    strokeWeight(20);
    point(spot.x, spot.y);
  }
}

void mouseDragged() {
  if (path.size()==0) {
    path.add(new Line(pmouseX, pmouseY, mouseX, mouseY));
  } else {
    Line prev = path.get(path.size()-1);
    path.add(new Line(prev.x2, prev.y2, mouseX, mouseY));
  }
}

PVector pointOnPathRaw(double t) {//no speed control
  t*=path.size();
  Line atIndex = path.get((int) t);
  t = t - (int) t;
  return new PVector((float)(atIndex.x1+t*(atIndex.x2-atIndex.x1)),(float)(atIndex.y1+t*(atIndex.y2-atIndex.y1)));
}

void keyPressed() {
  if(keyCode==BACKSPACE){path=new ArrayList();}
}
