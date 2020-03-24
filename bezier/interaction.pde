void keyPressed() {
  if (!selectSaveFile) {
    if (key==27) { // ESC
      key=0;
      if(commandPosBox)
        commands.remove(commands.size()-1);
      if(waitPointPosBox)
        waitPoints.remove(waitPoints.size()-1);
      saveBox = false;
      savedBox = false;
      enterPtLoc = false;
      saveNewDataBox = false;
      rotationBox = false;
      pidBox = false;
      commandBox = false;
      commandPosBox = false;
      waitPointBox = false;
      waitPointPosBox = false;
      typing = "";
    }
    if (saveBox) {
      if (key == '\n' ) {
        int amt = Integer.parseInt(typing);
        File file = new File("Points.java");
        if (file.exists())
          file.delete();
        if(allPoints.get(pointInd).length == 1) {
          allPoints.remove(pointInd);
          if(pointInd != 0)
            pointInd--;
        }
        ArrayList<Command> sortedComms = new ArrayList<Command>(commands);
        Collections.sort(sortedComms);
        PrintWriter output = createWriter("Points.java");
        String out = "package frc.team578.robot.subsystems.swerve.motionProfiling;\n\nimport java.util.ArrayList;\nimport frc.team578.robot.commands.*;\n\npublic class Points{\n\tpublic static final double curvesPerSec = " 
          + ((double)speed)/1000 + ";\n\tpublic static final int pointsPerCurve = " + amt + ";\n\t" + "public static final double[] pidValues = {"+robot.getP()+", "+robot.getI()+", "+robot.getD()+"};\n\n\t"
          + "protected static class TimedCommand{\n\t\tpublic String name;\n\t\tpublic double t;\n\n\t\tprotected TimedCommand(String name, double t){" + 
          "\n\t\t\tthis.name = name;\n\t\t\tthis.t = t;\n\t\t}\n\t\tpublic double getT(){\n\t\t\treturn t;\n\t\t}\n\t\tpublic String getName(){\n\t\t\treturn name;\n\t\t}\n\t}\n\n\t"
          + "public static TimedCommand[] commands = {";
        for(int i = 0; i < sortedComms.size(); i++){
          Command c = sortedComms.get(i);
          out += " new TimedCommand(\"" + c.getName() + "\", " + c.getT() + "),";
        }
        if(out.charAt(out.length()-1) == ',')
          out = out.substring(0, out.length() - 1);
        out += "};\n\tprivate static class p0{\n\t\tprivate static double[] getPoints0(){\n\t\t\tdouble[] d = {";
        int aLevel = 0;
        int cLevel = 0;
        int waitPointInd = 0;
        int totalPoints = 0;
        for (int i = 0; i < allPoints.size()*amt; i++) {
          int ptInd = i/amt;
          double time = ((double)i%amt)/amt;
          BezierFunc func = new BezierFunc(allPoints.get(ptInd));
          if(waitPointInd != waitPoints.size() && time >= waitPoints.get(waitPointInd).getT()){
            int mp = (int)(((double)speed)*amt*waitPoints.get(waitPointInd).getDuration()/1000000);
            Vector2D p = getFeetCoor(func.getPos(waitPoints.get(waitPointInd).getT()));
            for(int w = 0; w < mp; w++){
              out += p.x + ", " + p.y + ", " + getRotation(((double)i%amt)/amt) + ", ";
              totalPoints++;
              if ((totalPoints)%1000 == 0) {
                aLevel++;
                if(aLevel == 10){
                  aLevel--;
                  cLevel++;
                  out = out.substring(0, out.length()-2) + "};\n\t\t\treturn d;\n\t\t}\n\t\t";
                  out += endOfClass(aLevel);
                  out += "}\n\tprivate static class p" + cLevel
                    + "{\n\t\tprivate static double[] getPoints0(){\n\t\t\tdouble[] d = {";
                  aLevel = 0;
                }else
                  out = out.substring(0, out.length()-2) + "};\n\t\t\treturn d;\n\t\t}\n\t\tprivate static double[] getPoints" + aLevel + "(){\n\t\t\tdouble[] d = {";
              }
            }
            waitPointInd++;
          }
          Vector2D pos = getFeetCoor(new BezierFunc(allPoints.get(ptInd)).getPos(time));
          out += pos.x + ", " + pos.y + ", " + getRotation(((double)i%amt)/amt) + ", ";
          totalPoints++;
          if ((totalPoints)%1000 == 0) {
            aLevel++;
            if(aLevel == 10){
              aLevel--;
              cLevel++;
              out = out.substring(0, out.length()-2) + "};\n\t\t\treturn d;\n\t\t}\n\t\t";
              out += endOfClass(aLevel);
              out += "}\n\tprivate static class p" + cLevel
                + "{\n\t\tprivate static double[] getPoints0(){\n\t\t\tdouble[] d = {";
              aLevel = 0;
            }else
              out = out.substring(0, out.length()-2) + "};\n\t\t\treturn d;\n\t\t}\n\t\tprivate static double[] getPoints" + aLevel + "(){\n\t\t\tdouble[] d = {";
          }
        }
        if(out.substring(out.length()-2).equals(", "));
          out = out.substring(0, out.length()-2);
        out += "};\n\t\t\treturn d;\n\t\t}\n\t\t";
        out += endOfClass(aLevel);
        out += "}\n\tpublic static double[] getTotalPoints(){\n\t\t";
        for (int j = 0; j <= cLevel; j++)
          out += "double[] d" + j + " = p" + j + ".getTotalPoints();\n\t\t";
        out += "double[] d = new double[";
        for (int j = 0; j <= cLevel; j++)
          out += "d" + j + ".length + ";
        out = out.substring(0, out.length()-3) + "];\n\t\t";
        out += "ArrayList<double[]> dd = new ArrayList<double[]>();\n\t\t";
        for (int j = 0; j <= cLevel; j++)
          out += "dd.add(d" + j + ");\n\t\t";
        out += "int ind = 0;\n\t\tfor(int i = 0; i < dd.size(); i++){\n\t\t\tdouble[] ddd = dd.get(i);"
          + "\n\t\t\tfor(int j = 0; j < ddd.length; j++){\n\t\t\t\td[ind] = ddd[j];\n\t\t\t\tind++;\n\t\t\t}\n\t\t}\n\t\treturn d;\n\t}\n}";
        output.println(out);
        output.flush();
        output.close();
        typing = "";
        saveBox = false;
        savedBox = true;
      } else
        if((int)key != 65535)
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
        if((int)key != 65535)
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
        if((int)key != 65535)
          typing += key;
    }
    if(pidBox){
       if (key == '\n'){
         double c = Double.parseDouble(typing.trim());
         switch(pidChar){
           case 'P':
             robot.setP(c);
             pidChar = 'I';
             break;
           case 'I':
             robot.setI(c);
             pidChar = 'D';
             break;
           case 'D':
             robot.setD(c);
             pidChar = null;
             pidBox = false;
             pidSaveBox = true;
         }
         typing = "";
       }else
         if((int)key != 65535)
          typing += key;
    }
    if (pidSaveBox)
      if(key != '\n')
         pidSaveBox = false;
    if(commandBox){
      if(key == '\n'){
        addCommand(typing);
        typing = "";
        commandBox = false;
        commandPosBox = true;
        commT = 0d;
      }else
        if((int)key != 65535)
          typing += key;
    }
    if(commandPosBox && (key == 'c' || key == 'C')){
      addState();
      setCommandT(commT);
      commandPosBox = false;
      rotated = true;
      keyPrevPressed = true;
    }
    if(waitPointBox){
      if(key == '\n'){
        addWaitPoint(Double.parseDouble(typing.trim()));
        typing = "";
        waitPointBox = false;
        waitPointPosBox = true;
        waitT = 0d;
      }else
        if((int)key != 65535)
          typing += key;
    }
    if(waitPointPosBox && (key == 'W' || key == 'w')){
      addState();
      setWaitPointT(waitT);
      waitPointPosBox = false;
      rotated = true;
      keyPrevPressed = true;
    }
    if (keyCode == BACKSPACE) {
      if (typing.length() <= 2)
        typing = "";
      else
        typing = typing.substring(0, typing.length()-2);
    }
    if(typing.length() > 0 && (keyCode == LEFT || keyCode == RIGHT || keyCode == UP || keyCode == DOWN))
      typing = typing.substring(0, typing.length()-1);
  }
}

