import java.util.Scanner;
import java.util.function.Function;
// lit functional programming stuff https://softwareengineering.stackexchange.com/questions/276859/what-is-the-name-of-a-function-that-takes-no-argument-and-returns-nothing
ArrayList<BezierPoint[]> allPoints = new ArrayList<BezierPoint[]>(), allPointsPrev = new ArrayList<BezierPoint[]>();
PImage bg, sOff, sOn;
Vector2D mousePrev, mouseLoop, mouseSpecify;
int mouseInd, pointInd;
boolean saveBox = false;
boolean savedBox = false;
boolean keyPrevPressed = false;
PFont bigFont, defaultFont;
int speed;
String typing = "";
long startTime;
boolean savedDataBox = false;
boolean enterPtLoc = false;
boolean selectSaveFile = false;
boolean saveNewDataBox = false;
String currentFileName = null;
boolean simpleMode = true;
ArrayList<String> saveFileNames = new ArrayList<String>();
double botWidth, botHeight, botWeight, botMaxAccel, botWheelRadius;
ArrayList<double[]> torque = new ArrayList<double[]>();
TorqueCurve tCurve;
YitSwitch simpleModeSwitch;
void setup() {
  bg = loadImage("frcFieldCropped.png");
  sOn = loadImage("on.png");
  sOff = loadImage("off.png");
  simpleModeSwitch = new YitSwitch(new Vector2D(10, 60), .5, "easy");
  size(1200, 700);
  frameRate(60);
  bigFont = createFont("Arial", 20);
  defaultFont = createFont("Lucida Sans", 12);
  println(dataPath(""));
  startTime = System.currentTimeMillis();
  pointInd = 0;
  mouseLoop = mouse();
  mousePrev = new Vector2D(0, 0);
  mouseInd = -1;
  speed = 1000;
  File greg = new File(dataPath("") + "/bezierSave.gurg");
  selectSaveFile = greg.exists();
  try {
    Scanner sc;
    if (selectSaveFile) {
      sc = new Scanner(greg);
      while (sc.hasNextLine())
        saveFileNames.add(sc.nextLine());
      sc.close();
    }
    sc = new Scanner(new File(dataPath("") + "/robot.stats")); 
    String line;  
    line = sc.nextLine();
    botWidth = Double.parseDouble(line.substring(line.indexOf(":")+1).trim());
    line = sc.nextLine();
    botHeight = Double.parseDouble(line.substring(line.indexOf(":")+1).trim());
    line = sc.nextLine();
    botWeight = Double.parseDouble(line.substring(line.indexOf(":")+1).trim());
    line = sc.nextLine();
    botMaxAccel = Double.parseDouble(line.substring(line.indexOf(":")+1).trim());
    line = sc.nextLine();
    botWheelRadius = Double.parseDouble(line.substring(line.indexOf(":")+1).trim());
    sc.nextLine();
    ArrayList<double[]> torque = new ArrayList<double[]>();
    while (sc.hasNextLine()) {
      line = sc.nextLine().trim();
      int ind = line.indexOf(",");
      if (ind != -1) {
        double[] a = {Double.parseDouble(line.substring(0, ind).trim()), Double.parseDouble(line.substring(ind+1).trim())};
        if (torque.size() == 0)
          torque.add(a);
        else {
          ind = 0;
          while (ind < torque.size() && torque.get(ind)[0] < a[0])
            ind++;
          torque.add(ind, a);
        }
      }
    }
    tCurve = new TorqueCurve(torque);
    sc.close();
  } 
  catch(Exception e) {
    e.printStackTrace();
  }
}
void draw() {
  if (selectSaveFile) {
    background(204);
    fill(0, 0, 0);
    textFont(createFont("Arial", 30));
    text("Click on file or Create New Layout", 100, 50);
    textFont(bigFont);
    text("Create New Layout", 100, 100);
    for (int i = 0; i < saveFileNames.size(); i++)
      text(saveFileNames.get(i), 100, 50*(i+4));
  } else {
    simpleMode = simpleModeSwitch.getState();
    textFont(defaultFont);
    Vector2D mouse = mouse();
    long curTime = System.currentTimeMillis();
    //background(204);
    image(bg, 0, 0);
    strokeWeight(1);
    for (int i = 0; i < 45; i++) {
      if (i%5 == 0) {
        stroke(255, 0, 255, 75);
        strokeWeight(2);
      } else {
        stroke(255, 255, 0, 75);
        strokeWeight(1);
      }
      Vector2D pt = getPxlCoor(i, i);
      line(0, (float)pt.y, 1200, (float)pt.y);
      line((float)pt.x, 0, (float)pt.x, 700);
    }
    stroke(0, 0, 0);
    if (allPoints.size() > 0) {
      BezierPoint[] points = allPoints.get(pointInd);
      for (int i = 0; i < allPoints.size(); i++) {
        if (allPoints.get(i).length >= 2) {
          BezierFunc func = new BezierFunc(allPoints.get(i));
          strokeWeight(2);
          for (int x = 0; x < 1000; x++) {
            Vector2D pos = func.getPos(((float)x)/1000);
            point((float)pos.x, (float)pos.y);
          }
          strokeWeight(10);
          Vector2D pos = func.getPos((((double)(curTime - startTime)*speed/1000)%1000)/1000);
          point((float)pos.x, (float)pos.y);
        }
      }
      stroke(0, 200, 0);
      Vector2D prevPt = points[0].getPos(0);
      strokeWeight(1);
      if (points.length > 2)
        for (int i = 0; i < points.length; i++) {
          Vector2D pt = points[i].getPos(0);
          line((float)prevPt.x, (float)prevPt.y, (float)pt.x, (float)pt.y);
          prevPt = pt;
        }
      prevPt = points[0].getPos(0);
      stroke(0, 0, 255);
      strokeWeight(6);
      for (int i = 0; i < points.length; i++) {
        Vector2D pt = points[i].getPos(0);
        point((float)pt.x, (float)pt.y);
        prevPt = pt;
      }
      stroke(255, 0, 0);
      strokeWeight(8);
      for (int p = 0; p < allPoints.size(); p++) {
        Vector2D pt = allPoints.get(p)[0].getPos(0);
        point((float)pt.x, (float)pt.y);
      }
      BezierPoint[] last = allPoints.get(allPoints.size()-1);
      point((float)last[last.length-1].getPos(0).x, (float)last[last.length-1].getPos(0).y);
      stroke(0, 0, 0);
      if (mouseInd != -1) {
        allPointsPrev = allPoints;
        Vector2D dv = mouse.add(mouseLoop.scale(-1));
        points[mouseInd] = new BezierPoint(points[mouseInd].getPos(0).add(dv));
        if (mouseInd == 1 && points.length == 3) {
          adjustControlPoints(pointInd, dv, false, 1);
          adjustControlPoints(pointInd, dv, true, 1);
        } else if (mouseInd <= 1 && pointInd != 0)
          adjustControlPoints(pointInd, dv, false, mouseInd);
        else if (mouseInd >= points.length-2)
          adjustControlPoints(pointInd, dv, true, mouseInd);
      }
    }
    fill(255, 255, 255);
    strokeWeight(1);
    rect(0, 0, 175, 25);
    fill(0, 0, 0);
    text("Speed: " + (float)speed/1000 + " curves per sec", 10, 17);

    fill(255, 255, 255);
    rect(0, 675, 200, 700);
    fill(0, 0, 0);
    Vector2D loc = getFeetCoor(mouse());
    text("Location (feet): (" + round(loc.x, 2)  + ", " + round(loc.y, 2) + ")", 10, 692);

    fill(204, 204, 204);
    rect(0, 50, 150, 600);

    if (saveBox) {
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 300, 25);
      fill(0, 0, 0);
      text("Points per curve (>=100 recommended): " + typing, 10, 17);
    }
    if (savedBox) {
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 200, 25);
      fill(0, 0, 0);
      text("Exported! Press Esc to Close", 10, 17);
      saveBox = false;
    }
    if (savedDataBox) {
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 200, 25);
      fill(0, 0, 0);
      text("Saved! Press Esc to Close", 10, 17);
    }
    if (enterPtLoc) {
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 200, 25);
      fill(0, 0, 0);
      text("Add point(<x,y>): " + typing, 10, 17);
    }
    if (saveNewDataBox) {
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 300, 25);
      fill(0, 0, 0);
      text("Save name: " + typing, 10, 17);
    }
    mouseLoop = mouse;
    if (keyPressed) {
      if (!keyPrevPressed && allPoints.size() > 0 && !saveBox && !enterPtLoc && !saveNewDataBox) {
        if (key == 'N' || key == 'n' || keyCode == RIGHT) {
          allPointsPrev = allPoints;
          if (allPoints.get(pointInd).length > 2) {
            pointInd++;
            if (pointInd == allPoints.size()) {
              allPoints.add(new BezierPoint[1]);
              allPoints.get(pointInd)[0] = allPoints.get(pointInd-1)[allPoints.get(pointInd-1).length-1];
            }
          } else if (pointInd == 0 && allPoints.size() > 1) {
            allPoints.remove(0);
          }
          keyPrevPressed = true;
        } else if (key == 'B' || key == 'b' || keyCode == LEFT) {
          if (pointInd != 0) {
            if (pointInd == allPoints.size()-1 && allPoints.get(pointInd).length == 1) {
              allPointsPrev = allPoints;
              allPoints.remove(pointInd);
            }
            pointInd--;
          } else if (allPoints.size() > 0 && allPoints.get(0).length > 2)
            allPointsPrev = allPoints;
          allPoints.add(0, new BezierPoint[1]);
          allPoints.get(0)[0] = allPoints.get(1)[0];
        }
        keyPrevPressed = true;
      } else if (key == DELETE) {
        BezierPoint[] points = allPoints.get(pointInd);
        // deletes nearest point, if start or end and deletes point with point length of 3, delete entire curve segment,
        // cannot delete middle segment point if segment has 3 points
        if (points.length == 3) {
          allPointsPrev = allPoints;
          if (pointInd == 0) {
            allPoints.remove(0);
          } else if (pointInd == allPoints.size()-1) {
            allPoints.remove(pointInd);
            pointInd--;
          }
        } else if (points.length > 3) {
          allPointsPrev = allPoints;
          double lowDist = points[1].getPos(0).add(mouse.scale(-1)).getMagnitude();
          int lowInd = 1;
          for (int i = 2; i < points.length-1; i++) {
            double dist = points[i].getPos(0).add(mouse.scale(-1)).getMagnitude();
            if (dist < lowDist) {
              lowDist = dist;
              lowInd = i;
            }
          }
          if (lowInd == 1)
            adjustControlPoints(pointInd, points[2].getPos(0).add(points[1].getPos(0).scale(-1)), false, 1);
          else if (lowInd == points.length-2)
            adjustControlPoints(pointInd, points[points.length-3].getPos(0).add(points[points.length-2].getPos(0).scale(-1)), true, points.length-2);
          BezierPoint[] temp = new BezierPoint[points.length-1];
          int i = 0;
          boolean skipped = false;
          while (i < points.length) {
            if (i == lowInd) {
              i++;
              skipped = true;
            }
            temp[i - (skipped? 1: 0)] = points[i];
            i++;
          }
          allPoints.set(pointInd, temp);
        } else if (allPoints.size() == 1) {
          int lowInd = 0;
          if (points.length != 1) {
            double lowDist = points[0].getPos(0).add(mouse.scale(-1)).getMagnitude();
            for (int i = 0; i < points.length; i++) {
              double dist = points[i].getPos(0).add(mouse.scale(-1)).getMagnitude();
              if (dist < lowDist) {
                lowDist = dist;
                lowInd = i;
              }
            }
          }
          allPointsPrev = allPoints;
          if (points.length == 2) {
            BezierPoint[] temp = {points[1-lowInd]};
            allPoints.set(0, temp);
          } else {
            allPoints.remove(0);
          }
        }
        keyPrevPressed = true;
      } else if (key == 'e' || key == 'E') {
        saveBox = true;
        keyPrevPressed = true;
      } else if (keyCode == UP) {
        speed+=10;
        startTime = System.currentTimeMillis();
      } else if (keyCode == DOWN) {
        speed-=10;
        startTime = System.currentTimeMillis();
      } else if (key == 's' || key == 'S') {
        if (currentFileName == null)
          saveNewDataBox = true;
        else {
          saveData();
          savedDataBox = true;
        }
      } else if (key == 'a' || key == 'A')
        enterPtLoc = true;
      else if ((key == 'z' || key == 'Z') && keyCode == CONTROL)
        allPoints = allPointsPrev;
    } else {
      keyPrevPressed = false;
    }
    simpleModeSwitch.paint();
  }
}

