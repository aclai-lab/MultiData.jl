

# -------------------------------------------------------------
# LabeledMultiDataset

"""
    LabeledMultiDataset(md, labeling_variables)

Create a `LabeledMultiDataset` by associating an `AbstractMultiDataset` with
some labeling variables, specified as a column index (`Int`)
or a vector of column indices (`Vector{Int}`).

# Arguments

* `md` is the original `AbstractMultiDataset`;
* `labeling_variables` is an `AbstractVector` of integers indicating the indices of the
    variables that will be set as labels.

# Examples

```julia-repl
julia> lmd = LabeledMultiDataset(MultiDataset([[2],[4]], DataFrame(
           :id => [1, 2],
           :age => [30, 9],
           :name => ["Python", "Julia"],
           :stat => [[sin(i) for i in 1:50000], [cos(i) for i in 1:50000]]
       )), [1, 3])
● LabeledMultiDataset
   ├─ labels
   │   ├─ id: Set([2, 1])
   │   └─ name: Set(["Julia", "Python"])
   └─ dimensionalities: (0, 1)
- Modality 1 / 2
   └─ dimensionality: 0
2×1 SubDataFrame
 Row │ age
     │ Int64
─────┼───────
   1 │    30
   2 │     9
- Modality 2 / 2
   └─ dimensionality: 1
2×1 SubDataFrame
 Row │ stat
     │ Array…
─────┼───────────────────────────────────
   1 │ [0.841471, 0.909297, 0.14112, -0…
   2 │ [0.540302, -0.416147, -0.989992,…

```
"""
struct LabeledMultiDataset{MD} <: AbstractLabeledMultiDataset
    md::MD
    labeling_variables::Vector{Int}

    function LabeledMultiDataset{MD}(
        md::MD,
        labeling_variables::Union{Int,AbstractVector},
    ) where {MD<:AbstractMultiDataset}
        labeling_variables = Vector{Int}(vec(collect(labeling_variables)))
        for i in labeling_variables
            if _is_variable_in_modalities(md, i)
                # TODO: consider enforcing this instead of just warning
                @warn "Setting as label a variable used in a modality: this is " *
                    "discouraged and probably will not be allowed in future versions"
            end
        end

        return new{MD}(md, labeling_variables)
    end

    function LabeledMultiDataset(
        md::MD,
        labeling_variables::Union{Int,AbstractVector},
    ) where {MD<:AbstractMultiDataset}
        return LabeledMultiDataset{MD}(md, labeling_variables)
    end

    # TODO
    # function LabeledMultiDataset(
    #     labeling_variables::AbstractVector{L},
    #     dfs::Union{AbstractVector{DF},Tuple{DF}}
    # ) where {DF<:AbstractDataFrame,L}

    #     return LabeledMultiDataset(labeling_variables, MultiDataset(dfs))
    # end

    # # Helper
    # function LabeledMultiDataset(
    #     labeling_variables::AbstractVector{L},
    #     dfs::AbstractDataFrame...
    # ) where {L}
    #     return LabeledMultiDataset(labeling_variables, collect(dfs))
    # end

end

# -------------------------------------------------------------
# LabeledMultiDataset - accessors

unlabeleddataset(lmd::LabeledMultiDataset) = lmd.md
grouped_variables(lmd::LabeledMultiDataset) = grouped_variables(unlabeleddataset(lmd))
data(lmd::LabeledMultiDataset) = data(unlabeleddataset(lmd))

labeling_variables(lmd::LabeledMultiDataset) = lmd.labeling_variables

# -------------------------------------------------------------
# LabeledMultiDataset - informations

function show(io::IO, lmd::LabeledMultiDataset)
    println(io, "● LabeledMultiDataset")
    _prettyprint_labels(io, lmd)
    _prettyprint_modalities(io, lmd)
    _prettyprint_sparevariables(io, lmd)
end

# -------------------------------------------------------------
# LabeledMultiDataset - variables

function sparevariables(lmd::LabeledMultiDataset)
    filter!(var -> !(var in labeling_variables(lmd)), sparevariables(unlabeleddataset(lmd)))
end

function dropvariables!(lmd::LabeledMultiDataset, i::Integer)
    dropvariables!(unlabeleddataset(lmd), i)

    for (i_lbl, lbl) in enumerate(labeling_variables(lmd))
        if lbl > i
            labeling_variables(lmd)[i_lbl] = lbl - 1
        end
    end

    return lmd
end

# -------------------------------------------------------------
# LabeledMultiDataset - utils

function SoleBase.instances(
    lmd::LabeledMultiDataset,
    inds::AbstractVector{<:Integer},
    return_view::Union{Val{true},Val{false}} = Val(false)
)
    LabeledMultiDataset(
        SoleBase.instances(unlabeleddataset(lmd), inds, return_view),
        labeling_variables(lmd)
    )
end

function vcat(lmds::LabeledMultiDataset...)
    LabeledMultiDataset(
        vcat(unlabeleddataset.(lmds)...),
        labeling_variables(first(lmds))
    )
end

function _empty(lmd::LabeledMultiDataset)
    return LabeledMultiDataset(
        _empty(unlabeleddataset(lmd)),
        deepcopy(grouped_variables(lmd)),
    )
end
