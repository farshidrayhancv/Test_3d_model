/*
  Triple‑Camera Enclosure (depth‑split two‑piece)

  This OpenSCAD script extends the previous dual‑camera design to
  accommodate a third imaging module (a time‑of‑flight or ToF camera), an
  active USB hub and a CSI‑to‑HDMI adapter board.  The design
  continues to mount a Topdon TC001/TC001 Plus thermal camera and an
  Arducam B0205/B0506 night‑vision board side‑by‑side, while placing
  the ToF camera above them on the same front plane.  Internal
  compartments behind the ToF board provide space for a small powered
  USB hub and the near‑camera CSI‑to‑HDMI adapter board.  All three
  cameras look forward through dedicated openings in the front panel.

  Parameters for board sizes and clearances are exposed near the top
  of the file so you can adjust them for different hardware.  Two
  roof‑mounted cable holes allow you to route a USB‑A lead (from the
  hub) and a full‑size HDMI lead (from the adapter) out of the
  enclosure.  Assembly is completed with four M3 screws joining the
  front and back halves.

*/

$fn = 64;

// ------------------------------------------------------------------------
// Core dimensions (mm) for the existing cameras
// Topdon TC001 oriented as width × height × depth【609389745417641†L50-L53】.
// In this variant we will rotate the Topdon body 90° so that the original
// height becomes the new width and the original width becomes the new
// height.  The depth remains unchanged.
topdon_wid = 71.1;
topdon_h   = 41.9;
topdon_thk = 14.0;
// Rotated dimensions for the Topdon: swap width and height
topdon_rot_wid = topdon_h;
topdon_rot_h   = topdon_wid;

// Arducam B0205/B0506 parameters (38 mm square board, 6 IR LEDs)【6541847888620†L510-L514】.
ard_board      = 38.0;
ard_hole_pitch = 34.0;
ard_depth      = 15.0;
ard_hole_d     = 2.2;

// ------------------------------------------------------------------------
// Additional modules
// ToF camera board (assume square like many Arducam ToF boards).  Adjust
// these values for your specific sensor.  Many ToF modules are ~38 mm
// square and use an M12 lens; we leave a generous lens opening.
tof_board      = 38.0;
tof_depth      = 16.0;
tof_window_d   = 20.0;    // lens & emitter opening diameter

// Active USB hub (VL817 4‑port expansion module).  According to a
// mechanical drawing for a VL817‑based hub board, the PCBA measures
// roughly 45 mm × 40 mm with the stacked Type‑A connectors adding
// about 20 mm thickness【785468983661979†L569-L655】.  We model the board
// footprint accordingly so the pocket can accommodate the entire
// assembly.
hub_w          = 45.0;
hub_h          = 40.0;
hub_depth      = 20.0;

// CSI‑to‑HDMI adapter board (near camera).  The Arducam adapter set uses
// a 38×38 mm camera‑side board【30944712049717†L400-L405】.  Depth ~10 mm.
csi_w          = 38.0;
csi_h          = 38.0;
csi_depth      = 10.0;

// ToF board mounting hole pattern.  Most square Arducam boards use a
// 34 mm pitch and M2 screw holes; adjust these values if your ToF
// module differs.  The clearance diameter matches the Arducam board.
tof_hole_pitch = 34.0;
tof_hole_d     = 2.2;

// Countersink/head dimensions for M2 screws used to mount the Arducam and
// ToF boards.  These define the diameter and depth of the recess on
// the outside of the back panel where the screw head sits.
m2_head_d      = 4.5;
m2_head_h      = 2.0;

// ------------------------------------------------------------------------
// Housing parameters
wall            = 3.0;     // side wall thickness (x)
floor           = 3.0;     // bottom thickness (z)
roof            = 3.0;     // roof thickness (z)
gap             = 0.6;     // manufacturing clearance around pockets
front_clearance = 1.0;     // gap between module face and back of front panel
inter_gap       = 2.0;     // lateral gap between side‑by‑side modules (x)
front_thk       = 3.0;     // thickness of the removable front panel (y)

// Arducam standoff diameter (outer) – M2 clearance will be drilled in front panel
standoff_d      = 5.5;

