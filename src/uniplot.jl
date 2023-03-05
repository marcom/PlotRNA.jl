# Secondary structure plotting to terminal with UnicodePlots

# TODO
# - smaller plots for smaller structures, e.g. (((...))), (((((....)))))
# - bad aspect ratio for some structure, e.g. "Gladio" from Eterna100
#   "((....))..(...(...(..(.(..(...(((.(((...((((....)))).((((((.((((((.((((((.((((((.((((((((((.((((((.(((((.((((.((((..((((...)))).))).)))))).))))).)))))).)))))))).)))))).)))))).)))))).))))))).)))...(((.(((((.(..((((.(..((((.(..((((.(..(((((((.((((((.(((((.((((((.(((.((((((....))))))..)))).)))).))))).)))))).)))))))).)..)))).)..)))).)..)))).)..))))).((((....))))...))).)))...)..).)..)...)...)..((....))"

# Note: we have to use the dot before UnicodePlots as we are using
# Requires.jl to only compile this code if UnicodePlots is available
import ViennaRNA
import .UnicodePlots

# the docstring is in PlotRNA.jl so it's always available, even if
# this file wasn't loaded because of @require
function uniplot(dbn; title="", width=:auto, height=:auto)
    n = length(dbn)
    n > 0 || throw(ArgumentError("secondary structure dbn has length 0"))
    x, y = ViennaRNA.plot_coords(ViennaRNA.Pairtable(dbn))
    plot = UnicodePlots.lineplot(x, y; border=:none, labels=false, title, width, height)
    pt = Pairtable(dbn)
    for i = 1:n
        j = pt[i]
        if i < j
            # i,j form a base pair
            UnicodePlots.lines!(plot, x[i], y[i], x[j], y[j])
        end
    end
    return plot
end
