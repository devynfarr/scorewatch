use <gears.scad>

// Gears
mod=2;
width=3;
addendum=2.5;

// Font
textSize=5;
w_letters=0.8;

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
	rimSize=textSize+2;	
	ID=ones_teeth+addendum;
	OD=ID+rimSize;
	
	
	// Entities
	j=9;
	rotate([0,0,-j*36]) {
  
		
		// Entities
		union(){
			*translate([0,0,width]) {            
				// Ones digits
				color(digitColor) {
					for(i=[0:1:9]){
						rotate([0, 0, 36*i])
							translate([ones_pitchRadius+rimSize,-textSize/2,width])
								linear_extrude(width+w_letters)
									text(str(i),size=textSize,halign="center");
					}
				}
				
				// Ones Bezel
				color(bezelColor) {
					translate([0,0,width]) {
						difference() {
							cylinder(width,OD,OD);
							translate([0,0,-0.01])
								cylinder(2*width,ID,ID,false);
						}
					}
				}
			}	
				//Ones Gears
				//translate([0,0,-width]) {
					color("blue") {
						difference() {
							ring_gear(modul=mod, tooth_number=ones_teeth, width=width*2, rim_width=rimSize, pressure_angle = 20, helix_angle = 0);
							rotate([0,0,6]) {
								pieSlice(360-30,ID,2*width);
							}
							translate([0,0,-0.01])
								cylinder(2*width+0.01,cleared_diameter,cleared_diameter,false);
						}
					}
								
					cleared_diameter = ones_teeth+0.7;
					*difference() {
						difference() {
							cylinder(width,OD,OD);
							translate([0,0,-0.01])
								cylinder(2*width,cleared_diameter,cleared_diameter,false);
						}
						rotate([0,0,-24]) {
							pieSlice(24,ID,width+0.01);
						}
					}
				//}			
		}
	}
}

// Tens
translate([0,0,0]) {
	// Variables
	C=ones_pitchRadius-tens_pitchRadius;	
	labelRadius = tens_teeth+2;
		
	translate([C,0,0]) {
		rotate([0,0,0]) {		
							
			// Entities	
			union() {               
				//Tens Bezel
				color(bezelColor) {
					translate([0,0,width*2])
						cylinder(h=width,r1=labelRadius,r2=labelRadius);
				}        
				
				// Tens Digits
				color(digitColor) {
					tens_max_count=3;
					for(i=[0:1:tens_max_count]) {
						rotate([0, 0, 360/(tens_max_count+1)*i])
							translate([tens_pitchRadius,-textSize/2,width*2])
								linear_extrude(width+w_letters)
									text(str(i),size=textSize,halign="center");
					}
				}
				
				// Tens Gear
				
				difference() {
					spur_gear(modul=mod, tooth_number=tens_teeth, width=width*2, bore=3, pressure_angle=20, helix_angle=0, optimized=true);
					difference() {
						union() {
							for(i=[0:1:3]) {			
								rotate([0,0,-45+i*90]) {						
									pieSlice(60,tens_pitchRadius+addendum,width+0.8);
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