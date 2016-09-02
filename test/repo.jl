# tests from ecto/test/ecto/repo_test.exs

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
    TestRepo.update_all(MySchema, set= [:x "321"])

    e = in(MySchema)
    query = from(e, where= e.x == "123", update= [set [:x "321"]])
    @test isa(query, Query.t)
    TestRepo.update_all(query, [])

    @test_throws ArgumentError TestRepo.update_all(MySchema, [set [:x "321"]], returning= [])
    @test_throws Ecto.QueryError TestRepo.update_all(from(e, select= e), set= [:x "321"])
    @test_throws Ecto.QueryError TestRepo.update_all(from(e, order_by= e.x), set= [:x "321"])
end

@testset "validates delete_all" begin
    TestRepo.delete_all(MySchema)

    e = in(MySchema)
    query = from(e, where= e.x == "123")
    TestRepo.delete_all(query)

    @test_throws ArgumentError TestRepo.delete_all(MySchema, returning= [])
    @test_throws Ecto.QueryError TestRepo.delete_all(from(e, select= e))
    @test_throws Ecto.QueryError TestRepo.delete_all(from(e, order_by= e.x))
end

## Changesets
@testset "insert, update, insert_or_update and delete accepts changesets" begin
    valid = Ecto.Changeset.cast(%(MySchema, id= 1), Dict(), [])
    @test (:ok, %(MySchema)) == TestRepo.insert(valid)
    @test (:ok, %(MySchema)) == TestRepo.update(valid)
    @test (:ok, %(MySchema)) == TestRepo.insert_or_update(valid)
    @test (:ok, %(MySchema)) == TestRepo.delete(valid)
end

@testset "insert, update, insert_or_update and delete errors on invalid changeset" begin
    invalid = %(Ecto.Changeset.t, valid= false, data= %(MySchema))

    insert = %(invalid, action= :insert, repo= TestRepo.repo)
    @test (:error, insert) == TestRepo.insert(invalid)

    update = %(invalid, action= :update, repo= TestRepo.repo)
    @test (:error, update) == TestRepo.update(invalid)

    update = %(invalid, action= :insert, repo= TestRepo.repo)
    @test (:error, update) == TestRepo.insert_or_update(invalid)

    delete = %(invalid, action= :delete, repo= TestRepo.repo)
    @test (:error, delete) == TestRepo.delete(invalid)
end

@testset "insert!, update!, insert_or_update! and delete! fail on invalid changeset" begin
    invalid = %(Ecto.Changeset.t, valid= false, data= %(MySchema))

    @test_throws Ecto.InvalidChangesetError TestRepo.insert!(invalid)
    @test_throws Ecto.InvalidChangesetError TestRepo.update!(invalid)
    @test_throws Ecto.InvalidChangesetError TestRepo.insert_or_update!(invalid)
    @test_throws Ecto.InvalidChangesetError TestRepo.delete!(invalid)
end

@testset "insert!, update! and delete! fail on changeset without data" begin
    invalid = %(Ecto.Changeset.t, valid= true, data= nothing)

    @test_throws ArgumentError TestRepo.insert!(invalid)
    @test_throws ArgumentError TestRepo.update!(invalid)
    @test_throws ArgumentError TestRepo.delete!(invalid)
end
