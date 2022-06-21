using PlotRNA: VARNA

@testset "VARNA.plot" begin
    outfile = VARNA.plot("(((...)))"; seq="GCGAAACGC")
    @test outfile isa String
    @test isfile(outfile)
    # TODO: make sure there is something in the file

    savedir = mktempdir()
    savepath = joinpath(savedir, "out.png")
    outfile = VARNA.plot("(((...)))"; seq="GCGAAACGC", savepath)
    @test outfile isa String
    @test outfile == savepath
    @test isfile(savepath)
    # TODO: make sure there is something in the file
end

@testset "VARNA.plot_compare" begin
    outfile = VARNA.plot_compare(dbn1="(((.....)))", seq1="GCGAAAAACGC",
                                 dbn2="((-...---))", seq2="GG-AAA---CC")
    @test outfile isa String
    @test isfile(outfile)
    # TODO: make sure there is something in the file

    savedir = mktempdir()
    savepath = joinpath(savedir, "out.png")
    outfile = VARNA.plot_compare(dbn1="(((.....)))", seq1="GCGAAAAACGC",
                                 dbn2="((-...---))", seq2="GG-AAA---CC";
                                 savepath)
    @test outfile isa String
    @test outfile == savepath
    @test isfile(savepath)
    # TODO: make sure there is something in the file
end
