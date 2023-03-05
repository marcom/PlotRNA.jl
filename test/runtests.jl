using Test

# show which testset is currently running
showtestset() = println(" "^(2 * Test.get_testset_depth()), "testing ",
                        Test.get_testset().description)

@testset verbose=true "PlotRNA" begin
    showtestset()
    include("plot_structure.jl")
    include("varna.jl")
    include("r2r.jl")
    include("uniplot.jl")
    include("plot_structure_makie.jl")
end
