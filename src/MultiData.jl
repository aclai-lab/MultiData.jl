
__precompile__()

module MultiData

using DataFrames
using StatsBase
using ScientificTypes
using DataStructures
using Statistics
using Catch22
using CSV
using Random
using Reexport
using SoleBase
using SoleBase: AbstractDataset, slicedataset

@reexport using DataFrames

import Base: eltype, isempty, iterate, map, getindex, length
import Base: firstindex, lastindex, ndims, size, show, summary
import Base: vcat
import Base: isequal, isapprox
import Base: ==, ≈
import Base: in, issubset, setdiff, setdiff!, union, union!, intersect, intersect!
import Base: ∈, ⊆, ∪, ∩
import DataFrames: describe
import ScientificTypes: show

import SoleBase: instances, ninstances, concatdatasets
import SoleBase: eachinstance

# -------------------------------------------------------------
# exports

# export types
export AbstractDataset, AbstractMultiDataset
export MultiDataset
export AbstractLabeledMultiDataset
export LabeledMultiDataset

# information gathering
export instance, ninstances, slicedataset, concatdatasets
export modality, nmodalities
export variables, nvariables, dimensionality, sparevariables, hasvariables
export variableindex
export isapproxeq, ≊
export isapprox

export eachinstance, eachmodality

# filesystem
export datasetinfo, loaddataset, savedataset

# instance manipulation
export pushinstances!, deleteinstances!, keeponlyinstances!

# variable manipulation
export insertvariables!, dropvariables!, keeponlyvariables!, dropsparevariables!

# modality manipulation
export addmodality!, removemodality!, addvariable_tomodality!, removevariable_frommodality!
export insertmodality!, dropmodalities!

# labels manipulation
export nlabelingvariables, label, labels, labeldomain, setaslabeling!, unsetaslabeling!, joinlabels!

# re-export from DataFrames
export describe
# re-export from ScientificTypes
export schema

# -------------------------------------------------------------
# Abbreviations
const DF = DataFrames

# -------------------------------------------------------------
# Abstract types


"""
Abstract supertype for all multimodal datasets.

A concrete multimodal dataset should always provide accessors
[`data`](@ref), to access the underlying tabular structure (e.g., `DataFrame`) and
[`grouped_variables`](@ref), to access the grouping of variables
(a vector of vectors of column indices).
"""
abstract type AbstractMultiDataset <: AbstractDataset end

"""
Abstract supertype for all labeled multimodal datasets (used in supervised learning).

As any multimodal dataset, any concrete labeled multimodal dataset should always provide
the accessors [`data`](@ref), to access the underlying tabular structure (e.g., `DataFrame`) and
[`grouped_variables`](@ref), to access the grouping of variables.
In addition to these, implementations are required for
[`labeling_variables`](@ref), to access the indices of the labeling variables.

See also [`AbstractMultiDataset`](@ref).
"""
abstract type AbstractLabeledMultiDataset <: AbstractMultiDataset end

# -------------------------------------------------------------
# AbstractMultiDataset - accessors
#
# Inspired by the "Delegation pattern" of "Design Patterns and Best Practices with
# Julia" Chap. 5 by Tom KwongHands-On

"""
    grouped_variables(amd)::Vector{Vector{Int}}

Return the indices of the variables grouped by modality, of an `AbstractMultiDataset`.
The grouping describes how the different modalities are composed from the underlying
`AbstractDataFrame` structure.

See also [`data`](@ref), [`AbstractMultiDataset`](@ref).
"""
function grouped_variables(amd::AbstractMultiDataset)::Vector{Vector{Int}}
    return error("`grouped_variables` accessor not implemented for type "
        * string(typeof(amd))) * "."
end

"""
    data(amd)::AbstractDataFrame

Return the structure that underlies an `AbstractMultiDataset`.

See also [`grouped_variables`](@ref), [`AbstractMultiDataset`](@ref).
"""
function data(amd::AbstractMultiDataset)::AbstractDataFrame
    return error("`data` accessor not implemented for type "
        * string(typeof(amd))) * "."
end

function concatdatasets(amds::AbstractMultiDataset...)
    @assert allequal(grouped_variables.(amds)) "Cannot concatenate datasets " *
        "with different variable groupings. " *
        "$(@show grouped_variables.(amds))"
    Base.vcat(amds...)
end

# -------------------------------------------------------------
# AbstractLabeledMultiDataset - accessors

"""
    labeling_variables(almd)::Vector{Int}

Return the indices of the labelling variables, of the `AbstractLabeledMultiDataset`.
with respect to the underlying `AbstractDataFrame` structure (see [`data`](@ref)).

See also [`grouped_variables`](@ref), [`AbstractLabeledMultiDataset`](@ref).
"""
function labeling_variables(almd::AbstractLabeledMultiDataset)::Vector{Int}
    return error("`labeling_variables` accessor not implemented for type " *
        string(typeof(almd)))
end

function concatdatasets(almds::AbstractLabeledMultiDataset...)
    @assert allequal(grouped_variables.(almds)) "Cannot concatenate datasets " *
        "with different variable grouping. " *
        "$(@show grouped_variables.(almds))"
    @assert allequal(labeling_variables.(almds)) "Cannot concatenate datasets " *
        "with different labeling variables. " *
        "$(@show labeling_variables.(almds))"
    Base.vcat(almds...)
end

Base.summary(amd::AbstractMultiDataset) = string(length(amd), "-modality ", typeof(amd))
Base.summary(io::IO, amd::AbstractMultiDataset) = print(stdout, summary(amd))

include("utils.jl")
include("describe.jl")
include("iterable.jl")
include("comparison.jl")
include("set.jl")
include("variables.jl")
include("instances.jl")
include("modalities.jl")
include("interfaces.jl")

include("MultiDataset.jl")

include("labels.jl")
include("LabeledMultiDataset.jl")

include("filesystem.jl")

include("dimensionality.jl")

export dataframe2dimensional, dimensional2dataframe
export cube2dataframe, dataframe2cube
export get_instance, maxchannelsize
export hasnans, displaystructure

include("dimensional-data.jl")

include("deprecate.jl")

end # module
