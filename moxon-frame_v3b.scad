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
freq_mhz = 868;
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

/* [WIRE CHANNEL] */
// Wire clearance tolerance (mm) for 3D-printing
wire_tolerance = 0.1;
// Channel depth as fraction of wire diameter
wire_depth_ratio = 0.66;

/* [HANDLE & MOUNTING] */
// Handle length (mm) - set to 0 to disable
handle_length = 60;
// Handle width (mm)
handle_width = 21;

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
coax_routing_gap_width = 8;
coax_routing_gap_extra_length = 10;

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

//
eps = .01;

// END SECTION: calculations

// SECTION: 3d model generation
// SECTION: general shape helpers

// all 4 non-z-plane edges rounded cuboid
module zrrect(size, corner_radius = corner_radius) {
  cuboid(size, rounding=max(corner_radius, 0), edges=[LEFT + FRONT, LEFT + BACK, RIGHT + FRONT, RIGHT + BACK]);
}

module rrect_ring(width, height, radius, corner_radius = corner_radius) {
  path = rect([width, height], rounding=corner_radius, $fn=16);
  path_extrude2d(path, closed=true) circle(radius, $fn=8);
}

// END SECTION: general shape helpers

module antenna_gap_cutout() {
  _cutout_width = 3 + wire_channel_dia;
  zrrect([frame_width * 2 + _cutout_width, frame_width * 2 + gap_length, frame_thickness], corner_radius=2);
  tag("remove") zrrect([_cutout_width, gap_length, frame_thickness + 5 * eps]);
}

module main_frame() {
  zrrect([width + frame_width, height + frame_width, frame_thickness], corner_radius + frame_width / 2);
  tag("remove") zrrect([width - frame_width, height - frame_width, frame_thickness + eps], corner_radius - frame_width / 2);
}

module wire_channel() {
  tag("remove") rrect_ring(width, height, wire_channel_dia / 2);
}

module antenna() {
  diff() {
    main_frame();
	// I dont know why, but rendering here, speeds up things DRAMATICALLY
    render() up((frame_thickness- wire_depth) / 2) wire_channel();
    xflip_copy() {
      left(width / 2) back(gap_offset_from_center) antenna_gap_cutout();
    }
  }
}

antenna();

// selected_connector_negative(connector = connector, thickness = frame_thickness, screw_type = screw_type);