Vector2D getPxlCoor(double feetX, double feetY) {
  return new Vector2D(250 + feetX*23.2761, 665 - feetY*23.2761);
}
Vector2D getPxlCoor(Vector2D feet) {
  return getPxlCoor(feet.x, feet.y);
}
Vector2D getFeetCoor(double pxX, double pxY) {
  return new Vector2D((pxX - 250)/23.2761, (665-pxY)/23.2761);
}
Vector2D getFeetCoor(Vector2D pxl) {
  return getFeetCoor(pxl.x, pxl.y);
}

// rounds to the nearest decimal digit specified in "digit" variable
double round(double num, int digit) {
  double pow = Math.pow(10, digit);
  double n = num*pow;
  return (int)n / pow;
}
void readSaveData() {
  try {
    Scanner sc = new Scanner(new File(dataPath("") + "/" + currentFileName + ".greg"));
    speed = Integer.parseInt(sc.nextLine());
    allPoints = new ArrayList<BezierPoint[]>();
    while (sc.hasNextLine()) {
      String line = sc.nextLine();
      int ind = 0;
      ArrayList<Double> a = new ArrayList<Double>();
      do {
        ind = line.indexOf(',');
        if (ind == -1)
          a.add(Double.parseDouble(line));
        else {
          a.add(Double.parseDouble(line.substring(0, ind)));
          line = line.substring(ind+1);
        }
      } while (ind != -1);
      BezierPoint[] pts = new BezierPoint[a.size()/2];
      for (int i = 0; i < pts.length; i++)
        pts[i] = new BezierPoint(new Vector2D(a.get(2*i), a.get(2*i+1)));
      allPoints.add(pts);
    }
    pointInd = 0;
    sc.close();
  }
  catch(Exception e) {
    System.err.println("greg file not detected");
  }
}
void saveData() {
  File file = new File(dataPath("") + "/" + currentFileName + ".greg");
  if (file.exists())
    file.delete();
  PrintWriter greg = createWriter(dataPath("") + "/" + currentFileName + ".greg");
  greg.write(speed + "\n");
  for (int p = 0; p < allPoints.size(); p++) {
    String line = "";
    for (int i = 0; i < allPoints.get(p).length; i++)
      line += allPoints.get(p)[i].getPos(0).x + "," + allPoints.get(p)[i].getPos(0).y + ",";
    greg.write(line.substring(0, line.length()-1) + (p == allPoints.size()-1? "": "\n"));
  }
  greg.flush();
  greg.close();
}
void keyPressed() {
  if (!selectSaveFile) {
    if (key==27) { // ESC
      key=0;
      saveBox = false;
      savedBox = false;
      enterPtLoc = false;
      saveNewDataBox = false;
      typing = "";
    }
    if (saveBox) {
      if (key == '\n') {
        int amt = Integer.parseInt(typing);
        File file = new File("Points.java");
        if (file.exists())
          file.delete();
        PrintWriter output = createWriter("Points.java");
        String out = "package frc.team578.robot.subsystems.swerve.motionProfiling;\nimport java.util.ArrayList;\npublic class Points{\n\tpublic static final double curvesPerSec = " 
          + ((double)speed)/1000 + ";\n\tprivate static double[] getPoints0(){\n\t\tdouble[] d = {";
        int aLevel = 0;
        for (int i = 0; i < allPoints.size()*amt; i++) {
          int ptInd = i/amt;
          Vector2D pos = getFeetCoor(new BezierFunc(allPoints.get(ptInd)).getPos(((double)i%amt)/amt));
          out += pos.x + ", " + pos.y + ", ";
          if ((i+1)%1000 == 0) {
            aLevel++;
            out = out.substring(0, out.length()-2) + "};\n\t\treturn d;\n\t}\n\tprivate static double[] getPoints" + aLevel + "(){\n\t\tdouble[] d = {";
          }
        }
        out += "};\n\t\treturn d;\n\t}\n\tpublic static double[] getTotalPoints(){\n\t\t";
        for (int i = 0; i <= aLevel; i++)
          out += "double[] d" + i + " = getPoints" + i + "();\n\t\t";
        out += "double[] d = new double[";
        for (int i = 0; i <= aLevel; i++)
          out += "d" + i + ".length + ";
        out = out.substring(0, out.length()-3) + "];\n\t\t";
        out += "ArrayList<double[]> dd = new ArrayList<double[]>();\n\t\t";
        for (int i = 0; i <= aLevel; i++)
          out += "dd.add(d" + i + ");\n\t\t";
        out += "int ind = 0;\n\t\tfor(int i = 0; i < dd.size(); i++){\n\t\t\tdouble[] ddd = dd.get(i);\n\t\t\tfor(int j = 0; j < ddd.length; j++){\n\t\t\t\td[ind] = ddd[j];\n\t\t\t\tind++;\n\t\t\t}\n\t\t}\n\t\t";
        out += "return d;\n\t}\n}";
        output.println(out);
        output.flush();
        output.close();
        typing = "";
        saveBox = false;
        savedBox = true;
      } else
        typing += key;
    }
    if (savedDataBox)
      if (key != 's' && key != 'S')
        savedDataBox = false;
    if (enterPtLoc) {
      if (key == '\n') {
        int ind = typing.indexOf(',');
        mouseSpecify = getPxlCoor(new Vector2D(Double.parseDouble(typing.substring(0, ind)), Double.parseDouble(typing.substring(ind+1).trim())));
        mouseReleased();
        typing = "";
        enterPtLoc = false;
      } else
        typing += key;
    }
    if (saveNewDataBox) {
      if (key == '\n') {
        currentFileName = typing;
        saveFileNames.add(currentFileName);
        String t = "";
        for (int i = 0; i < saveFileNames.size(); i++)
          t += saveFileNames.get(i) + "\n";
        t = t.substring(0, t.length()-1);
        PrintWriter greg = createWriter(dataPath("") + "/" + "bezierSave.gurg");
        greg.append(t);
        greg.flush();
        greg.close();
        saveData();
        saveNewDataBox = false;
        savedDataBox = true;
        typing = "";
      } else
        typing += key;
    }
    if (keyCode == BACKSPACE) {
      if (typing.length() <= 2)
        typing = "";
      else
        typing = typing.substring(0, typing.length()-2);
    }
  }
}
int mxPrev = 0, myPrev = 0;
void mousePressed() {
  if (!selectSaveFile) {
    Vector2D mouse = mouse();
    mousePrev = mouse;
    if (allPoints.size() > 0) {
      BezierPoint[] points = allPoints.get(pointInd);
      double smallDist = Double.MAX_VALUE;
      for (int i = 0; i < points.length; i++) {
        double mag = points[i].getPos(0).add(mouse.scale(-1)).getMagnitude();
        if (mag < smallDist) {
          mouseInd = i;
          smallDist = mag;
        }
      }
    }
  }
}

