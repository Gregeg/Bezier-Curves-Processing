class Robot {
  private Vector2D botPos, botSpeed, targetPos;
  private double p, i, d, rot;

  Robot(double p, double i, double d, Vector2D botPos, Vector2D targetPos) {
    this.p = p;
    this.i = i;
    this.d = d;
    this.botPos = botPos;
    this.targetPos = targetPos;
    rot = 0;
  }
  void periodic(){
    drawBot(botPos, rot);
  }
}

class TorqueCurve {
  private ArrayList<double[]> torque;
  private int prev;

  TorqueCurve(ArrayList<double[]> torque) {  // torque is sorted by rpm
    this.torque = torque;
  }
  
  // returns accel in ft/sec^2
  public double getAccel(double speed, double power) {   // accel in (ft/sec^2), speed in (ft/sec), power from 0 to 1
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
    println("torque: " + torque);
    println("rev per min: " + revPerMin);
    double a = t*botDriveGearRatio/power * 4/*four wheels*/ / botWheelRadius / botWeight * 32.174/*slug*/;
    return a - (drag*speed*speed + fric)/botWeight;
  }
}
