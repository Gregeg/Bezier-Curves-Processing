import java.util.ArrayList;
import java.util.function.Function;

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
	public Vector2D getDeriv(double t) {
		Vector2D b0Deriv = b0.getDeriv(t);
		return b1.getDeriv(t).add(b0Deriv.scale(-1)).scale(t).add(b0Deriv).add(b1.getPos(t)).add(b0.getPos(t).scale(-1));
	}
	// !!!! speed will be controlled in motionprofiling class where speed will affect rate at which points are iterated through
	public double[] getStableTimeRange(int size) {
		double[] out = new double[size];
		double prevTime = 1 * getDeriv(0).getMagnitude();
		double totalTime = 0;
		for(int i = 0; i < size; i++) {
			double curVal = 1 * getDeriv(((double)(i+1))/size).getMagnitude();
			totalTime += prevTime + 4 * getDeriv(((double)(i+.5))/size).getMagnitude() + curVal;
			out[i] = totalTime;
			prevTime = curVal;
		}
		for(int i = 0; i < size; i++)
			out[i] = out[i]/out[out.length-1];
		return out;
	}
	// returns points on curve that travel at a constant rate
	public Vector2D[] getStablePoints(int size) {
		Vector2D[] out = new Vector2D[size];
		double[] a = getStableTimeRange(size);
		for(int i = 0; i < size; i++)
			out[i] = getPos(a[i]);
		return out;
	}
	
	public static void main(String[] args) {
		BezierFunc f = new BezierFunc(pointMaker(1,1, 2,5, 4,1, -1,-4, -6,0));
		Vector2D[] a = f.getStablePoints(100);
		double[] r = f.getStableTimeRange(100);
		for(int i = 0; i < a.length-1; i++) {
			System.out.println(i + "," + f.getPos((double)(i+1)/100).add(f.getPos((double)(i)/100).scale(-1)).getMagnitude()+ ",");
			//System.out.println(i + "," + a[i].add(a[i+1].scale(-1)).getMagnitude()*100 + ",");
			//System.out.println(i + "   " + f.getPos((double)i/1000));
		}
	}
	private static BezierPoint[] pointMaker(double... p) {
		BezierPoint[] out = new BezierPoint[p.length/2];
		for(int i = 0; i < p.length/2; i++)
			out[i] = new BezierPoint(p[2*i], p[2*i+1]);
		return out;
	}
}