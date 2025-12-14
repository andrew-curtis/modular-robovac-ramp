// Robo-vac Rug Ramp - Modular Version

ramp_height = 18;                 // Height of the ramp surface (mm) - grip texture adds ~1mm
ramp_length = 100;                // Length of the ramp (mm)
ramp_width = 100;                 // Width of each modular section (mm)
ramp_thickness = 1;               // Thickness at the base of the ramp (mm)
texture_protrusion = -0.5;        // Offset perpendicular to ramp surface (mm)
top_fillet_radius = 8;            // Radius for rounded top edge (mm)

// Dovetail rendering options
enable_dovetails = true;           // Set to false to print a plain ramp with no dovetails
render_both_sides = true;         // true = both male and female, false = use dovetail_side
dovetail_side = "male";           // "male" or "female" - only used if render_both_sides = false

// Dovetail parameters (oriented along vertical edges running parallel to X-axis)
// Trapezoidal profile for self-tightening fit. 
// A trapeoid is used to render the dovetails. The middle of the trapeoid is aligned with the edge of the ramp body
// so that half the dovetail is inside the body and half protrudes outward.
// Dimensions are in mm. 
dovetail_trap_narrow = 8;         // Trapezoid (narrow end)
dovetail_trap_wide = 11.2;        // Trapezoid (wide end)
dovetail_trap_height = 8;         // Trapezoid Height (vertical, in Z direction)
dovetail_trap_depth = 8;          // Trapezoid depth - half inside body, half outside (mm)
dovetail_count = 3;               // Number of dovetails per side
dovetail_margin = 15;             // Minimum distance from front/back ends
tolerance = 0.1;                  // Clearance for male dovetails (total gap)

// Calculated values
ramp_rise = ramp_height;
ramp_angle = atan(ramp_rise / ramp_length);

// Actual surface angle after hull() operation modifies the top corner
// The hulled surface runs from [0, ramp_thickness] to [ramp_length - top_fillet_radius, ramp_rise]
actual_surface_angle = atan((ramp_rise - ramp_thickness) / (ramp_length - top_fillet_radius));

// Module to create a single dovetail (3D)
// Creates a dovetail using a trapezoidal profile in both +/- Y directions to ensure overlap with ramp body.
// i.e. the centre of the trapezoid is aligned with the edge of the ramp body.
module dovetail_3d(narrow, wide, depth, height, is_male=true) {
  offset_amount = is_male ? -tolerance/2 : tolerance/2;

  // Rotate to correct orientation and extrude along Z axis
  rotate([0, 0, 90])
    linear_extrude(height = height, center = false) {
      offset(offset_amount)
        polygon([
          [0, -narrow/2],      // Face at narrow end (left)
          [0, narrow/2],       // Face at narrow end (right)
          [depth, wide/2],     // Tip at wide end (right)
          [depth, -wide/2]     // Tip at wide end (left)
        ]);
    }
}

