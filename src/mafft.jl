"""
    mafft(input_file, output_file = tempname(); options = "--auto", quiet = false)
    Run mafft on input_file with the options writing to output_file
    set quiet = true (or add --quet to options" to suppress output.
    Return name of output_file
    Documentation says "--maxiterate 1000 --localpair" is probably most accurate
"""
function mafft(input_file, output_file = tempname(); options = "--auto", quiet = false)
  # High accuracy (for <~200 sequences x <~2,000 aa/nt):
  # % mafft --maxiterate 1000 --localpair  in > out (% linsi in > out is also ok) L-INS-i (Probably most accurate, very slow)

  # % mafft --maxiterate 1000 --genafpair  in > out (% einsi in > out) E-INS-i (Suitable for sequences with long unalignable regions, very slow)

  # % mafft --maxiterate 1000 --globalpair in > out (% ginsi in > out) G-INS-i (Suitable for sequences of similar lengths, very slow)

    ## https://mafft.cbrc.jp/alignment/software/algorithms/algorithms.html
    ## For simple alignments, they give identical results

    if quiet
        options *= " --quiet"
    end
    _mafft = "mafft" ## TODO get from MAFFT_jll
    _options = split(options)
    cmd = `$(_mafft) $(_options)  $input_file`
    run(pipeline(cmd, stdout = output_file))
    output_file
end

## read msa
using FASTX
using BioSequences
abstract type AbstractMsa end 
struct MSA <: AbstractMsa
    filename::String
    identifiers::Vector{String}
    sequences::Vector{String}
end

struct MSA_window <: AbstractMsa
    filename::String
    identifiers::Vector{String}
    sequences::Vector{String}
    window::Tuple{Int,Int} ## first position, last position
end

struct MSA_matrix{T}
    filename::String
    identifiers::Vector{String}
    seq_matrix::T 
    window::Tuple{Int,Int}
    is_full::Bool ## is the window the full msa?
end

function read_msa(file)
    records = collect(FASTAReader(open(file,"r")))
    MSA(file,
        string.(identifier.(records)),
        string.(FASTA.sequence.(records)),
        )    
end

"""
    msa_matrix(msa::AbstractMsa)
    convert a MSA obejct to matrix of Char values
"""
function msa_matrix(msa::AbstractMsa; reverse_order=false)
    res = only.(hcat(split.(msa.sequences, "")...))
    if reverse_order
        res = res[:,end:-1:1]
    end
    res
end


function plot_charmatrix!(ax, mat)
    p1 = vec(Point2f.(Tuple.(CartesianIndices(mat))))
    t1 = vec(mat)
    scatter!(ax, p1,
             marker = t1,
             align = (:center, :center),
             color = :black,
             )
     hidedecorations!(ax)
end

## plot an msa
## Make function that works with static as well as observable input
## or dispatch it on type of arguments
function plot_msa!(ax, msa_matrix, color_matrix; hide_decorations=true)
    
end

## slice an msa. This is used with lift to make a scrollable msa.
function slize_msa(msa, start_pos, end_pos)
    
end

