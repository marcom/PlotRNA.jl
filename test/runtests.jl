using Test

# show which testset is currently running
showtestset() = println(" "^(2 * Test.get_testset_depth()), "testing ",
                        Test.get_testset().description)

@testset verbose=true "PlotRNA" begin
    showtestset()
    include("plot_structure.jl")
    if isnothing(Sys.which("java"))
        @warn "Can't find java executable, skipping VARNA tests"
    else
        include("varna.jl")
    end
    include("r2r.jl")
    include("uniplot.jl")
    include("plot_structure_makie.jl")
end
