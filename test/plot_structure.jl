using PlotRNA
using PlotRNA: Luxor
using ViennaRNA: Pairtable

# TODO: simplify tests
@testset "plot_structure" begin
    showtestset()
    w = "((((.....))))."
    s = "GGCGAAUACCGCCU"
    @test plot_structure(w) isa Luxor.Drawing
    @test plot_structure(Pairtable(w)) isa Luxor.Drawing
    @test plot_structure(w; sequence=s) isa Luxor.Drawing
    @test plot_structure(Pairtable(w); sequence=s) isa Luxor.Drawing
    for layout in [:simple, :naview, :circular, :turtle, :puzzler]
        @test plot_structure(w; sequence=s, layout_type=layout) isa Luxor.Drawing
        @test plot_structure(w; sequence=s, layout_type=layout,
                             base_colors=rand(length(w))) isa Luxor.Drawing
        # savepath
        outdir = mktempdir()
        savepath = joinpath(outdir, "out.png")
        @test plot_structure(w; sequence=s, layout_type=layout, savepath) isa Luxor.Drawing
        @test isfile(savepath)

        @test plot_structure(w; sequence=s, layout_type=layout,
                             base_colors=rand(length(w)), savepath) isa Luxor.Drawing
        @test plot_structure(Pairtable(w); sequence=s, layout_type=layout,
                             base_colors=rand(length(w)), savepath) isa Luxor.Drawing
        @test isfile(savepath)
    end
end
