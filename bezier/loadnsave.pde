void readSaveData() {
  try {
    Scanner sc = new Scanner(new File(dataPath("") + "/" + currentFileName + ".greg"));
    speed = Integer.parseInt(sc.nextLine());
    allPoints = new ArrayList<BezierPoint[]>();
    int ind = 0;
    boolean positions = true;
    while (sc.hasNextLine()) {
      String line = sc.nextLine();
      if (line.charAt(0)=='R') {
        positions=false;
        ind = 0;
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
        BezierPoint[] pts = allPoints.get(ind);
        rotation.put(pts[pts.length-1], Double.parseDouble(line.trim()));
        ind++;
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
  for (int i = 0; i < allPoints.size(); i++) {
    BezierPoint[] pts = allPoints.get(i);
    if(pts.length > 1){
      Double r = rotation.get(pts[pts.length-1]);
      greg.write((r == null?0:r)+(i == allPoints.size()-1?"":"\n"));
    }
  }
  greg.flush();
  greg.close();
}
