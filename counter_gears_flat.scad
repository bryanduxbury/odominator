use <publicDomainGearV1.1.scad>
use <bitmap.scad>

function center_distance(t1, t2) = pitch_radius(number_of_teeth=t1, mm_per_tooth = mm_per_tooth) 
  + pitch_radius(number_of_teeth=t2, mm_per_tooth = mm_per_tooth);

digit_width=8;

num_digits=10;

t = 5.2;

d = 1/8 * 25.4;

mm_per_tooth = 5;

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
      cylinder(r=root_radius(mm_per_tooth=mm_per_tooth, number_of_teeth=8), h=t, center=true, $fn=36);
    }
    cylinder(r=d/2, h=t*2, center=true, $fn=36);
  }
}

module connecting_gear_spacer() {
  color([96/255, 96/255, 96/255])
  render()
  difference() {
    cylinder(r=root_radius(mm_per_tooth = mm_per_tooth, number_of_teeth = 8), h=t, center=true, $fn=36);
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
      rotate([0, 0, 360/20*4.5]) gear(mm_per_tooth = mm_per_tooth, hole_diameter = d, number_of_teeth = 20, teeth_to_hide=18, thickness = t);
      cylinder(r=root_radius(mm_per_tooth = mm_per_tooth, number_of_teeth = 20), h=t, center=true, $fn=72);
    }
    cylinder(r=d/2, h=t*2, center=true, $fn=36);
    // translate([0, root_radius(mm_per_tooth = mm_per_tooth, number_of_teeth = 20)/2, 0]) cylinder(r=d/2-0.5, h=t*2, center=true, $fn=36);
  }
}

module retaining_disc() {
  render()
  difference() {
    cylinder(r=outer_radius(mm_per_tooth = mm_per_tooth, number_of_teeth = 20), h=t, center=true, $fn=72);
    cylinder(r=d/2, h=t*2, center=true, $fn=36);
    translate([-outer_radius(mm_per_tooth = mm_per_tooth, number_of_teeth = 20), 0, 0]) {
      assign(base_block_size = outer_radius(mm_per_tooth = mm_per_tooth, number_of_teeth = 20) - root_radius(mm_per_tooth = mm_per_tooth, number_of_teeth = 20))
      difference() {
        translate([base_block_size/2, 0, 0]) cube(size=[base_block_size, mm_per_tooth, t*2], center=true);
        translate([outer_radius(mm_per_tooth = mm_per_tooth, number_of_teeth = 20), 0, 0]) rotate([0, 0, 360/20*4.5]) gear(mm_per_tooth = mm_per_tooth, hole_diameter = d, number_of_teeth = 20, teeth_to_hide=18, thickness = t*2+0.1);
      }
    }
  }
}

module spacing_disc() {
  render()
  difference() {
    cylinder(r=root_radius(mm_per_tooth = mm_per_tooth, number_of_teeth = 20), h=t, center=true, $fn=72);
    cylinder(r=d/2, h=t*2, center=true, $fn=36);
  }
}

chars=["0","1","2","3","4","5","6","7","8","9"];
module numeral_disc() {
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

module complete_gear() {
  rotate([0, 0, 360/20*0.5]) render() gear(mm_per_tooth = mm_per_tooth, hole_diameter = d, number_of_teeth = 20, thickness = t);
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
  cube(size=[digit_width+5, complete_gear_od+5+2*t, t], center=true);
}

module digit_window_assembly() {
  digit_window_faceplate();
}

cd=center_distance(mm_per_tooth=mm_per_tooth, t1=20, t2=8);
gear_to_gear=2*center_distance(mm_per_tooth=mm_per_tooth, t1=20, t2=8);
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

