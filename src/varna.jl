# Notes
# - VARNA doesn't warn or error on unknown options, e.g.
#   `-foo` : error, no argument for option foo
#   `-foo bar` : no error or warning

"""
    plot_varna(dbn; [seq], [other kwargs...]) -> ouput_file

Plot a secondary structure `dbn` in dot-bracket notation with VARNA.

Notes:
- can accept pseudoknotted structures, e.g. `((((...[[[...))))...]]]`
- `chemical_probing` can be used for markers on the backbone (connecting bases)
"""
function plot_varna(dbn::AbstractString;
                    seq::AbstractString=' '^length(dbn),
                    varna_jarpath::AbstractString,
                    kwargs...)
    if length(dbn) != length(seq)
        throw(ArgumentError("structure and sequence must have same length: $(length(dbn)) != $(length(seq))"))
    end
    outdir = mktempdir()
    outfile = joinpath(outdir, "out.png")
    cmd = _cmd_varna_common(length(dbn); varna_jarpath, kwargs...)
    cmd = `$cmd -o $outfile
                -structureDBN $dbn
                -sequenceDBN $seq`
    run(cmd)
    return outfile
end

"""
    plot_varna_compare(; dbn1, seq1, dbn2, seq2, [other kwargs...]) -> output_file

Plot two aligned (structure, sequence) pairs in comparative mode with
VARNA.

Notes:
- pseudoknots not supported here
"""
function plot_varna_compare(; dbn1::AbstractString,
                            dbn2::AbstractString,
                            seq1::AbstractString,
                            seq2::AbstractString,
                            gap_color::AbstractString="",
                            varna_jarpath::AbstractString,
                            kwargs...)
    if length(dbn1) != length(dbn2) || length(dbn1) != length(seq1) || length(dbn1) != length(seq2)
        throw(ArgumentError("all structures and sequences must have same length, here they are: " *
            "dbn1=$(length(dbn1)), seq1=$(length(seq1)), dbn2=$(length(dbn2)), seq2=$(length(seq2)))"))
    end
    outdir = mktempdir()
    outfile = joinpath(outdir, "out.png")
    cmd = _cmd_varna_common(length(dbn1); varna_jarpath, kwargs...)
    cmd = `$cmd -o $outfile
                -comparisonMode true
                -firstStructure $dbn1
                -firstSequence $seq1
                -secondStructure $dbn2
                -secondSequence $seq2
                -gapsColor $gap_color`
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
        throw(ArgumentError("algorithm must be one of: :line, :circular, :radiate, :naview"))
    end
    if length(base_style_define) < length(base_style_apply_on)
        throw(ArgumentError("fewer base styles defined (base_style_defines) than base style applications (base_style_apply_on)"))
    end
    if ! isempty(color_map) && length(color_map) != length(len_struct)
        throw(ArgumentError("color_map must have same length as structure"))
    end

    cmd = `java -Djava.awt.headless=true
                -cp $varna_jarpath fr.orsay.lri.varna.applications.VARNAcmd
                -algorithm $(string(algorithm))
                -annotations $annotations
                -autoHelices $auto_helices
                -autoInteriorLoops $auto_interior_loops
                -autoTerminalLoops $auto_terminal_loops
                -auxBPs $additional_basepairs
                -backbone $backbone_color
                -background $background_color
                -baseInner $base_inner_color
                -baseName $base_name_color
                -baseNum $base_num_color
                -baseOutline $base_outline_color
                -border $border_dist
                -bp $basepair_color
                -bpIncrement $line_mode_bp_vertical_scale
                -bpStyle $basepair_style
                -chemProb $chemical_probing
                -drawBackbone $draw_backbone
                -drawBases $draw_bases
                -drawNC $draw_noncanonical_bp
                -drawTertiary $draw_tertiary_bp
                -error $show_errors
                -fillBases $fill_bases
                -flat $flat_radiate_mode
                -highlightRegion $highlight_region
                -nsBasesColor $nonstandard_bases_color
                -periodNum $numbering_period
                -resolution $(float(resolution))
                -rotation $(float(rotation))
                -spaceBetweenBases $space_between_bases
                -title $title
                -titleColor $title_color
                -titleSize $title_size
                -warning $show_warnings
                -zoom $(float(zoom))`
    for (i, appl) in enumerate(base_style_apply_on)
        def = base_style_define[i]
        cmd = `$cmd -basesStyle$(i) $def
                    -applyBasesStyle$(i)on $appl`
    end
    if ! isempty(color_map)
        cmd = `$cmd -colorMap $(join(float.(color_map), ';'))
                    -colorMapCaption $color_map_caption
                    -colorMapStyle $color_map_style
                    -colorMapMin $(float(color_map_min))
                    -colorMapMax $(float(color_map_max))`
    end
    return cmd
end
