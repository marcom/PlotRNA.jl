module PlotRNA

using PrecompileTools: @compile_workload
export VARNA, R2R, plot_structure

# for julia < v1.9 we use Requires.jl instead of package extensions
@static if !isdefined(Base, :get_extension)
    using Requires: @require
end
@static if !isdefined(Base, :get_extension)
    function __init__()
        @require CairoMakie="13f3f980-e62b-5c42-98c6-ff1f3baf88f0" include(
            normpath(@__DIR__, "..", "ext", "CairoMakieExt.jl")
        )
        @require UnicodePlots="b8865327-cd53-5732-bb35-84acbb429228" include(
            normpath(@__DIR__, "..", "ext", "UnicodePlotsExt.jl")
        )
    end
end

include("plot_structure.jl")
include("varna.jl")
include("r2r.jl")

@compile_workload begin
    plot_structure("(((...)))")
    plot_structure("(((...)))"; sequence="GGGAAACCC")
end


# Predefine docstrings of functions that are only available when other
# packages are also loaded, either via package extensions (julia >=
# v1.9) or Requires.jl (julia < v1.9).
#
#  - plot_structure_makie (needs CairoMakie)
#  - uniplot (needs UnicodePlots)

"""
    plot_structure_makie(structure; [sequence, savepath, layout_type, colorscheme])

Plot a secondary structure to a PNG image or PDF file depending on `savepath` ending.

Using this function requires CairoMakie to be loaded.
"""
function plot_structure_makie end

"""
    uniplot(dbn; title, width, height)

Plot secondary structure using UnicodePlots, usually to show inside a
terminal.

Using this function requires UnicodePlots to be loaded.
"""
function uniplot end


end # module PlotRNA
