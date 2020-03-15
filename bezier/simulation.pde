class Robot {
  private Vector2D botPos, botSpeed, targetPos;
  private double p, i, d;

  Robot(int p, int i, int d, Vector2D botPos, Vector2D targetPos) {
    this.p = p;
    this.i = i;
    this.d = d;
  }
}

class TorqueCurve {
  private ArrayList<double[]> torque;
  private int prev;

  TorqueCurve(ArrayList<double[]> torque) {  // torque is sorted by rpm
    this.torque = torque;
  }

  public double getAccel(double speed, double power) {   // accel in (ft/sec^2), speed in (ft/sec), power from 0 to 1
    Boolean dirUp = null;
    double t = -888888888; // calculated torque
    double revPerMin = speed*30/Math.PI/botWheelRadius;



    while (true) {
      if (prev == torque.size()) {
        prev--;
        t = torque.get(prev)[1];
        break;
      } else if (torque.get(prev)[0] < revPerMin) {
        prev++;
        if (dirUp == null)
          dirUp = true;
        else if (!dirUp) {
          double dv = torque.get(prev-1)[1]-torque.get(prev)[1];
          t = torque.get(prev-1)[0]*1;//don't know what this does, so I broke it
        }
      } else if (torque.get(prev)[0] > revPerMin) {
        prev--;
      } else {
        t = torque.get(prev)[1];
        break;
      }
    }
    return t;//yit was here
  }
}
