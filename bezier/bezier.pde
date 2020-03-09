import java.util.Scanner;

ArrayList<BezierPoint[]> allPoints = new ArrayList<BezierPoint[]>();
PImage bg;
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
boolean saveNewData = false;
String currentFileName = null;                                      // use me to store file and see if new layout or not!!!
ArrayList<String> saveFileNames = new ArrayList<String>();
void setup(){
  saveFileName = null;
  bg = loadImage("frcFieldCropped.png");
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
  selectSaveFile = greg.exists()
  if(selectSaveFile){
    try{
      Scanner sc = new Scanner(greg);
      while(sc.hasNextLine()){
        saveFileNames.add(sc.nextLine());
      }
    }catch(Exception e){
      e.printStackTrace();
    }
  }
}
void draw(){
  if(selectSaveFile){
    font(bigFont);
    background(204);
    text("Click on Save File or select New Layout", 100, 50);
    text("Create New Layout", 100, 100);
    for(int i = 0; i < saveFileNames.size(); i++)
      text(saveFileNames.get(i), 100, 100*(i+2));
  }else{
    font(defaultFont);
    Vector2D mouse = mouse();
    long curTime = System.currentTimeMillis();
    //background(204);
    image(bg, 0, 0);
    strokeWeight(1);
    for(int i = 0; i < 45; i++){
      if(i%5 == 0){
        stroke(255, 0, 255, 75);
        strokeWeight(2);
      }else{
        stroke(255, 255, 0, 75);
        strokeWeight(1);
      }
      Vector2D pt = getPxlCoor(i, i);
      line(0, (float)pt.y, 1200, (float)pt.y);
      line((float)pt.x, 0, (float)pt.x, 700);
    }
    stroke(0, 0, 0);
    if(allPoints.size() > 0){
      BezierPoint[] points = allPoints.get(pointInd);
      for(int i = 0; i < allPoints.size(); i++){
        if(allPoints.get(i).length >= 2){
          BezierFunc func = new BezierFunc(allPoints.get(i));
          strokeWeight(2);
          for(int x = 0; x < 1000; x++){
            Vector2D pos = func.getPos(((float)x)/1000);
            point((float)pos.x,(float)pos.y);
          }
          strokeWeight(10);
          Vector2D pos = func.getPos((((double)(curTime - startTime)*speed/1000)%1000)/1000);
          point((float)pos.x, (float)pos.y);
        }
      }
      stroke(0, 200, 0);
      Vector2D prevPt = points[0].getPos(0);
      strokeWeight(1);
      if(points.length > 2)
        for(int i = 0; i < points.length; i++){
          Vector2D pt = points[i].getPos(0);
          line((float)prevPt.x, (float)prevPt.y, (float)pt.x, (float)pt.y);
          prevPt = pt;
        }
      prevPt = points[0].getPos(0);
      stroke(0, 0, 255);
      strokeWeight(6);
      for(int i = 0; i < points.length; i++){
        Vector2D pt = points[i].getPos(0);
        point((float)pt.x, (float)pt.y);
        prevPt = pt;
      }
      stroke(255, 0, 0);
      strokeWeight(8);
      for(int p = 0; p < allPoints.size(); p++){
        Vector2D pt = allPoints.get(p)[0].getPos(0);
        point((float)pt.x, (float)pt.y);
      }
      BezierPoint[] last = allPoints.get(allPoints.size()-1);
      point((float)last[last.length-1].getPos(0).x, (float)last[last.length-1].getPos(0).y);
      stroke(0, 0, 0);
      if(mouseInd != -1){
        Vector2D dv = mouse.add(mouseLoop.scale(-1));
        points[mouseInd] = new BezierPoint(points[mouseInd].getPos(0).add(dv));
        if(mouseInd == 1 && points.length == 3){
          adjustControlPoints(pointInd, dv, false, 1);
          adjustControlPoints(pointInd, dv, true, 1);
        }else if(mouseInd <= 1 && pointInd != 0)
          adjustControlPoints(pointInd, dv, false, mouseInd);
        else if(mouseInd >= points.length-2)
          adjustControlPoints(pointInd, dv, true, mouseInd);
      }
    }
    fill(255, 255, 255);
    strokeWeight(1);
    rect(0, 0, 175, 25);
    fill(0, 0, 0);
    text("Speed: " + (float)speed/1000 + " curves per sec", 10, 17);

    fill(255, 255, 255);
    rect(0, 700, 300, 675);
    fill(0, 0, 0);
    Vector2D loc = getFeetCoor(mouse());
    text("Location (feet): "(" + round(loc.x, 3),  + ", " + round(loc.y, 3) + ")", 10, 683);

    if(saveBox){
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 300, 25);
      fill(0, 0, 0);
      text("Points per curve (>=100 recommended): " + typing, 10, 17);
    }
    if(savedBox){
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 200, 25);
      fill(0, 0, 0);
      text("Exported! Press Esc to Close", 10, 17);
      saveBox = false;
    }
    if(savedDataBox){
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 200, 25);
      fill(0, 0, 0);
      text("Saved! Press Esc to Close", 10, 17);
    }
    if(enterPtLoc){
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 200, 25);
      fill(0, 0, 0);
      text("Add point(<x,y>): " + typing, 10, 17);
    }
    if(

    mouseLoop = mouse;
    if(keyPressed){
      if(!keyPrevPressed && allPoints.size() > 0 && !saveBox && !enterPtLoc && !saveNewDataBox){
        if(key == 'N' || key == 'n'){
          if(allPoints.get(pointInd).length > 2){
            pointInd++;
            if(pointInd == allPoints.size()){
              allPoints.add(new BezierPoint[1]);
              allPoints.get(pointInd)[0] = allPoints.get(pointInd-1)[allPoints.get(pointInd-1).length-1];
            }
          }else if(pointInd == 0 && allPoints.size() > 1){
            allPoints.remove(0);
          }
          keyPrevPressed = true;
        }else if(key == 'B' || key == 'b'){
          if(pointInd != 0){
            if(pointInd == allPoints.size()-1 && allPoints.get(pointInd).length == 1)
              allPoints.remove(pointInd);
            pointInd--;
          }else if(allPoints.size() > 0 && allPoints.get(0).length > 2){
              allPoints.add(0, new BezierPoint[1]);
              allPoints.get(0)[0] = allPoints.get(1)[0];
          }
          keyPrevPressed = true;
        }else if(key == DELETE){
          BezierPoint[] points = allPoints.get(pointInd);
          // deletes nearest point, if start or end and deletes point with point length of 3, delete entire curve segment,
          // cannot delete middle segment point if segment has 3 points
          if(points.length == 3){
            if(pointInd == 0)
              allPoints.remove(0);
            else if(pointInd == allPoints.size()-1){
              allPoints.remove(pointInd);
              pointInd--;
            }
          }else if(points.length > 3){
            double lowDist = points[1].getPos(0).add(mouse.scale(-1)).getMagnitude();
            int lowInd = 1;
            for(int i = 2; i < points.length-1; i++){
              double dist = points[i].getPos(0).add(mouse.scale(-1)).getMagnitude();
              if(dist < lowDist){
                lowDist = dist;
                lowInd = i;
              }
            }
            if(lowInd == 1)
              adjustControlPoints(pointInd, points[2].getPos(0).add(points[1].getPos(0).scale(-1)), false, 1);
            else if(lowInd == points.length-2)
              adjustControlPoints(pointInd, points[points.length-3].getPos(0).add(points[points.length-2].getPos(0).scale(-1)), true, points.length-2);
            BezierPoint[] temp = new BezierPoint[points.length-1];
            int i = 0;
            boolean skipped = false;
            while(i < points.length){
              if(i == lowInd){
                i++;
                skipped = true;
              }
              temp[i - (skipped? 1: 0)] = points[i];
              i++;
            }
            allPoints.set(pointInd, temp);
          }
          keyPrevPressed = true;
        }else if(key == 'e' || key == 'E'){
          saveBox = true;
          keyPrevPressed = true;
        }else if(keyCode == UP){
          speed+=10;
          startTime = System.currentTimeMillis();
        }else if(keyCode == DOWN){
          speed-=10;
          startTime = System.currentTimeMillis();
        }else if(key == 's' || key == 'S')
          if(currentSaveFile == null)
            saveNewDataBox = true;
          else {
            saveData();
            savedDataBox = true;
          }
        }else if(key == 'a' || key == 'A')
          enterPtLoc = true;
      }
    }else{
      keyPrevPressed = false;
    }
  }
}
Vector2D getPxlCoor(double feetX, double feetY){
  return new Vector2D(250 + feetX*23.2761, 665 - feetY*23.2761);
}
Vector2D getPxlCoor(Vector2D feet){return getPxlCoor(feet.x, feet.y);}
Vector2D getFeetCoor(double pxX, double pxY){
  return new Vector2D((pxX - 250)/23.2761, (665-pxY)/23.2761);
}
Vector2D getFeetCoor(Vector2D pxl){return getFeetCoor(pxl.x, pxl.y);

// rounds to the nearest decimal digit specified in "digit" variable
double round(double num, int digit){
  double pow = Math.pow(10, digit);
  double n = num*pow;
  return (n - ((int)n)) / pow;
}
void readSaveData(){
  try{
    Scanner sc = new Scanner(new File(dataPath("") + "/" + currentSaveFile + ".greg"));
    speed = Integer.parseInt(sc.nextLine());
    allPoints = new ArrayList<BezierPoint[]>();
    while(sc.hasNextLine()){
      String line = sc.nextLine();
      int ind = 0;
      ArrayList<Double> a = new ArrayList<Double>();
      do{
         ind = line.indexOf(',');
         if(ind == -1)
           a.add(Double.parseDouble(line));
         else{
           a.add(Double.parseDouble(line.substring(0, ind)));
           line = line.substring(ind+1);
         }
      } while(ind != -1);
      BezierPoint[] pts = new BezierPoint[a.size()/2];
      for(int i = 0; i < pts.length; i++)
        pts[i] = new BezierPoint(new Vector2D(a.get(2*i), a.get(2*i+1)));
      allPoints.add(pts);
    }
    pointInd = 0;
    sc.close();
  }catch(Exception e){
    System.err.println("greg file not detected");
  }
}
void saveData(){
  File file = new File(dataPath("") + "/" + currentSaveFile + ".greg");
  if(file.exists())
    file.delete();
  PrintWriter greg = createWriter(dataPath("") + "/" + currentSaveFile + ".greg");
  greg.write(speed + "\n");
  for(int p = 0; p < allPoints.size(); p++){
    String line = "";
    for(int i = 0; i < allPoints.get(p).length; i++)
      line += allPoints.get(p)[i].getPos(0).x + "," + allPoints.get(p)[i].getPos(0).y + ",";
    greg.write(line.substring(0, line.length()-1) + (p == allPoints.size()-1? "": "\n"));
  }
  greg.flush();
  greg.close();
}
void keyPressed(){
  if(!selectSaveFile){
    if(key==27){ // ESC
      key=0;
      saveBox = false;
      savedBox = false;
      enterPtLoc = false;
      typing = "";
    }
    if(saveBox){
      if(key == '\n'){
        int amt = Integer.parseInt(typing);
        File file = new File("Points.java");
        if(file.exists())
          file.delete();
        PrintWriter output = createWriter("Points.java");
        String out = "package frc.team578.robot.subsystems.swerve.motionProfiling;\n\n
          public class Points{\n\tpublic static final double curvesPerSec = " 
          + speed/1000 + ";\n\tpublic static final double[] points = {\n";
        for(int i = 0; i < allPoints.size()*amt; i++){
          int ptInd = i/amt;
          Vector2D pos = getFeetCoor(new BezierFunc(allPoints.get(ptInd)).getPos(((double)i%amt)/amt));
          out += "\t\t" + pos.x + ", " + pos.y + ",\n";
        }
        out = out.substring(0, out.length()-2) + "\n\t};\n}";
        output.println(out);
        output.flush();
        output.close();
        typing = "";
        saveBox = false;
        savedBox = true;
      }else
        typing += key;
    }
    if(savedDataBox)
      if(key != 's' && key != 'S')
        savedDataBox = false;
    if(enterPtLoc){
      if(key == '\n'){
        int ind = typing.indexOf(',');
        mouseSpecify = getPxlCoor(new Vector2D(Double.parseDouble(typing.substring(0, ind)), Double.parseDouble(typing.substring(ind+1).trim())));
        mouseReleased();
        typing = "";
        enterPtLoc = false;
      }else
        typing += key;
    }
    if(keyCode == BACKSPACE){
      if(typing.length() <= 2)
        typing = "";
      else
        typing = typing.substring(0, typing.length()-2);
    }
  }
}
int mxPrev = 0, myPrev = 0;
void mousePressed(){
  if(!selectSaveFile){
    Vector2D mouse = mouse();
    mousePrev = mouse;
    if(allPoints.size() > 0){
      BezierPoint[] points = allPoints.get(pointInd);
      double smallDist = Double.MAX_VALUE;
      for(int i = 0; i < points.length; i++){
        double mag = points[i].getPos(0).add(mouse.scale(-1)).getMagnitude();
        if(mag < smallDist){
          mouseInd = i;
          smallDist = mag;
        }
      }
    }
  }
}

Vector2D mouse(){
  return new Vector2D(mouseX, mouseY);
}

void mouseReleased(){
  if(selectSaveFile){
    ////////////////////////////////////////////////////////////////// TODO: get Height mouse coors to get save file name and read data
    // also include "new layout" text
    // also add box to specify save file name when saving new layout for first time(only new layout)
    int ind = ((int)(mouseY-150))/100;
    if(ind != -1){
      currentFileName = saveFileNames.get();
      readSaveData();
    }
    selectsSaveFile = false;
  }else{
    Vector2D mouse = mouse();
    if(mouseSpecify != null)
      mouse = mouseSpecify;
    if(mousePrev.add(mouse.scale(-1)).getMagnitude() < 0.0001 || mouseSpecify != null){
      if(allPoints.size() == 0){
        allPoints.add(new BezierPoint[1]);
        allPoints.get(0)[0] = new BezierPoint(mouse);
      }else {
        BezierPoint[] points = allPoints.get(pointInd);
        if(points.length == 1){
          if(pointInd == 0){
            if(allPoints.size() == 1){
              BezierPoint[] temp = new BezierPoint[2];
              temp[0] = points[0];
              temp[1] = new BezierPoint(mouse);
              allPoints.set(0, temp);
            }else{
              BezierPoint[] nextPts = allPoints.get(pointInd+1);
              BezierPoint[] temp = new BezierPoint[3];
              temp[2] = points[0];
              temp[1] = new BezierPoint(nextPts[0].getPos(0).add(nextPts[1].getPos(0).scale(-1)).add(temp[2].getPos(0)));
              temp[0] = new BezierPoint(mouse);
              allPoints.set(0, temp);
            }
          }else{
            BezierPoint[] temp = new BezierPoint[3];
            temp[0] = points[0];
            BezierPoint[] prevPts = allPoints.get(pointInd-1);
            temp[1] = new BezierPoint(prevPts[prevPts.length-1].getPos(0).add(prevPts[prevPts.length-2].getPos(0).scale(-1)).add(points[0].getPos(0)));
            temp[2] = new BezierPoint(mouse);
            allPoints.set(pointInd, temp);
          }
        }else{
          BezierPoint[] temp = new BezierPoint[points.length+1];
          for(int i = 0; i < points.length-1; i++)
            temp[i] = points[i];
          temp[temp.length-2] = new BezierPoint(mouse);
          temp[temp.length-1] = points[points.length-1];
          allPoints.set(pointInd, temp);
          adjustControlPoints(pointInd, temp[temp.length-2].getPos(0).add(temp[temp.length-3].getPos(0).scale(-1)), true, temp.length-2);
        } 
      }
    }
    mouseInd = -1;
    mouseSpecify = null;
  }
}

void adjustControlPoints(int pi, Vector2D dv, boolean up, int mouseInd){
  BezierPoint[] points = allPoints.get(pi);
  if(allPoints.get(pi).length == 1)
    dv = new Vector2D(0, 0);
  if(mouseInd == 0 && pi != 0 && !up){
      allPoints.get(pi-1)[allPoints.get(pi-1).length-1] = points[0];
      dv = dv.scale(2);
      allPoints.get(pi-1)[allPoints.get(pi-1).length-2] = new BezierPoint(allPoints.get(pi-1)[allPoints.get(pi-1).length-2].getPos(0).add(dv));
      if(allPoints.get(pi-1).length == 3)
        adjustControlPoints(pi-1, dv, false, 1);
    }else if(mouseInd == points.length-1 && pi != allPoints.size()-1 && up){
      allPoints.get(pi+1)[0] = points[mouseInd];
      dv = dv.scale(2);
      allPoints.get(pi+1)[1] = new BezierPoint(allPoints.get(pi+1)[1].getPos(0).add(dv));
      if(allPoints.get(pi+1).length == 3)
        adjustControlPoints(pi+1, dv, true, 1);
    }else if(mouseInd == points.length-2 && pi != allPoints.size()-1 && up){
      dv = dv.scale(-1);
      allPoints.get(pi+1)[1] = new BezierPoint(allPoints.get(pi+1)[1].getPos(0).add(dv));
      if(allPoints.get(pi+1).length == 3)
        adjustControlPoints(pi+1, dv, true, 1);
    }else if(mouseInd == 1 && pi != 0 && !up){
      dv = dv.scale(-1);
      allPoints.get(pi-1)[allPoints.get(pi-1).length-2] = new BezierPoint(allPoints.get(pi-1)[allPoints.get(pi-1).length-2].getPos(0).add(dv));
      if(allPoints.get(pi-1).length == 3)
        adjustControlPoints(pi-1, dv, false, 1);
    }
} 
