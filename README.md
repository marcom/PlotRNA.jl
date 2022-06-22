# PlotRNA.jl

Plot nucleic acid secondary structures with Julia. Currently only the
most basic structure visualisation is implemented.

This package is quite new and there might be some sharp edges.

## Installation

As PlotRNA is not yet registered you have to add it like this:
```julia
] add https://github.com/marcom/PlotRNA.jl
```

## Usage

```julia
using PlotRNA, ViennaRNA
```

### Built-in plotting functionality (basic at the moment)

```julia
# plot_structure: draw an image of a secondary structure
dbn = "(((...)))"
seq = "GGGAAACCC"
plot_structure(dbn)
plot_structure(dbn; sequence=seq, base_colors=prob_of_basepairs(seq, dbn))
```

There is also an experimental `PlotRNA.plot_structure_makie` which
looks a bit nicer but currently has a rather large time to first plot
(40 seconds). Subsequent plots are very fast though.


### Plotting structures with VARNA

This uses the quite featureful [VARNA](https://varna.lri.fr/) program
via its command-line interface.

```julia
using PlotRNA
VARNA.plot("(((...)))")
VARNA.plot("(((...)))"; seq="GCGAAACGC", savepath="save.png")
VARNA.plot_compare(dbn1="(((.....)))", seq1="GCGAAAAACGC",
                   dbn2="((-...---))", seq2="GG-AAA---CC")
```

#### Note: Java must be installed for VARNA plotting to work

You will need a working Java installation (can be headless i think).
You can test this by running:
```julia
run(`java -version`)
```
If you don't get an error, plotting with VARNA should work.

The VARNA jar file will get downloaded automatically the first time
you plot something with VARNA. It gets stored in a scratch space that
gets cleaned up by the Julia package manager when you uninstall
PlotRNA.


#### Plot options

More details about these parameters can be found in the [VARNA
documentation](https://varna.lri.fr/index.php?lang=en&page=command&css=varna).

- `algorithm=:radiate`: RNA graph layout algorithm to
   use. Options are: `:line`, `:circular`, `:naview`, `:radiate.`.

- `additional_basepairs=""`: the option is called `-auxBPs` in
  VARNA. String of the form `"(i1,j1);(i2,j2):opt1=val1,opt2=val2;..."`.
  - `edge5`, `edge3=[wc|h|s]`: classification of noncanonical basepair
    as defined by Leontis & Westhof. Values are "wc" (Watson-Crick
    edge), "h" (Hoogsteen edge), "s" (sugar edge)
  - `stericity=[cis|trans]`: strand orientation
  - `color`: base pair color as string
  - `thickness`: basepair thickness as integer

  Example: `additional_basepairs="(1,10);(2,9):edge5=h,edge3=s,stericity=cis,color=#ff0000,thickness=5"`

- `annotations=""`: annotation string of the form
  `"text1:opt1=val1,...;type=T2,opt2=val2;..."`.
  - `type=[P|B|H|L]`: can be `P` (static), `B` (anchored on base), `H` (anchored
    on helix), or `L` (anchored on loop)
  - `x`, `y`: x and y coordinates for a static annotation (`P`)
  - `anchor`: which base should annotation be anchored to (not
    applicable for static annotations)
  - `size` font size as an integer
  - `color` as a string e.g. "#FF0000"

  Example: `annotations="Static annotation:type=P,x=100,y=50,size=12,color=#ff0000;Base annotation:type=B,anchor=42"`

- `auto_helices=false`: annotate helix n with "Hn"
- `auto_interior_loops=false`: annotate interior loop n with "In"
- `auto_terminal_loops=false`: annotate terminal loop n with "Tn"
- `backbone_color=""`
- `background_color=""`
- `base_inner_color=""`
- `base_name_color=""`
- `base_num_color=""`
- `base_outline_color=""`

- `base_style_define=String[]`: corresponds to the `-basesStyleX` options in VARNA.
- `base_style_apply_on=String[]`: corresponds to the `-applyBasesStyleXon` options in VARNA.

- `basepair_color=""`

- `basepair_style=""`: can be "none" (no basepairs drawn), "line",
  "rnaviz" (draw square equidistant from both bases), or "lw"
  (Leontis/Westhof rendering).

- `border_dist="0x0"`: x and y distance of drawing area from border,
  e.g. `10x20`

- `chemical_probing=""`: string of the form
   `"a1-b1:opt1=v1,...;a2-b2:opt1=v2,..."`.  Here a1 and b1 are adjacent
   bases, the marker is placed on the backbone between them.
   Options are:
   - `glyph=[arrow|dot|pin|triangle]`: shape of annotation
   - `dir=[in|out]`: direction of annotation
   - `intensity=float`: annotation thickness
   - `color=color`

- `color_map=Float64[]`: color map for coloring bases
- `color_map_caption=""`
- `color_map_min=0.0`: color map range minimum
- `color_map_max=1.0`: color map range maximum

- `color_map_style="heat"`: color map style. Predefined styles are:
  "red", "blue", "green", "heat", "energy", and "bw". A custom palette
  can be passed in the form `"0:#ff0000;1:#ffffff"`.

- `draw_backbone=true`
- `draw_bases=true`
- `draw_noncanonical_bp=true`
- `draw_tertiary_bp=true`
- `fill_bases=true`

- `flat_radiate_mode=true`: align exterior loop horizontally in the
  `:radiate` layout algorithm.

- `highlight_region=""`: string for highlighting consecutive regions
  of bases of the format `"i1-j1:opt1=val1,...;i2-j2:opt1=val2,..."`. Options are:
  - `radius`: thickness of highlight
  - `fill=color`: highlight fill color
  - `outline=color`: highlight outline color

  Example: `highlight_region="2-5:radius=10,fill=#00ff00;7-12:radius=10,fill=#00ff00,outline=#000000"`

- `line_mode_bp_vertical_scale=1.0`: vertical scaling of basepair
  lines in the `:line` layout algorithm

- `nonstandard_bases_color=""`
- `numbering_period=10`: numbering interval for bases
- `resolution=1.0`
- `rotation=0.0`: rotate RNA structure by an angle in degrees
- `show_errors=true`
- `show_warnings=true`
- `space_between_bases=1.0`
- `title=""`: plot title
- `title_color=""`
- `title_size=18`: title font size
- `zoom=1.0`


## Other Julia packages for RNA secondary structure prediction

- [ViennaRNA.jl](https://github.com/marcom/ViennaRNA.jl)
- [LinearFold.jl](https://github.com/marcom/LinearFold.jl)
