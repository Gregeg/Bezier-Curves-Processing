
public class BezierFunc implements BezierUnit{
	private BezierUnit b0, b1;
	
	public BezierFunc(BezierUnit b0, BezierUnit b1) {
		this.b1 = b1;
		this.b0 = b0;
	}
	public BezierFunc(BezierPoint[] points) {
		if(points.length == 2) {
			b0 = points[0];
			b1 = points[1];
		}else {
			BezierPoint[] a0 = new BezierPoint[points.length-1],
					a1 = new BezierPoint[points.length-1];
			
			for(int i = 0; i < points.length-1; i++) {
				a0[i] = points[i];
				a1[i] = points[i+1];
			}
			
			b0 = new BezierFunc(a0);
			b1 = new BezierFunc(a1);
		}
	}
	
	public Vector2D getPos(double t) {
		Vector2D b0Pos = b0.getPos(t);
		return b1.getPos(t).add(b0Pos.scale(-1)).scale(t).add(b0Pos);
	}
	// derivative must be 0 or positive
	public Vector2D getNthDeriv(double t, int deriv) {
		Vector2D b0Deriv = b0.getNthDeriv(t, deriv);
		return b1.getNthDeriv(t, deriv).add(b0Deriv.scale(-1)).scale(t).add(b1.getNthDeriv(t, deriv-1).add(b0.getNthDeriv(t, deriv-1).scale(-1)).scale(deriv)).add(b0Deriv);
	}
	
	// vel is velcity funtion with inputs of old times from 0 to 1
	// returns t values to plug into bezierFunc to get actual stable position(therefore the inverse of these points can be used to find desired bezier func t)	
	// optimized getStableTime that returns range of values with equal time apart
	// integrates using Simpson's Rule
	/*public double[] getStableTimeRange(Function<Double, Double> vel, int size) {
		double[] out = new double[size];
		double prevTime = getDeriv(0).getMagnitude() / vel.apply(0d);
		double totalTime = 0;
		for(int i = 0; i < size; i++) {
			double curVal = getDeriv(((double)(i+1))/size).getMagnitude() / vel.apply(((double)(i+1))/size);
			totalTime += prevTime + 4 * getDeriv(((double)(i+.5))/size).getMagnitude() / vel.apply(((double)(i+.5))/size) + curVal;
			out[i] = totalTime;
			prevTime = curVal;
		}
		for(int i = 0; i < out.length; i++)
			out[i] = out[i]/size/3;
		return out;
	}*/
	
	// !!!! speed will be controlled in motionprofiling class where speed will affect rate at which points are iterated through
	/*public double[] getStableTimeRange(int accuracy) {
		double[] out = new double[accuracy];
		double prevTime = 1 * getDeriv(0).getMagnitude();
		double totalTime = 0;
		for(int i = 0; i < accuracy; i++) {
			double curVal = 1 * getDeriv(((double)(i+1))/accuracy).getMagnitude();
			totalTime += prevTime + 4 * getDeriv(((double)(i+.5))/accuracy).getMagnitude() + curVal;
			out[i] = totalTime;
			prevTime = curVal;
		}
		for(int i = 0; i < accuracy; i++)
			out[i] = out[i]/accuracy/3;
		return out;
	}*/
	// returns points on curve that travel at a constant rate
	// size is pts per second
	/*public ArrayList<Vector2D> getStablePoints(int accuracy, int size) {
		ArrayList<Vector2D> out = new ArrayList<Vector2D>();
		double[] a = getStableTimeRange(accuracy);
		int ia = 1;
		int iOut = 0;
		while(((double)iOut)/size <a[a.length-1]) {
			double dist = ((double)iOut)/size;
			if(a[ia] < dist)
				ia++;
			else {
				double betweenPrep = (dist-a[ia-1]) / (a[ia]-a[ia-1])/size;
				out.add(getPos(((betweenPrep)*a[ia-1] + (1-betweenPrep)*a[ia])/a[a.length-1]));
				iOut++;
			}
		}
		return out;
	}*/
	/*
	public static void main(String[] args) {
		BezierFunc f = new BezierFunc(pointMaker(1,1, 2,5, 4,1, -1,-4, -6,0));
		for(int i = 0; i < 100; i++) {
			System.out.println(f.getNthDeriv(((double)i)/100, 3)+ ",");
		}
	}*/
	public static BezierPoint[] pointMaker(double... p) {
		BezierPoint[] out = new BezierPoint[p.length/2];
		for(int i = 0; i < p.length/2; i++)
			out[i] = new BezierPoint(p[2*i], p[2*i+1]);
		return out;
	}
}
