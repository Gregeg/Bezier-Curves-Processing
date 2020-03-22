public class BezierFunc implements BezierUnit{
	private BezierUnit b0, b1;
	private Vector2D b0Pos, b1Pos;
	private double prevT = -1;
	
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
		if(prevT != t) {
			b0Pos = b0.getPos(t); // for efficiency
			b1Pos = b1.getPos(t);
			prevT = t;
		}
		return b1Pos.add(b0Pos.scale(-1)).scale(t).add(b0Pos);
	}
	public Vector2D getDeriv(double t) {
		Vector2D b0Deriv = b0.getDeriv(t);
		return b1.getDeriv(t).add(b0Deriv.scale(-1)).scale(t).add(b0Deriv).add(b1.getPos(t)).add(b0.getPos(t).scale(-1));
	}
}