// "Self-calculating Moxon antenna frame generator"
// Original idea: https://www.thingiverse.com/thing:2068392
// Based on empirical formulas by L.B. Cebik (W4RNL)
// https://www.antenna2.net/cebik/books/Moxon-Rectangle-Notes.pdf
// 2025 DO2THX (tom@jitter.eu)
// License: CC-BY-NC-SA

include <dependencies/BOSL2/std.scad>;
include <connectors.scad>;
include <calculations.scad>;

// SECTION: user adjustable parameters

/* [BASIC ANTENNA DESIGN] */
// Design frequency in MHz
freq_mhz = 433;
// Wire diameter in mm
wire_dia = 0.5;

/* [MATERIAL PROPERTIES] */
correction_factor = 1.1;

/* [FRAME CONSTRUCTION] */
// Frame wall thickness (mm)
frame_width = 4.0;
// Frame height/thickness (mm)
frame_thickness = 1.5;
// Corner rounding radius (mm)
corner_radius = 1.0;
// enable cross-beams for extra stability
enable_cross_beams = true;

/* [WIRE CHANNEL] */
// Wire clearance tolerance (mm) for 3D-printing
wire_tolerance = 0.1;
// Channel depth as fraction of wire diameter
wire_depth_ratio = 0.66;

/* [HANDLE & MOUNTING] */
// Handle (offset between mount-point and antenna)
handle_length = 30;
// Handle width (mm), this should coincide with the required mounting width
handle_width = 21;
// mounting direction
mounting_direction = "flat"; // ["flat", "up", "forward"]

/* [CONNECTOR] */
// RF connector type (see README)
connector = "bnc"; // ["none", "sma", "sma2", "bnc", "bnc2", "screw"]
// Screw diameter (mm) - for screw connector type
screw_type = "M3";

/* [APPEARANCE] */
// Frequency label text size (mm)
text_size = 7;
// Text font
text_font = "Liberation Sans:style=Bold";
// Show frequency label on handle
show_frequency_text = true;

/* [RENDERING QUALITY] */
// Circle resolution - higher values = smoother curves but slower rendering
$fn = 64;

/* [COAX ROUTING] */

coax_diameter = 5;

coax_solder_space_width = 12;
coax_routing_gap_width = 6;
coax_routing_gap_extra_length = 10;

include_coax_clamp = true;

// END SECTION: user adjustable parameters

// SECTION: calculations

/* [Hidden] */

// Calculate the actual dimensions
calc_result = moxon_calculate_dimensions(freq_mhz * correction_factor, wire_dia);

width = calc_result[IDX_WIDTH];
driver_tail_length = calc_result[IDX_DRIVER_TAIL_LENGTH];
gap_length = calc_result[IDX_GAP_LENGTH];
reflector_tail_length = calc_result[IDX_REFLECTOR_TAIL_LENGTH];
height = calc_result[IDX_HEIGHT];

wavelength = calc_result[IDX_WAVELENGTH];
diameter_valid = calc_result[IDX_DIAMETER_VALID];
boom_length_wavelengths = calc_result[IDX_BOOM_LENGTH_WAVELENGTHS];
wire_length = calc_result[IDX_WIRE_LENGTH_MM];
compactness_factor = calc_result[IDX_COMPACTNESS_FACTOR];

// derived helper variables

// Wire channel parameters
wire_channel_dia = wire_dia + wire_tolerance; // Add tolerance for 3D printing
wire_depth = wire_dia * wire_depth_ratio;

gap_offset_from_center = (reflector_tail_length - driver_tail_length) / 2;

coax_bay_width = coax_diameter + frame_thickness * 2;

//
eps = .01;

// END SECTION: calculations

// SECTION: 3d model generation
// SECTION: general shape helpers

// all 4 non-z-plane edges rounded cuboid
module zrrect(size, corner_radius = corner_radius) {
  cuboid(size, rounding=max(corner_radius, 0), edges=[LEFT + FRONT, LEFT + BACK, RIGHT + FRONT, RIGHT + BACK]) children();
}

module rrect_ring(width, height, radius, corner_radius = corner_radius) {
  path = rect([width, height], rounding=corner_radius, $fn=16);
  path_extrude2d(path, closed=true) circle(radius, $fn=8);
}

// END SECTION: general shape helpers

// SECTION: handle

