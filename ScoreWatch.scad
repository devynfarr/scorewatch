use <gears.scad>
    
textSize = 5;
w_letters=0.8;

module onesGear(mod="1",teeth=20,width=3){
    rimSize = textSize+2;

    pitchRadius=mod*teeth/2;    
    union(){
        translate([0,0,width]){
            ring_gear(modul=mod, tooth_number=teeth, width=width, rim_width=rimSize, pressure_angle = 20, helix_angle = 0);

            for(i=[0:1:9]){
                rotate([0, 0, 36*i])
                    translate([pitchRadius+rimSize,-textSize/2,width])
                        linear_extrude(width+w_letters)
                            text(str(i),size=textSize,halign="center");
            }
            translate([0,0,width]){
                difference(){
                    cylinder(width,teeth+2.3+rimSize,teeth+2.3+rimSize);
                    translate([0,0,-0.01])
                        cylinder(2*width,teeth+2.3,teeth+2.3,false);
                }
            }
        }
    }
}

module tensGear(mod=1,teeth=12, width=3){
    pitchRadius = mod*teeth/2;
    labelRadius = (teeth+2);
    union(){
        spur_gear(modul=mod, tooth_number=teeth, width=width*2, bore=3, pressure_angle=20, helix_angle=0, optimized=true);
        translate([0,0,width*2])
            cylinder(h=width,r1=labelRadius,r2=labelRadius);
        for(i=[0:1:5]){
        rotate([0, 0, 60*i])
            translate([pitchRadius,-textSize/2,width*2])
                linear_extrude(width+w_letters)
                    text(str(i),size=textSize,halign="center");
    }
    }
}

mod=2;
onesPitchRadius=mod*20/2;
tensPitchRadius=mod*12/2;

onesGear(mod,20,3);

mesh=onesPitchRadius-tensPitchRadius;
translate([mesh,0,0])
    tensGear(mod,12,3);
