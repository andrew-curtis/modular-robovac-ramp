# Robo-Vac Rug Ramp - Modular Design

A parametric OpenSCAD design for creating modular ramps to help robot vacuums climb over rugs and floor transitions. Features interlocking dovetail joints for connecting multiple sections to cover wider areas.
<img width="907" height="558" alt="image" src="https://github.com/user-attachments/assets/acaeb193-e8c9-4002-957e-40b33047ce8b" />

## Features

- **Modular Design**: Connect multiple sections side-by-side using dovetail joints
- **Parametric**: Easily adjust dimensions to fit your specific rug height and space requirements
- **Grip Texture**: Surface pattern provides traction for robot vacuum wheels
- **Smooth Top Transition**: Rounded fillet at the top edge prevents catching on rug edges
- **Print-in-Place Ready**: No supports needed for basic ramp sections

## Parameters

### Main Dimensions

| Parameter | Default | Description |
|-----------|---------|-------------|
| `ramp_height` | 18mm | Height of the ramp surface (grip texture adds ~1mm) |
| `ramp_length` | 100mm | Length of the ramp |
| `ramp_width` | 200mm | Width of each modular section |
| `ramp_thickness` | 1mm | Thickness at the base of the ramp |
| `top_fillet_radius` | 8mm | Radius for rounded top edge |
| `texture_protrusion` | -0.5mm | Offset of grip texture perpendicular to ramp surface (negative = recessed) |

### Dovetail Parameters

The dovetails use a trapezoidal profile for a self-tightening fit. The center of the trapezoid is aligned with the edge of the ramp body, so half the dovetail is inside the body and half protrudes outward.

| Parameter | Default | Description |
|-----------|---------|-------------|
| `dovetail_trap_narrow` | 8mm | Trapezoid narrow end (base) |
| `dovetail_trap_wide` | 11.2mm | Trapezoid wide end (tip) |
| `dovetail_trap_height` | 8mm | Trapezoid height (vertical, in Z direction) |
| `dovetail_trap_depth` | 8mm | Trapezoid depth - half inside body, half outside |
| `dovetail_count` | 3 | Number of dovetails per side |
| `dovetail_margin` | 15mm | Minimum distance from front/back ends |
| `tolerance` | 0.1mm | Clearance for male dovetails (total gap) |

### Rendering Options

| Parameter | Default | Description |
|-----------|---------|-------------|
| `enable_dovetails` | true | Set to false to print a plain ramp with no dovetails |
| `render_both_sides` | false | true = render both male and female dovetails, false = use dovetail_side |
| `dovetail_side` | "male" | "male" or "female" - only used if render_both_sides = false |
| `test_mode` | false | true = render quick test piece, false = render full ramp |

## Usage

### Basic Printing

1. Open `modular_robovac_ramp.scad` in OpenSCAD
2. Adjust `ramp_height` to match your rug height
3. Adjust `ramp_width` based on your printer bed size and desired coverage
4. Choose your printing approach:
   - **Plain ramp (no dovetails)**: Set `enable_dovetails = false`
   - **Single standalone ramp with dovetails**: Set `enable_dovetails = true` and `render_both_sides = true`
   - **Modular sections**: Set `enable_dovetails = true`, print separate male and female pieces:
     - Set `render_both_sides = false` and `dovetail_side = "male"` for first piece
     - Set `dovetail_side = "female"` for second piece
     - Continue alternating for additional sections

### Testing Dovetail Fit

Before printing full-size sections, test the dovetail tolerance:

1. Set `test_mode = true`
2. Print the test piece (30mm x 30mm with one dovetail of each type)
3. Check if the joints fit snugly
4. Adjust `tolerance` parameter if needed (increase for looser fit, decrease for tighter)
5. Set `test_mode = false` to return to full ramp rendering

### Customization Tips

- **Rug Height**: Measure your rug thickness and set `ramp_height` to match (the ramp surface will be at this height)
- **Printer Bed Size**: Adjust `ramp_width` to maximize use of your print bed
- **Longer Ramps**: Increase `ramp_length` for a more gradual slope
- **Top Fillet**: Adjust `top_fillet_radius` for smoother or sharper transition to rug (larger = smoother)
- **Grip Texture**: Adjust `texture_protrusion` (negative values recess the texture into the surface)

## Technical Details

### Adaptive Dovetails

The dovetail system automatically adjusts height based on the available space at each position along the ramp. Dovetails near the thin end of the ramp are shorter to maintain a 3mm clearance from the top surface. Any dovetail that would be shorter than 5mm is not rendered.

### Floor Clipping

All geometry below Z=0 (floor plane) is automatically clipped, ensuring the ramp sits flat regardless of parameter choices for `ramp_thickness` or `top_fillet_radius`.

### Grip Texture Calculation

The grip texture follows the actual hull() surface, accounting for both the straight ramp section and the curved fillet at the top. The texture uses circle geometry to correctly position along the rounded edge.

## Print Settings Recommendations

- **Layer Height**: 0.2mm or 0.3mm
- **Infill**: 15-20% (ramp is thin, doesn't need high infill)
- **Perimeters**: 3-4 walls
- **Supports**: None required
- **Adhesion**: Brim recommended for larger sections

## License

This design is released under Creative Commons - feel free to modify and share!

## Compatibility

Designed for the Roborock S5, but should work with most robot vacuums. Adjust parameters as needed for your specific model and rug height.
