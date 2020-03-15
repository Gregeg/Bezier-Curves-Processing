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

void mousePressed() {
  if (!selectSaveFile && !simpleModeSwitch.contains(mouse())) {
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

void mouseReleased() {
  if (simpleModeSwitch.contains(mouse())) {
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
      if(!simpleMode)
        allPointsPrev.add(new ArrayList<BezierPoint[]>(allPoints));
      if (!simpleMode || allPoints.size() == 0) {
        if (allPoints.size() == 0) {
          allPoints.add(new BezierPoint[1]);
          allPoints.get(0)[0] = new BezierPoint(mouse);
        } else {
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
      } else {//SIMPLE MODE CODE
        allPointsPrev.add(new ArrayList<BezierPoint[]>(allPoints));
        pointInd = allPoints.size()-1;
        if (allPoints.get(pointInd).length < 4) {
          ////////////////////////////////////////////////// TODO, add the 3 points for a cubic spline
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
            allPoints.set(allPoints.size()-1, temp);
            adjustControlPoints(pointInd, temp[temp.length-2].getPos(0).add(temp[temp.length-3].getPos(0).scale(-1)), true, temp.length-2);
          }
        } else {
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
          mouseReleased();
          Vector2D prePoint = allPoints.get(allPoints.size()-1)[0].pos;
          mouseX = (int)(prePoint.x+(mouseX-prePoint.x)/2);
          mouseY = (int)(prePoint.y+(mouseY-prePoint.y)/2);
          mousePrev = mouse();
          mouseReleased();
        }
        if (allPoints.get(allPoints.size()-1).length==2) {
          BezierPoint[] temp = new BezierPoint[4], points=allPoints.get(allPoints.size()-1);
          temp[0] = points[0];
          temp[1] = new BezierPoint(new Vector2D((points[0].pos.x+points[1].pos.x)/2, (points[0].pos.y+points[1].pos.y)/2));
          temp[2] = new BezierPoint(new Vector2D((points[0].pos.x+points[1].pos.x)/2, (points[0].pos.y+points[1].pos.y)/2));
          temp[3] = points[1];
          allPoints.set(allPoints.size()-1, temp);
        }
      }
    }
    mouseInd = -1;
    mouseSpecify = null;
  }
}
