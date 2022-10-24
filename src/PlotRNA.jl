module PlotRNA

using SnoopPrecompile: @precompile_all_calls
using Requires: @require

export VARNA, R2R, plot_structure

function __init__()
    @require CairoMakie="13f3f980-e62b-5c42-98c6-ff1f3baf88f0" include("plot_structure_makie.jl")
end

include("plot_structure.jl")
include("varna.jl")
include("r2r.jl")

@precompile_all_calls begin
    plot_structure("(((...)))")
    plot_structure("(((...)))"; sequence="GGGAAACCC")
    # TODO: how to precompile but using @require from Requires.jl?
    #       measure: are these precompile statements improving TTFP?
    #plot_structure_makie("(((...)))")
    #plot_structure_makie("(((...)))"; sequence="GGGAAACCC")
end

end # module PlotRNA