void mousePressed() {
  if (!selectSaveFile && mouseX > 200) {
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
  if (rotationBox) {
    BezierPoint[] points = allPoints.get(pointInd);
    BezierPoint point = points[points.length-1];
    if(rotation.get(point) == null)
      rotation.put(point, mouse().add(point.getPos(0).scale(-1)).getAngleRad());
    else
      rotation.replace(point, mouse().add(point.getPos(0).scale(-1)).getAngleRad());
    mouseInd = -1;
    rotationBox = false;
    rotated = true;
  } else {
    if(mouseX < 200)
      checkIO();
    if (selectSaveFile) {
      int ind = ((int)(mouseY-175))/50;
      if (ind < saveFileNames.size()) {
        if (ind >= 0) {
          if(mouseX < 600){
            currentFileName = saveFileNames.get(ind);
            readSaveData();
            selectSaveFile = false;
          }else{
            int n = JOptionPane.showConfirmDialog(null, "Are you sure you want to delete " + saveFileNames.get(ind) 
              + "?\nDeleted save files cannot be recovered.", "Delete Save" , JOptionPane.ERROR_MESSAGE, JOptionPane.YES_NO_OPTION);
            if(n != JOptionPane.YES_OPTION)
              return;
            new File(dataPath("") + "/" + saveFileNames.get(ind) + ".greg").delete();
            saveFileNames.remove(ind);
            new File(dataPath("") + "/bezierSave.gurg").delete();
            PrintWriter pw = createWriter(dataPath("") + "/bezierSave.gurg");
            String out = "";
            for(String name: saveFileNames)
              out += name + "\n";
            pw.write(out.substring(0, out.length()-1));
            pw.flush();
            pw.close();
            return;
          }
        }
        selectSaveFile = false;
      }
    } else {
      Vector2D mouse = mouse();
      if (mouseSpecify != null)
        mouse = mouseSpecify;
      if (mousePrev.add(mouse.scale(-1)).getMagnitude() < 0.0001 || mouseSpecify != null) {
        moved = true;
        inc = false;
        if(simulation)
          robot.resetTime();
        if(!simpleMode)
          addState();
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
                  changeAllWaitPointT(1);
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
          pointInd = allPoints.size()-1;
          if (allPoints.get(pointInd).length < 4) {
            BezierPoint[] points = allPoints.get(pointInd);
            if (points.length == 1) {
              addState();
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
}
Double moveDot(Double t){ //changes double based on user input
  if(keyCode == LEFT){
    if(waitLeft > 75)
      t -= .04;
    else if(waitLeft > 45)
      t -= .02;
    else
      t -= .0025;
    if(t < 0)
      t = 0d;
    waitLeft++;
    waitRight = 0;
  }else if(keyCode == RIGHT){
    if(waitRight > 75)
      t += .04;
    else if(waitRight > 45)
      t += .02;
    else
      t += .0025;
    if(t >= allPoints.size())
      t = allPoints.size() - .0000001d;
    waitRight++;
    waitLeft = 0;
  }
  return t;
}
String endOfClass(int aLevel){
  String out = "";
  out += "public static double[] getTotalPoints(){\n\t\t\t";
  for (int j = 0; j <= aLevel; j++)
    out += "double[] d" + j + " = getPoints" + j + "();\n\t\t\t";
  out += "double[] d = new double[";
  for (int j = 0; j <= aLevel; j++)
    out += "d" + j + ".length + ";
  out = out.substring(0, out.length()-3) + "];\n\t\t\t";
  out += "ArrayList<double[]> dd = new ArrayList<double[]>();\n\t\t\t";
  for (int j = 0; j <= aLevel; j++)
    out += "dd.add(d" + j + ");\n\t\t\t";
  out += "int ind = 0;\n\t\t\tfor(int i = 0; i < dd.size(); i++){\n\t\t\t\tdouble[] ddd = dd.get(i);"
    + "\n\t\t\t\tfor(int j = 0; j < ddd.length; j++){\n\t\t\t\t\td[ind] = ddd[j];\n\t\t\t\t\tind++;\n\t\t\t\t}\n\t\t\t}\n\t\t\treturn d;\n\t\t}\n\t";
  return out;
}
