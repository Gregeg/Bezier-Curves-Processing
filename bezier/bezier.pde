import java.util.Scanner;
import java.util.function.Function;
import java.util.Collections;
PGraphics gLine;
boolean pushed = false;
ArrayList<BezierPoint[]> allPoints = new ArrayList<BezierPoint[]>();
PImage bg, sOff, sOn, botrot,bOn,bOff;
Vector2D mousePrev, mouseSpecify;
int prevAllPointsPrevInd = 0;
int mouseInd, pointInd;
float botRotScale;
boolean saveBox = false;
boolean waitPointBox = false;
boolean waitPointPosBox = false;
double waitT;
boolean inc;
boolean pidSaveBox = false;
int commandRight, commandLeft, waitRight, waitLeft;
boolean rotationBox = false;
boolean commandPosBox = false;
HashMap<BezierPoint, Double> rotation = new HashMap<BezierPoint, Double>();   // input last point of curve, returns bot rotation in RADIANS at that point
boolean savedBox = false;
boolean keyPrevPressed = false;
PFont bigFont, defaultFont;
int speed;
double commT;
Character pidChar = null;
String typing = "";
float botSimSize = 2.5;
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
  bg = loadImage("frcFieldCropped.png");
  sOn = loadImage("on.png");
  sOff = loadImage("off.png");
  botrot = loadImage("botrot.png");
  bOn = loadImage("button.png");
  bOff = loadImage("buttoff.png");
  gLine = createGraphics(1200, 700);
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
}

double getLineDouble(Scanner sc){
  String line = sc.nextLine();
  return Double.parseDouble(line.substring(line.indexOf(":")+1).trim());
}
