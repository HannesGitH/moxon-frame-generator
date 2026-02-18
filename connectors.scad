include <dependencies/BOSL2/screws.scad>;

module selected_connector_negative(connector, thickness, screw_type = "M3") {
  screw_hole_spec = str(screw_type, ",", thickness);
  if (connector == "sma") {
    sma_connector_negative(thickness, screw_hole_spec);
  }
  if (connector == "sma2") {
    sma2_connector_negative(thickness, screw_hole_spec);
  } else if (connector == "bnc") {
    bnc_connector_negative(thickness, screw_hole_spec);
  } else if (connector == "bnc2") {
    bnc_connector_no_holes_negative(thickness, screw_hole_spec);
  } else if (connector == "screw") {
    screw_negative(screw_hole_spec);
  }
}

// 2-hole SMA jack
module sma_connector_negative(thickness, screw_hole_spec) {
  cylinder(h=(thickness), r=4.5 / 2);
  left(6) screw_negative(screw_hole_spec);
  right(6) screw_negative(screw_hole_spec);
}

// holes for another SMA jack with recessed hex nut
module sma2_connector_negative(thickness, screw_hole_spec) {
  cylinder(h=(thickness), r=6.5 / 2);
  up(1) cylinder(h=(thickness), r=9.5 / 2, $fn=6);
}

// 4-hole BNC jack
module bnc_connector_negative(thickness, screw_hole_spec) {
  cylinder(h=thickness, r=9.2 / 2);
  for (x = [-6.35, 6.35]) {
    for (y = [-6.35, 6.35]) {
      translate([x, y, 0]) screw_negative(screw_hole_spec);
    }
  }
}

// another BNC jack (without mounting holes)
module bnc_connector_no_holes_negative(thickness, screw_hole_spec) {
  intersection() {
    cylinder(h=thickness, r=9.2 / 2);
    cuboid([1000, 8.2, 1000]);
  }
}

// just a screw hole
module screw_negative(screw_hole_spec) {
  screw_hole(screw_hole_spec, anchor=BOTTOM, thread=false, bevel=true);
}
