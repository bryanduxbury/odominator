// TODOs
// give the digit windows another pair of sides for stability

use <publicDomainGearV1.1.scad>
use <bitmap.scad>


digit_width=8;
num_digits=5;

// material thickness
// t = 5.2; // birch ply
t = 3; // 1/8" acrylic

// shaft diameter
d = 1/8 * 25.4;

crank_shaft_d=12;
crank_shaft_length = 75;
crank_gear_num_teeth=60;

crank_connecting_gear_num_teeth = 8;

carrier_plate_height=6.5*25;

mm_per_tooth = 5;


function big_gear_or() = outer_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=20);
function big_gear_root_r() = root_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=20);

function small_gear_or() = outer_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=8);
function small_gear_root_r() = root_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=8);

function digit_window_faceplate_height() = (big_gear_or() + 3 * t)*2;

function distance_between_big_gears() = 2 * center_distance(mm_per_tooth=mm_per_tooth, num_teeth1=20, num_teeth2=8);
function distance_between_big_and_small_gears() = center_distance(mm_per_tooth=mm_per_tooth, num_teeth1=20, num_teeth2=8);

function faceplate_width() = distance_between_big_gears() * num_digits + 20;

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
    cylinder(r=big_gear_or(), h=t, center=true, $fn=72);
    cylinder(r=d/2, h=t*2, center=true, $fn=36);

    for (i=[0:9]) {
      rotate([0, 0, 360/10*i - 90]) translate([-big_gear_or() + digit_width/2, 0, -t]) 
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
  assign(width=distance_between_big_gears()*num_digits + 20)
  assign(height=carrier_plate_height)
  render()
  difference() {
    cube(size=[width, height, t], center=true);
    translate([0, carrier_plate_height/2 - t*3 - big_gear_or(), 0]) {
      translate([-(width-20)/2 + distance_between_big_and_small_gears(), 0, 0]) {
        for (i=[0:num_digits-1]) {
          translate([distance_between_big_gears()*i, 0, 0]) {
            cylinder(r=d/2, h=t*2, center=true, $fn=36);
            for (i=[-1,1]) translate([0, i * (digit_window_faceplate_height()/2 - t - t/2), 0]) cube(size=[5, t, t*2], center=true);
          }
        }

        translate([distance_between_big_gears(), 0, 0]) for (i=[0:num_digits-2]) {
          translate([distance_between_big_gears()*i, 0, 0]) {
            cylinder(r=d/2, h=t*2, center=true, $fn=36);
          }
        }
      }

      translate([distance_between_big_gears()*num_digits/2 - distance_between_big_and_small_gears(), 0, 0]) {
        rotate([0, 0, -45]) translate([center_distance(mm_per_tooth=mm_per_tooth, num_teeth1=20, num_teeth2=crank_connecting_gear_num_teeth), 0, 0]) {
          cylinder(r=d/2, h=t*2, center=true, $fn=36);
          rotate([0, 0, -45]) translate([center_distance(mm_per_tooth=mm_per_tooth, num_teeth1=crank_connecting_gear_num_teeth, num_teeth2=crank_connecting_gear_num_teeth), 0, 0]) {
            cylinder(r=d/2, h=t*2, center=true, $fn=36);
            rotate([0, 0, -45]) translate([center_distance(mm_per_tooth=mm_per_tooth, num_teeth1=crank_connecting_gear_num_teeth, num_teeth2=crank_connecting_gear_num_teeth), 0, 0]) {
              cylinder(r=d/2, h=t*2, center=true, $fn=36);
              translate([center_distance(mm_per_tooth=mm_per_tooth, num_teeth1=crank_gear_num_teeth, num_teeth2=crank_connecting_gear_num_teeth), 0, 0]) {
                cylinder(r=d/2, h=t*2, center=true, $fn=36);
              }
            }
          }
        }
      }
    }
  }
}

