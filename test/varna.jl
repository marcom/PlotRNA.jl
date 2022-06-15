using PlotRNA: VARNA

@testset "VARNA.plot" begin
    outfile = VARNA.plot("(((...)))"; seq="GCGAAACGC")
    @show outfile
    @test outfile isa String
    @test isfile(outfile)
end

@testset "VARNA.plot_compare" begin
    outfile = VARNA.plot_compare(dbn1="(((.....)))", seq1="GCGAAAAACGC",
                                 dbn2="((-...---))", seq2="GG-AAA---CC")
    @test outfile isa String
    @test isfile(outfile)
end