// Cable exit diameters for Topdon and Arducam (USB) – unchanged
usb_topdon_d    = 12.0;
usb_arducam_d   = 10.0;

// Additional cable exit diameters for USB‑A and HDMI cables
usb_a_d         = 14.0;   // hole for standard USB‑A plug
hdmi_d          = 20.0;   // slot diameter for full‑size HDMI plug

// Dimensions for the single accessible USB‑A port and DC barrel on the
// VL817 hub.  A standard USB‑A receptacle is approximately 14 mm wide
// and 7 mm tall; the DC barrel jack on this module uses a 5.5 mm × 
// 2.5 mm plug, so we choose an 8 mm hole to provide clearance.
usb_port_w      = 14.0;
usb_port_h      = 7.0;
dc_barrel_d     = 8.0;

// Countersink parameters for M2 screws (front panel)
csk_head_d      = 4.4;
csk_head_h      = 1.4;

// Assembly screw parameters (M3).  Four screws join front panel to back housing.
asm_hole_d      = 3.2;
asm_head_d      = 6.4;
asm_head_h      = 2.5;
asm_offset_x    = 6.5;
asm_offset_z    = 6.5;

// ------------------------------------------------------------------------
// Topdon lens window parameters
// When the Topdon camera is rotated 90° (portrait orientation), the dual
// sensors stack vertically rather than horizontally.  We swap the
// original window dimensions (18 × 16 mm) so the new window is taller
// than it is wide.  You can adjust these values if you measure your
// own unit.  The horizontal offset remains near the left edge of the
// rotated Topdon, and the vertical offset is measured from the bottom
// of the enclosure.  Note: these variables are used only for cutting
// the Topdon opening in the front panel.
topdon_window_w      = 16.0;  // new width (across x) for rotated Topdon
topdon_window_h      = 18.0;  // new height (across z) for rotated Topdon
topdon_window_off_x  = 6.0;
// Vertically align the Topdon lens opening with the Arducam and ToF
// lenses.  Set the Topdon window centre to the same Z height as the
// centre of the other 38 mm square boards: half their height plus
// half the manufacturing gap.  This helps keep all optical axes on
// the same horizontal plane.
topdon_window_off_z  = (tof_board + gap) / 2;

// --- USB‑C L‑plug side‑relief and Topdon shift ---
// When using a right‑angle (L‑shaped) USB‑C adapter on the TC001, the elbow of
// the plug protrudes sideways toward the night‑vision board.  To keep the
// adapter from colliding with the Arducam module, we allow a user‑adjustable
// horizontal shift of the Topdon pocket (increasing the gap between the
// Arducam and Topdon) and carve a local relief pocket in the roof.  The
// default 8 mm shift combined with the relief pocket provides roughly 28 mm
// of clearance for an L‑plug head.  Adjust these parameters if your plug
// differs in size.
topdon_shift_x       = 8.0;   // additional gap (mm) between Arducam and Topdon
usbC_relief_len_x    = 22.0;  // how far the relief extends horizontally (mm)
usbC_relief_depth_y  = 12.0;  // how far into the roof the relief is carved (mm)
usbC_relief_drop_z   = 8.0;   // how far below the roof the relief drops (mm)
usbC_relief_thick_z  = 9.0;   // vertical thickness of the L‑plug body to clear (mm)

// ------------------------------------------------------------------------
// Derived dimensions
// Maximum thickness among the three camera modules.  We will stack the
// hub and CSI boards behind the cameras along the Y axis, so the
// enclosure depth must allow for the camera thickness plus the hub
// thickness and CSI thickness.
cam_depth = max(topdon_thk, ard_depth, tof_depth);
// Total width now includes all three modules side‑by‑side.  The Arducam,
// the rotated Topdon (width becomes original height) and the ToF board
// sit in a row separated by inter_gap.  The housing width is:
//   side walls + Arducam width + gap + Topdon shift + rotated Topdon width + gap + ToF width + side walls.
housing_w   = wall + ard_board + inter_gap + topdon_shift_x + topdon_rot_wid + inter_gap + tof_board + wall;

