module PlotRNA

using SnoopPrecompile: @precompile_all_calls
using Requires: @require

export VARNA, R2R, plot_structure

function __init__()
    @require CairoMakie="13f3f980-e62b-5c42-98c6-ff1f3baf88f0" include("plot_structure_makie.jl")
    @require UnicodePlots="b8865327-cd53-5732-bb35-84acbb429228" include("uniplot.jl")
end

include("plot_structure.jl")
include("varna.jl")
include("r2r.jl")

@precompile_all_calls begin
    plot_structure("(((...)))")
    plot_structure("(((...)))"; sequence="GGGAAACCC")
    # TODO: how to precompile but using @require from Requires.jl?
    #       measure: are these precompile statements improving TTFP?
    #uniplot("(((...)))")
    #plot_structure_makie("(((...)))")
    #plot_structure_makie("(((...)))"; sequence="GGGAAACCC")
end

# We define the docstrings of plot_structure_makie and uniplot here so they're always
# available, even if they weren't loaded via @require in __init__().

"""
    plot_structure_makie(structure; [sequence, savepath, layout_type, colorscheme])

Plot a secondary structure to a PNG image or PDF file depending on `savepath` ending.

Using this function requires CairoMakie to have been loaded before
PlotRNA with `using CairoMakie, PlotRNA`.
"""
function plot_structure_makie end

"""
    uniplot(dbn; title, width, height)

Plot secondary structure using UnicodePlots, usually to show inside a
terminal.

Using this function requires UnicodePlots to have been loaded before
PlotRNA with `using UnicodePlots, PlotRNA`.
"""
function uniplot end


end # module PlotRNA
