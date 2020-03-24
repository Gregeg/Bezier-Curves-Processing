class Robot {
  private Vector2D botPos, botSpeed, targetPos;
  private Vector2D[] lastWheelPos;
  private double p, i, d, rot, angularSpeed, targetRot;
  private double sinB, cosB; // sin and cos of botrot wheel positions
  private long prevTime;

  Robot(double p, double i, double d, Vector2D botPos, Vector2D targetPos) {
    
    this.p = p;
    this.i = i;
    this.d = d;
    this.botPos = botPos;
    this.targetPos = targetPos;
    rot = 0;
    double l = Math.sqrt(botWidth*botWidth + botHeight*botHeight);
    sinB = botHeight / l;
    cosB = botWidth / l;
    lastWheelPos = new Vector2D[4];
    reset();
  }
  void resetTime(){
    prevTime = System.currentTimeMillis();
  }
  void reset(){
    resetTime();
    botSpeed = new Vector2D(0, 0.0001);
    angularSpeed = 0;
    rot = 0;
  }
  void periodic(){
    long curTime = System.currentTimeMillis();
    long dt = curTime-prevTime;
    drawBot(getPxlCoor(botPos), rot + PI/2);
    Vector2D errP = targetPos.add(botPos.scale(-1)).scale(p);
    Vector2D eF;
    if(errP.getMagnitude() > 1)
      eF = errP.scale(1/errP.getMagnitude());
    else
      eF = errP;
    double r = rot - targetRot;
    r %= 2*PI;
    if(Math.abs(r) > PI)
      r += 2*PI*(r<0? 1: -1);
    if(Math.abs(r) > 1)
      r = (r<0? -1: 1);
    Vector2D[] wheels = getPreportionalWheelPower(eF.add(botSpeed.scale(-d)), r, rot); // wheel power
    double powerSumMag = 0;
    for(int i = 0; i < 4; i++)
       powerSumMag += wheels[i].getMagnitude();
    double speed = botSpeed.getMagnitude();
    Vector2D[] wheelForce = new Vector2D[4];
    for(int i = 0; i < 4; i++){
      wheelForce[i] = wheels[i].scale(tCurve.getWheelForce(speed/powerSumMag*wheels[i].getMagnitude(), wheels[i].getMagnitude())/wheels[i].getMagnitude());
    }
    double angleAccel = 0;
    for(int i = 0; i < 4; i++)
      angleAccel += dotProd(lastWheelPos[i].scale(1/lastWheelPos[i].getMagnitude()), wheelForce[i]);
    angleAccel /= moment2;
    Vector2D wheelForceSum = new Vector2D(0, 0);
    for(int i = 0; i < 4; i++)
      wheelForceSum = wheelForceSum.add(wheelForce[i]);
    Vector2D botAccel = wheelForceSum.scale(32.174/*slug*//botWeight);
    skidding = false;
    if(botAccel.getMagnitude() > botMaxAccel){
      botAccel = botAccel.scale(botMaxAccel/botAccel.getMagnitude());
      skidding = true;
    }
    botAccel = botAccel.add(botSpeed.scale(-drag*speed - fric/speed));// reduced accel due to friction
    Vector2D nBotSpeed = botSpeed.add(botAccel.scale((double)dt/1000));
    angleAccel = angleAccel - angResistance*angularSpeed;
    double nAngularSpeed = angularSpeed + angleAccel*dt/1000;
    botPos = botPos.add(nBotSpeed.add(botSpeed).scale((double)dt/2000));
    rot += (nAngularSpeed + angularSpeed)/2;
    rot %= 2*PI;
    botSpeed = nBotSpeed;
    angularSpeed = nAngularSpeed;
    prevTime = curTime; //<>// //<>//
  }
  void setTargetPos(Vector2D pos){
    targetPos = pos;
  }
  void setTargetRot(double tr){
    if(tr < 0)
    tr += PI*2;
    targetRot = tr;
  }
  void setPos(Vector2D pos){
    botPos = pos;
  }
  void setP(double p){this.p = p;}
  void setI(double i){this.i = i;}
  void setD(double d){this.d = d;}
  
  double getP(){return p;}
  double getI(){return i;}
  double getD(){return d;}
  
  // rewrite of "move" method in SwerveMath.java, much more efficenct and compact
  // str = (both vars range<-1, 1>; forces relative to bot), rotPower = (rot power positive is cw), ang = (current angle in radians)
  Vector2D[] getPreportionalWheelPower(Vector2D str, double rotPower, double ang){
    double sinA = Math.sin(ang), cosA = Math.cos(ang);
    double sAcB = sinA*cosB, cAsB = cosA*sinB, c2 = cosA*cosB, s2 = sinA*sinB;
    Vector2D v1 = new Vector2D(-sAcB-cAsB, c2-s2),  // rotate vector <1,0> A+B+pi/2 radians(rot speed of wheel 1)
      v2 = new Vector2D(-sAcB+cAsB, c2+s2);         // rotate vector <1,0> A-B+pi/2 radians(rot speed of wheel 4)
    Vector2D[] out = {v1, v2.scale(-1), v1.scale(-1), v2};
    double max = 0;
    for(int i = 0; i < 4; i++){
      lastWheelPos[i] = out[i];
      out[i] = out[i].scale(-rotPower).add(str);     // add strafe speed to angle speed
      double l = out[i].getMagnitude();
      if(l > max)
        max = l;
    }
    if(max > 1)
      for(int i = 0; i < 4; i++)
        out[i] = out[i].scale(1/max);   // normalize vectors
    return out;
  }
}
class TorqueCurve {
  private ArrayList<double[]> torque;
  private int prev;

  TorqueCurve(ArrayList<double[]> torque) {  // torque is sorted by rpm
    this.torque = torque;
  }
  
  // returns accel in ft/sec^2
  public double getWheelForce(double speed, double power) {   // scalar force in (lbs), speed in (ft/sec), power from 0 to 1
    Boolean dirUp = null;
    double t = -888888888; // calculated torque
    double revPerMin = speed*30/Math.PI/botWheelRadius*botDriveGearRatio;
    prev = 0;


    while (true) {
      if (prev == torque.size()) {
        prev--;
        t = torque.get(prev)[1];
        break;
      }else if(prev == -1){
        prev++;
        t = torque.get(prev)[1];
        break;
      } else if (torque.get(prev)[0] < revPerMin) {
        prev++;
        if (dirUp == null)
          dirUp = true;
        else if (!dirUp) {
          double dt = torque.get(prev)[1]-torque.get(prev-1)[1];
          double dr = torque.get(prev)[0]-torque.get(prev-1)[0];
          t = torque.get(prev-1)[1] + (dt/dr)*(revPerMin-torque.get(prev-1)[0]);    // linearization
          break;
        }
      } else if (torque.get(prev)[0] > revPerMin) {
        prev--;
        if(dirUp == null)
          dirUp = false;
        else if(dirUp){
          double dt = torque.get(prev+1)[1]-torque.get(prev)[1];
          double dr = torque.get(prev+1)[0]-torque.get(prev)[0];
          t = torque.get(prev)[1] + (dt/dr)*(revPerMin-torque.get(prev)[0]);     // linearization
          break;
        }
      }else{
        t = torque.get(prev)[1];
        break;
      }
    }
    return t*botDriveGearRatio*power/botWheelRadius;
  }
}
