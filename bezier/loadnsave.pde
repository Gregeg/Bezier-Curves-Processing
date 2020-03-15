void readSaveData() {
  try {
    Scanner sc = new Scanner(new File(dataPath("") + "/" + currentFileName + ".greg"));
    speed = Integer.parseInt(sc.nextLine());
    allPoints = new ArrayList<BezierPoint[]>();
    boolean positions = true;
    while (sc.hasNextLine()) {
      String line = sc.nextLine();
      int ind = 0;
      if (line.charAt(0)=='R') {
        positions=false;
      } else if (positions) {
        ArrayList<Double> a = new ArrayList<Double>();
        do {
          ind = line.indexOf(',');
          if (ind == -1) {
            a.add(Double.parseDouble(line));
          } else {
            a.add(Double.parseDouble(line.substring(0, ind)));
            line = line.substring(ind+1);
          }
        } while (ind != -1);
        BezierPoint[] pts = new BezierPoint[a.size()/2];
        for (int i = 0; i < pts.length; i++)
          pts[i] = new BezierPoint(new Vector2D(a.get(2*i), a.get(2*i+1)));
        allPoints.add(pts);
      } else {
        double[] tempR = new double[rotations.length+1];
        for (int i = 0; i < rotations.length; i++) {
          tempR[i]=rotations[i];
        }
        tempR[rotations.length]=Double.parseDouble(line);
        rotations=tempR;
      }
    }
    pointInd = 0;
    sc.close();
  }
  catch(Exception e) {
    System.err.println("greg file not detected");
  }
}
void saveData() {
  File file = new File(dataPath("") + "/" + currentFileName + ".greg");
  if (file.exists())
    file.delete();
  PrintWriter greg = createWriter(dataPath("") + "/" + currentFileName + ".greg");
  greg.write(speed + "\n");
  for (int p = 0; p < allPoints.size(); p++) {
    String line = "";
    for (int i = 0; i < allPoints.get(p).length; i++)
      line += allPoints.get(p)[i].getPos(0).x + "," + allPoints.get(p)[i].getPos(0).y + ",";
    greg.write(line.substring(0, line.length()-1) + "\n");
  }
  greg.write("R\n");
  for (int i = 0; i < rotations.length; i++) {
    greg.write(rotations[i]+(i==rotations.length-1?"":"\n"));
  }
  greg.flush();
  greg.close();
}
