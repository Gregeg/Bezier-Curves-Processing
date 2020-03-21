void draw() {
  speed=constrain(speed,0,Integer.MAX_VALUE);
  botRotScale = (simulation? botSimSize: 1);
  if (selectSaveFile) {
    background(204);
    fill(0, 0, 0);
    textFont(createFont("Arial", 30));
    text("Click on file or Create New Layout", 100, 50);
    textFont(bigFont);
    text("Create New Layout", 100, 100);
    for (int i = 0; i < saveFileNames.size(); i++)
      text(saveFileNames.get(i), 100, 50*(i+4));
  }else{
    simpleMode = io.get(0).state();
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
    if(pointInd < 0)
      pointInd = 0;
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
          strokeWeight(14);
          if(commandPosBox && (int)commT == i){
            stroke(0, 255, 255);
            Vector2D pos = func.getPos(commT-i);
            point((float)pos.x, (float)pos.y);
            stroke(0, 0, 0);
          }
          strokeWeight(10);
          Vector2D pos = func.getPos((((double)(curTime - startTime)*speed/1000)%1000)/1000);
          if(simulation){
            Double rot;
            if((curTime-startTime) >= ((double)allPoints.size()*1000000)/speed){
              BezierPoint[] pts = allPoints.get(allPoints.size()-1);
              BezierPoint p = pts[pts.length-1];
              pos = p.getPos(0);
              rot = rotation.get(p);
              if(rot == null)
                rot = 0d;
            }else
              rot = getRotation((((double)(curTime - startTime)*speed/1000)%1000)/1000+i);
            if(i == (int)(((double)(curTime - startTime)*speed/1000)%(1000*allPoints.size()))/1000){
              point((float)pos.x, (float)pos.y);
              robot.setTargetPos(getFeetCoor(pos));
              robot.setTargetRot(rot);
            }
            robot.periodic();
          }else
            if(!commandPosBox)
              drawBot(pos, getRotation((((double)(curTime - startTime)*speed/1000)%1000)/1000+i) + Math.PI/2);
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
      strokeWeight(14);
      stroke(0, 255, 255);
      fill(0, 255, 255);
      if(!commandPosBox)
        for(int i = 0; i < commands.size(); i++){
          Command c = commands.get(i);
          BezierFunc func = new BezierFunc(allPoints.get((int)c.getT()));
          Vector2D pos = func.getPos(c.getT()%1);
          point((float)pos.x, (float)pos.y);
          text(c.getName(), (float)pos.x + 15, (float)pos.y);
        }
      stroke(255, 0, 0);
      strokeWeight(2);
      for (int p = 0; p < allPoints.size(); p++) {
        BezierPoint[] pts = allPoints.get(p);
        BezierPoint ptLast  = pts[pts.length-1];
        Vector2D pt = allPoints.get(p)[0].getPos(0);
        strokeWeight(8);
        point((float)pt.x, (float)pt.y);
        strokeWeight(2);
        Double m = rotation.get(ptLast);
        if(m == null)
          m = 0d;
        if(!rotationBox || p != pointInd){
          Vector2D end = new Vector2D(ptLast.getPos(0).x + lengthOfArrows*Math.cos(m), ptLast.getPos(0).y + lengthOfArrows*Math.sin(m));
          line((float)ptLast.getPos(0).x, (float)ptLast.getPos(0).y, (float)end.x, (float)end.y);
          line((float)end.x, (float)end.y, (float)(end.x - arrowSize*Math.cos(m + Math.PI/4)), (float)(end.y - arrowSize*Math.sin(m + Math.PI/4)));
          line((float)end.x, (float)end.y, (float)(end.x - arrowSize*Math.cos(m - Math.PI/4)), (float)(end.y - arrowSize*Math.sin(m - Math.PI/4)));
        }
    }
      if(allPoints.size() != 0){
        Vector2D p = allPoints.get(0)[0].getPos(0);
        line((float)p.x, (float)p.y, (float)p.x + lengthOfArrows, (float)p.y);
        line((float)p.x + lengthOfArrows, (float)p.y, (float)p.x + lengthOfArrows - arrowSize/1.414, (float)p.y + arrowSize/1.414);
        line((float)p.x + lengthOfArrows, (float)p.y, (float)p.x + lengthOfArrows - arrowSize/1.414, (float)p.y - arrowSize/1.414);

      }
      strokeWeight(8);
      BezierPoint[] last = allPoints.get(allPoints.size()-1);
      point((float)last[last.length-1].getPos(0).x, (float)last[last.length-1].getPos(0).y);
      stroke(0, 0, 0);
      if (mouseInd != -1) {
        Vector2D dv = mouse.add(pmouse().scale(-1));
        if(!moved && dv.getMagnitude() != 0){
          addState();
          moved = true;
        }
        points[mouseInd].setPos(points[mouseInd].getPos(0).add(dv));
        if (mouseInd == 1 && points.length == 3) {
          adjustControlPoints(pointInd, dv, false, 1);
          adjustControlPoints(pointInd, dv, true, 1);
        } else if (mouseInd <= 1 && pointInd != 0)
          adjustControlPoints(pointInd, dv, false, mouseInd);
        else if (mouseInd >= points.length-2)
          adjustControlPoints(pointInd, dv, true, mouseInd);
      }else
        moved = false;
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
    rect(0, 50, 200, 600);  // Menu

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
    if (rotationBox) {
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 150, 25);
      fill(0, 0, 0);
      text("Click to set Rotation", 10, 17);
      strokeWeight(3);
      stroke(255, 0, 0);
      Vector2D pt = allPoints.get(pointInd)[allPoints.get(pointInd).length-1].getPos(0);
      Vector2D m = mouse().add(pt.scale(-1));
      m = m.scale((lengthOfArrows+20)/m.getMagnitude());
      Vector2D end = m.add(pt);
      line((float)pt.x, (float)pt.y, (float)(end.x), (float)(end.y));
      line((float)end.x, (float)end.y, (float)(end.x - arrowSize*Math.cos(m.getAngleRad() + Math.PI/4)), (float)(end.y - arrowSize*Math.sin(m.getAngleRad() + Math.PI/4)));
      line((float)end.x, (float)end.y, (float)(end.x - arrowSize*Math.cos(m.getAngleRad() - Math.PI/4)), (float)(end.y - arrowSize*Math.sin(m.getAngleRad() - Math.PI/4)));
    }
    if (pidBox){
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 200, 25);
      fill(0, 0, 0);
      double c;
      switch(pidChar){
        case 'P':
          c = robot.getP();
          break;
        case 'I':
          c = robot.getI();
          break;
        case 'D':
          c = robot.getD();
          break;
        default:
          c = 0;
      }
      text(pidChar + "(" + c + "): " + typing, 10, 17);
    }
    if(pidSaveBox) {
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 300, 25);
      fill(0, 0, 0);
      text("P:" + robot.getP() + " I:" + robot.getI() + " D:" + robot.getD() + " Press Esc to Close", 10, 17);
    }
    if(commandBox){
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 400, 25);
      fill(0, 0, 0);
      text("Command class name: " + typing, 10, 17);
    }
    if(commandPosBox){
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 300, 25);
      fill(0, 0, 0);
      text("use arrow keys and press \"C\" for position" + typing, 10, 17);
    }
    if (keyPressed || pushed) {
      if (!keyPrevPressed && allPoints.size() > 0 && !saveBox && !enterPtLoc && !saveNewDataBox && !commandBox && !pidBox && !commandPosBox) {
        if(pushed)
          pushed = false;
        if (!commandPosBox && (key == 'N' || key == 'n' || keyCode == RIGHT)) {
          if (allPoints.get(pointInd).length > 2) {
            pointInd++;
            if (pointInd == allPoints.size()) {
               addState();
              allPoints.add(new BezierPoint[1]);
              allPoints.get(pointInd)[0] = allPoints.get(pointInd-1)[allPoints.get(pointInd-1).length-1];
            }
          } else if (pointInd == 0 && allPoints.size() > 1) {
            addState();
            changeAllCommandT(-1);
            allPoints.remove(0);
          }
          keyPrevPressed = true;
        } else if (!commandPosBox && (key == 'B' || key == 'b' || keyCode == LEFT)) {
          if (pointInd != 0) {
            if (pointInd == allPoints.size()-1 && allPoints.get(pointInd).length == 1) {
              addState();
              allPoints.remove(pointInd);
            }
            pointInd--;
          } else if (allPoints.size() > 0 && allPoints.get(0).length > 2){
            addState();
            changeAllCommandT(1);
            allPoints.add(0, new BezierPoint[1]);
            allPoints.get(0)[0] = allPoints.get(1)[0];
          }
          keyPrevPressed = true;
        }else if (key == DELETE) {
          BezierPoint[] points = allPoints.get(pointInd);
          // deletes nearest point, if start or end and deletes point with point length of 3, delete entire curve segment,
          // cannot delete middle segment point if segment has 3 points
          if (points.length == 3) {
            addState();
            if (pointInd == 0) {
              allPoints.remove(0);
              for(int i = 0; i < commands.size(); i++)
                if((int)commands.get(i).getT() == 0){
                  commands.remove(i);
                  i--;
                }
                changeAllCommandT(-1);
            } else if (pointInd == allPoints.size()-1) {
              allPoints.remove(pointInd);
              for(int i = 0; i < commands.size(); i++)
                if((int)commands.get(i).getT() == pointInd){
                  commands.remove(i);
                  i--;
                }
              pointInd--;
            }
          } else if (points.length > 3) {
            addState();
            double lowDist = points[1].getPos(0).add(mouse.scale(-1)).getMagnitude();
            int lowInd = 1;
            for (int i = 2; i < points.length-1; i++) {
              double dist = points[i].getPos(0).add(mouse.scale(-1)).getMagnitude();
              if (dist < lowDist) {
                lowDist = dist;
                lowInd = i;
              }
            }
            double lowDistComm = Double.MAX_VALUE;
            int lowIndComm = -1;
            for(int i = 0; i < commands.size(); i++){
              double t = commands.get(i).getT();
              BezierFunc func = new BezierFunc(allPoints.get((int)t));
              double dist = mouse.add(func.getPos(t%1).scale(-1)).getMagnitude();
              if(dist < lowDistComm){
                lowDistComm = dist;
                lowIndComm = i;
              }
            }
            if(lowIndComm != -1 && lowDistComm < lowDist)
              commands.remove(lowIndComm);
            else{
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
            }
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
            addState();
            if (points.length == 2) {
              BezierPoint[] temp = {points[1-lowInd]};
              allPoints.set(0, temp);
            } else {
              allPoints.remove(0);
            }
          }
          keyPrevPressed = true;
        } else if (key == 'e' || key == 'E' || io.get(2).state()) { // Export
          saveBox = true;
          keyPrevPressed = true;
        } else if (keyCode == UP) {
          speed+=10;
        } else if (keyCode == DOWN) {
          speed-=10;
        } else if (key == 's' || key == 'S' || io.get(1).state()) { // Save
          if (currentFileName == null)
            saveNewDataBox = true;
          else {
            saveData();
            savedDataBox = true;
          }
        } else if (key == 'a' || key == 'A' || io.get(3).state()) // specify point
          enterPtLoc = true;
        else if (key == 26 || io.get(4).state()){       // UNDO
          restoreState();
          keyPrevPressed = true;
        } else if ((key == 'r' || key == 'R' || io.get(5).state()) && allPoints.size() != 0 && allPoints.get(pointInd).length > 1){  // rotate
          rotationBox = !rotationBox;
          keyPrevPressed = true;
        }else if((key == ' ' || io.get(7).state()) && allPoints.get(0).length > 1){
          simulation = !simulation;
          if(simulation){
            robot.setPos(getFeetCoor(allPoints.get(0)[0].getPos(0)));
            robot.reset();
            startTime = System.currentTimeMillis();
          }
          keyPrevPressed = true;
        }else if(key == 'p' || key == 'P' || io.get(8).state()){ // pid values
          pidChar = 'P';
          pidBox = !pidBox;
          typing = "";
          keyPrevPressed = true;
        }else if(allPoints.get(pointInd).length > 1 && (key == 'c' || key == 'C' || io.get(6).state())){ // command
          commandBox = true;
          typing = "";
          keyPrevPressed = true;
        }
      }
      if(commandPosBox){
          if(keyCode == LEFT){
            if(commandLeft > 75)
              commT -= .04;
            else if(commandLeft > 45)
              commT -= .02;
            else
              commT -= .0025;
            if(commT < 0)
              commT = 0;
            commandLeft++;
            commandRight = 0;
          }else if(keyCode == RIGHT){
            if(commandRight > 75)
              commT += .04;
            else if(commandRight > 45)
              commT += .02;
            else
              commT += .0025;
            if(commT >= allPoints.size())
              commT = allPoints.size() - .0000001;
            commandRight++;
            commandLeft = 0;
          }
        }
    } else {
      keyPrevPressed = false;
      commandLeft = 0;
      commandRight = 0;
    }
    paintIO();
  }
}
