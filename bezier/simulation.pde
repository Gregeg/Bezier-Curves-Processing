class Robot {
  private Vector2D botPos, botSpeed, targetPos;
  private double p, i, d, rot;
  private double sinB, cosB; // sin and cos of botrot wheel positions

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
  }
  void periodic(){
    drawBot(botPos, rot);
  }
  void setTargetPos(Vector2D pos){
    targetPos = pos;
  }
  void setP(double p){this.p = p;}
  void setI(double i){this.i = i;}
  void setD(double d){this.d = d;}
  
  // rewrite of "move" method in SwerveMath.java, much more efficenct and compact
  // str = (both vars range<-1, 1>; forces relative to bot), rot = (rot power positive is cw), ang = (current angle in radians)
  ArrayList<Vector2D> getWheelForces(Vector2D str, double rot, double ang){
    double sinA = Math.sin(ang), cosA = Math.sin(ang);
    double sAcB = sinA*cosB, cAsB = cosA*sinB, c2 = cosA*cosB, s2 = sinA*sinB;
    Vector2D v1 = new Vector2D(-sAcB-cAsB, c2-s2),  // rotate vector <1,0> A+B+pi/2 radians
      v2 = new Vector2D(-sAcB+cAsB, c2+s2);       // rotate vector <1,0> A+B+pi/2 radians
    
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
      if (prev == torque.size()) { //<>//
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
    return t*botDriveGearRatio/power/botWheelRadius;
  }
}
