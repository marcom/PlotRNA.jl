module PlotRNA

using SnoopPrecompile: @precompile_all_calls

export VARNA, R2R, plot_structure

include("plot_structure.jl")
include("varna.jl")
include("r2r.jl")

@precompile_all_calls begin
    plot_structure("(((...)))")
    plot_structure("(((...)))"; sequence="GGGAAACCC")
    plot_structure_makie("(((...)))")
    plot_structure_makie("(((...)))"; sequence="GGGAAACCC")
end

end # module PlotRNA
