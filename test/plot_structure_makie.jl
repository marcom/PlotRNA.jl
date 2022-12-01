using CairoMakie: Makie

@testset "plot_structure_makie" begin
    showtestset()
    w = "((((.....))))."
    s = "GGCGAAUACCGCCU"
    @test PlotRNA.plot_structure_makie(w) isa Makie.Figure
end
