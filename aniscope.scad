// -------------------------------- //
// ----- Import dependencies ------ //
// -------------------------------- //

use <parts/core/core.scad>;
use <parts/adapters/adapters.scad>;
use <parts/platforms/platforms.scad>;
use <parts/frame/frame.scad>;
use <parts/frame/platform_adapter.scad>;
use <parts/misc/misc.scad>;


// -------------------------------- //
// ---------- Variables ----------- //
// -------------------------------- //

$fn = $preview ? 60 : 60;

/* [Assembly] */
// Which part to render?
part = "frame"; // [frame: Frame, platform_adapter: Platform adapter, platform_mount: Platform mount, platform_empty: Platform (empty), platform_diffuser: Platform (diffuser), platform_tubes: Platform (tubes), platform_petri: Platform (Petri dishes), platform_wellplate: Platform (wellplate), platform_grid: Platform (grid), grid_box_scaffold: Grid box scaffold, x_mount: X-mount, adapter_empty: Adapter empty, cam_adapter: Adapter camera, cam_adapter_elp: Adapter camera (ELP), adapter_breakoutgarden: Adapter Breakout Garden, adapter_neopixel: Adapter Neopixel, adapter_neopixel_lid: Adapter Neopixel lid, tube_plug: Tube plug, tube_floor: Tube floor]

// What is a tube insert?

/* [Frame] */
// Ethoscope dimensions (length, width, height)
dims = [160,160,15]; //normal length
// Thickness of the wall
wall_thick = 8; 
// Which T-slots are used?
makerbeam = 10.2; // [10.2: Makerbeam, 15.2: MakerbeamXL]
// Magnet size (diameter, height)
magnet_size = [6,3];
magnet_size_corrected = magnet_size_correct(magnet_size);
// Floor type
frame_floor_type = "none"; // [none: None, hex: Hex, x: X-mount]

/* [Platform dimensions] */
// Dimensions, preference chamber (diameter, height, gap width)
chamber_dims = [100,20,20]; 
// Dimensions, wellplate (length, width, height)
wellplate_dims = [127.63,85.47,2]; 
// Dimensions, glass tubes (outer diameter, length)
glass_tube_dims = [20.5, 130];

/* [Grid Box] */
// Grid box height
box_height = 50;
// Grid box magnet spacing
box_magnet_spacing = 100;
// Grid box panel thickness
box_panel_thickness = 3;

/* [Camera] */
// Number of cameras
n_cams = 2; // [1:1:2]
// Type of camera
Camera_type = "usb"; // [usb: USB, rpi: Raspberry Pi]
// Camera bolt diameter
Camera_screw = 2; // Bolt used to attach cameras
// Magnet placement on adapter
adapter_magnet_orientation = "bottom"; // [bottom: Bottom, top: Top]
// Diameter of hole for lens (0 for no hole)
lens_hole_diam = 0; // [0:1:30]

/* [Acrylic tubes] */
// Dimensions, acrylic tubes (outer diameter, thickness, length)
acrylic_tube_dims = [30, 2, 100]; 
// O-ring diameter
o_ring_diam = 2.5; // Diameter of the O-ring
o_ring_dims = [acrylic_tube_dims[0], o_ring_diam];
// Type of tube plug
tube_plug = "flush"; // [flush: Flush, funnel: Funneled, with_floor: With floor, with_anchor: With anchor-point]
// Plug: Hose connector thread (diameter)
hose_connector_d = 10; 
// Plug: Hose connector position
connector_position = "end"; // [end: End of tube, side: Side of tube]

/* [Petri dishes] */
// Dimensions of Petri dishes (diameter, height)
petri_dish_dims = [60, 20];

/* [Misc] */
// NeoPixel diffuser
lid_thickness = 10;
// Misc for visualization
beam_height = 300;
// Target diameter
target_diam = 7;

