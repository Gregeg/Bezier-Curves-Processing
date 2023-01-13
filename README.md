# Stuzzy's Scouter

Provides a path and commands for the robot to follow autonomously. <br />
Generates PID values and coordinate/rotation points for the robot to follow using a pure pursuit algorithm. <br />



<br /><br />
![Recordit GIF](http://g.recordit.co/PGHzP9pbLD.gif)
<br /><br /><br />


## Installation
### [Download Latest Release](https://github.com/Gregeg/Bezier-Curves-Processing/releases/)
<br /><br />

## Usage
### Click to create points
 - Easy mode enabled
   - click to add new curves
 - Advanced mode
   - first two points sets the endpoints of the curve
   - points made afterwords set control points

### Create coordinate specific point
 - press "a" then type the coordinates of the point EX:( Add point(<x,y>): 100, 50) or (Add point(<x,y>): 69,420)
 - press "ENTER" to add the point, or "ESC: to cancel

### Editing points
 - drag points around to edit their location
 - pressing "DELETE" key will delete point closest to the mouse pointer

### Undo
 - press "CTRL+Z" to undo changes done to points

### Editing speed
 - hold "UP" and "DOWN" arrow keys

### Adding Wait Points
 - press "w" and type the duration of the wait in milliseconds(can be a decimal) and press "ENTER"
 - use the left/right arrow keys to move your control dot along the curve, and press "w" to lock it in place

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
 
### Run Command in Robot Code
 - press "C" and type the name of your command class and press "ENTER" EX: for ShootBall.java type `ShootBall`
 - use the left/right arrow keys to move your control dot along the curve, and press "C" to lock it in place
 - the robot will run the `execute()` method when it reaches this point

### Robot PID Simulation
 - press "SPACE" to run a simulation of the robot following the position
 - robot with a red highlight indicates it is skidding on the surface
 - editing robot values
   - press "p" to edit pid constants
   - change data on specific robot in data/robot.stats

### Main Menu
 - press "M" to return to the main menu

### Drawing
 - press "D" or any number key and press and hold to draw
 - number keys change size the size, 0 is erase
 - LEFT and RIGHT keys change the color
 - press "C" while drawing to clear your drawing screen
 
<br /><br /><br />
## Other Info
[Papers used for Bezier Curve research](https://www.cs.cornell.edu/courses/cs4620/2017sp/slides/16spline-curves.pdf)