// Height: bottom + the maximum of the three module heights + roof.  Since
// the rotated Topdon is tallest, this becomes floor + topdon_rot_h + roof.
housing_h   = floor + max(topdon_rot_h, ard_board, tof_board) + roof;

// Depth: stack the cameras and support boards along the Y axis.  To
// place the active USB hub and CSI adapter behind the cameras, the
// interior depth must accommodate the camera thickness, the hub
// thickness, the CSI thickness, plus two clearance gaps.  Define
// `cam_depth` above as the maximum thickness of the camera modules.
max_depth   = cam_depth + hub_depth + csi_depth + 2*gap;
housing_d   = wall + max_depth + wall;

// Interior depth (distance from back of front panel to inner back wall)
// includes the front clearance and a final clearance gap behind the
// stacked boards.
interior_depth = front_clearance + max_depth + gap;
back_depth     = interior_depth + wall;

// ------------------------------------------------------------------------
// Pocket sizes and positions
// Left‑to‑right (x) layout: Arducam → gap → rotated Topdon → gap → ToF
// Vertical (z) layout: all three modules sit at the same level (no vertical stacking).

// Arducam pocket
ard_pocket_size  = [ ard_board + gap, ard_depth + gap, ard_board + gap ];
ard_pocket_pos   = [ wall,
                     front_clearance,
                     floor ];

// Topdon pocket (rotated): width becomes original height; height becomes original width
// Apply a rightward shift (`topdon_shift_x`) to provide extra space for an
// L‑shaped USB‑C adapter between the Arducam and Topdon cameras.
top_pocket_size  = [ topdon_rot_wid + gap, topdon_thk + gap, topdon_rot_h + gap ];
top_pocket_pos   = [ wall + ard_board + inter_gap + topdon_shift_x,
                     front_clearance,
                     floor ];

// ToF pocket – placed to the right of the (shifted) rotated Topdon on the same level.
tof_pocket_size  = [ tof_board + gap, tof_depth + gap, tof_board + gap ];
tof_pocket_pos   = [ wall + ard_board + inter_gap + topdon_shift_x + topdon_rot_wid + inter_gap,
                     front_clearance,
                     floor ];

// Active USB hub pocket – centered horizontally behind the three camera
// pockets along the Y axis.  Position the hub immediately behind the
// cameras: its Y coordinate begins after the camera depth plus a
// clearance gap.
hub_pocket_size  = [ hub_w + gap, hub_depth + gap, hub_h + gap ];
hub_pocket_pos   = [ wall + ( (housing_w - 2*wall) - (hub_w + gap) )/2,
                     front_clearance + cam_depth + gap,
                     floor ];

// CSI‑to‑HDMI adapter pocket – centered horizontally behind the hub
// pocket along the Y axis.  Position it after the hub, with a
// clearance gap.
csi_pocket_size  = [ csi_w + gap, csi_depth + gap, csi_h + gap ];
csi_pocket_pos   = [ wall + ( (housing_w - 2*wall) - (csi_w + gap) )/2,
                     front_clearance + cam_depth + gap + hub_depth + gap,
                     floor ];

// Centres for windows and standoffs
ard_center_x = ard_pocket_pos[0] + (ard_board + gap)/2;
ard_center_z = floor + (ard_board + gap)/2;
// The rotated Topdon centre: use its rotated width and height
top_center_x = top_pocket_pos[0] + (topdon_rot_wid + gap)/2;
top_center_z = floor + (topdon_rot_h + gap)/2;
// ToF centre is halfway across its pocket, at the same base level
tof_center_x = tof_pocket_pos[0] + (tof_board + gap)/2;
tof_center_z = floor + (tof_board + gap)/2;

// Vertical positions of cable exits in back panel
topdon_cable_y = front_clearance + topdon_thk - 0.5;
ard_cable_y    = front_clearance + ard_depth   - 0.5;
tof_cable_y    = front_clearance + tof_depth   - 0.5;

