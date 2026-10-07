use <../core/core.scad>;
use <../misc/misc.scad>;

module grid_box_floor(
    magnet_spacing = 85,
    makerbeam = 10,
    bolt_diam = 3,
    thickness = 1,
    corner_radius = 3
) {
    floor_size = magnet_spacing + makerbeam;

    difference() {
        // Solid rounded floor plate
        translate([0, 0, -makerbeam/2 + thickness/2])
            rounded_cube([floor_size, floor_size, thickness], corner_radius, outside = true);

        // Bolt holes at four corners
        for (i = [-1, 1]) {
            for (j = [-1, 1]) {
                translate([i * magnet_spacing/2, j * magnet_spacing/2, 0])
                cylinder(d=bolt_diam, h=makerbeam + 1, center=true, $fn=24);
            }
        }
    }
}

module grid_box_wall_basic(
    makerbeam_spacing = 85,
    box_height = 60,
    makerbeam = 10,
    wall_thickness = 2.5
) {
    wall_width = makerbeam_spacing - 2 * 2; // mm

    cube([wall_width, box_height, wall_thickness], center = true);
}


module grid_box_wall_fan(
    makerbeam_spacing = 85,
    box_height = 60,
    makerbeam = 10,
    wall_thickness = 2.5,
    fan_dims = [40, 10, 40],
    h_align = "center", // "left", "center", "right"
    v_align = "top",    // "top", "center", "bottom"
    fan_margin = 0
) {
    wall_width = makerbeam_spacing - 2 * 2;

    // Fan holder outside dimensions (from fan_holder module)
    fe = 1;
    fan_outer_w = fan_dims[0] + wall_thickness * 2 + fe * 2;
    fan_outer_d = fan_dims[1] + wall_thickness * 2 + fe * 2;
    fan_outer_h = fan_dims[2] + wall_thickness + fe;

    h_offset =
        h_align == "left"  ? -(wall_width/2 - fan_outer_w/2 - fan_margin) :
        h_align == "right" ?  (wall_width/2 - fan_outer_w/2 - fan_margin) :
        0;

    v_offset =
        v_align == "top"    ?  (box_height/2 - fan_outer_h/2 - fan_margin) :
        v_align == "bottom" ? -(box_height/2 - fan_outer_h/2 - fan_margin) :
        0;

    // Base wall with airflow cutout
    difference() {
        cube([wall_width, wall_thickness, box_height], center = true);

        translate([h_offset, 0, v_offset])
            cube(fan_dims, center = true);
    }

    // Fan holder
    translate([h_offset, -fan_outer_d / 2 + wall_thickness / 2, v_offset])
        fan_holder(fan_dims, wall_thickness = wall_thickness);
}