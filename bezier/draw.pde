void draw() {
  speed=constrain(speed,0,Integer.MAX_VALUE);
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
      stroke(255, 0, 0);
      strokeWeight(2);
      float lengthOfArrows = 30;
      for (int p = 0; p < allPoints.size(); p++) {
        BezierPoint[] pts = allPoints.get(p);
        BezierPoint ptLast  = pts[pts.length-1];
        Vector2D pt = allPoints.get(p)[0].getPos(0);
        point((float)pt.x, (float)pt.y);
        Double m = rotation.get(ptLast);
        if(m == null)
          m = 0d;
        line((float)ptLast.getPos(0).x, (float)ptLast.getPos(0).y, (float)(ptLast.getPos(0).x + lengthOfArrows*Math.cos(m)), (float)(ptLast.getPos(0).y + lengthOfArrows*Math.sin(m)));
      }
      if(allPoints.size() != 0){
        Vector2D p = allPoints.get(0)[0].getPos(0);
        line((float)p.x, (float)p.y, (float)p.x + lengthOfArrows, (float)p.y);
      }
      BezierPoint[] last = allPoints.get(allPoints.size()-1);
      point((float)last[last.length-1].getPos(0).x, (float)last[last.length-1].getPos(0).y);
      stroke(0, 0, 0);
      if (mouseInd != -1) {
        Vector2D dv = mouse.add(pmouse().scale(-1));
        points[mouseInd].setPos(points[mouseInd].getPos(0).add(dv));
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
    if (rotationBox) {
      fill(255, 255, 255);
      strokeWeight(1);
      rect(0, 0, 150, 25);
      fill(0, 0, 0);
      text("Click to set Rotation", 10, 17);
      
      
      strokeWeight(10);
      stroke(0, 255, 255);
      
    }
    if (keyPressed) {
      if (!keyPrevPressed && allPoints.size() > 0 && !saveBox && !enterPtLoc && !saveNewDataBox) {
        if (key == 'N' || key == 'n' || keyCode == RIGHT) {
          allPointsPrev.add(new ArrayList<BezierPoint[]>(allPoints));
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
              allPointsPrev.add(new ArrayList<BezierPoint[]>(allPoints));
              allPoints.remove(pointInd);
            }
            pointInd--;
          } else if (allPoints.size() > 0 && allPoints.get(0).length > 2){
            allPointsPrev.add(new ArrayList<BezierPoint[]>(allPoints));
            allPoints.add(0, new BezierPoint[1]);
            allPoints.get(0)[0] = allPoints.get(1)[0];
          }
          keyPrevPressed = true;
        }else if (key == DELETE) {
          BezierPoint[] points = allPoints.get(pointInd);
          // deletes nearest point, if start or end and deletes point with point length of 3, delete entire curve segment,
          // cannot delete middle segment point if segment has 3 points
          if (points.length == 3) {
            allPointsPrev.add(new ArrayList<BezierPoint[]>(allPoints));
            if (pointInd == 0) {
              allPoints.remove(0);
            } else if (pointInd == allPoints.size()-1) {
              allPoints.remove(pointInd);
              pointInd--;
            }
          } else if (points.length > 3) {
            allPointsPrev.add(new ArrayList<BezierPoint[]>(allPoints));
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
            allPointsPrev.add(new ArrayList<BezierPoint[]>(allPoints));
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
        } else if (keyCode == DOWN) {
          speed-=10;
        } else if (key == 's' || key == 'S') {
          if (currentFileName == null)
            saveNewDataBox = true;
          else {
            saveData();
            savedDataBox = true;
          }
        } else if (key == 'a' || key == 'A')
          enterPtLoc = true;
        else if (key == 26){
          if(allPointsPrev.size() > 0){
            allPoints = allPointsPrev.remove(allPointsPrev.size()-1);
            if(allPoints.size() == 0)
              pointInd = 0;
            else if(allPoints.size() == pointInd)
              pointInd = allPoints.size()-1;
            if(simpleMode){
              allPoints.remove(pointInd);
              pointInd--;
            }
          }
          keyPrevPressed = true;
        } else if ((key == 'r' || key == 'R') && allPoints.size() != 0 && allPoints.get(pointInd).length > 1)
            rotationBox = true;
      } 
    } else {
      keyPrevPressed = false;
    }
    simpleModeSwitch.paint();
  }
}
