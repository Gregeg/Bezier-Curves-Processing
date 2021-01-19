import java.util.Scanner;
import java.util.function.Function;
import java.util.Collections;
import javax.swing.JOptionPane;
PGraphics gLine, bgg, gPoint, gDraw;
boolean control = false;
boolean pushed = false;
ArrayList<BezierPoint[]> allPoints = new ArrayList<BezierPoint[]>();
PImage bg, sOff, sOn, botrot,bOn,bOff;
Vector2D mousePrev, mouseSpecify;
int prevAllPointsPrevInd = 0;
int mouseInd, pointInd;
boolean saveBox = false;
boolean waitPointBox = false;
boolean waitPointPosBox = false;
Double waitT;
int textAuraSize = 1;
boolean inc = false;
boolean pidSaveBox = false;
int waitRight, waitLeft;
boolean rotationBox = false;
boolean commandPosBox = false;
HashMap<BezierPoint, Double> rotation = new HashMap<BezierPoint, Double>();   // input last point of curve, returns bot rotation in RADIANS at that point
boolean savedBox = false;
boolean keyPrevPressed = false;
boolean rotated = false;
PFont bigFont, defaultFont;
int speed;
boolean draw = false;
boolean erase = true;
int drawColor;
Vector2D botDim;
Double commT;
Character pidChar = null;
String typing = "";
long startTime;
int waitInd = 0;
long startWaitTime = -1;
boolean wait = false;
float lengthOfArrows = 30;
float arrowSize = 10;
boolean simDone = false;
boolean savedDataBox = false;
boolean commandBox = false;
boolean enterPtLoc = false;
boolean selectSaveFile = false;
boolean saveNewDataBox = false;
boolean skidding = false;
String currentFileName = null;
boolean simpleMode = true;
boolean moved = true;
boolean pidBox = false;
ArrayList<String> saveFileNames = new ArrayList<String>();
double botWidth, botHeight, botWeight, botMaxAccel, botWheelRadius, botDriveGearRatio, drag, fric, moment2, angResistance;
boolean simulation = false;
ArrayList<double[]> torque = new ArrayList<double[]>();
TorqueCurve tCurve;
Robot robot;
void setup() {
  bg = loadImage("newfield.png");
  sOn = loadImage("on.png");
  sOff = loadImage("off.png");
  botrot = loadImage("botrot.png");
  bOn = loadImage("button.png");
  bOff = loadImage("buttoff.png");
  gLine = createGraphics(1200, 700);
  bgg = createGraphics(1200, 700);
  gPoint = createGraphics(1200, 700);
  gDraw = createGraphics(1200, 700);
  bgg.beginDraw();
  bgg.image(bg, 0, 0);
  strokeWeight(1);
  for (int i = 0; i < 45; i++) {
    if (i%5 == 0) {
      bgg.stroke(255, 0, 255, 75);
      bgg.strokeWeight(2);
    } else {
      bgg.stroke(255, 255, 0, 75);
      bgg.strokeWeight(1);
    }
    Vector2D pt = getPxlCoor(i, i);
    bgg.line(0, (float)pt.y, 1200, (float)pt.y);
    bgg.line((float)pt.x, 0, (float)pt.x, 700);
  }
  bgg.endDraw();
  new YitSwitch("Simple");            // ignore it, IDE is just stupid
  new YitButton("Save (s)");  
  new YitButton("Export (e)");
  new YitButton("Specify Point", "(a)");
  new YitButton("Undo (Ctrl+Z)");
  new YitButton("Rotate (r)");
  new YitButton("Command ", "Point (c)");
  new YitButton("Simulation", "(Space)");
  new YitButton("PID Values (p)");
  new YitButton("Wait Point (w)");
  new YitButton("Draw (d)");
  new YitButton("Menu (m)");
  size(1200, 700);
  frameRate(60);
  bigFont = createFont("Arial", 20);
  defaultFont = createFont("Lucida Sans", 12);
  startTime = System.currentTimeMillis();
  pointInd = 0;
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
    botWidth = getLineDouble(sc);
    botHeight = getLineDouble(sc);
    botWeight = getLineDouble(sc);
    botMaxAccel = getLineDouble(sc);
    botWheelRadius = getLineDouble(sc);
    botDriveGearRatio = getLineDouble(sc);
    drag = getLineDouble(sc);
    fric = getLineDouble(sc);
    angResistance = getLineDouble(sc);
    moment2 = getLineDouble(sc);
    sc.nextLine();
    ArrayList<double[]> torque = new ArrayList<double[]>();
    while (sc.hasNextLine()) {
      String line = sc.nextLine().trim();
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
  robot = new Robot(1, 0, .08, new Vector2D(0, 10), new Vector2D(10, 10));
  botDim = getPxlCoor(new Vector2D(botWidth, botHeight)).add(getPxlCoor(new Vector2D(0, 0)).scale(-1));
}

double getLineDouble(Scanner sc){
  String line = sc.nextLine();
  return Double.parseDouble(line.substring(line.indexOf(":")+1).trim());
}
void reInit(){
  pushed = false;
  allPoints = new ArrayList<BezierPoint[]>();
  prevAllPointsPrevInd = 0;
  saveBox = false;
  waitPointBox = false;
  waitPointPosBox = false;
  textAuraSize = 1;
  inc = false;
  pidSaveBox = false;
  rotationBox = false;
  commandPosBox = false;
  rotation = new HashMap<BezierPoint, Double>();
  savedBox = false;
  keyPrevPressed = false;
  rotated = false;
  draw = false;
  erase = true;
  pidChar = null;
  typing = "";
  startTime = 0;
  waitInd = 0;
  startWaitTime = -1;
  wait = false;
  lengthOfArrows = 30;
  arrowSize = 10;
  simDone = false;
  savedDataBox = false;
  commandBox = false;
  enterPtLoc = false;
  selectSaveFile = false;
  saveNewDataBox = false;
  skidding = false;
  currentFileName = null;
  simpleMode = true;
  moved = true;
  pidBox = false;
  saveFileNames = new ArrayList<String>();
  simulation = false;
  torque = new ArrayList<double[]>();
}
