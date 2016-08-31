module TestQuery

module MySchema
using Ecto.Schema
schema("my") do
    field(:name, :string)
    field(:age, :integer)
end
end

end # module TestQuery


using Ecto
using Base.Test
mirror = in(TestQuery.MySchema)
@test isa(mirror, Ecto.MirrorTypes._My)
@test isa(mirror.name, Ecto.MirrorTypes.MirrorField)
@test isa(mirror.age, Ecto.MirrorTypes.MirrorField)
