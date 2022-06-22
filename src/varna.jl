module VARNA

# Notes
# - VARNA doesn't warn or error on unknown options, e.g.
#   `-foo` : error, no argument for option foo
#   `-foo bar` : no error or warning

using Scratch: @get_scratch!

const _download_url = "https://varna.lri.fr/bin/VARNAv3-93.jar"

# this will be filled in by `__init__()`
_download_cache = ""

function __init__()
    global _download_cache = @get_scratch!("jar")
end

function _download_varna_jar(url=_download_url)
    fname = joinpath(_download_cache, basename(url))
    if !isfile(fname)
        @info "downloading VARNA jar file from $url"
        download(url, fname)
    end
    return fname
end

const docstr_savepath = """
- `savepath=""`: path where the image should be saved. If set to `""`,
  the image is stored in the temp directory.
"""

const docstr_plot_opts = """
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

- `chemical_probing=""`: markers on the RNA backbone, for example from
   chemical probing. String of the form
   `"a1-b1:opt1=v1,...;a2-b2:opt1=v2,..."`.  Here a1 and b1 are
   adjacent bases, the marker is placed on the backbone between them.
   - `glyph=[arrow|dot|pin|triangle]`: shape of annotation
   - `dir=[in|out]`: direction of annotation
   - `intensity=float`: annotation thickness
   - `color=color`

  Example: `chemical_probing="2-3:glyph=triangle,dir=in,intensity=1.0,color=#ff0000;4-5:glyph=dot"`

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
"""


"""
    plot(dbn; [seq], [savepath], [plot_opts...]) -> outpath::String

Plot a secondary structure `dbn` in dot-bracket notation with
VARNA. Pseudoknotted structures are allowed here.

Keyword arguments
- `seq=""`: sequence of the RNA, must have same length as structure
$docstr_savepath

$docstr_plot_opts
"""
function plot(dbn::AbstractString;
              seq::AbstractString=' '^length(dbn),
              savepath::AbstractString="",
              plot_opts...)
    varna_jarpath = _download_varna_jar()
    if length(dbn) != length(seq)
        throw(ArgumentError("structure and sequence must have same length: $(length(dbn)) != $(length(seq))"))
    end
    if savepath == ""
        outdir = mktempdir()
        outfile = joinpath(outdir, "out.png")
    else
        outfile = savepath
    end
    cmd = _cmd_varna_common(length(dbn); varna_jarpath, plot_opts...)
    cmd = `$cmd -o $outfile
                -structureDBN $dbn
                -sequenceDBN $seq`
    run(cmd)
    return outfile
end

"""
    plot_compare(; dbn1, seq1, dbn2, seq2, [savepath], [plot_opts...]) -> outpath::String

Plot two aligned (structure, sequence) pairs in comparative mode with
VARNA. Pseudoknots are not supported here. A '-' gap character can be
used in the aligned structures and sequences.

Comparative mode options
- `dbn1`: structure of the first RNA in dot-bracket notation
- `dbn2`: structure of second RNA, same length as `dbn1`
- `seq1: sequence of first RNA
- `seq2`: sequence of second RNA, same length as `seq1`
- `gap_color=""`
$docstr_savepath

$docstr_plot_opts
"""
function plot_compare(; dbn1::AbstractString,
                      dbn2::AbstractString,
                      seq1::AbstractString,
                      seq2::AbstractString,
                      gap_color::AbstractString="",
                      savepath::AbstractString="",
                      plot_opts...)
    varna_jarpath = _download_varna_jar()
    if length(dbn1) != length(dbn2) || length(dbn1) != length(seq1) || length(dbn1) != length(seq2)
        throw(ArgumentError("all structures and sequences must have same length, here they are: " *
            "dbn1=$(length(dbn1)), seq1=$(length(seq1)), dbn2=$(length(dbn2)), seq2=$(length(seq2)))"))
    end
    if savepath == ""
        outdir = mktempdir()
        outfile = joinpath(outdir, "out.png")
    else
        outfile = savepath
    end
    cmd = _cmd_varna_common(length(dbn1); varna_jarpath, plot_opts...)
    cmd = `$cmd -o $outfile
                -comparisonMode     true
                -firstStructure     $dbn1
                -firstSequence      $seq1
                -secondStructure    $dbn2
                -secondSequence     $seq2
                -gapsColor          $gap_color`
    run(cmd)
    return outfile
end

