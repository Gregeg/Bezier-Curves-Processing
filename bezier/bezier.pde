import java.util.Scanner;
import java.util.function.Function;
// lit functional programming stuff https://softwareengineering.stackexchange.com/questions/276859/what-is-the-name-of-a-function-that-takes-no-argument-and-returns-nothing
ArrayList<BezierPoint[]> allPoints = new ArrayList<BezierPoint[]>();
ArrayList<ArrayList<BezierPoint[]>> allPointsPrev = new ArrayList<ArrayList<BezierPoint[]>>();
PImage bg, sOff, sOn, botrot;
Vector2D mousePrev, mouseLoop, mouseSpecify;
int prevAllPointsPrevInd = 0;
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
double[] rotations = new double[0];
TorqueCurve tCurve;
YitSwitch simpleModeSwitch;
void setup() {
  bg = loadImage("frcFieldCropped.png");
  sOn = loadImage("on.png");
  sOff = loadImage("off.png");
  botrot = loadImage("botrot.png");
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
