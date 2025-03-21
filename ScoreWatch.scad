use <gears.scad>
include <BOSL2/std.scad>
$fn = $preview ? 100 : 100; 

// visibility options

showOnesWheel = true;
showTensWheel = true;
showEnclosure = true;
showBackPlate = true;
showCover = true;
showBezels = true;

onesDigit = 0;
tensDigit = 0;

// print parameters
layerHeight = 0.2; // mm
textHeight = 2; // number of printed layers
bezelHeight = 4; // number of printed layers
gearHeight = 3; // number of printed layers
plateLayers = 4; // number of printed layers

// Gears
mod=2; // modulus
pressure_angle=25;
width=gearHeight*layerHeight;
addendum=2.33;
out_addendum=1.6;

// Font
textSize=5;
textKern=1;
w_letters=textHeight*layerHeight;
bezelSize=textSize+textKern;
bezelThickness=bezelHeight*layerHeight;

// Color
digitColor="blue";
bezelColor="lightblue";

function pitchRadius(modul, numTeeth) = modul * numTeeth/2;

module pieSlice(swept_angle, radius, height){  
  rotate_extrude(angle=swept_angle) square([radius,height]);
}

tens_teeth = 8;
tens_pitchRadius = pitchRadius(mod, tens_teeth);
tens_axle_diameter=3;

ones_teeth = 20;
ones_pitchRadius = pitchRadius(mod, ones_teeth);

C=ones_pitchRadius-tens_pitchRadius;

// Ones Wheel
if(showOnesWheel) {
	translate([0,0,0]) {
		// Variables	
		currentDigit=onesDigit;
		ones_max_count=9;	
		ones_OD=ones_pitchRadius+out_addendum;	
		ID=ones_pitchRadius;
		OD=ID+bezelSize;
		increment=360/(ones_max_count+1);
		teethPerIncrement=ones_teeth/(ones_max_count+1);
		
		// Entities	
		rotate([0,0,-currentDigit*increment]) {
	  
			
			// Entities
			union(){
				if(showBezels) {
					translate([0,0,0]) {
						difference() {
							// Ones Bezel
							color(bezelColor) {
								translate([0,0,0]) {
									difference() {
										cylinder(bezelThickness,OD,OD);
										translate([0,0,-0.01])
											cylinder(2*bezelThickness,ID,ID,false);
									}
								}
							}
							
							// Ones digits
							color(digitColor) {
								for(i=[0:1:ones_max_count]){
									rotate([0, 0, increment*i])
										translate([ID+textKern,-textSize/2,bezelThickness-w_letters])							
											linear_extrude(w_letters+0.01)
												offset(delta=0.2) {
													text(str(i),size=textSize,halign="left");								
												}
								}
							}
						}
					}
				}
				
				//Ones Gear			
				translate([0,0,-width*2]) {
					difference() {
						union() {
							// ones ring gear
							color("green") {
								difference() {
									ring_gear(modul=mod, tooth_number=ones_teeth, width=width*2, rim_width=bezelSize-addendum, pressure_angle = pressure_angle, helix_angle = 0);
									
									rotate([0,0,0]) {
										// carry tooth selector
										difference() {
											pieSlice(360-increment,ones_pitchRadius+addendum,width*2);
											cylinder(width*2,ones_pitchRadius-addendum,ones_pitchRadius-addendum,false);
										}
									}
								}
							}
							
							// ones slip Ring
							color("purple") {
								rotate([0,0,-0.25*increment]) {									
									pieSlice(360-0.5*increment,OD,width);							
								}
							}
						}
						
						slip_ring_ID=ones_pitchRadius+0.25;
						cylinder(2*width,slip_ring_ID,slip_ring_ID,false);
					}
				}
			}
		}
	}
}

