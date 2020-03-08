ArrayList<BezierPoint[]> allPoints = new ArrayList<BezierPoint[]>();
Vector2D mousePrev, mouseLoop;
int mouseInd, pointInd;
int t = 0;
boolean keyPrevPressed = false;
void setup(){
  pointInd = 0;
  mouseLoop = mouse();
  mouseInd = -1;
  size(600, 500);
  frameRate(60);
}
void draw(){
  Vector2D mouse = mouse();
  println(pointInd);
  background(204);
  if(allPoints.size() > 0){
    println(allPoints.get(0).length);
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
        Vector2D pos = func.getPos(((double)t)/100);
        point((float)pos.x, (float)pos.y);
      }
    }
    t++;
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
    if(t >= 100)
      t = 0;
  }
  mouseLoop = mouse;
  if(keyPressed){
    if(!keyPrevPressed && allPoints.size() > 0){
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
      }
    }
  }else{
    keyPrevPressed = false;
  }
}
int mxPrev = 0, myPrev = 0;
void mousePressed(){
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

Vector2D mouse(){
  return new Vector2D(mouseX, mouseY);
}

void mouseReleased(){
  if(mousePrev.add(mouse().scale(-1)).getMagnitude() < 0.0001){
    if(allPoints.size() == 0){
      allPoints.add(new BezierPoint[1]);
      allPoints.get(0)[0] = new BezierPoint(mouse());
    }else {
      BezierPoint[] points = allPoints.get(pointInd);
      if(points.length == 1){
        if(pointInd == 0){
          if(allPoints.size() == 1){
            BezierPoint[] temp = new BezierPoint[2];
            temp[0] = points[0];
            temp[1] = new BezierPoint(mouse());
            allPoints.set(0, temp);
          }else{
            BezierPoint[] nextPts = allPoints.get(pointInd+1);
            BezierPoint[] temp = new BezierPoint[3];
            temp[2] = points[0];
            temp[1] = new BezierPoint(nextPts[0].getPos(0).add(nextPts[1].getPos(0).scale(-1)).add(temp[2].getPos(0)));
            temp[0] = new BezierPoint(mouse());
            allPoints.set(0, temp);
          }
        }else{
          BezierPoint[] temp = new BezierPoint[3];
          temp[0] = points[0];
          BezierPoint[] prevPts = allPoints.get(pointInd-1);
          temp[1] = new BezierPoint(prevPts[prevPts.length-1].getPos(0).add(prevPts[prevPts.length-2].getPos(0).scale(-1)).add(points[0].getPos(0)));
          temp[2] = new BezierPoint(mouse());
          allPoints.set(pointInd, temp);
        }
      }else{
        BezierPoint[] temp = new BezierPoint[points.length+1];
        for(int i = 0; i < points.length-1; i++)
          temp[i] = points[i];
        temp[temp.length-2] = new BezierPoint(mouse());
        temp[temp.length-1] = points[points.length-1];
        allPoints.set(pointInd, temp);
        adjustControlPoints(pointInd, temp[temp.length-2].getPos(0).add(temp[temp.length-3].getPos(0).scale(-1)), true, temp.length-2);
      } 
    }
  }
  mouseInd = -1;
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
