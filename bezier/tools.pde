Vector2D mouse() {
  return new Vector2D(mouseX, mouseY);
}
Vector2D pmouse() {
  return new Vector2D(pmouseX, pmouseY);
}
Vector2D getPxlCoor(double feetX, double feetY) {
  return new Vector2D(250 + feetX*23.2761, 665 - feetY*23.2761);
}
Vector2D getPxlCoor(Vector2D feet) {
  return getPxlCoor(feet.x, feet.y);
}
Vector2D getFeetCoor(double pxX, double pxY) {
  return new Vector2D((pxX - 250)/23.2761, (665-pxY)/23.2761);
}
Vector2D getFeetCoor(Vector2D pxl) {
  return getFeetCoor(pxl.x, pxl.y);
}

// rounds to the nearest decimal digit specified in "digit" variable
double round(double num, int digit) {
  double pow = Math.pow(10, digit);
  double n = num*pow;
  return (int)n / pow;
}

// one unit t per curve, returns range(0, 2pi)
double getRotation(double t){
  Double r1, r2;
  if(t >= allPoints.size()){
    t = allPoints.size();
    if((int)t-2 == -1)
      r1 = 0d;
    else
      r1 = rotation.get(allPoints.get((int)t-2)[allPoints.get((int)t-2).length-1]);
    r2 = rotation.get(allPoints.get((int)t-1)[allPoints.get((int)t-1).length-1]);
  }else{
    if((int)t-1 == -1)
      r1 = 0d;
    else
      r1 = rotation.get(allPoints.get((int)t-1)[allPoints.get((int)t-1).length-1]);
    r2 = rotation.get(allPoints.get((int)t)[allPoints.get((int)t).length-1]);
  }
  r1 = (r1 == null)? 0: r1%(Math.PI*2);
  r2 = (r2 == null)? 0: r2%(Math.PI*2);
  double f = 2*Math.PI;
  if(Math.abs(r1-r2) < Math.PI)
    f = 0;
  if(r2 > r1)
    f = -f;
  return ((1-t%1)*r1 + (t%1)*(r2 + f))%(2*Math.PI);
}
