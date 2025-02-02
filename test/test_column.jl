@testset "Column" begin

@testset "Constructors" begin
    a = Field{:A,Int64}()
    b = Field{:B,Float64}()
    a_new = Field{:A_new,Int64}()
    c1 = @cell A::Int64 = 1
    c2 = @cell(A::Int64 = 2)
    c3 = @cell(A::Int64 = 3)
    v1 = [1,2,3]

    @test Column(a,v1) == Column{a,Int64,Vector{Int64}}(v1)
    @test Column(a) == Column{a,Int64,Vector{Int64}}(Vector{Int64}())
    @test Column(c1,c2,c3) == Column{a,Int64,Vector{Int64}}(v1)
    @test Column(a,1,2,3) == Column{a,Int64,Vector{Int64}}(v1)

    # Wait for respone from NullablesArray.jl issue #98 (https://github.com/JuliaStats/NullableArrays.jl/issues/98)
    #@test (an = @field(A::Nullable{Int64}); Column(an) == Column{an,Nullable{Int64},NullableVector{Int64}}(NullableVector{Int64}()) )
    #@test (an = @field(A::Nullable{Int64}); c1 = Cell(an,Nullable(1));  Column(c1) == Column{an,Nullable{Int64},NullableVector{Int64}}(NullableVector{Int64}([1])) )
    #@test (an = @field(A::Nullable{Int64}); Column(an,Nullable(1)) == Column{an,Nullable{Int64},NullableVector{Int64}}(NullableVector{Int64}([1])) )

    @test @column(A::Int64 = [1,2,3]) == Column{a,Int64,Vector{Int64}}(v1)
    @test (@column A::Int64 = [1,2,3]) == Column{a,Int64,Vector{Int64}}(v1)

    @test @column(a = [1,2,3]) == Column{a,Int64,Vector{Int64}}(v1)
    @test (@column a = [1,2,3]) == Column{a,Int64,Vector{Int64}}(v1)
end



@testset "Introspection" begin
    a = Field{:A,Int64}()
    b = Field{:B,Float64}()
    a_new = Field{:A_new,Int64}()
    c1 = @cell A::Int64 = 1
    c2 = @cell(A::Int64 = 2)
    c3 = @cell(A::Int64 = 3)
    v1 = [1,2,3]
    col1 = Column(a,v1)

    @test (show(col1); println(); true)

    @test name(col1) == :A
    @test name(typeof(col1)) == :A
    @test eltype(col1) == Int64
    @test eltype(typeof(col1)) == Int64
    @test field(col1) == a
    @test field(typeof(col1)) == a

    @test rename(col1,a_new) == @column a_new = v1

    @test length(col1) == 3
    @test ncol(col1) == 1
    @test nrow(col1) == 3
    @test ndims(col1) == 1
    @test size(col1) == (3,)
    @test size(col1,1) == 3
    @test isempty(col1) == false
    @test endof(col1) == 3
end

@testset "Accessing and iterating" begin
    a = Field{:A,Int64}()
    b = Field{:B,Float64}()
    a_new = Field{:A_new,Int64}()
    c1 = @cell A::Int64 = 1
    c2 = @cell(A::Int64 = 2)
    c3 = @cell(A::Int64 = 3)
    v1 = [1,2,3]
    col1 = Column(a,v1)

    @test map(x->x^2,col1) == v1.^2

    @test col1[2] == 2
    @test col1[2:3] == @column a=[2,3]
    @test col1[:] == col1

    @test (col1_copy = copy(col1); col1_copy[3] = col1[1]; col1_copy == Column(a,[1,2,1]))
    @test (col1_copy = copy(col1); col1_copy[3:-1:2] = col1[2:3]; col1_copy == Column(a,[1,3,2]))
    @test (col1_copy = copy(col1); col1_copy[:] = col1[:]; col1_copy == Column(a,[1,2,3]))

    @test (col1_copy = copy(col1); @inbounds col1_copy[3] = col1[1]; col1_copy == Column(a,[1,2,1]))
    @test (col1_copy = copy(col1); @inbounds col1_copy[3:-1:2] = col1[2:3]; col1_copy == Column(a,[1,3,2]))
    @test (col1_copy = copy(col1); @inbounds col1_copy[:] = col1[:]; col1_copy == Column(a,[1,2,3]))

    @test first(col1) == 1
    @test next(col1,start(col1)) == (1, 2)
    @test last(col1) == 3

    @test (col1_copy = copy(col1); col1_copy[2] = 3; col1_copy.data == [1,3,3])
    @test (col1_copy = deepcopy(col1); col1_copy[2] = c3; col1_copy.data == [1,3,3])
end

@testset "Composing and concatenating" begin
    a = Field{:A,Int64}()
    b = Field{:B,Float64}()
    a_new = Field{:A_new,Int64}()
    c1 = @cell A::Int64 = 1
    c2 = @cell(A::Int64 = 2)
    c3 = @cell(A::Int64 = 3)
    v1 = [1,2,3]
    col1 = Column(a,v1)

    @test vcat(c1) == Column(c1)
    @test vcat(c1,c2,c3) == col1
    @test vcat(col1,c1) == @column a = [1,2,3,1]
    @test vcat(c1,col1) == @column a = [1,1,2,3]
    @test vcat(col1,col1) == @column a = [1,2,3,1,2,3]
end

end