function _cmd_varna_common(len_struct::Integer;
    varna_jarpath::AbstractString,
    algorithm::Symbol=:radiate,
    additional_basepairs::AbstractString="",
    annotations::AbstractString="",
    auto_helices::Bool=false,
    auto_interior_loops::Bool=false,
    auto_terminal_loops::Bool=false,
    backbone_color::AbstractString="",
    background_color::AbstractString="",
    base_inner_color::AbstractString="",
    base_name_color::AbstractString="",
    base_num_color::AbstractString="",
    base_outline_color::AbstractString="",
    base_style_define::Vector{<:AbstractString}=String[],
    base_style_apply_on::Vector{<:AbstractString}=String[],
    basepair_color::AbstractString="",
    basepair_style::AbstractString="",
    border_dist::AbstractString="0x0",
    chemical_probing::AbstractString="",
    color_map::Vector{<:Real}=Float64[],
    color_map_caption::AbstractString="",
    color_map_min::Real=0.0,
    color_map_max::Real=1.0,
    color_map_style::AbstractString="heat",
    draw_backbone::Bool=true,
    draw_bases::Bool=true,
    draw_noncanonical_bp::Bool=true,
    draw_tertiary_bp::Bool=true,
    fill_bases::Bool=true,
    flat_radiate_mode::Bool=true,
    highlight_region::AbstractString="",
    line_mode_bp_vertical_scale::Real=1.0,
    nonstandard_bases_color::AbstractString="",
    numbering_period::Integer=10,
    resolution::Real=1.0,
    rotation::Real=0.0,
    show_errors::Bool=true,
    show_warnings::Bool=true,
    space_between_bases::Real=1.0,
    title::AbstractString="",
    title_color::AbstractString="",
    title_size::Integer=18,
    zoom::Real=1.0,
    )

    # Note: not implemented command-line args
    # - url: load file describing structure in one of the following formats:
    #        dot-bracket, .ct (connect), .bpseq, and RNAML as produced by RNAView
    # - modifiable: prohibits modification in the GUI except for basic
    #               cosmetic operations
    # TODO: background_color kwarg doesn't have any effect?
    #       (-background command-line arg)
    # TODO: -spaceBetweenBases is listed twice in the VARNA cmd-line
    #       docs, one is supposed to be inter-base distance (for
    #       basepairs?), one for consecutive bases -> check java sources
    # TODO
    # - missing options https://varna.lri.fr/index.php?lang=en&page=command&css=varna
    #   - multipanel layout (this requires some rework)
    #     -rows
    #     -columns
    #   - input_file `-i` command-line option
    
    # check arguments
    if algorithm ∉ (:line, :circular, :radiate, :naview)
        throw(ArgumentError("algorithm must be one of: " *
                            ":line, :circular, :radiate, :naview"))
    end
    if length(base_style_define) < length(base_style_apply_on)
        throw(ArgumentError("fewer base styles defined (base_style_defines) " *
            "than base style applications (base_style_apply_on)"))
    end
    if ! isempty(color_map) && length(color_map) != length(len_struct)
        throw(ArgumentError("color_map must have same length as structure"))
    end

    cmd = `java -Djava.awt.headless=true
                -cp $varna_jarpath fr.orsay.lri.varna.applications.VARNAcmd
                -algorithm            $(string(algorithm))
                -annotations          $annotations
                -autoHelices          $auto_helices
                -autoInteriorLoops    $auto_interior_loops
                -autoTerminalLoops    $auto_terminal_loops
                -auxBPs               $additional_basepairs
                -backbone             $backbone_color
                -background           $background_color
                -baseInner            $base_inner_color
                -baseName             $base_name_color
                -baseNum              $base_num_color
                -baseOutline          $base_outline_color
                -border               $border_dist
                -bp                   $basepair_color
                -bpIncrement          $line_mode_bp_vertical_scale
                -bpStyle              $basepair_style
                -chemProb             $chemical_probing
                -drawBackbone         $draw_backbone
                -drawBases            $draw_bases
                -drawNC               $draw_noncanonical_bp
                -drawTertiary         $draw_tertiary_bp
                -error                $show_errors
                -fillBases            $fill_bases
                -flat                 $flat_radiate_mode
                -highlightRegion      $highlight_region
                -nsBasesColor         $nonstandard_bases_color
                -periodNum            $numbering_period
                -resolution           $(float(resolution))
                -rotation             $(float(rotation))
                -spaceBetweenBases    $space_between_bases
                -title                $title
                -titleColor           $title_color
                -titleSize            $title_size
                -warning              $show_warnings
                -zoom                 $(float(zoom))`
    for (i, appl) in enumerate(base_style_apply_on)
        def = base_style_define[i]
        cmd = `$cmd -basesStyle$(i)           $def
                    -applyBasesStyle$(i)on    $appl`
    end
    if ! isempty(color_map)
        cmd = `$cmd -colorMap           $(join(float.(color_map), ';'))
                    -colorMapCaption    $color_map_caption
                    -colorMapStyle      $color_map_style
                    -colorMapMin        $(float(color_map_min))
                    -colorMapMax        $(float(color_map_max))`
    end
    return cmd
end

end # module VARNA
