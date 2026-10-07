use <../core/core.scad>;

module platform_grid(
    dims, 
    grid_spacing,
    magnet_dims,
    magnet_size,
    makerbeam,
    grid_layout = "max", // "max", "4x4", "4x2", etc.
    top_magnets=false,
) {
    corner_height = magnet_size[1] + 3;
    magnet_dims_actual = [magnet_dims[0], magnet_dims[1], corner_height];
    
    dimsA = [dims[0]-makerbeam-1, dims[1]+makerbeam, corner_height];

    // Calculate grid size based on layout
    margin = 15;
    safe_x = magnet_dims[0] - margin;
    safe_y = magnet_dims[1] - margin;
    
    // Parse grid_layout
    grid_x = grid_layout == "max" 
        ? floor(safe_x / grid_spacing) + 1
        : search("x", grid_layout) == [[]] 
            ? 4  // fallback if parsing fails
            : let(parts = [for (i = [0:len(grid_layout)-1]) grid_layout[i]])
              let(x_pos = search(["x"], parts)[0])
              let(before_x = [for (i = [0:x_pos-1]) parts[i]])
              atoi(before_x);
    
    grid_y = grid_layout == "max" 
        ? floor(safe_y / grid_spacing) + 1
        : search("x", grid_layout) == [[]] 
            ? 4  // fallback
            : let(parts = [for (i = [0:len(grid_layout)-1]) grid_layout[i]])
              let(x_pos = search(["x"], parts)[0])
              let(after_x = [for (i = [x_pos+1:len(parts)-1]) parts[i]])
              atoi(after_x);
    
    // Use grid_spacing directly, center the grid
    total_span_x = (grid_x - 1) * grid_spacing;
    total_span_y = (grid_y - 1) * grid_spacing;
    
    offset_x = -total_span_x / 2;
    offset_y = -total_span_y / 2;
    
    beam_width = 3; // Width of connecting beams

    difference(){
        union(){
            
            // Plate base (frame)
            difference(){
                rounded_cube(dimsA, makerbeam/2, true);
                rounded_cube([dimsA[0]-10, dimsA[1] - 10, dimsA[2]+2], makerbeam/2, true);
            }

            // Magnet holders in corners
            corners(magnet_dims_actual, makerbeam);
            mirror([1,0,0]) corners(magnet_dims_actual, makerbeam);
            
            // Horizontal beams (connecting each row) - full width
            for (j = [0:grid_y-1]) {
                translate([0, offset_y + j*grid_spacing, 0])
                    cube([dimsA[0], beam_width, corner_height], center=true);
            }
            
            // Vertical beams (connecting each column) - full length
            for (i = [0:grid_x-1]) {
                translate([offset_x + i*grid_spacing, 0, 0])
                    cube([beam_width, dimsA[1], corner_height], center=true);
            }
            
            // Grid of rounded cubes at intersections
            for (i = [0:grid_x-1]) {
                for (j = [0:grid_y-1]) {
                    translate([offset_x + i*grid_spacing, offset_y + j*grid_spacing, 0])
                        rounded_cube(
                            dims = [makerbeam, makerbeam, corner_height],
                            radius = 2,
                            outside = true
                        );
                }
            }
        }
               
        // Corner magnets for scaffold connection (bottom)
        translate([0, 0, -corner_height/2]){
            magnets2([magnet_dims[0], magnet_dims[1], magnet_size[1]+2], magnet_size, 3);
            mirror([1,0,0]) magnets2([magnet_dims[0], magnet_dims[1], magnet_size[1]+2], magnet_size, 3);
        }
        
        if (top_magnets == true){
            translate([0, 0, corner_height/2 - magnet_size[1]]){
                magnets2(magnet_dims_actual, magnet_size, 3);
                mirror([1,0,0]) magnets2(magnet_dims_actual, magnet_size, 3);
            }
        }

        // Grid magnet holes at intersections (TOP)
        translate([0, 0, corner_height/2 - magnet_size[1]]) {
            for (i = [0:grid_x-1]) {
                for (j = [0:grid_y-1]) {
                    translate([offset_x + i*grid_spacing, offset_y + j*grid_spacing, 0])
                        cylinder(h=magnet_size[1], d=magnet_size[0]);
                }
            }
        }
    }
}