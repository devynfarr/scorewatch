use <gears.scad>
$fn = $preview ? 100 : 100; 
// Gears
mod=2;
width=3;
addendum=2.33;
out_addendum=1.6;

// Font
textSize=5;
textKern=1;
w_letters=0.8;
bezelSize=textSize+textKern;

// Color
digitColor="blue";
bezelColor="lightblue";

function pitchRadius(modul, numTeeth) = modul * numTeeth/2;

module pieSlice(swept_angle, radius, height){  
  rotate_extrude(angle=swept_angle) square([radius,height]);
}

ones_teeth = 20;
ones_pitchRadius = pitchRadius(mod, ones_teeth);
tens_teeth = 8;
tens_pitchRadius = pitchRadius(mod, tens_teeth);

// Ones
translate([0,0,0]) {
	// Variables	
	currentDigit=9;
	ones_max_count=9;	
	ones_OD=ones_pitchRadius+out_addendum;
	OD=ones_pitchRadius;
	ID=OD-bezelSize;
	increment=360/(ones_max_count+1);
	
	// Entities	
	rotate([0,0,-currentDigit*increment]) {
  
		
		// Entities
		union(){
			translate([0,0,0]) {            
				// Ones digits
				color(digitColor) {
					for(i=[0:1:ones_max_count]){
						rotate([0, 0, increment*i])
							translate([-ones_pitchRadius+textKern,-textSize/2,0])
								linear_extrude(width+w_letters)
									text(str(i),size=textSize,halign="left");
					}
				}
				
				// Ones Bezel
				color(bezelColor) {
					translate([0,0,0]) {
						difference() {
							cylinder(width,OD,OD);
							translate([0,0,-0.01])
								cylinder(2*width,ID,ID,false);
						}
					}
				}
			}	
			
			//Ones Gears
			color("green") {
				translate([0,0,-width*2]) {
					rotate([0,0,9]) {						
						difference() {
							intersection() {
								spur_gear(modul=mod, tooth_number=ones_teeth, width=width*2, bore=3, pressure_angle=20, helix_angle=0, optimized=true);
								cylinder(width*2, ones_OD, ones_OD, false);
							}
							rotate([0,0,180-increment/4]) {
								difference() {
									pieSlice(360-increment,ones_OD,width*2);
									cylinder(width*2,ones_pitchRadius-addendum,ones_pitchRadius-addendum,false);
								}
							}
						}						
					}
					
					rotate([0,0,180-increment/4]) {
						difference() {
							pieSlice(360-increment/2,ones_OD,width);
							cylinder(width,ones_pitchRadius-addendum,ones_pitchRadius-addendum,false);
						}
					}
				}			
			}
		}
	}
}

// Tens
translate([0,0,0]) {
	// Variables
	currentDigit=0;
	tens_max_count=3;
	tens_OD=tens_pitchRadius+out_addendum;
	C=ones_pitchRadius+tens_pitchRadius;	
	OD=tens_pitchRadius;
	ID=OD-bezelSize;	
	increment = 360/(tens_max_count+1);
		
	translate([-C,0,0]) {
		rotate([0,0,-currentDigit*increment]) {		
							
			// Entities	
			union() {
				translate([0,0,0]) {							
					// Tens Digits
					color(digitColor) {
						for(i=[0:1:tens_max_count]){
							rotate([0, 0, -increment*i])
								translate([tens_pitchRadius-textKern,-textSize/2,0])
									linear_extrude(width+w_letters)
										text(str(i),size=textSize,halign="right");
						}
					}
					
					//Tens Bezel
					color(bezelColor) {						
						difference() {
							cylinder(width,OD,OD);
							translate([0,0,-0.01])
								cylinder(2*width,ID,ID,false);
						}						
					}	
				}
				
				// Tens Gear
				color("red") {
					translate([0,0,-width*2]) {
						difference() {
							intersection() {
								spur_gear(modul=mod, tooth_number=tens_teeth, width=width*2, bore=3, pressure_angle=20, helix_angle=0, optimized=true);
								cylinder(width*2, tens_OD, tens_OD, false);							
							}
							difference() {
								union() {
									for(i=[0:1:3]) {			
										rotate([0,0,-22.5+i*increment]) {						
											pieSlice(45,tens_pitchRadius+addendum,width);
										}
									}
								}
								cylinder(h=width+0.8,r1=tens_pitchRadius-addendum, r2=tens_pitchRadius-addendum);								
							}
						}
					}
				}				
			}
		}
	}
}