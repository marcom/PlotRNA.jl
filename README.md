# PlotRNA.jl

Plot nucleic acid secondary structures with Julia. Currently only the
most basic structure visualisation is implemented.

This package is quite new and there might be some sharp edges.

## Installation

As PlotRNA is not yet registered you have to add it like this:
```julia
] add https://github.com/marcom/PlotRNA.jl
```

## Usage

```julia
using PlotRNA, ViennaRNA
```

### Built-in plotting functionality (basic at the moment)

```julia
# plot_structure: draw an image of a secondary structure
dbn = "(((...)))"
seq = "GGGAAACCC"
plot_structure(dbn)
plot_structure(dbn; sequence=seq, base_colors=prob_of_basepairs(seq, dbn))
```

There is also an experimental `PlotRNA.plot_structure_makie` which
looks a bit nicer but currently has a rather large time to first plot
(40 seconds). Subsequent plots are very fast though.


### Plotting structures with VARNA

```julia
using PlotRNA
VARNA.plot("(((...)))")
VARNA.plot("(((...)))"; seq="GCGAAACGC")
VARNA.plot_compare(dbn1="(((.....)))", seq1="GCGAAAAACGC", dbn2="((-...---))", seq2="GG-AAA---CC")
```

There are many more (not yet documented) keyword arguments that allow
customising the plot.

#### Note: Java must be installed

You will need a working Java installation (can be headless i think).
You can test this by running:
```julia
run(`java -version`)
```
If you don't get an error, plotting with VARNA should work.

The VARNA jar file will get downloaded automatically the first time
you plot something with VARNA. It gets stored in a scratch space that
gets cleaned up by the Julia package manager when you uninstall
PlotRNA.

#### Warning: output files are saved to tmpdir

At the moment, the VARNA plot functions save the PNG they create in a
temporary directory that gets deleted when the Julia session ends.
The plotting functions return the file name of the image created.  You
have to copy that file to another location before the Julia session
ends, otherwise the file will be gone!

This should be improved in the future.


## Other Julia packages for RNA secondary structure prediction

- [ViennaRNA.jl](https://github.com/marcom/ViennaRNA.jl)
- [LinearFold.jl](https://github.com/marcom/LinearFold.jl)