module attach_handle() {
  if (mounting_direction == "flat") {
    attach(TOP, BOTTOM) children();
  } else if (mounting_direction == "up") {
    attach(BACK, BOTTOM, align=TOP) children();
  } else if (mounting_direction == "forward") {
    attach(BACK, BOTTOM, align=RIGHT+TOP, spin=90) children();
  } else {
    echo("Invalid mounting direction");
  }
}

module handle() {
  cuboid([handle_width, frame_thickness, handle_length], rounding=-5, edges=[BOTTOM + RIGHT, BOTTOM + LEFT])
    attach_handle()
      cuboid([handle_width, frame_thickness, handle_width], rounding=5, edges=[UP + RIGHT, UP + LEFT])
        attach(FWD, BOTTOM, inside=true, shiftout=eps / 2)
          tag("remove") selected_connector_negative(connector=connector, thickness=frame_thickness + eps, screw_type=screw_type);
}

// END SECTION: handle

// SECTION: antenna

module antenna_gap_cutout() {
  _cutout_width = 3 + wire_channel_dia;
  zrrect([frame_width * 2 + _cutout_width, frame_width * 2 + gap_length, frame_thickness], corner_radius=2);
  tag("remove") zrrect([_cutout_width, gap_length, frame_thickness + 5 * eps]);
}

module main_frame() {
  difference() {
    zrrect([width + frame_width, height + frame_width, frame_thickness], corner_radius + frame_width / 2) children();
    zrrect([width - frame_width, height - frame_width, frame_thickness + eps], corner_radius - frame_width / 2);
  }

  if (enable_cross_beams) {
    // calculate inner square dimensions
    inner_height = height - frame_width;
    inner_width = (width - frame_width - coax_bay_width) / 2;

    inner_length = sqrt(inner_height ^ 2 + inner_width ^ 2);
    xflip_copy() yflip_copy()
        left(inner_width / 2 + coax_bay_width / 2) cuboid([inner_length + eps, frame_width, frame_thickness], spin=atan2(inner_height, inner_width));
  }
}

module wire_channel() {
  tag("remove") rrect_ring(width, height, wire_channel_dia / 2);
}

module coax_routing() {
  // top notches for easier wire routing
  back(height / 2) {
    zrrect([coax_solder_space_width + frame_width * 2, coax_solder_space_width + frame_width * 2, frame_thickness], corner_radius);
    tag_this("remove") zrrect([coax_solder_space_width, coax_solder_space_width, frame_thickness + eps], corner_radius)
        align(FWD, shiftout=-eps) {
          zrrect([coax_routing_gap_width + frame_width * 2, coax_routing_gap_extra_length + frame_width, frame_thickness], corner_radius);
          tag_this("remove") cuboid([coax_routing_gap_width, coax_routing_gap_extra_length, frame_thickness + eps], rounding=max(corner_radius, 0), edges=[LEFT + FRONT, RIGHT + FRONT]) children();;
        }
  }
  // plate until end of frame
  cuboid([coax_diameter + frame_thickness * 2, height, frame_thickness]) align(TOP) {
      if (include_coax_clamp) {
        top_offset = coax_routing_gap_extra_length + coax_solder_space_width / 2 + frame_width;
        length = height - frame_width / 2 - top_offset;
        fwd(top_offset / 2 - frame_width) {
          stick_height = coax_diameter / 4;
          cuboid([coax_bay_width, length, coax_diameter * 3 / 4]) {
            align(TOP, LEFT) prismoid(size1=[frame_thickness, length], size2=[frame_thickness, length], h=stick_height, shift=[stick_height, 0]);
            align(TOP, RIGHT) prismoid(size1=[frame_thickness, length], size2=[frame_thickness, length], h=stick_height, shift=[-stick_height, 0]);
          }
          tag("remove") cuboid([coax_diameter, length + eps, coax_diameter * 3 / 4 + eps], rounding=coax_diameter / 2 - eps, edges=[BOTTOM + LEFT, BOTTOM + RIGHT]);
        }
      }
    }
}

module antenna() {
  diff() {
    main_frame() children();
    // I dont know why, but rendering here, speeds up things DRAMATICALLY
    render() up((frame_thickness - wire_depth) / 2) wire_channel();
    xflip_copy() {
      left(width / 2) back(gap_offset_from_center) antenna_gap_cutout();
    }
    coax_routing();
  }
}

// END SECTION: antenna

antenna()
  attach(FRONT, BOTTOM)
    handle();
