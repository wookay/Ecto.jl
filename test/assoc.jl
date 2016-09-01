using Ecto.Schema.Assoc
using Base.Test

vector = Assoc(Vector([(:name, String)]))

@test String == vector[:name]
@test_throws KeyError vector[:age]

push!(vector, (:age, Int))

@test [:name, :age] == keys(vector)
@test [String, Int] == values(vector)
@test haskey(vector, :age)
@test !haskey(vector, :locker)

for (k,v) in vector
end
