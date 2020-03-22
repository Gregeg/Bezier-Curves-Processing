ArrayList<Command> commands = new ArrayList<Command>();
ArrayList<WaitPoint> waitPoints = new ArrayList<WaitPoint>();
ArrayList<PointState> states = new ArrayList<PointState>();


void drawBot(Vector2D pos, double rot) {
  pushMatrix();
  translate((float)pos.x, (float)pos.y);
  rotate((float)rot);
  stroke(255, 0, 0, 50);
  fill(255, 0, 0, 50);
  image(botrot, -botrot.width/2*botRotScale, -botrot.height/2*botRotScale, botrot.width*botRotScale, botrot.height*botRotScale);
  if(skidding && simulation)
    rect(-botrot.width/2*botRotScale, -botrot.height/2*botRotScale, botrot.width*botRotScale, botrot.height*botRotScale);
  popMatrix();
  stroke(0, 0, 0);
}

void addCommand(String c){
  c = c.trim();
  if(c.length() >= 5)
    if(c.substring(c.length()-5).equals(".java"))
      c = c.substring(0, c.length()-5);
  commands.add(new Command(c));
}
void addWaitPoint(double duration){
  waitPoints.add(new WaitPoint(duration));
}
void setWaitPointT(double t){
  waitPoints.get(waitPoints.size()-1).setT(t);
  Collections.sort(waitPoints);
}
void setCommandT(double t){
  commands.get(commands.size()-1).setT(t);
}

class Command implements Comparable{
  private String name;
  private double t;
  
  Command(String name){
    this.name = name;
  }
  Command(String name, double t){
    this.name = name;
    this.t = t;
  }
  void setT(double t){this.t = t;}
  void setName(String name){this.name = name;}
  
  String getName(){return name;}
  double getT(){return t;}
  
  public int compareTo(Object o){
    Command c = (Command)o;
    double v = t-c.getT();
    return (v > 0? 1: (v == 0? 0: -1));
  }
}
class WaitPoint implements Comparable{
  private double t, duration;
  
  WaitPoint(double duration, double t){
    this.t = t;
    this.duration = duration;
  }
  WaitPoint(double duration){
    this.duration = duration;
  }
  double getT(){return t;}
  double getDuration(){return duration;}
  
  void setT(double t){this.t = t;}
  void setDuration(double d){duration = d;}
  
  public int compareTo(Object o){
    double v = t-((WaitPoint)o).getT();
    return (v > 0? 1: (v == 0? 0: -1));
  }
}

void changeAllCommandT(double v){
  for(int i = 0; i < commands.size(); i++)
    commands.get(i).setT(commands.get(i).getT() + v);
}
void changeAllWaitPointT(double v){
  for(int i = 0; i < waitPoints.size(); i++)
    waitPoints.get(i).setT(waitPoints.get(i).getT() + v);
}

class PointState {
  ArrayList<BezierPoint[]> allPts;
  ArrayList<Command> comms;
  ArrayList<WaitPoint> wp;
  
  PointState(ArrayList<BezierPoint[]> aPts, ArrayList<Command> comms, ArrayList<WaitPoint> wp){
    allPts = new ArrayList<BezierPoint[]>(aPts);
    for(int i = 0; i < allPts.size(); i++){
      BezierPoint[] bp = new BezierPoint[aPts.get(i).length];
      for(int d = 0; d < bp.length; d++) bp[d] = new BezierPoint(aPts.get(i)[d].getPos(0));
      allPts.set(i, bp);
    }
    this.comms = new ArrayList<Command>(comms);
    this.wp = new ArrayList<WaitPoint>(wp);
  }
  
  ArrayList<BezierPoint[]> getAllPts(){return allPts;}
  ArrayList<Command> getComms(){return comms;}
  ArrayList<WaitPoint> getWaitPoints(){return wp;}
}

void addState(){
  states.add(new PointState(allPoints, commands, waitPoints));
}

void restoreState(){
  if(states.size() != 0){
    PointState ps = states.remove(states.size()-1);
    boolean c = allPoints.size() > 1 && allPoints.get(0).length == 3 && ps.getAllPts().get(0).length == 1;
    allPoints = ps.getAllPts();
    commands = ps.getComms();
    waitPoints = ps.getWaitPoints();
    if(c)
      changeAllWaitPointT(-1);
    if(allPoints.size() == 0)
      pointInd = 0;
    else if(pointInd == allPoints.size())
      pointInd--;
    if(simpleMode && allPoints.get(pointInd).length == 1){
       allPoints.remove(pointInd);
       pointInd--;
    }
  }
}
