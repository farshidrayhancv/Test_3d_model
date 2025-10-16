$fn = 64;

topdon_wid = 71.1;
topdon_h   = 41.9;
topdon_thk = 14.0;

ard_board      = 38.0;
ard_hole_pitch = 34.0;
ard_depth      = 15.0;
ard_hole_d     = 2.2;

wall  = 3.0;
floor = 3.0;
roof  = 3.0;
gap   = 0.6;
front_clearance = 1.0;
inter_gap = 2.0;

ard_window_size     = 26.0;
topdon_window_w     = 18.0;
topdon_window_h     = 16.0;
topdon_window_off_x = 6.0;
topdon_window_off_z = 12.0;

usb_topdon_d   = 12.0;
usb_arducam_d  = 10.0;

csk_enable = true;
csk_head_d = 4.4;
csk_head_h = 1.4;

screw_margin = 12.0;

housing_w = screw_margin + wall + ard_board + inter_gap + topdon_wid + wall + screw_margin;
housing_d = wall + max(topdon_thk, ard_depth) + wall;
housing_h = floor + max(topdon_h, ard_board) + roof;

ard_pocket_size = [ ard_board + gap, ard_depth + gap, ard_board + gap ];
ard_pocket_pos  = [ screw_margin + wall, wall + front_clearance, floor ];

top_pocket_size = [ topdon_wid + gap, topdon_thk + gap, topdon_h + gap ];
top_pocket_pos  = [ screw_margin + wall + ard_board + inter_gap, wall + front_clearance, floor ];

ard_center = [ ard_pocket_pos[0] + (ard_board + gap)/2, 0, floor + (ard_board + gap)/2 ];
top_center = [ top_pocket_pos[0] + (topdon_wid + gap)/2, 0, floor + (topdon_h + gap)/2 ];

split_y = housing_d / 2;

corner_screw_d = 3.2;
corner_screw_boss_d = 7.0;
corner_screw_boss_h = 8.0;
corner_inset = 6.0;

part = "both";

module corner_screw_positions() {
    corners = [
        [corner_inset, corner_inset],
        [housing_w - corner_inset, corner_inset],
        [corner_inset, housing_h - corner_inset],
        [housing_w - corner_inset, housing_h - corner_inset]
    ];
    for (c = corners) {
        translate([c[0], 0, c[1]]) children();
    }
}

module front_half() {
    difference() {
        intersection() {
            enclosure_body();
            translate([0, 0, 0]) cube([housing_w, split_y, housing_h]);
        }
        
        corner_screw_positions() {
            translate([0, split_y - 0.01, 0])
                rotate([90, 0, 0])
                    cylinder(h = corner_screw_boss_h + 1, d = corner_screw_d);
        }
    }
    
    corner_screw_positions() {
        translate([0, split_y, 0])
            rotate([90, 0, 0])
                difference() {
                    cylinder(h = corner_screw_boss_h, d = corner_screw_boss_d);
                    translate([0, 0, -0.1])
                        cylinder(h = corner_screw_boss_h + 0.2, d = corner_screw_d);
                }
    }
}

module back_half() {
    difference() {
        intersection() {
            enclosure_body();
            translate([0, split_y, 0]) cube([housing_w, housing_d - split_y, housing_h]);
        }
        
        corner_screw_positions() {
            translate([0, split_y, 0])
                rotate([90, 0, 0])
                    cylinder(h = corner_screw_boss_h + 1, d = corner_screw_d);
        }
    }
    
    corner_screw_positions() {
        translate([0, split_y - corner_screw_boss_h, 0])
            rotate([90, 0, 0])
                difference() {
                    cylinder(h = corner_screw_boss_h, d = corner_screw_boss_d);
                    translate([0, 0, -0.1])
                        cylinder(h = corner_screw_boss_h + 0.2, d = corner_screw_d);
                }
    }
}

module enclosure_body(){
  difference(){
    cube([housing_w, housing_d, housing_h], center=false);

    translate([wall, wall, floor])
      cube([housing_w-2*wall, housing_d-2*wall, housing_h-floor-roof], center=false);

    translate(ard_pocket_pos) cube(ard_pocket_size, center=false);
    translate(top_pocket_pos) cube(top_pocket_size, center=false);

    translate([
      ard_pocket_pos[0] + (ard_board + gap - ard_window_size)/2,
      -0.6,
      floor + (ard_board + gap - ard_window_size)/2
    ])
      cube([ard_window_size, wall+1.2, ard_window_size], center=false);

    translate([
      top_pocket_pos[0] + topdon_window_off_x,
      -0.6,
      floor + topdon_window_off_z - topdon_window_h/2
    ])
      cube([topdon_window_w, wall+1.2, topdon_window_h], center=false);

    translate([
      top_pocket_pos[0] + top_pocket_size[0]/2,
      wall + topdon_thk + front_clearance - 0.5,
      housing_h - roof
    ])
      rotate([90,0,0]) cylinder(h=roof+1.2, d=usb_topdon_d, center=true);

    translate([
      ard_pocket_pos[0] + ard_pocket_size[0]/2,
      wall + ard_depth + front_clearance - 0.5,
      housing_h - roof
    ])
      rotate([90,0,0]) cylinder(h=roof+1.2, d=usb_arducam_d, center=true);

    for (sx = [-1,1]) for (sz = [-1,1]){
      x = ard_center[0] + sx*(ard_hole_pitch/2);
      z = ard_center[2] + sz*(ard_hole_pitch/2);

      translate([x, -1.0, z])
        rotate([90,0,0]) cylinder(h=housing_d+2, d=ard_hole_d, center=false);

      if (csk_enable)
        translate([x, 0.02, z])
          rotate([90,0,0]) cylinder(h=csk_head_h, d1=csk_head_d, d2=ard_hole_d, center=false);
    }
    
    corner_screw_positions() {
      translate([0, -1, 0])
        rotate([90, 0, 0])
          cylinder(h = housing_d + 2, d = corner_screw_d);
    }
  }

  standoff_d = 5.5;
  standoff_h = ard_depth;
  for (sx = [-1,1]) for (sz = [-1,1]){
    x = ard_center[0] + sx*(ard_hole_pitch/2);
    z = ard_center[2] + sz*(ard_hole_pitch/2);

    translate([x, ard_pocket_pos[1], z])
      rotate([90,0,0]) cylinder(h=standoff_h, d=standoff_d, center=false);
  }
}

if (part == "front") {
    front_half();
} else if (part == "back") {
    back_half();
} else if (part == "both") {
    front_half();
    translate([0, housing_d + 10, 0]) back_half();
}