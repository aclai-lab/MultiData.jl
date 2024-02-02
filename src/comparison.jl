
# -------------------------------------------------------------
# AbstractMultiDataset - comparison

"""
    ==(md1, md2)
    isequal(md1, md2)

Determine whether two `AbstractMultiDataset`s are equal.

Note: the check is also performed on the instances; this means that if the two datasets only
differ by the order of their instances, this will return `false`.

If the intent is to check if two `AbstractMultiDataset`s have same instances regardless
of the order use [`isapproxeq`](@ref) instead.
If the intent is to check if two `AbstractMultiDataset`s have same variable groupings and
variables use [`isapprox`](@ref) instead.
"""
function isequal(md1::AbstractMultiDataset, md2::AbstractMultiDataset)
    return (data(md1) == data(md2) && grouped_variables(md1) == grouped_variables(md2)) ||
        (_same_md(md1, md2) && _same_labeling_variables(md1, md2))
end
function ==(md1::AbstractMultiDataset, md2::AbstractMultiDataset)
    return isequal(md1, md2)
end

"""
    ≊(md1, md2)
    isapproxeq(md1, md2)

Determine whether two `AbstractMultiDataset`s have
the same variable groupings, variables and instances.

Note: the order of the instance does not matter.

If the intent is to check if two `AbstractMultiDataset`s have same instances in the
same order use [`isequal`](@ref) instead.
If the intent is to check if two `AbstractMultiDataset`s have same variable groupings and
variables use [`isapprox`](@ref) instead.

TODO review
"""
function isapproxeq(md1::AbstractMultiDataset, md2::AbstractMultiDataset)
    return isequal(md1, md2) && _same_instances(md1, md2)
end
function ≊(md1::AbstractMultiDataset, md2::AbstractMultiDataset)
    return isapproxeq(md1, md2)
end

"""
    ≈(md1, md2)
    isapprox(md1, md2)

Determine whether two `AbstractMultiDataset`s are similar, that is,
 if they have same variable groupings
and variables. Note that this means no check over instances is performed.

If the intent is to check if two `AbstractMultiDataset`s have same instances in the same
order use [`isequal`](@ref) instead.
If the intent is to check if two `AbstractMultiDataset`s have same instances regardless
of the order use [`isapproxeq`](@ref) instead.
"""
function isapprox(md1::AbstractMultiDataset, md2::AbstractMultiDataset)
    # NOTE: _same_grouped_variables already includes variables checking
    return _same_grouped_variables(md1, md2)
end
