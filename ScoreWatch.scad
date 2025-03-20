use <gears.scad>

// Misc
fudge = 0.01; // used to clean up zero thickness surfaces after bool operations

// Gears
mod=2;
width=3;
addendum=2.23;

// Font
textSize=5;
w_letters=0.8;

// Colors
digitColor="blue";
bezelColor="lightblue";

module polarDigit(digit=0, radius=0, angle=0) {
	// digit is first translated by radius, then rotated by angle
	// offsets expect single digit
	
	// Variables				
	
	// Entities
	rotate([0, 0, angle])
		translate([radius,-textSize/2,0])
			linear_extrude(width+w_letters)
				text(str(digit),size=textSize,halign="left");
}

module pieSlice(swept_angle, radius, height){  
  rotate_extrude(angle=swept_angle) square([radius,height]);
}

// Ones Ring Gear
// 36º per digit (3T)
// 12º per tooth

// Variables
teeth=20;
pitchDiameter = mod*teeth;
pitchRadius = pitchDiameter/2;
ID=teeth+addendum;
OD=ID+textSize+3;
	
// Ones
rotate([0,0,0]) {
	
	union(){           
		translate([0,0,width]) {
			// Digits
			color(digitColor) {
				for(i=[0:1:9]){
					polarDigit(digit=i,radius=ID+2,angle=i*36);
				}
			}
		
			// Bezel		
			color(bezelColor) {		
				difference() {
					cylinder(width,OD,OD);
					cylinder(2*width+2*fudge,ID,ID,true);
				}			
			}
		}
		
		// Gear
		difference() {
			ring_gear(modul=mod, tooth_number=teeth, width=width, rim_width=OD-ID, pressure_angle=20, helix_angle=0);				
			rotate([0,0,180+18]) {
				pieSlice(swept_angle=360-18, radius=ID, height=width*3);					
			}
		}	
	}
}

// Carry
// Variables
carry_teeth = 8;
carry_pitchDiameter = mod*carry_teeth;
carry_pitchRadius = carry_pitchDiameter/2;
carry_C=(pitchDiameter-carry_pitchDiameter)/2;	

// Entities
translate([-carry_C,0,-width]) {
	rotate([0,0,0]) {
		spur_gear(modul=mod, tooth_number=carry_teeth, width=2*width, bore=4, pressure_angle=20, helix_angle=0, optimized=true);
	}
}


// Tens Gear
// 60º per digit (2T)
// 30º per tooth
translate([0,0,-width]) {
	// Variables
	tens_teeth = 12;
	tens_pitchDiameter = mod*tens_teeth;
	tens_pitchRadius = tens_pitchDiameter/2;
	tens_C=-carry_C+(tens_pitchDiameter+carry_pitchDiameter)/2;	
	
	// Entities
	translate([tens_C,0,0]) {
		rotate([0,0,15]) {
			spur_gear(modul=mod, tooth_number=tens_teeth, width=width, bore=4, pressure_angle=20, helix_angle=0, optimized=true);
		}
	}
}