module digit_window_faceplate() {
  render()
  assign(width=digit_width+5)
  difference() {
    cube(size=[width, digit_window_faceplate_height(), t], center=true);
    cylinder(r=d/2, h=t*2, center=true, $fn=36);
    translate([0, big_gear_or() - digit_width/2, 0]) 
      cube(size=[digit_width, digit_width, t*2], center=true);
    for (i=[-1,1]) {
      translate([0, i * (digit_window_faceplate_height()/2 - t - t/2), 0]) cube(size=[5, t, t*2], center=true);
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
  for (a=[0,180]) {
    rotate([0, 0, a]) 
    translate([0, digit_window_faceplate_height()/2 - t - t/2, -3*t])
      rotate([90, 0, 0]) digit_window_support();
  }
}

module crank_base_spacer() {
  render()
  difference() {
    cylinder(r=20, h=t, center=true, $fn=72);
    cylinder(r=d/2, h=t*2, center=true, $fn=36);
  }
}

module crank_gear() {
  difference() {
    gear(mm_per_tooth = mm_per_tooth, hole_diameter = d, number_of_teeth = crank_gear_num_teeth, thickness = t);
    translate([0, root_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=crank_gear_num_teeth) - 5, 0]) cylinder(r=d/2, h=t*2, center=true, $fn=36);
  }
}

module crank_connecting_gear() {
  full_connecting_gear();
}

module crank_connecting_gear_assembly() {
  for (y=[0:2]) {
    translate([0, 0, y*t]) crank_connecting_gear();
  }
}

module crank_assembly() {
  crank_base_spacer();
  translate([0, 0, t]) crank_gear();
  translate([0, 0, 2*t]) crank_gear();
  translate([0, root_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=crank_gear_num_teeth) - 5, 2.5*t+crank_shaft_length/2])
    color([192/255, 127/255, 127/255]) cylinder(r=crank_shaft_d/2, h=crank_shaft_length, center=true, $fn=36);
}


module faceplate_and_gears_assembly() {
  translate([0, carrier_plate_height/2 - 3*t - big_gear_or(), 0]) {
    translate([distance_between_big_gears()*-num_digits/2 + distance_between_big_and_small_gears(), 0, 0]) {
      for (i=[0:num_digits-1]) {
        translate([distance_between_big_gears()*i, 0, 0]) {
          if (i % 2 == 1) {
            gear_assembly_b();
          } else {
            gear_assembly_a();
          }
          translate([0, 0, 2*t]) digit_window_assembly();
        }
      }

      translate([distance_between_big_and_small_gears(), 0, 0]) for (i=[0:num_digits-2]) {
        translate([distance_between_big_gears()*i, 0, 0]) {
          if (i % 2 == 0) {
            connecting_gear_assembly_b();
          } else {
            connecting_gear_assembly_a();
          }
        }
      }
    }

    assign(dc_dist=center_distance(mm_per_tooth=mm_per_tooth, num_teeth1=20, num_teeth2=crank_connecting_gear_num_teeth))
    assign(cc_dist=center_distance(mm_per_tooth=mm_per_tooth, num_teeth1=crank_connecting_gear_num_teeth, num_teeth2=crank_connecting_gear_num_teeth))
    assign(crank_c_dist=center_distance(mm_per_tooth=mm_per_tooth, num_teeth1=crank_gear_num_teeth, num_teeth2=crank_connecting_gear_num_teeth))
    translate([distance_between_big_gears()*num_digits/2 - distance_between_big_and_small_gears(), 0, -t*3]) {
      rotate([0, 0, -45]) translate([dc_dist, 0, 0]) {
        rotate([0, 0, 360/crank_connecting_gear_num_teeth/2]) crank_connecting_gear_assembly();
        rotate([0, 0, -45]) translate([cc_dist, 0, 0]) {
          crank_connecting_gear_assembly();
          rotate([0, 0, -45]) translate([cc_dist, 0, 0]) {
            rotate([0, 0, 360/crank_connecting_gear_num_teeth/2]) crank_connecting_gear_assembly();
            translate([crank_c_dist, 0, 0]) {
              crank_assembly();
            }
          }
        }
      }
    }
  }

  translate([0, 0, -t*4]) carrier_plate();
}

module foot_plate() {
  cube(size=[faceplate_width(), carrier_plate_height / sqrt(2), t], center=true);
}

module leg() {
  
}

module assembled() {
  rotate([45, 0, 0]) translate([0, 0, t*4]) faceplate_and_gears_assembly();
  for (x=[-1,1]) {
    translate([faceplate_width()/2, 0, 0]) 
      leg();
  }
  
  translate([0, 0, -carrier_plate_height / 2 / sqrt(2)]) foot_plate();
  
}

assembled();