// ------------------------------------------------------------------------
// Front panel module
module front_panel() {
  /*
    The front panel carries all optical openings and serves as the primary
    mounting surface for the Arducam board and the ToF board.  The Arducam
    board attaches via integrated standoff pegs (drilled for M2 screws)
    similarly to the dual‑camera design.  The ToF board uses a
    large circular opening for its lens and emitter; we assume the board
    itself is clamped in place behind the panel by the enclosure without
    dedicated screws.
  */
  // Create a slab for the front panel: width (x) × thickness (y) × height (z)
  // The front face is at y=0 and the panel extends along +y by front_thk.
  difference() {
    cube([housing_w, front_thk, housing_h], center=false);

    // --- Windows and openings ---
    // Topdon window (right side) – subtract a rectangular hole through the panel
    translate([
      top_pocket_pos[0] + topdon_window_off_x,
      -0.5,
      floor + topdon_window_off_z - topdon_window_h/2
    ])
      cube([ topdon_window_w, front_thk + 1.0, topdon_window_h ], center=false);

    // Arducam openings: lens + 2×3 LED holes per side
    lens_d       = 16.0;
    led_d        = 4.5;
    led_off_x_vals = [ 14.5, 15.8 ];
    led_off_z_vals = [ 10.0, 0.0, -10.0 ];
    // central lens hole (cylinder oriented along +y)
    translate([ ard_center_x, -0.5, ard_center_z ])
      rotate([-90, 0, 0]) cylinder(h = front_thk + 1.0, d = lens_d, center=false);
    // LED holes (cylinders oriented along +y)
    for (sx = [-1, 1])
      for (ox = led_off_x_vals)
        for (oz = led_off_z_vals) {
          led_x = ard_center_x + sx * ox;
          led_z = ard_center_z + oz;
          translate([ led_x, -0.5, led_z ])
            rotate([-90, 0, 0]) cylinder(h = front_thk + 1.0, d = led_d, center=false);
        }

    // ToF lens opening: single large circle (cylinder oriented along +y)
    translate([ tof_center_x, -0.5, tof_center_z ])
      rotate([-90, 0, 0]) cylinder(h = front_thk + 1.0, d = tof_window_d, center=false);

    // --- Assembly screw holes (M3) ---
    // Four holes near corners for joining front and back panels.
    for (ix = [-1, 1]) for (iz = [-1, 1]) {
      x_pos = (ix < 0) ? asm_offset_x : (housing_w - asm_offset_x);
      z_pos = (iz < 0) ? (floor + asm_offset_z) : (housing_h - asm_offset_z);
      // through hole (cylinder along +y)
      translate([ x_pos, -0.1, z_pos ])
        rotate([-90,0,0]) cylinder(h = back_depth + front_thk + 2, d = asm_hole_d, center=false);
      // countersink cone in front panel (cylinder along +y with taper)
      translate([ x_pos, 0.02, z_pos ])
        rotate([-90,0,0]) cylinder(h = asm_head_h, d1 = asm_head_d, d2 = asm_hole_d, center=false);
    }
  }

  // No standoff pegs on the front panel.  Both the Arducam and ToF boards
  // are mounted from the rear: their mounting posts reside in the back
  // housing so that screws can be inserted from the outside of the
  // enclosure.  This keeps the front face clean and free of mounting
  // hardware.
}

