void adjustControlPoints(int pi, Vector2D dv, boolean up, int mouseInd) {//pi is point index?
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
