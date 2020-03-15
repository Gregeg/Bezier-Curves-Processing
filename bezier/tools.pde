Vector2D mouse() {
  return new Vector2D(mouseX, mouseY);
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