Vector2D mouse() {
  return new Vector2D(mouseX, mouseY);
}

void mouseReleased() {
  if (mouseX>simpleModeSwitch.pos.x&&mouseY>simpleModeSwitch.pos.y&&mouseX<simpleModeSwitch.pos.x+simpleModeSwitch.size.x&&mouseY<simpleModeSwitch.pos.y+simpleModeSwitch.size.y) {
    simpleModeSwitch.toggleState();
  } else if (selectSaveFile) {
      int ind = ((int)(mouseY-175))/50;
      if (ind < saveFileNames.size()) {
        if (ind >= 0) {
          currentFileName = saveFileNames.get(ind);
          readSaveData();
          selectSaveFile = false;
        }
        selectSaveFile = false;
      }
    } else {
      Vector2D mouse = mouse();
      if (mouseSpecify != null)
        mouse = mouseSpecify;
      if (mousePrev.add(mouse.scale(-1)).getMagnitude() < 0.0001 || mouseSpecify != null) {
        if (!simpleMode || allPoints.size() == 0) {
          if (allPoints.size() == 0) {
            allPoints.add(new BezierPoint[1]);
            allPoints.get(0)[0] = new BezierPoint(mouse);
          } else {
            allPointsPrev = allPoints;
            BezierPoint[] points = allPoints.get(pointInd);
            if (points.length == 1) {
              if (pointInd == 0) {
                if (allPoints.size() == 1) {
                  BezierPoint[] temp = new BezierPoint[2];
                  temp[0] = points[0];
                  temp[1] = new BezierPoint(mouse);
                  allPoints.set(0, temp);
                } else {
                  BezierPoint[] nextPts = allPoints.get(pointInd+1);
                  BezierPoint[] temp = new BezierPoint[3];
                  temp[2] = points[0];
                  temp[1] = new BezierPoint(nextPts[0].getPos(0).add(nextPts[1].getPos(0).scale(-1)).add(temp[2].getPos(0)));
                  temp[0] = new BezierPoint(mouse);
                  allPoints.set(0, temp);
                }
              } else {
                BezierPoint[] temp = new BezierPoint[3];
                temp[0] = points[0];
                BezierPoint[] prevPts = allPoints.get(pointInd-1);
                temp[1] = new BezierPoint(prevPts[prevPts.length-1].getPos(0).add(prevPts[prevPts.length-2].getPos(0).scale(-1)).add(points[0].getPos(0)));
                temp[2] = new BezierPoint(mouse);
                allPoints.set(pointInd, temp);
              }
            } else {
              BezierPoint[] temp = new BezierPoint[points.length+1];
              for (int i = 0; i < points.length-1; i++)
                temp[i] = points[i];
              temp[temp.length-2] = new BezierPoint(mouse);
              temp[temp.length-1] = points[points.length-1];
              allPoints.set(pointInd, temp);
              adjustControlPoints(pointInd, temp[temp.length-2].getPos(0).add(temp[temp.length-3].getPos(0).scale(-1)), true, temp.length-2);
            }
          }
        } else {
          if (allPoints.get(pointInd).length != 4) {
            allPointsPrev = allPoints;
            ////////////////////////////////////////////////// TODO, add the 3 points for a cubic spline
          }
        }
      }
      mouseInd = -1;
      mouseSpecify = null;
    }
}