/* [Hidden] */
light_chamber_dims = [dims[0],dims[1],40];
platform_dims = [dims[0],dims[1],3];
magnet_dims = [dims[0]-25,dims[1],magnet_size_corrected[1]];
x_mount_dims = [dims[0]-25,dims[1], magnet_size_corrected[1]*2 + wall_thick/2];
adapter_magnet_dims = [50,50,magnet_size_corrected[1]*2+wall_thick]; // Size of the mount
primary_bolt = 3; // Bolt used in MakerBeams
usb_hole_distances = [
    ["rpi", [21,13.5]],
    ["usb", [28,28]]
]; // USB: [28,28] - RPi: [21,13.5];
adapter_hole_positions = selector(Camera_type, usb_hole_distances);
pos_holes = get_points(adapter_hole_positions[1]);

// Hidden tube params
// Parameters: [with_funnel, with_floor, with_anchor]
tube_parameters = [
    ["flush", [false,false,false]], 
    ["funnel", [true,false,false]],
    ["with_floor", [true,true,false]],
    ["with_anchor", [false,false,true]]
]; 
// Plug: Carve out funnel?
include_funnel = selector(tube_plug, tube_parameters)[1][0];
// Plug: Include space for floor (only works with funnel)
include_floor = selector(tube_plug, tube_parameters)[1][1];
// Plug: Include space for floor (only works with funnel)
include_anchor = selector(tube_plug, tube_parameters)[1][2];

// -------------------------------- //
// --------- Compile model -------- //
// -------------------------------- //

print_part();

