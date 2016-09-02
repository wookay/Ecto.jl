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

vector = Assoc(Vector([(:join, 0), (:where, 1), (:where, 2)]))
@test [:join, :where, :where] == keys(vector)
@test [0, 1, 2] == values(vector)
@test [:where, :where] == [k for (k,v) in vector if :where==k]
@test [1, 2] == [v for (k,v) in vector if :where==k]
@test [] == [v for (k,v) in vector if :locker==k]
@test haskey(vector, :where)