void adjustControlPoints(int pi, Vector2D dv, boolean up, int mouseInd) {
  BezierPoint[] points = allPoints.get(pi);
  if (allPoints.get(pi).length == 1)
    dv = new Vector2D(0, 0);
  if (mouseInd == 0 && pi != 0 && !up) {
    allPoints.get(pi-1)[allPoints.get(pi-1).length-1] = points[0];
    dv = dv.scale(2);
    allPoints.get(pi-1)[allPoints.get(pi-1).length-2] = new BezierPoint(allPoints.get(pi-1)[allPoints.get(pi-1).length-2].getPos(0).add(dv));
    if (allPoints.get(pi-1).length == 3)
      adjustControlPoints(pi-1, dv, false, 1);
  } else if (mouseInd == points.length-1 && pi != allPoints.size()-1 && up) {
    allPoints.get(pi+1)[0] = points[mouseInd];
    dv = dv.scale(2);
    allPoints.get(pi+1)[1] = new BezierPoint(allPoints.get(pi+1)[1].getPos(0).add(dv));
    if (allPoints.get(pi+1).length == 3)
      adjustControlPoints(pi+1, dv, true, 1);
  } else if (mouseInd == points.length-2 && pi != allPoints.size()-1 && up) {
    dv = dv.scale(-1);
    allPoints.get(pi+1)[1] = new BezierPoint(allPoints.get(pi+1)[1].getPos(0).add(dv));
    if (allPoints.get(pi+1).length == 3)
      adjustControlPoints(pi+1, dv, true, 1);
  } else if (mouseInd == 1 && pi != 0 && !up) {
    dv = dv.scale(-1);
    allPoints.get(pi-1)[allPoints.get(pi-1).length-2] = new BezierPoint(allPoints.get(pi-1)[allPoints.get(pi-1).length-2].getPos(0).add(dv));
    if (allPoints.get(pi-1).length == 3)
      adjustControlPoints(pi-1, dv, false, 1);
  }
} 

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
}
@FunctionalInterface
  public interface Action {
  void execute();
}

