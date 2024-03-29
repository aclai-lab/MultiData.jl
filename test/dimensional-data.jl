_ninstances = 4
for ((channel_size1, channel_size2), shouldfail) in [
    ((),()) => false,
    ((1),(1)) => false,
    ((1,2),(1,2)) => false,
    ((1,2),(1,)) => true,
    ((1,),()) => true,
    ((1,2),()) => true,
]
    local df = DataFrame(
        x=[rand(channel_size1...) for i_instance in 1:_ninstances],
        y=[rand(channel_size2...) for i_instance in 1:_ninstances]
    )

    if shouldfail
        @test_throws AssertionError MultiData.dataframe2cube(df)
    else
        cube, varnames = @test_nowarn MultiData.dataframe2cube(df)
    end
end

begin
    local df = MultiData.dimensional2dataframe(eachslice(rand(3,4); dims=2), ["a", "b", "c"])
    @test first(unique(size.(dataframe2dimensional(df)[1]))) == (3,)
end

begin
    local df = MultiData.dimensional2dataframe(eachslice(rand(1,3,4); dims=3), ["a", "b", "c"])
    @test first(unique(size.(dataframe2dimensional(df)[1]))) == (1,3)
end

begin
    local df = MultiData.dimensional2dataframe(eachslice(rand(2,3,4); dims=3), ["a", "b", "c"])
    @test first(unique(size.(dataframe2dimensional(df)[1]))) == (2,3)
end

begin
    local df = MultiData.dimensional2dataframe(eachslice(rand(2,2,3,4); dims=4), ["a", "b", "c"])
    @test first(unique(size.(dataframe2dimensional(df)[1]))) == (2,2,3)
end
