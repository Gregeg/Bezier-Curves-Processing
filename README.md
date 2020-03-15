# Manual
### Click to create points
 - first two points sets the endpoints of the curve
 - next points set control points

### Create coordinate specific point
 - press "a" then type the coordinates of the point EX:( Add point(<x,y>): 100, 50) or (Add point(<x,y>): 69,420)
 - press "ENTER" to add the point, or "ESC: to cancel

### Editing points
 - drag points around to edit their location
 - pressing "DELETE" key will delete point closest to the mouse pointer

### Editing speed
 - hold "UP" and "DOWN arrow keys

### Adding new curves
 - press "n" to add curve in front, and click to set second curve endpoint
 - press "b" to add curve in back,  and click to set second curve endpoint
 - next points set control points
	
### Navigating curves
 - press "n" to go to next curve
 - press "b" to go to previous curve
	
### Exporting curves
 - press "e" then type the number of waypoints that each curve will have
 - press "ENTER" to export, or "ESC" to cancel export
 - Points.java file will apear in main directory
 - move Points.java to "src/frc/team578/robot/subsystems/swerve/motionProfiling" in robot code and overwrite the pre-existing file

### Save simulation
 - press "s" to save
   - if first time saving, enter save name and press "Enter" to save, or "ESC" to cancel
 - simulation can be selected in menu on startup

### Rotations
 - press "r" to move arrow at the the last endpoint of your curve
 - click to set the new arrow position, which represents the robot's rotation

### [Papers used for Bezier Curve research](https://www.cs.cornell.edu/courses/cs4620/2017sp/slides/16spline-curves.pdf)
