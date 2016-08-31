module MySchema
using Ecto.Schema
schema("my_schema") do
    field(:x, :string)
    field(:y, :binary)
end
end

module MySchemaNoPK
using Ecto.Schema
primary_key(false)
schema("my_schema") do
    field(:x, :string)
end
end


using Ecto
TestRepo = Ecto.Repo.t()

using Base.Test
@testset "needs schema with primary key field" begin
    schema = %(MySchemaNoPK, x= "abc")
    @test isa(schema, Schema.t)
    @test "abc" == schema.struct[:x]
    @test_throws Ecto.NoPrimaryKeyFieldError TestRepo.update!(schema |> Ecto.Changeset.change, force= true)
    @test_throws Ecto.NoPrimaryKeyFieldError TestRepo.delete!(schema)
end

@testset "works with primary key value" begin
    schema = %(MySchema, id= 1, x= "abc")
    @test isa(schema, Schema.t)
    @test 1 == schema.struct[:id]
    @test "abc" == schema.struct[:x]
    TestRepo.get(MySchema, 123)
    TestRepo.get_by(MySchema, x= "abc")
    TestRepo.update!(schema |> Ecto.Changeset.change, force= true)
    TestRepo.delete!(schema)
end

@testset "works with custom source schema" begin
    schema = %(MySchema, id= 1, x= "abc") |> put_meta(source= "custom_schema")
    @test isa(schema, Schema.t)
    TestRepo.update!(schema |> Ecto.Changeset.change, force= true)
    TestRepo.delete!(schema)
    to_insert = %(MySchema, x= "abc") |> put_meta(source= "custom_schema")
    @test isa(to_insert, Schema.t)
    TestRepo.insert!(to_insert)
end

@testset "fails without primary key value" begin
    schema = %(MySchema, x= "abc")
    @test_throws Ecto.NoPrimaryKeyValueError TestRepo.update!(schema |> Ecto.Changeset.change, force= true)
    @test_throws Ecto.NoPrimaryKeyValueError TestRepo.delete!(schema)
end

@testset "validates schema types" begin
    schema = %(MySchema, x= 123)
    @test_throws Ecto.ChangeError TestRepo.insert!(schema)
end

@testset "validates get" begin
    TestRepo.get(MySchema, 123)
    @test_throws ArgumentError TestRepo.get(MySchema, nothing)
    @test_throws Ecto.Query.CastError TestRepo.get(MySchema, :atom)
    @test_throws Ecto.QueryError TestRepo.get(%(Ecto.Query), :atom)
end

@testset "validates get_by" begin
    TestRepo.get_by(MySchema, id= 123)
    TestRepo.get_by(MySchema, Dict(:id=>123))
    @test_throws Ecto.Query.CastError TestRepo.get_by(MySchema, id= :atom)
end

@testset "validates update_all" begin
    TestRepo.update_all(MySchema, [set [:x "321"]])

#    e = in(MySchema)
#    query = from(e, where= e.x == "123", update= [set [:x "321"]])

#    TestRepo.update_all(query, [])
#
#    @test_throws ArgumentError TestRepo.update_all(MySchema, [set [:x "321"]], returning= [])
#
#    @test_throws Ecto.QueryError TestRepo.update_all(from(e, select= e), set= [:x "321"])
#    @test_throws Ecto.QueryError TestRepo.update_all(from(e, order_by= e.x), set= [:x "321"])
end
