using Ecto

using Base.Test

import Ecto.Typ: dump, julia_type, elixir_type

@testset "Ecto.Typ.dump" begin
    @test (:ok, nothing) == dump(Val{:string}, nothing)
    @test (:ok, "foo") == dump(Val{:string}, "foo")
    @test (:ok, 1) == dump(Val{:integer}, 1)
    @test (:error, "10") == dump(Val{:integer}, "10")
    @test (:ok, "foo") == dump(Val{:binary}, "foo")
    @test (:error, 1) == dump(Val{:binary}, 1)
    @test (:ok, [1, 2, 3]) == dump(Val{(:array, :integer)}, [1, 2, 3])
    @test (:error, ["1", "2", "3"]) == dump(Val{(:array, :integer)}, ["1", "2", "3"])
    @test (:ok, ["1", "2", "3"]) == dump(Val{(:array, :binary)}, ["1", "2", "3"])
end

@testset "Ecto.Typ.julia_type" begin
    @test Int == julia_type(Val{:id})
    @test Int == julia_type(Val{:integer})
    @test String == julia_type(Val{:string})
    @test Vector{Int} == julia_type(Val{(:array, :integer)})
    @test Vector{String} == julia_type(Val{(:array, :binary)})
end

@testset "Ecto.Typ.elixir_type" begin
    @test :integer == elixir_type(Int)
    @test :string == elixir_type(String)
    @test (:array, :integer) == elixir_type(Vector{Int})
    @test (:array, :binary) == elixir_type(Vector{String})
end
