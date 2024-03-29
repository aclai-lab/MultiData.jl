
a = MultiDataset([deepcopy(df_langs), DataFrame(:id => [1, 2])])
b = MultiDataset([[2,3,4], [1]], df_data)

c = MultiDataset([[:age,:name,:stat], [:id]], df_data)
@test b == c
d = MultiDataset([[:age,:name,:stat], :id], df_data)
@test c == d

@test_throws ErrorException MultiDataset([[:age,:name,4], :id], df_data)

@test MultiData.data(a) != MultiData.data(b)
@test collect(eachmodality(a)) == collect(eachmodality(b))

md = MultiDataset([[1],[2]], deepcopy(df))
original_md = deepcopy(md)

@test isa(md, MultiDataset)

@test isa(first(eachmodality(md)), SubDataFrame)
@test length(eachmodality(md)) == nmodalities(md)

@test modality(md, [1,2]) == [modality(md, 1), modality(md, 2)]

@test isa(modality(md, 1), SubDataFrame)
@test isa(modality(md, 2), SubDataFrame)

@test nmodalities(md) == 2

@test nvariables(md) == 2
@test nvariables(md, 1) == 1
@test nvariables(md, 2) == 1

@test ninstances(md) == length(eachinstance(md)) == 3

@test_throws ErrorException slicedataset(md, [])
@test_nowarn slicedataset(md, :)
@test_nowarn slicedataset(md, 1)
@test_nowarn slicedataset(md, [1])

@test ninstances(slicedataset(md, :)) == 3
@test ninstances(slicedataset(md, 1)) == 1
@test ninstances(slicedataset(md, [1])) == 1

@test_nowarn concatdatasets(md, md, md)
@test_nowarn vcat(md, md, md)

@test dimensionality(md) == (0, 1)
@test dimensionality(md, 1) == 0
@test dimensionality(md, 2) == 1

# # test auto selection of modalities
# auto_md = MultiDataset(deepcopy(df))
# @test nmodalities(auto_md) == 0
# @test length(sparevariables(auto_md)) == nvariables(auto_md)

auto_md_all = MultiDataset(deepcopy(df); group = :all)
@test auto_md_all == md
@test !(:mixed in dimensionality(auto_md_all))

lang_md1 = MultiDataset(df_langs; group = :all)
@test nmodalities(lang_md1) == 2
@test !(:mixed in dimensionality(lang_md1))

lang_md2 = MultiDataset(df_langs; group = [1])
@test nmodalities(lang_md2) == 3
dims_md2 = dimensionality(lang_md2)
@test length(filter(x -> isequal(x, 0), dims_md2)) == 2
@test length(filter(x -> isequal(x, 1), dims_md2)) == 1
@test !(:mixed in dimensionality(lang_md2))

# test equality between mixed-columns datasets
md1_sim = MultiDataset([[1,2]], DataFrame(:b => [3,4], :a => [1,2]))
md2_sim = MultiDataset([[2,1]], DataFrame(:a => [1,2], :b => [3,4]))
@test md1_sim ≈ md2_sim
@test md1_sim == md2_sim

# addmodality!
@test addmodality!(md, [1, 2]) == md # test return
@test nmodalities(md) == 3
@test nvariables(md) == 2
@test nvariables(md, 3) == 2

@test dimensionality(md) == (0, 1, :mixed)
@test dimensionality(md, 3) == :mixed
@test dimensionality(md, 3; force = :min) == 0
@test dimensionality(md, 3; force = :max) == 1

# removemodality!
@test removemodality!(md, 3) == md # test return
@test nmodalities(md) == 2
@test nvariables(md) == 2
@test_throws Exception nvariables(md, 3) == 2

# sparevariables
@test length(sparevariables(md)) == 0
removemodality!(md, 2)
@test length(sparevariables(md)) == 1
addmodality!(md, [2])
@test length(sparevariables(md)) == 0

# pushinstances!
new_inst = DataFrame(:sex => ["F"], :h => [deepcopy(ts_cos)])[1,:]
@test pushinstances!(md, new_inst) == md # test return
@test ninstances(md) == 4
pushinstances!(md, ["M", deepcopy(ts_cos)])
@test ninstances(md) == 5

# deleteinstances!
@test deleteinstances!(md, ninstances(md)) == md # test return
@test ninstances(md) == 4
deleteinstances!(md, ninstances(md))
@test ninstances(md) == 3

# keeponlyinstances!
pushinstances!(md, ["F", deepcopy(ts_cos)])
pushinstances!(md, ["F", deepcopy(ts_cos)])
pushinstances!(md, ["F", deepcopy(ts_cos)])
@test keeponlyinstances!(md, [1, 2, 3]) == md # test return
@test ninstances(md) == 3
for i in 1:ninstances(md)
    @test instance(md, i) == instance(original_md, i)
end

# modality manipulation
@test addvariable_tomodality!(md, 1, 2) === md # test return
@test nvariables(md, 1) == 2
@test dimensionality(md, 1) == :mixed

@test removevariable_frommodality!(md, 1, 2) === md # test return
@test nvariables(md, 1) == 1
@test dimensionality(md, 1) == 0

# variables manipulation
@test insertmodality!(md, deepcopy(ages)) == md # test return
@test nmodalities(md) == 3
@test nvariables(md, 3) == 1

