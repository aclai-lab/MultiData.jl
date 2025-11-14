
# -------------------------------------------------------------
# AbstractMultiDataset - iterable interface

getindex(md::AbstractMultiDataset, i::Integer) = modality(md, i)
function getindex(md::AbstractMultiDataset, indices::AbstractVector{<:Integer})
    return [modality(md, i) for i in indices]
end

length(md::AbstractMultiDataset) = length(grouped_variables(md))
ndims(md::AbstractMultiDataset) = length(md)
isempty(md::AbstractMultiDataset) = length(md) == 0
firstindex(md::AbstractMultiDataset) = 1
lastindex(md::AbstractMultiDataset) = length(md)
eltype(::Type{AbstractMultiDataset}) = SubDataFrame
eltype(::AbstractMultiDataset) = SubDataFrame

Base.@propagate_inbounds function iterate(md::AbstractMultiDataset, i::Integer = 1)
    (i ≤ 0 || i > length(md)) && return nothing
    return (@inbounds modality(md, i), i+1)
end

function getindex(
    md::AbstractMultiDataset,
    i::Colon,
    j::Colon
)
    return deepcopy(md)
end

# Slice on instances and modalities/variables
function getindex(
    md::AbstractMultiDataset,
    i::Union{Integer,AbstractVector{<:Integer},Tuple{<:Integer}},
    j::Union{Integer,AbstractVector{<:Integer},Tuple{<:Integer}},
)
    i = vec(collect(i))
    j = vec(collect(j))
    return getindex(getindex(md, i, :), :, j)
    # return error("MultiDataset currently does not allow simultaneous slicing on " *
    #     * "instances and modalities/variables.")
end

# Slice on modalities/variables
function getindex(
    md::AbstractMultiDataset,
    ::Colon,
    j::Union{Integer,AbstractVector{<:Integer},Tuple{<:Integer}},
)
    j = vec(collect(j))
    return keeponlymodalities!(deepcopy(md), j)
end

# Slice on instances
function getindex(
    md::AbstractMultiDataset,
    i::Union{Integer,AbstractVector{<:Integer},Tuple{<:Integer}},
    ::Colon
)
    i = vec(collect(i))
    return SoleBase.slicedataset(md, i; return_view = false)
end

function getindex(
    md::AbstractMultiDataset,
    i::Union{Colon,<:Integer,<:AbstractVector{<:Integer},<:Tuple{<:Integer}},
    j::typeof(!),
)
    # NOTE: typeof(!) is left-out to avoid problems but consider adding it
    return error("MultiDataset currently does not allow in-place operations.")
end

function getindex(
    md::AbstractMultiDataset,
    i::typeof(!),
    j::Union{Colon,<:Integer,<:AbstractVector{<:Integer},<:Tuple{<:Integer}},
)
    # NOTE: typeof(!) is left-out to avoid problems but consider adding it
    return error("MultiDataset currently does not allow in-place operations.")
end



# # TODO: consider adding interfaces to access the underlying AbstractDataFrame
# function getindex(
#     md::AbstractMultiDataset,
#     i::Union{Integer,AbstractVector{<:Integer},Tuple{<:Integer}},
#     j::Union{
#         <:Integer,
#         <:AbstractVector{<:Integer},
#         <:Tuple{<:Integer},
#         Symbol,
#         <:AbstractVector{Symbol}
#     },
# )
#     return keeponlyvariables!(deepcopy(md), j)
# end
