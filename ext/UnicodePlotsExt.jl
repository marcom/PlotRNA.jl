module UnicodePlotsExt

# Secondary structure plotting to terminal with UnicodePlots

# TODO
# - smaller plots for smaller structures, e.g. (((...))), (((((....)))))
# - bad aspect ratio for some structure, e.g. "Gladio" from Eterna100
#   "((....))..(...(...(..(.(..(...(((.(((...((((....)))).((((((.((((((.((((((.((((((.((((((((((.((((((.(((((.((((.((((..((((...)))).))).)))))).))))).)))))).)))))))).)))))).)))))).)))))).))))))).)))...(((.(((((.(..((((.(..((((.(..((((.(..(((((((.((((((.(((((.((((((.(((.((((((....))))))..)))).)))).))))).)))))).)))))))).)..)))).)..)))).)..)))).)..))))).((((....))))...))).)))...)..).)..)...)...)..((....))"

using PrecompileTools: @compile_workload
using PlotRNA
import ViennaRNA
if isdefined(Base, :get_extension)
    import UnicodePlots
else
    import ..UnicodePlots
end

# Note: docstring is in src/PlotRNA.jl
function PlotRNA.uniplot(dbn::AbstractString; title::AbstractString="",
                         width::Symbol=:auto, height::Symbol=:auto)
    n = length(dbn)
    n > 0 || throw(ArgumentError("secondary structure dbn has length 0"))
    x, y = ViennaRNA.plot_coords(ViennaRNA.Pairtable(dbn))
    plot = UnicodePlots.lineplot(x, y; border=:none, labels=false, title, width, height)
    pt = ViennaRNA.Pairtable(dbn)
    for i = 1:n
        j = pt[i]
        if i < j
            # i,j form a base pair
            UnicodePlots.lines!(plot, x[i], y[i], x[j], y[j])
        end
    end
    return plot
end

@compile_workload begin
    PlotRNA.uniplot("(((...)))")
end

end # module