@test dropmodalities!(md, 3) == md # test return
@test nmodalities(md) == 2

insertmodality!(md, deepcopy(ages), [1])
@test nmodalities(md) == 3
@test nvariables(md, 3) == 2
@test dimensionality(md, 3) == 0

@test_nowarn md[:,:]
@test_nowarn md[1,:]
@test_nowarn md[:,1]
@test_nowarn md[:,1:2]
@test_nowarn md[[1,2],:]
@test_nowarn md[1,1]
@test_nowarn md[[1,2],[1,2]]
@test_nowarn md[1,[1,2]]
@test_nowarn md[[1,2],1]

# drop "inner" modality and multiple modalities in one operation
insertmodality!(md, DataFrame(:t2 => [deepcopy(ts_sin), deepcopy(ts_cos), deepcopy(ts_sin)]))
@test nmodalities(md) == 4
@test nvariables(md) == 4
@test nvariables(md, nmodalities(md)) == 1

# dropping the modality 3 should result in dropping the first too
# because the variable at index 1 is shared between them and will be
# dropped but modality 1 has just the variable at index 1 in it, this
# should result in dropping that modality too
dropmodalities!(md, 3)
@test nmodalities(md) == 2
@test nvariables(md) == 2
@test nvariables(md, nmodalities(md)) == 1

dropmodalities!(md, 2)
@test nmodalities(md) == 1
@test nvariables(md) == 1

# RESET
md = deepcopy(original_md)

# dropsparevariables!
removemodality!(md, 2)
@test dropsparevariables!(md) == DataFrame(names(df)[2] => df[:,2])

# keeponlyvariables!
md_var_manipulation = MultiDataset([[1], [2], [3, 4]],
    DataFrame(
        :age => [30, 9],
        :name => ["Python", "Julia"],
        :stat1 => [deepcopy(ts_sin), deepcopy(ts_cos)],
        :stat2 => [deepcopy(ts_cos), deepcopy(ts_sin)]
    )
)
md_var_manipulation_original = deepcopy(md_var_manipulation)

@test keeponlyvariables!(md_var_manipulation, [1, 3]) == md_var_manipulation
@test md_var_manipulation == MultiDataset([[1], [2]],
    DataFrame(
        :age => [30, 9],
        :stat1 => [deepcopy(ts_sin), deepcopy(ts_cos)]
    )
)

# addressing variables by name
md1 = MultiDataset([[1],[2]],
    DataFrame(
        :age => [30, 9],
        :name => ["Python", "Julia"],
    )
)
md_var_names_original = deepcopy(md1)
md2 = deepcopy(md1)

@test hasvariables(md1, :age) == true
@test hasvariables(md1, :name) == true
@test hasvariables(md1, :missing_variable) == false
@test hasvariables(md1, [:age, :name]) == true
@test hasvariables(md1, [:age, :missing_variable]) == false

@test hasvariables(md1, 1, :age) == true
@test hasvariables(md1, 1, :name) == false
@test hasvariables(md1, 1, [:age, :name]) == false

@test hasvariables(md1, 2, :name) == true
@test hasvariables(md1, 2, [:name]) == true

@test variableindex(md1, :age) == 1
@test variableindex(md1, :missing_variable) == 0
@test variableindex(md1, 1, :age) == 1
@test variableindex(md1, 2, :age) == 0
@test variableindex(md1, 2, :name) == 1

# addressing variables by name - insertmodality!
md1 = deepcopy(md_var_names_original)
md2 = deepcopy(md_var_names_original)
@test addmodality!(md1, [1]) == addmodality!(md2, [:age])

# addressing variables by name - addvariable_tomodality!
md1 = deepcopy(md_var_names_original)
md2 = deepcopy(md_var_names_original)
@test addvariable_tomodality!(md1, 2, 1) == addvariable_tomodality!(md2, 2, :age)

# addressing variables by name - removevariable_frommodality!
@test removevariable_frommodality!(md1, 2, 1) ==
    removevariable_frommodality!(md2, 2, :age)

# addressing variables by name - dropvariables!
md1 = deepcopy(md_var_names_original)
md2 = deepcopy(md_var_names_original)
@test dropvariables!(md1, 1) ==
    dropvariables!(md2, :age)
@test md1 == md2

# addressing variables by name - insertmodality!
md1 = deepcopy(md_var_names_original)
md2 = deepcopy(md_var_names_original)
@test insertmodality!(
    md1,
    DataFrame(:stat1 => [deepcopy(ts_sin), deepcopy(ts_cos)]),
    [1]
) == insertmodality!(
    md2,
    DataFrame(:stat1 => [deepcopy(ts_sin), deepcopy(ts_cos)]),
    [:age]
)

# addressing variables by name - dropvariables!
@test dropvariables!(md1, [1, 2]) ==
    dropvariables!(md2, [:age, :name])
@test md1 == md2

@test nmodalities(md1) == nmodalities(md2) == 1
@test nvariables(md1) == nvariables(md2) == 1
@test nvariables(md1, 1) == nvariables(md2, 1) == 1

# addressing variables by name - keeponlyvariables!
md1 = deepcopy(md_var_names_original)
md2 = deepcopy(md_var_names_original)
@test keeponlyvariables!(md1, [1]) == keeponlyvariables!(md2, [:age])
@test md1 == md2