// Main ramp section
module ramp_section(width, add_dovetails=true, side="both") {
  // Clip everything below Z=0 (floor plane)
  difference() {
    union() {
      // Main ramp body
      difference() {
        union() {
          intersection() {
            rotate([90, 0, 0])
              linear_extrude(height = width, center = true)
                hull() {
                  // Main polygon without the top corner point
                  polygon(points = [
                    [0, 0],
                    [ramp_length, 0],
                    [ramp_length - top_fillet_radius, ramp_rise],
                    [0, ramp_thickness]
                  ]);

                  // Circle at the top corner for rounding
                  translate([ramp_length - top_fillet_radius, ramp_rise - top_fillet_radius])
                    circle(r = top_fillet_radius, $fn = 30);
                }

            // Clip to section width
            translate([ramp_length/2, 0, ramp_rise/2])
              cube([ramp_length*2, width, ramp_rise*2], center=true);
          }

          // Add male dovetails on +Y side (protruding outward)
          if (add_dovetails && (side == "male" || side == "both")) {
            echo("=== MALE DOVETAILS ===");
            echo("Body edge at Y =", width/2);
            echo("Dovetail starts at Y =", width/2 - dovetail_trap_depth/2);
            echo("Dovetail ends at Y =", width/2 + dovetail_trap_depth/2);
            echo("Inside body:", dovetail_trap_depth/2, "mm, Outside body:", dovetail_trap_depth/2, "mm");

            for (i = [0 : dovetail_count - 1]) {
              // Distribute dovetails evenly along X axis
              x_pos = dovetail_margin + i * ((ramp_length - 2*dovetail_margin) / (dovetail_count - 1));

              // Calculate ramp height at this X position
              z_at_pos = ramp_thickness + (ramp_rise - ramp_thickness) * (x_pos / ramp_length);

              // Calculate dovetail height: available height minus 3mm clearance from top
              dt_height = min(dovetail_trap_height, z_at_pos - 3);

              // Only render dovetail if height is at least 5mm
              if (dt_height >= 5) {
                // Position dovetail centered on body edge (half inside, half outside)
                translate([x_pos, width/2 - dovetail_trap_depth/2, 0])
                  dovetail_3d(dovetail_trap_narrow, dovetail_trap_wide, dovetail_trap_depth, dt_height, true);
              }
            }
          }
        }

        // Subtract female dovetails on -Y side
        if (add_dovetails && (side == "female" || side == "both")) {
          echo("=== FEMALE DOVETAILS ===");
          echo("Body edge at Y =", -width/2);
          echo("Dovetail starts at Y =", -width/2 - dovetail_trap_depth/2);
          echo("Dovetail ends at Y =", -width/2 + dovetail_trap_depth/2);
          echo("Cut depth into body:", dovetail_trap_depth/2, "mm, Space for male:", dovetail_trap_depth/2, "mm");

          for (i = [0 : dovetail_count - 1]) {
            // Distribute dovetails evenly along X axis
            x_pos = dovetail_margin + i * ((ramp_length - 2*dovetail_margin) / (dovetail_count - 1));

            // Calculate ramp height at this X position
            z_at_pos = ramp_thickness + (ramp_rise - ramp_thickness) * (x_pos / ramp_length);

            // Calculate dovetail height: available height minus 3mm clearance from top
            dt_height = min(dovetail_trap_height, z_at_pos - 3);

            // Only render dovetail if height is at least 5mm
            if (dt_height >= 5) {
              // Position female centered on body edge (matching male position)
              translate([x_pos, -width/2 - dovetail_trap_depth/2, 0])
                dovetail_3d(dovetail_trap_narrow, dovetail_trap_wide, dovetail_trap_depth, dt_height, false);
            }
          }
        }
      }

      // Grip texture
      for(x = [5 : 15 : ramp_length-5])
        for(y = [-width/2+10 : 20 : width/2-10]) {
          // Calculate position on actual hulled ramp surface
          // Two regions: straight ramp surface and curved fillet

          if (x <= ramp_length - top_fillet_radius) {
            // Straight section of ramp
            z_on_ramp = ramp_thickness + (ramp_rise - ramp_thickness) * (x / (ramp_length - top_fillet_radius));

            translate([
              x - texture_protrusion * sin(actual_surface_angle),
              y,
              z_on_ramp + texture_protrusion * cos(actual_surface_angle)
            ])
              rotate([90, actual_surface_angle, 0])
                cylinder(h=2, r=1.5, $fn=20);
          } else {
            // Curved fillet section - calculate position on circle
            // Circle center is at [ramp_length - top_fillet_radius, ramp_rise - top_fillet_radius]
            circle_center_x = ramp_length - top_fillet_radius;
            circle_center_z = ramp_rise - top_fillet_radius;

            // Distance from circle center along X axis
            dx = x - circle_center_x;

            // Calculate Z position on circle: z = center_z + sqrt(r^2 - dx^2)
            z_on_circle = circle_center_z + sqrt(top_fillet_radius * top_fillet_radius - dx * dx);

            // Calculate local surface angle on the circle
            // Tangent angle at this point on the circle
            local_angle = atan2(dx, sqrt(top_fillet_radius * top_fillet_radius - dx * dx));

            translate([
              x - texture_protrusion * sin(local_angle),
              y,
              z_on_circle + texture_protrusion * cos(local_angle)
            ])
              rotate([90, local_angle, 0])
                cylinder(h=2, r=1.5, $fn=20);
          }
        }
    }

    // Remove anything below the floor plane (Z < 0)
    translate([ramp_length/2, 0, -50])
      cube([ramp_length*2, width*2, 100], center=true);
  }
}

// Test piece module - small section with one dovetail of each type for tolerance testing
module dovetail_test_piece() {
  test_length = 30;  // Short length for quick printing
  test_width = 30;   // Narrow width
  test_height = 10;  // Fixed height

  difference() {
    union() {
      // Base block
      translate([0, -test_width/2, 0])
        cube([test_length, test_width, test_height]);

      // Male dovetail on +Y side (centered on edge)
      translate([test_length/2, test_width/2 - dovetail_trap_depth/2, 0])
        dovetail_3d(dovetail_trap_narrow, dovetail_trap_wide, dovetail_trap_depth, dovetail_trap_height, true);
    }

    // Female dovetail on -Y side (centered on edge)
    translate([test_length/2, -test_width/2 - dovetail_trap_depth/2, 0])
      dovetail_3d(dovetail_trap_narrow, dovetail_trap_wide, dovetail_trap_depth, dovetail_trap_height, false);
  }
}

// Set test_mode to true to render the quick test piece
// Set test_mode to false to render the full ramp section
test_mode = false;

if (test_mode) {
  dovetail_test_piece();
} else {
  // Render the section
  // Set side to "both" to see male and female dovetails together
  // Set to "male" or "female" to render individual pieces for printing
  side_to_render = render_both_sides ? "both" : dovetail_side;
  ramp_section(ramp_width, enable_dovetails, side_to_render);
}
