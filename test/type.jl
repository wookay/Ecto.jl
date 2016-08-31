using Ecto

using Base.Test

import Ecto.Typ: dump

@testset "Ecto.Typ.dump" begin
    @test (:ok, nothing) == dump(Val{:string}, nothing)
    @test (:ok, "foo") == dump(Val{:string}, "foo")
    @test (:ok, 1) == dump(Val{:integer}, 1)
    @test :error == dump(Val{:integer}, "10")
    @test (:ok, "foo") == dump(Val{:binary}, "foo")
    @test :error == dump(Val{:binary}, 1)
    @test (:ok, [1, 2, 3]) == dump(Val{(:array, :integer)}, [1, 2, 3])
    @test :error == dump(Val{(:array, :integer)}, ["1", "2", "3"])
    @test (:ok, ["1", "2", "3"]) == dump(Val{(:array, :binary)}, ["1", "2", "3"])
end
