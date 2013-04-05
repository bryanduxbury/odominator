// TODOs
// holes are slightly off
// add a crank
// add tab-ins for the digit window assemblies to the carrier plate
// add alignment holes to gear stacks

use <publicDomainGearV1.1.scad>
use <bitmap.scad>


digit_width=8;
num_digits=5;

// material thickness
// t = 5.2; // birch ply
t = 3; // 1/8" acrylic

// shaft diameter
d = 1/8 * 25.4;

mm_per_tooth = 5;

function big_gear_or() = outer_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=20);
function big_gear_root_r() = root_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=20);

function small_gear_or() = outer_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=8);
function small_gear_root_r() = root_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=8);


module full_connecting_gear() {
  color([64/255, 64/255, 64/255]) 
  render()
  gear(mm_per_tooth = mm_per_tooth, hole_diameter = d, number_of_teeth = 8, thickness = t);
}

module partial_connecting_gear() {
  color([96/255, 96/255, 96/255])
  render()
  difference() {
    union() {
      for (a=[0:3]) {
        rotate([0, 0, 45 + 90*a]) gear(mm_per_tooth = mm_per_tooth, hole_diameter = d, number_of_teeth = 8, thickness = t, teeth_to_hide=7);
      }
      cylinder(r=small_gear_root_r(), h=t, center=true, $fn=36);
    }
    cylinder(r=d/2, h=t*2, center=true, $fn=36);
  }
}

module connecting_gear_spacer() {
  color([96/255, 96/255, 96/255])
  render()
  difference() {
    cylinder(r=small_gear_root_r(), h=t, center=true, $fn=36);
    cylinder(r=d/2, h=t*2, center=true, $fn=36);
  }
}

module connecting_gear_assembly_a() {
  full_connecting_gear();
  translate([0, 0, -t]) partial_connecting_gear();
  translate([0, 0, -2*t]) connecting_gear_spacer();
  translate([0, 0, -3*t]) connecting_gear_spacer();
}

module connecting_gear_assembly_b() {
  connecting_gear_spacer();
  translate([0, 0, -1*t]) connecting_gear_spacer();
  translate([0, 0, -2*t]) partial_connecting_gear();
  translate([0, 0, -3*t]) full_connecting_gear();
}

module two_tooth_gear() {
  color([192/255, 32/255, 32/255])
  render()
  difference() {
    union() {
      rotate([0, 0, 360/20*3.5]) gear(mm_per_tooth = mm_per_tooth, hole_diameter = d, number_of_teeth = 20, teeth_to_hide=18, thickness = t);
      cylinder(r=big_gear_root_r(), h=t, center=true, $fn=72);
    }
    cylinder(r=d/2, h=t*2, center=true, $fn=36);
  }
}

module retaining_disc() {
  rotate([0, 0, -360/20 * 1])
  render()
  difference() {
    cylinder(r=big_gear_or(), h=t, center=true, $fn=72);
    cylinder(r=d/2, h=t*2, center=true, $fn=36);
    translate([-big_gear_or(), 0, 0]) {
      assign(base_block_size = big_gear_or() - big_gear_root_r())
      difference() {
        translate([base_block_size/2, 0, 0]) cube(size=[base_block_size, mm_per_tooth, t*2], center=true);
        translate([big_gear_or(), 0, 0]) rotate([0, 0, 360/20*4.5]) gear(mm_per_tooth = mm_per_tooth, hole_diameter = d, number_of_teeth = 20, teeth_to_hide=18, thickness = t*2+0.1);
      }
    }
  }
}

module spacing_disc() {
  render()
  difference() {
    cylinder(r=big_gear_root_r(), h=t, center=true, $fn=72);
    cylinder(r=d/2, h=t*2, center=true, $fn=36);
  }
}

chars=["0","1","2","3","4","5","6","7","8","9"];
module numeral_disc() {
  color([192/255, 128/255, 128/255])
  render()
  difference() {
    cylinder(r=outer_radius(mm_per_tooth = mm_per_tooth, number_of_teeth = 20), h=t, center=true, $fn=72);
    cylinder(r=d/2, h=t*2, center=true, $fn=36);

    for (i=[0:9]) {
      rotate([0, 0, 360/10*i - 90]) translate([-outer_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=20) + digit_width/2, 0, -t]) 
        8bit_char(chars[i], digit_width/8,t*2,false);
    }
  }
}

module complete_gear() {
  color([128/255, 128/255, 255/255])
  rotate([0, 0, 360/20*0.5])
  render()
  gear(mm_per_tooth = mm_per_tooth, hole_diameter = d, number_of_teeth = 20, thickness = t);
}

