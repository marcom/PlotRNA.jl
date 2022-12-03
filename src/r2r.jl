# Notes from R2R-manual.pdf (R2R version 1.0.6)
#
# - R2R input format: a special version of Stockholm format, in which
#   interleaved lines are not permitted (called the "Pfam format" in
#   the R2R manual)

# Input
#
# r2r --GSC-weighted-consensus identity-levels present-levels max-non-canon
# - `--GSC-weighted-consensus`: calculate consensus sequence
# - identity-levels: N [N float numbers], integer N followed by N
#   float numbers in decreasing order
#   - N levels for classifying degree of conservation of a "nucleotide identity"
#     float numbers (0 to 1) are minimum frequency for each level
# - present-levels: N [N float numbers], integer N followed by N float
#   numbers in decreasing order
#   - N levels for classifying how frequently nucleotide is present,
#     float numbers (0 to 1) are min freq at each level in decreasing
#     order
# - max-non-canon: float (0 to 1), max freq of non-canonical basepairs
#   (not AU, UA, CG, GC, GU, UG). If there are more than max-non-canon
#   noncanonical basepairs, R2R will never declare covarying,
#   compatible, or non-mutating pairs (i.e. code ?, basepairs not
#   shaded in consensus diagrams)
# - Note: identity-levels <= 3, present-levels <= 4 or R2R can't draw
#   consensus diagram
# - `--disable-usage-warning`: don't display warning about
#   inappropriate usage

# Output
#
# - `#=GC cons`: consensus sequence with gaps. R/Y seq wildcards, n
#   for columns that are typically present but don't preserve
#   nucleotide identity (drawn as circles by R2R)
# - `#=GC conss`: degree of conservation, 1 is highest.
#   - degenerate nucleotide (R/Y): levels 1-3
#   - `n` (lowercase): levels 1-4 (default), how often is any
#     nucleotide found in this position (versus a gap)
#   - for a gap `-`: always 0
# - `#=GC cov_SS_cons`: covariation annotation
#   - 2: basepair with at least one instance of covariation
#   - 1: at least one compatible mutation
#   - 0: no mutations
#   - ?: too many non-canonical basepairs
# - `#=GC cov_SS_cons[x]`: covariation data for pseudoknot structure line `#GC SS_cons[x]`
# - `#=GF NUM_COV`: number of basepairs with covariation (per-file annotation)
# - `#=GF WEIGHT_MAP`: list GSC algorithm weights used for each seq, in
#   space-separated list (per-file annotation ?)
#   - even-numbered fields: identify a sequence
#   - odd-numbered fields: weights
#   - Note: if `#=GF USE_THIS_WEIGHT_MAP` is used, this will be
#     idential to `#=GF USE_THIS_WEIGHT_MAP`
# - `#=GF USED_GSC TRUE`: confirms that GSC algorithm was used
#   (per-file annotation)
# - `#=GF col_entropy_[i]`: experimental, entropy of each column,
#   written vertically
# - `#=GF DID_FRAGMENTARY FALSE`: use of FRAGMENTARY feature (per-file
#   annotation)

# .r2r_meta file
# - tab delimited
# - comment if first tab-delimited field is empty
# - line with only 1 field: path to .sto file
# - more than one field, if field 1 == "SetDrawingParam": change
#   default drawing params
# - specify single RNA molecule to be drawn
#
# - <path_to_sto_file>
# - SetDrawingParam name value
# - define name value
# - <path_to_sto_file> oneseq <seq_id>


module R2R

using BioStockholm: MSA
import R2R_jll

function _runcmd(cmd::Cmd)
    buf_out = IOBuffer()
    buf_err = IOBuffer()
    r = run(pipeline(ignorestatus(cmd); stdout=buf_out, stderr=buf_err))
    exitcode = r.exitcode
    out = String(take!(buf_out))
    err = String(take!(buf_err))
    return exitcode, out, err
end

struct Plot
    svg::String
end

function Base.showable(mime::Type{T}, p::Plot) where {T <: MIME}
    if mime === MIME"image/svg+xml"
        return true
    end
    return false
end

function Base.show(io::IO, mime::MIME"image/svg+xml", p::Plot)
    # TODO: why doesn't the following signature work? claims there is
    #       no method to call for MIME"image/svg+xml", but
    #       MIME"image/svg+xml" <: MIME ???
    # function Base.show(io::IO, mime::T, p::Plot) where {T <: MIME}
    println(io, p.svg)
end

function plot(msa::MSA; kwargs...)
    ps, res, out, err = run_r2r(msa; kwargs...)
    return Plot(res)
end

function run_r2r(msa::MSA;
                 GSC_weighted_consensus::Bool = true,
                 identity_levels = [0.97, 0.9, 0.75],
                 present_levels = [0.97, 0.9, 0.75, 0.5],
                 max_noncanon::Real = 0.1)
    # TODO
    # - output file type: svg or pdf
    # - assertions on identity_levels, present_levels, max_noncanon

    # build string of form "3 0.97 0.9 0.75", format: N<int> [N float numbers]
    cmd_identity_levels = `$(length(identity_levels))`
    for lvl in identity_levels
        cmd_identity_levels = `$cmd_identity_levels $lvl`
    end
    # build string of form "4 0.97 0.9 0.75 0.5", format: N<int> [N float numbers]
    cmd_present_levels = `$(length(present_levels))`
    for lvl in present_levels
        cmd_present_levels = `$cmd_present_levels $lvl`
    end
    exitcode = 0
    res = out = err = ""
    mktemp() do input_path, _
        write(input_path, msa)
        mktempdir() do output_dir
            output_sto_path = joinpath(output_dir, "out.sto")
            output_path = joinpath(output_dir, "out.svg")
            metafile_path = joinpath(output_dir, "out.r2r_meta")
            cmd = `$(R2R_jll.r2r())`
            if GSC_weighted_consensus
                cmd = `$cmd --GSC-weighted-consensus`
            end
            cmd = `$cmd $input_path $output_sto_path $cmd_identity_levels $cmd_present_levels $max_noncanon`
            exitcode, out, err = _runcmd(cmd)
            if exitcode != 0
                error("non-zero exit code running r2r to generate out.sto")
            end
            if ! (isfile(output_sto_path) && filesize(output_sto_path) > 0)
                error("out.sto doesn't exist or is empty")
            end
            # write r2r_meta file
            open(metafile_path, "w") do io
                println(io, output_sto_path)
            end
            cmd = `$(R2R_jll.r2r()) --disable-usage-warning $metafile_path $output_path`
            exitcode, out, err = _runcmd(cmd)
            if exitcode != 0
                error("non-zero exit code running r2r to make plot")
            end
            res = read(output_path, String)
        end
    end
    return exitcode, res, out, err
end

end # module R2R
