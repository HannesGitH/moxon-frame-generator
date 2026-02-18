// "Self-calculating Moxon antenna frame generator"
// Original idea: https://www.thingiverse.com/thing:2068392
// Based on empirical formulas by L.B. Cebik (W4RNL)
// https://www.antenna2.net/cebik/books/Moxon-Rectangle-Notes.pdf
// 2025 DO2THX (tom@jitter.eu)
// License: CC-BY-NC-SA

include <dependencies/BOSL2/std.scad>;
include <connectors.scad>;
include <calculations.scad>;

/* [USER ADJUSTABLE PARAMETERS] */

/* [BASIC ANTENNA DESIGN] */
// Design frequency in MHz
freq_mhz = 868;
// Wire diameter in mm
wire_dia_mm = 0.5;

/* [MATERIAL PROPERTIES] */
correction_factor = 1.1;

/* [FRAME CONSTRUCTION] */
// Frame wall thickness (mm)
frame_width = 4.0;
// Frame height/thickness (mm)
frame_thickness = 2.5;
// Corner rounding radius (mm)
corner_radius = 1.0;

/* [WIRE CHANNEL] */
// Wire clearance tolerance (mm) for 3D-printing
wire_tolerance = 0;
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

/* [Hidden] */

// Calculate the actual dimensions
calc_result = moxon_calculate_dimensions(freq_mhz * correction_factor, wire_dia_mm);

width = calc_result[IDX_WIDTH];
driver_tail_length = calc_result[IDX_DRIVER_TAIL_LENGTH];
gap_length = calc_result[IDX_GAP_LENGTH];
reflector_tail_length = calc_result[IDX_REFLECTOR_TAIL_LENGTH];
height = calc_result[IDX_HEIGHT];

wavelength = calc_result[IDX_WAVELENGTH];
diameter_valid = calc_result[IDX_DIAMETER_VALID];
boom_length_wavelengths = calc_result[IDX_BOOM_LENGTH_WAVELENGTHS];
wire_length_mm = calc_result[IDX_WIRE_LENGTH_MM];
compactness_factor = calc_result[IDX_COMPACTNESS_FACTOR];

// Wire channel parameters
wire_channel_dia = wire_dia_mm + wire_tolerance;	// Add tolerance for 3D printing
wire_depth = wire_dia_mm * wire_depth_ratio;


// ===== 3D MODEL GENERATION =====

selected_connector_negative(connector = connector, thickness = frame_thickness, screw_type = screw_type);