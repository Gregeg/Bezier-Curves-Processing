
public class BezierPoint implements BezierUnit{
	public Vector2D pos;
	
	public BezierPoint(Vector2D pos) {
		this.pos = pos;
	}
	public BezierPoint(double x, double y) {
		pos = new Vector2D(x, y);
	}
	
	public Vector2D getPos(double t) {
		return pos;
	}
	public Vector2D getNthDeriv(double t, int deriv) {
		if(deriv == 0)
			return getPos(t);
		else
			return new Vector2D(0, 0);
	}
}
