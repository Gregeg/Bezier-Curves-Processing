
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
	public Vector2D getNorm() {
		return new Vector2D(this).scale(1/getMagnitude());
	}
	public String toString() {
		return x + ", " + y;
	}
	public Vector2D rotateBy(double ang) {
		return new Vector2D(x*Math.cos(ang)-y*Math.sin(ang),x*Math.sin(ang)+y*Math.cos(ang));
	}
	public double angle() {
		return Math.atan2(y,x)
	}
}