class Robot {
  private Vector2D botPos, botSpeed, targetPos;
  private double p, i, d;

  Robot(int p, int i, int d, Vector2D botPos, Vector2D targetPos) {
    this.p = p;
    this.i = i;
    this.d = d;
  }
}

class TorqueCurve {
  private ArrayList<double[]> torque;
  private int prev;

  TorqueCurve(ArrayList<double[]> torque) {  // torque is sorted by rpm
    this.torque = torque;
  }

  public double getAccel(double speed, double power) {   // accel in (ft/sec^2), speed in (ft/sec), power from 0 to 1
    Boolean dirUp = null;
    double t = -888888888; // calculated torque
    double revPerMin = speed*30/Math.PI/botWheelRadius;



    while (true) {
      if (prev == torque.size()) {
        prev--;
        t = torque.get(prev)[1];
        break;
      } else if (torque.get(prev)[0] < revPerMin) {
        prev++;
        if (dirUp == null)
          dirUp = true;
        else if (!dirUp) {
          double dv = torque.get(prev-1)[1]-torque.get(prev)[1];
          t = torque.get(prev-1)[0]*1;//don't know what this does, so I broke it
        }
      } else if (torque.get(prev)[0] > revPerMin) {
        prev--;
      } else {
        t = torque.get(prev)[1];
        break;
      }
    }
    return t;//yit was here
  }
}