module gear_assembly_a() {
  translate([0, 0, t]) numeral_disc();
  two_tooth_gear();
  translate([0, 0, -t]) retaining_disc();
  translate([0, 0, -2*t]) spacing_disc();
  translate([0, 0, -3*t]) complete_gear();
}

module gear_assembly_b() {
  translate([0, 0, t]) numeral_disc();
  complete_gear();
  translate([0, 0, -t]) spacing_disc();
  translate([0, 0, -2*t]) retaining_disc();
  translate([0, 0, -3*t]) two_tooth_gear();
}

module carrier_plate() {
  color([32/255, 192/255, 32/255])
  assign(complete_gear_od=2 * outer_radius(mm_per_tooth = mm_per_tooth, number_of_teeth = 20))
  assign(connecting_gear_root_r=root_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=8))
  assign(width=num_digits*complete_gear_od + (num_digits-1) * 2 * connecting_gear_root_r + 20)
  assign(height=complete_gear_od+20)
  difference() {
    cube(size=[width, height, t], center=true);
    translate([-width/2 + 10 + complete_gear_od/2, 0, 0]) {
      for (i=[0:num_digits-1]) {
        translate([gear_to_gear*i, 0, 0]) {
          cylinder(r=d/2, h=t*2, center=true, $fn=36);
        }
      }

      translate([cd, 0, 0]) for (i=[0:num_digits-2]) {
        translate([gear_to_gear*i, 0, 0]) {
          cylinder(r=d/2, h=t*2, center=true, $fn=36);
        }
      }
    }
  }
}

module digit_window_faceplate() {
  render()
  assign(complete_gear_od=2 * outer_radius(mm_per_tooth = mm_per_tooth, number_of_teeth = 20))
  difference() {
    cube(size=[digit_width+5, complete_gear_od+5+2*t, t], center=true);
    cylinder(r=d/2, h=t*2, center=true, $fn=36);
    translate([0, outer_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=20) - digit_width/2, 0]) 
      cube(size=[digit_width, digit_width, t*2], center=true);
    for (i=[-1,1]) {
      translate([0, i * ((complete_gear_od+5+2*t)/2 - 2 - t/2), 0]) cube(size=[5, t, t*2], center=true);
    }
    
  }
}

module digit_window_support() {
  color([128/255, 192/255, 128/255])
  render()
  difference() {
    cube(size=[digit_width+5, 7*t, t], center=true);
    for (x=[-1,1], y=[-1,1]) {
      translate([x * (digit_width+5)/2, y * (7 * t / 2 - t/2), 0]) 
        cube(size=[digit_width, t, t*2], center=true);
    }
    
  }
  
}

module digit_window_assembly() {
  digit_window_faceplate();
  assign(complete_gear_od=2 * outer_radius(mm_per_tooth = mm_per_tooth, number_of_teeth = 20))
  for (a=[0,180]) {
    rotate([0, 0, a]) 
    translate([0, (complete_gear_od+5+2*t)/2 - t/2 - 2, -3*t])
      rotate([90, 0, 0]) digit_window_support();
  }
}

cd=center_distance(mm_per_tooth=mm_per_tooth, num_teeth1=20, num_teeth2=8);
gear_to_gear=2*center_distance(mm_per_tooth=mm_per_tooth, num_teeth1=20, num_teeth2=8);
module assembled() {
  // echo("width", gear_to_gear*10);
  translate([gear_to_gear*-num_digits/2 + cd, 0, 0]) {
    for (i=[0:num_digits-1]) {
      translate([gear_to_gear*i, 0, 0]) {
        if (i % 2 == 1) {
          gear_assembly_a();
        } else {
          gear_assembly_b();
        }
        translate([0, 0, 2*t]) digit_window_assembly();
      }
    }

    translate([cd, 0, 0]) for (i=[0:num_digits-2]) {
      translate([gear_to_gear*i, 0, 0]) {
        if (i % 2 == 0) {
          connecting_gear_assembly_a();
        } else {
          connecting_gear_assembly_b();
        }
      }
    }
  }
  
  translate([0, 0, -t*4]) carrier_plate();
  
  // translate([-cd - gear_to_gear, 0, 0])
  //   gear_assembly_a();
  // translate([-cd, 0, 0])
  //   gear_assembly_b();
  // translate([cd, 0, 0])
  //   gear_assembly_a();
  // 
  // connecting_gear_assembly_a();
  // translate([-gear_to_gear, 0, 0]) 
  //   connecting_gear_assembly_b();



  // translate([0, 0, -2*t]) carrier_plate();
}

assembled();

