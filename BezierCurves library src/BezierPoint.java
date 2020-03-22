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
	public void setPos(Vector2D pos) {
		this.pos = pos;
	}
	public Vector2D getDeriv(double t) {
		return new Vector2D(0, 0);
	}
}
