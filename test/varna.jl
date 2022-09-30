using PlotRNA.VARNA: VARNA, plot, plot_compare, VarnaPlot

const file_endings_to_mime = VARNA._map_fileendings_to_mime

# TODO
# - test verbose option

@testset "VARNA.plot" begin
    # basic usage
    for kwargs in [(;), (; seq="GCGAAACGC")]
        vp = plot("(((...)))"; kwargs...)
        @test vp isa VarnaPlot
        @test isfile(vp.filepath)
        @test filesize(vp.filepath) > 0
        rm(vp.filepath)
    end

    for (ending, mimetype) in file_endings_to_mime
        # savepath
        mktempdir() do savedir
            savepath = joinpath(savedir, "out.$ending")
            vp = plot("(((...)))"; seq="GCGAAACGC", savepath)
            @test vp isa VarnaPlot{mimetype}
            @test vp.filepath == savepath
            @test isfile(vp.filepath)
            @test filesize(vp.filepath) > 0
        end

        # fileformat
        vp = plot("(((...)))"; seq="GCGAAACGC", fileformat=ending)
        @test vp isa VarnaPlot{mimetype}
        @test isfile(vp.filepath)
        @test filesize(vp.filepath) > 0
        rm(vp.filepath)
    end

    # illegal file endings / file formats
    @test_throws ErrorException plot("(((...)))"; fileformat="doesnotexist")
    mktempdir() do savedir
        savepath = joinpath(savedir, "out.doesnotexist")
        @test_throws ErrorException plot("(((...)))"; savepath)
    end
end

@testset "VARNA.plot_compare" begin
    # basic usage
    vp = plot_compare(dbn1="(((.....)))", seq1="GCGAAAAACGC",
                      dbn2="((-...---))", seq2="GG-AAA---CC")
    @test vp isa VarnaPlot
    @test isfile(vp.filepath)
    @test filesize(vp.filepath) > 0
    rm(vp.filepath)

    for (ending, mimetype) in file_endings_to_mime
        # savepath
        mktempdir() do savedir
            savepath = joinpath(savedir, "out.$ending")
            vp = plot_compare(dbn1="(((.....)))", seq1="GCGAAAAACGC",
                              dbn2="((-...---))", seq2="GG-AAA---CC",
                              savepath=savepath)
            @test vp isa VarnaPlot{mimetype}
            @test vp.filepath == savepath
            @test isfile(vp.filepath)
            @test filesize(vp.filepath) > 0
        end

        # fileformat
        vp = plot_compare(dbn1="(((.....)))", seq1="GCGAAAAACGC",
                          dbn2="((-...---))", seq2="GG-AAA---CC",
                          fileformat=ending)
        @test vp isa VarnaPlot{mimetype}
        @test isfile(vp.filepath)
        @test filesize(vp.filepath) > 0
        rm(vp.filepath)
    end

    # illegal file endings / file formats
    @test_throws ErrorException plot_compare(dbn1="(((.....)))", seq1="GCGAAAAACGC",
                                             dbn2="((-...---))", seq2="GG-AAA---CC",
                                             fileformat="doesnotexist")
    mktempdir() do savedir
        savepath = joinpath(savedir, "out.doesnotexist")
        @test_throws ErrorException plot_compare(dbn1="(((.....)))", seq1="GCGAAAAACGC",
                                                 dbn2="((-...---))", seq2="GG-AAA---CC",
                                                 savepath=savepath)
    end
end
