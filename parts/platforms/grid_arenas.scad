use <../core/core.scad>;
module grid_box_scaffold(
    makerbeam_spacing = 85,
    magnet_spacing = 100,
    magnet_size = [5, 3],
    makerbeam = 10,
    bolt_diam = 3
) {
    corner_height = magnet_size[1] + 2; // Full height for corners
    makerbeam_dims = [makerbeam_spacing, makerbeam_spacing, corner_height];
    magnet_dims = [magnet_spacing, magnet_spacing, corner_height];
    diff_dims_pre = magnet_dims - makerbeam_dims;
    diff_dims = [diff_dims_pre[0]/2, diff_dims_pre[1]/2, diff_dims_pre[2]]; 

    beam_height = 2; // Just the visible lip height
    beam_width = 5;
    $fn = 60;
    
    difference(){
        union(){
            // Corner holders
            for (i=[-1,1]) {
                translate([makerbeam_dims[0]/2,i*makerbeam_dims[1]/2,-corner_height/2])
                hull(){
                    rounded_cube(
                        dims = [makerbeam, makerbeam, makerbeam_dims[2]],
                        radius = 2,
                        outside = true
                        );
                    translate([diff_dims[0], i*diff_dims[1], 0])
                    rounded_cube(
                        dims = [makerbeam, makerbeam, magnet_dims[2]],
                        radius = 2,
                        outside = true
                        );
                }
            }
            mirror([1,0,0])
            for (i=[-1,1]) {
                translate([makerbeam_dims[0]/2,i*makerbeam_dims[1]/2,-corner_height/2])
                hull(){
                    rounded_cube(
                        dims = [makerbeam, makerbeam, makerbeam_dims[2]],
                        radius = 2,
                        outside = true
                        );
                    translate([diff_dims[0], i*diff_dims[1], 0])
                    rounded_cube(
                        dims = [makerbeam, makerbeam, magnet_dims[2]],
                        radius = 2,
                        outside = true
                        );
                }
            }

            // // Corner magnet
            // translate([0, 0, -(makerbeam_dims[2] - magnet_dims[2])/2])
            // corners(magnet_dims, makerbeam);
            // mirror([1,0,0]) corners(magnet_dims, makerbeam);
            
            // Horizontal beams connecting corners - match visible corner height
            for (j = [-1, 1]) {
                translate([0, j * makerbeam_spacing/2, -corner_height + beam_height /2])
                    cube([makerbeam_spacing, beam_width, beam_height], center=true);
            }
            
            // Vertical beams connecting corners - match visible corner height
            for (i = [-1, 1]) {
                translate([i * makerbeam_spacing/2, 0, -corner_height + beam_height /2])
                    cube([beam_width, makerbeam_spacing, beam_height], center=true);
            }
        }
        
        // Bolt holes for Makerbeam attachment
        translate([0,0,-corner_height/2]){
            corners_hollow(makerbeam_dims, makerbeam, bolt_diam);
            mirror([1,0,0]) corners_hollow(makerbeam_dims, makerbeam, bolt_diam);
        }

        translate([0,0,-corner_height]){
            magnets2(dims = magnet_dims, magnet_size = magnet_size);
            mirror([1,0,0]) magnets2(dims = magnet_dims, magnet_size = magnet_size);
        }
    }
}

// module grid_box_scaffold(
//     box_height = 50,
//     makerbeam_spacing = 85,
//     magnet_size = [5, 3],
//     makerbeam = 10
// ) {
//     beam_height = magnet_size[1] + 3;
//     magnet_dims = [makerbeam_spacing, makerbeam_spacing, box_height];
    
//     beam_width = 3;
//     side_thickness = 3.2;
    
//     difference(){
//         union(){
//             // Magnet holders in corners
//             difference(){
//                 translate([0,0,box_height / 2 - beam_height / 2]){
//                     corners(magnet_dims, makerbeam);
//                     mirror([1,0,0]) corners(magnet_dims, makerbeam);
//                 }

//                 // Slits for side elements
//                 // Horizontal beams connecting corners
//                 for (j = [-1, 1]) {
//                     #translate([0, j * makerbeam_spacing/2, box_height / 2])
//                         cube([makerbeam_spacing - 5, side_thickness, box_height], center=true);
//                 }
                
//                 // Vertical beams connecting corners
//                 for (i = [-1, 1]) {
//                     #translate([i * makerbeam_spacing/2, 0, box_height / 2])
//                         cube([side_thickness, makerbeam_spacing - 5, box_height], center=true);
//                 }
//             }
            
//             // Horizontal beams connecting corners
//             for (j = [-1, 1]) {
//                 translate([0, j * makerbeam_spacing/2, 0])
//                     cube([makerbeam_spacing, beam_width, beam_height], center=true);
//             }
            
//             // Vertical beams connecting corners
//             for (i = [-1, 1]) {
//                 translate([i * makerbeam_spacing/2, 0, 0])
//                     cube([beam_width, makerbeam_spacing, beam_height], center=true);
//             }
//         }
        
//         // Downward-facing magnets at bottom of each corner
//         translate([0, 0, -beam_height / 2 ]){
//             magnets2([makerbeam_spacing, makerbeam_spacing, magnet_size[1]+2], magnet_size, 3);
//             mirror([1,0,0]) magnets2([makerbeam_spacing, makerbeam_spacing, magnet_size[1]+2], magnet_size, 3);
//         }
//     }
// }