// Tens Wheel
if (showTensWheel) {
	translate([0,0,0]) {
		// Variables
		currentDigit=tensDigit;		
		tens_max_count=3;
		tens_OD=tens_pitchRadius+out_addendum;		
		OD=tens_pitchRadius;
		ID=OD-bezelSize;	
		increment = 360/(tens_max_count+1);
		teethPerIncrement=ones_teeth/(tens_max_count+1);
		
			
		translate([C,0,0]) {
			rotate([0,0,-currentDigit*increment]) {		
								
				// Entities	
				union() {
					if(showBezels) {
						difference() {												
							//Tens Bezel
							color(bezelColor) {						
								difference() {
									cylinder(bezelThickness,OD,OD);
									translate([0,0,-0.01])
										cylinder(2*bezelThickness,ID,ID,false);
								}						
							}	
							
							// Tens Digits
							color(digitColor) {
								for(i=[0:1:tens_max_count]){
									rotate([0, 0, increment*i]) // positive increment for ones as ring, negative increment for ones as spur
										translate([tens_pitchRadius-textKern,-textSize/2,bezelThickness-w_letters])
											linear_extrude(w_letters+0.01)
												offset(delta=0.2) {
													text(str(i),size=textSize,halign="right");
												}
								}
							}
						}
					}
					
					// Tens Gear
					color("grey") {
						translate([0,0,-width*2]) {
							difference() {
								difference() {
									union() {
										spur_gear(modul=mod, tooth_number=tens_teeth, width=width*2, bore=tens_axle_diameter, pressure_angle=pressure_angle, helix_angle=0, optimized=true);
										difference() {
											cylinder(width*2, tens_pitchRadius-addendum, tens_pitchRadius-addendum, false);
											translate([0,0,-0.01])
												cylinder(width*3, tens_axle_diameter/2, tens_axle_diameter/2, false);
										}
									}
									// foreshorten every other gear tooth to allow for a wider slip ring
									difference() {
										union() {
											for(i=[0:1:3]) {			
												rotate([0,0,22.5+i*increment]) {						
													pieSlice(45,tens_pitchRadius+addendum,width*2);
												}
											}									
										}
										cylinder(width*2, tens_OD, tens_OD, false);							
									}
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
}

//Enclosure
if (showEnclosure) {
	axle_clearance=0.2;
	width=55;
	length=55;

	// Backplate
	if (showBackPlate) {
		translate([0,0,-(2*gearHeight*layerHeight+plateLayers*layerHeight)]) {
			

			height=2*gearHeight*layerHeight+bezelHeight*layerHeight+plateLayers*layerHeight;		
			depth=2*gearHeight*layerHeight+bezelHeight*layerHeight;
			ones_axle_radius = ones_pitchRadius + bezelSize + axle_clearance;
			wall=bezelSize/2;	
			
			difference() {
				// plate
				translate([0,0,0]) {
					cylinder(h=height,r1=ones_axle_radius+wall, r2=ones_axle_radius+wall);		
					//cuboid([width, length, height], rounding=ones_axle_radius, edges="Z", anchor=[0,0,-1]);
				}
				
				// ones axle
				translate([0,0,plateLayers*layerHeight]) {			
					cylinder(h=height,r1=ones_axle_radius, r2=ones_axle_radius);
				}
				
				// thumbwheel
				translate([width/2-5,-length/2,-0.01]) {
					cube([width,length,height+2*0.01],center=false);
				}
			}
			
			// tens axle
			color("darkblue") {
				translate([C,0,0]) {
					cylinder(h=height,r1=(tens_axle_diameter/2 - axle_clearance), r2=(tens_axle_diameter/2 - axle_clearance));
				}
			}
			
			// enclosure fastener
			translate([0,0,0]) {
				cylinder(h=height+bezelThickness,r1=(tens_axle_diameter/2 - axle_clearance), r2=(tens_axle_diameter/2 - axle_clearance));
			}
			
		}
	}
	// Cover
	if (showCover) {
		//color("white") {
			translate([0,0,bezelThickness]) {
				radius=ones_pitchRadius + bezelSize + axle_clearance + bezelSize/2;
				
				difference() {		
					translate([0,0,0]) {
						cylinder(h=bezelThickness,r1=radius, r2=radius);
					}
					
					// thumbwheel
					translate([width/2-5,-length/2,-0.01]) {
						cube([width,length,2*bezelThickness+2*0.01],center=false);
					}
					
					// window
					translate([ones_pitchRadius-bezelSize,-0.5*1.5*textSize,-0.01]) {
						//cube([2*bezelSize,1.5*textSize,2*bezelThickness+2*0.01],center=false);
						cuboid([2*bezelSize,1.5*textSize,2*bezelThickness+2*0.01], rounding=textSize/4, edges="Z", anchor=[-1,-1,-1]);
					}
					
					// enclosure fastener
					translate([0,0,-0.01]) {
						cylinder(h=bezelThickness+2*0.01,r1=(tens_axle_diameter/2), r2=(tens_axle_diameter/2));
					}
				}
			}
		//}
	}
}