// ------------------------------------------------------------------------
// Back housing module
module back_housing() {
  /*
    The back housing holds the three camera modules and the two support
    boards.  It includes pockets sized according to the variables above,
    plus roof holes for the USB and HDMI cables.  Four bosses for
    assembly screws align with the front panel holes.  This back
    housing also includes internal standoff posts and rear mounting
    holes for both the Arducam and ToF boards, so they can be
    secured from the outside with M2 screws.
  */
  difference() {
    // Outer box
    cube([housing_w, back_depth, housing_h], center=false);
    // Interior cavity
    translate([wall, wall, floor])
      cube([ housing_w - 2*wall,
             back_depth - wall,
             housing_h - floor - roof ], center=false);
    // Remove pockets for modules
    translate(ard_pocket_pos) cube(ard_pocket_size, center=false);
    translate(top_pocket_pos) cube(top_pocket_size, center=false);
    translate(tof_pocket_pos) cube(tof_pocket_size, center=false);
    translate(hub_pocket_pos) cube(hub_pocket_size, center=false);
    translate(csi_pocket_pos) cube(csi_pocket_size, center=false);
    // Remove cable exit holes for Topdon, Arducam and ToF USB leads
    translate([ top_pocket_pos[0] + top_pocket_size[0]/2,
                topdon_cable_y,
                housing_h - roof ])
      rotate([90,0,0]) cylinder(h = roof + 2, d = usb_topdon_d, center=true);
    translate([ ard_pocket_pos[0] + ard_pocket_size[0]/2,
                ard_cable_y,
                housing_h - roof ])
      rotate([90,0,0]) cylinder(h = roof + 2, d = usb_arducam_d, center=true);
    translate([ tof_pocket_pos[0] + tof_pocket_size[0]/2,
                tof_cable_y,
                housing_h - roof ])
      rotate([90,0,0]) cylinder(h = roof + 2, d = usb_arducam_d, center=true);
    // Remove additional cable holes: USB‑A port and HDMI port.  These
    // holes are placed near the centre of the roof behind the stacked
    // support boards (hub and CSI).  Position them after the hub and
    // CSI boards along Y.
    translate([ housing_w/2 - 10.0,
                front_clearance + cam_depth + hub_depth + csi_depth + 2*gap,
                housing_h - roof ])
      rotate([90,0,0]) cylinder(h = roof + 2, d = usb_a_d, center=true);
    translate([ housing_w/2 + 10.0,
                front_clearance + cam_depth + hub_depth + csi_depth + 2*gap,
                housing_h - roof ])
      rotate([90,0,0]) cylinder(h = roof + 2, d = hdmi_d, center=true);

    // ------------------------------------------------------------------
    // Exposed connectors for the VL817 hub
    // We expose a single downstream USB‑A port and the DC barrel jack on
    // the back wall.  These holes are aligned with the hub pocket.
    // Compute the approximate centre of the hub pocket inline when
    // subtracting the holes.
    // USB‑A rectangular hole: center on hub width and height, carve from
    // the back wall inward along +Y.
    translate([ (hub_pocket_pos[0] + (hub_w + gap)/2) - usb_port_w/2,
                back_depth - wall - 0.1,
                (floor + (hub_h + gap)/2) - usb_port_h/2 ])
      cube([ usb_port_w, wall + 1.2, usb_port_h ], center=false);
    // DC barrel jack hole: offset to the right by 15 mm from the hub
    // centre and aligned vertically to the hub centre.  Carve a
    // cylindrical hole through the back wall.
    translate([ (hub_pocket_pos[0] + (hub_w + gap)/2) + 15.0,
                back_depth - wall - 0.1,
                (floor + (hub_h + gap)/2) ])
      rotate([90,0,0]) cylinder(h = wall + 1.5, d = dc_barrel_d, center=true);

    // --- Relief for L‑shaped USB‑C adapter on the Topdon camera ---
    // The Topdon’s USB‑C connector sits near the middle of the enclosure.  When
    // using a right‑angle adapter, the elbow protrudes toward the Arducam.
    // Carve a rectangular pocket out of the roof in the region above the
    // Topdon pocket.  The relief extends leftwards (−x) from the left edge of
    // the Topdon pocket by `usbC_relief_len_x`, extends into the roof along
    // +y by `usbC_relief_depth_y`, and drops down from the roof by
    // `usbC_relief_drop_z` with a vertical thickness of
    // `usbC_relief_thick_z`.  Adjust the parameters near the top of the file
    // to match your adapter.
    translate([
      // X: start at the left edge of the Topdon pocket and extend leftwards
      top_pocket_pos[0] - usbC_relief_len_x,
      // Y: carve from just below the roof inward along +y
      back_depth - roof - usbC_relief_depth_y,
      // Z: near the roof, drop down by the configured amount
      housing_h - roof - usbC_relief_drop_z
    ])
      cube([
        usbC_relief_len_x,
        usbC_relief_depth_y,
        usbC_relief_thick_z
      ], center=false);
    // Assembly screw holes in back part (through the bosses)
    for (ix = [-1, 1]) for (iz = [-1, 1]) {
      x_pos = (ix < 0) ? asm_offset_x : (housing_w - asm_offset_x);
      z_pos = (iz < 0) ? (floor + asm_offset_z) : (housing_h - asm_offset_z);
      // through hole for M3 screw
      translate([ x_pos, back_depth - 0.1, z_pos ])
        rotate([90,0,0]) cylinder(h = wall + 1.2, d = asm_hole_d, center=false);
    }

    // --- M2 mounting holes for Arducam board ---
    // These holes allow M2 screws to pass through the back wall and the
    // night‑vision board, threading into the interior standoffs.  A
    // counterbore is provided for the screw heads.
    for (sx = [-1, 1]) for (sz = [-1, 1]) {
      // x and z positions relative to board centre
      m2_x = ard_center_x + sx * (ard_hole_pitch / 2);
      m2_z = ard_center_z + sz * (ard_hole_pitch / 2);
      // through hole for M2 screw (clearance)
      translate([ m2_x, back_depth - 0.1, m2_z ])
        rotate([90,0,0]) cylinder(h = back_depth + 2, d = ard_hole_d, center=false);
      // head recess in back wall
      translate([ m2_x, back_depth - wall + 0.05, m2_z ])
        rotate([90,0,0]) cylinder(h = wall + 0.2, d = m2_head_d, center=false);
    }

    // --- M2 mounting holes for ToF board ---
    // Similar holes for the ToF module.  The hole pitch and clearance
    // diameter can be adjusted via `tof_hole_pitch` and `tof_hole_d`.
    for (sx = [-1, 1]) for (sz = [-1, 1]) {
      tof_x = tof_center_x + sx * (tof_hole_pitch / 2);
      tof_z = tof_center_z + sz * (tof_hole_pitch / 2);
      translate([ tof_x, back_depth - 0.1, tof_z ])
        rotate([90,0,0]) cylinder(h = back_depth + 2, d = tof_hole_d, center=false);
      translate([ tof_x, back_depth - wall + 0.05, tof_z ])
        rotate([90,0,0]) cylinder(h = wall + 0.2, d = m2_head_d, center=false);
    }
  }

