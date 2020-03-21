ArrayList<Command> commands = new ArrayList<Command>();
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

void changeAllCommandT(double v){
  for(int i = 0; i < commands.size(); i++)
    commands.get(i).setT(commands.get(i).getT() + v);
}

class PointState {
  ArrayList<BezierPoint[]> allPts;
  ArrayList<Command> comms;
  
  PointState(ArrayList<BezierPoint[]> aPts, ArrayList<Command> comms){
    allPts = new ArrayList<BezierPoint[]>(aPts);
    for(int i = 0; i < allPts.size(); i++){
      BezierPoint[] bp = new BezierPoint[aPts.get(i).length];
      for(int d = 0; d < bp.length; d++) bp[d] = new BezierPoint(aPts.get(i)[d].getPos(0));
      allPts.set(i, bp);
    }
    this.comms = new ArrayList<Command>(comms);
  }
  
  ArrayList<BezierPoint[]> getAllPts(){return allPts;}
  ArrayList<Command> getComms(){return comms;}
}

void addState(){
  states.add(new PointState(allPoints, commands));
}

void restoreState(){
  if(states.size() != 0){
    PointState ps = states.remove(states.size()-1);
    allPoints = ps.getAllPts();
    commands = ps.getComms();
    if(allPoints.size() == 0)
      pointInd = 0;
    else if(pointInd == allPoints.size())
      pointInd--;
    if(simpleMode){
       allPoints.remove(pointInd);
       pointInd--;
    }
  }
}
