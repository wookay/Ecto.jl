module TestQuery

module MyQuerySchema
using Ecto.Schema
schema("my") do
    field(:name, :string)
    field(:age, :integer)
end
end

end # module TestQuery


using Ecto
using Base.Test
mirror = in(TestQuery.MyQuerySchema)
@test isa(mirror.name, Ecto.MirrorTypes.MirrorField)
@test isa(mirror.age, Ecto.MirrorTypes.MirrorField)