// We create a loooooong function that enables us to create all our models from the customizer.
module print_part() {
    // Base without floor
	if (part == "frame") {
        frame(
            dims = dims, 
            magnet_pos = magnet_dims, 
            makerbeam = makerbeam, 
            wall_type = "hex",
            wall_thick = wall_thick, 
            magnet_size = magnet_size_corrected, 
            bolt_diam = primary_bolt,
            floor_type = frame_floor_type,
            floor_thick = 2,
            adapter_magnet_dims = adapter_magnet_dims
        );
    } else if (part == "platform_adapter") {
        rotate([180,0,0])
        platform_adapter(
            dims = dims, 
            magnet_pos = magnet_dims, 
            makerbeam = makerbeam, 
            wall_type = "hex",
            wall_thick = wall_thick, 
            magnet_size = magnet_size_corrected, 
            bolt_diam = primary_bolt,
            adapter_magnet_dims = adapter_magnet_dims
        );
	} else if (part == "platform_mount") {
        platform_mount(
            makerbeam = makerbeam,
            magnet_size = magnet_size_corrected,
            wall_thick = 3,
            bolt_diam = primary_bolt
        );
    } else if (part == "platform_empty") {
        platform_empty(
            dims = platform_dims, 
            magnet_dims = magnet_dims,
            magnet_size = magnet_size_corrected,
            makerbeam = makerbeam,
            top_magnets = false
        );
	} else if (part == "platform_diffuser") {
        platform_diffuser(
            dims = platform_dims, 
            magnet_dims = magnet_dims,
            magnet_size = magnet_size_corrected,
            makerbeam = makerbeam
        );
	} else if (part == "platform_tubes") {
		platform_tubes(
            dims = platform_dims, 
            magnet_dims = magnet_dims, 
            magnet_size = magnet_size_corrected, 
            tube_dims = acrylic_tube_dims,
            o_ring_dims = o_ring_dims,
            makerbeam = makerbeam
        );
    } else if (part == "platform_wellplate") {
        platform_wellplate(
            dims = platform_dims, 
            magnet_dims = magnet_dims, 
            wellplate_dims = wellplate_dims,
            magnet_size = magnet_size_corrected, 
            makerbeam = makerbeam
        );
    } else if (part == "platform_petri") {
		platform_petri(
            dims = platform_dims, 
            magnet_dims = magnet_dims, 
            magnet_size = magnet_size_corrected, 
            makerbeam = makerbeam,
            dish_dims = petri_dish_dims
        );
    } else if (part == "platform_grid") {
        platform_grid(
            dims = platform_dims, 
            grid_spacing = box_magnet_spacing,
            grid_layout = "2x2",
            magnet_dims = magnet_dims, 
            magnet_size = magnet_size_corrected,
            makerbeam = makerbeam,
            top_magnets = false
        );
    } else if (part == "grid_box_scaffold") {
        grid_box_scaffold(
            magnet_spacing = box_magnet_spacing,
            magnet_size = magnet_size_corrected,
            makerbeam = makerbeam,
            bolt_diam = primary_bolt
        );
    } else if (part == "x_mount") {
        x_mount(
            dims = x_mount_dims,
            makerbeam = makerbeam,
            wall_thick = 6, 
            magnet_size = magnet_size_corrected,
            adapter_magnet_dims = adapter_magnet_dims
        );
    } else if (part == "adapter_empty") {
        adapter_empty(
            n=1,
            dims = magnet_dims,
            makerbeam = makerbeam,
            wall_thick = 3,
            magnet_pos = adapter_magnet_orientation,
            magnet_size = magnet_size_corrected, 
            adapter_magnet_dims = adapter_magnet_dims
        );
    } else if (part == "cam_adapter") {
        adapter_usb_cam(
            n_cams = n_cams,
            dims = magnet_dims,
            makerbeam = makerbeam,
            wall_thick = 3, 
            magnet_pos = adapter_magnet_orientation,
            magnet_size = magnet_size_corrected,
            bolt_diam = 2.5,
            adapter_magnet_dims = adapter_magnet_dims,
            usb_hole_positions = pos_holes,
            lens_hole_diam = lens_hole_diam
            );
    } else if (part == "cam_adapter_elp") {
        adapter_usb_elp(
            n_cams = n_cams,
            dims = magnet_dims,
            makerbeam = makerbeam,
            wall_thick = 3, 
            magnet_pos = adapter_magnet_orientation,
            magnet_size = magnet_size_corrected,
            adapter_magnet_dims = adapter_magnet_dims,
            );
    } else if (part == "adapter_breakoutgarden") {
        adapter_breakoutgarden(
            dims = magnet_dims,
            makerbeam = makerbeam,
            wall_thick = 3,
            magnet_pos = adapter_magnet_orientation,
            magnet_size = magnet_size_corrected, 
            adapter_magnet_dims = adapter_magnet_dims
        );
	} else if (part=="adapter_neopixel") {
        adapter_neopixel(
            dims = magnet_dims,
            makerbeam=10,
            wall_thick=3,
            magnet_pos="bottom",
            magnet_size = magnet_size_corrected, 
            adapter_magnet_dims = adapter_magnet_dims, 
            bolt_diam = 2.5,
            neopixel_diam = 60
        );
    } else if (part=="adapter_neopixel_lid") {
        adapter_neopixel_lid(
            lid_thickness,
            magnet_size = magnet_size_corrected,
            wall_thick
        );
    } else if (part=="tube_plug") {
        tube_plug(
            connector_position = connector_position, 
            include_floor = include_floor,
            include_funnel = include_funnel,
            include_anchor = include_anchor,
            inner_d = acrylic_tube_dims[0]-2*acrylic_tube_dims[1], 
            outer_d = acrylic_tube_dims[0], 
            o_ring_d = o_ring_diam,
            magnet_size = magnet_size_corrected,
            hose_connector_d = hose_connector_d
        );
    } else if (part=="tube_floor") {
        tube_floor(
            chamber_length = acrylic_tube_dims[2],
            inner_d1 = acrylic_tube_dims[0] - 2 * acrylic_tube_dims[1],
            inner_d2 = acrylic_tube_dims[0] - 2 * acrylic_tube_dims[1]
        );
    }
}