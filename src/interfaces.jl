using ScientificTypes

function ScientificTypes.schema(md::AbstractMultiDataset, i::Integer; kwargs...)
    ScientificTypes.schema(modality(md, i); kwargs...)
end


using Tables

Tables.istable(X::AbstractMultiDataset) = true
Tables.rowaccess(X::AbstractMultiDataset) = true

function Tables.rows(X::AbstractMultiDataset)
    eachinstance(X)
end

function Tables.subset(X::AbstractMultiDataset, inds; viewhint = nothing)
    SoleBase.slicedataset(X, inds; return_view = (isnothing(viewhint) || viewhint == true))
end

function _columntruenames(row::Tuple{AbstractMultiDataset,Integer})
    multilogiset, i_row = row
    return [(i_mod, i_feature) for i_mod in 1:nmodalities(multilogiset) for i_feature in Tables.columnnames((modality(multilogiset, i_mod), i_row),)]
end

function Tables.getcolumn(row::Tuple{AbstractMultiDataset,Integer}, i::Int)
    multilogiset, i_row = row
    (i_mod, i_feature) = _columntruenames(row)[i] # Ugly and not optimal. Perhaps AbstractMultiDataset should have an index attached to speed this up
    m = modality(multilogiset, i_mod)
    feats, featchs = Tables.getcolumn((m, i_row), i_feature)
    featchs
end

function Tables.columnnames(row::Tuple{AbstractMultiDataset,Integer})
    # [(i_mod, i_feature) for i_mod in 1:nmodalities(multilogiset) for i_feature in Tables.columnnames((modality(multilogiset, i_mod), i_row),)]
    1:length(_columntruenames(row))
end


using MLJModelInterface: Table
import MLJModelInterface: selectrows, nrows

function nrows(X::AbstractMultiDataset)
    length(Tables.rows(X))
end

function selectrows(X::AbstractMultiDataset, r)
    r = r isa Integer ? (r:r) : r
    return Tables.subset(X, r)
end

# function scitype(X::AbstractMultiDataset)
#     Table{
#         if featvaltype(X) <: AbstractFloat
#             scitype(1.0)
#         elseif featvaltype(X) <: Integer
#             scitype(1)
#         elseif featvaltype(X) <: Bool
#             scitype(true)
#         else
#             @warn "Unexpected featvaltype: $(featvaltype(X)). SoleModels may need adjustments."
#             typejoin(scitype(1.0), scitype(1), scitype(true))
#         end
#     }
# end
