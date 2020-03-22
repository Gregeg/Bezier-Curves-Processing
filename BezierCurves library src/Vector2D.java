
public class Vector2D {
	public double x;
	public double y;
	
	public Vector2D(double x, double y) {
		this.x = x;
		this.y = y;
	}
	public Vector2D(Vector2D vec) {
		this.x = vec.x;
		this.y = vec.y;
	}
	
	public void setX(double x) {this.x = x;}
	public void setY(double y) {this.y = y;}
	
	public double getX() {return x;}
	public double getY() {return y;}
	
	public Vector2D add(Vector2D vec) {
		return new Vector2D(x+vec.x, y+vec.y);
	}
	public Vector2D scale(double s) {
		return new Vector2D(x*s, y*s);
	}
	public double getMagnitude() {
		return Math.sqrt(x*x + y*y);
	}
	public double componentSum() {
		return x+y;
	}
	/**
	 * @return 0 at vector<1,0> , increases counter-clockwise, range(-pi, pi)
	 */
	public double getAngleRad() {
		return Math.atan2(y, x);
	}
	public double getAngleDeg() {
		return Math.toDegrees(getAngleRad());
	}
	public void setAngleRad(double ang) {
		double mag = getMagnitude();
		x = Math.cos(ang)*mag;
		y = Math.sin(ang)*mag;
	}
	public void setAngleDeg(double ang) {
		setAngleRad(Math.toRadians(ang));
	}
	public Vector2D getNorm() {
		return new Vector2D(this).scale(1/getMagnitude());
	}
	public String toString() {
		return x + ", " + y;
	}
}