  // --- Standoff posts for Arducam and ToF boards ---
  // The posts extend from the rear of each board to the interior face of
  // the back wall.  Screws inserted from the outside thread into
  // these posts, clamping the boards in place.
  // Calculate post heights based on board depth and interior depth.
  ard_post_start_y = front_clearance + ard_depth;
  ard_post_h       = (back_depth - wall) - ard_post_start_y;
  tof_post_start_y = front_clearance + tof_depth;
  tof_post_h       = (back_depth - wall) - tof_post_start_y;

  // Arducam standoffs
  for (sx = [-1, 1]) for (sz = [-1, 1]) {
    post_x = ard_center_x + sx * (ard_hole_pitch / 2);
    post_z = ard_center_z + sz * (ard_hole_pitch / 2);
    translate([ post_x, ard_post_start_y, post_z ]) {
      difference() {
        // outer post
        rotate([-90,0,0]) cylinder(h = ard_post_h + 0.5, d = standoff_d, center=false);
        // inner hole for M2 screw (clearance) – same diameter as board hole
        rotate([-90,0,0]) cylinder(h = ard_post_h + 0.5, d = ard_hole_d, center=false);
      }
    }
  }

  // ToF standoffs
  for (sx = [-1, 1]) for (sz = [-1, 1]) {
    post_x = tof_center_x + sx * (tof_hole_pitch / 2);
    post_z = tof_center_z + sz * (tof_hole_pitch / 2);
    translate([ post_x, tof_post_start_y, post_z ]) {
      difference() {
        rotate([-90,0,0]) cylinder(h = tof_post_h + 0.5, d = standoff_d, center=false);
        rotate([-90,0,0]) cylinder(h = tof_post_h + 0.5, d = tof_hole_d, center=false);
      }
    }
  }
}

// ------------------------------------------------------------------------
// Render selected part
// Set `part` to "front" or "back" to render that half; use "both" to
// preview both halves together (front separated along y).
part = "both";

if (part == "front") {
  front_panel();
} else if (part == "back") {
  back_housing();
} else if (part == "both") {
  front_panel();
  translate([0, back_depth + 10.0, 0]) back_housing();
}
