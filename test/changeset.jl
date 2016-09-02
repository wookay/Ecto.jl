module TestChangeset

module MySchema
using Ecto.Schema
schema("my") do
end
end

end # module TestChangeset


using Ecto
using Base.Test
schema = Schema.t(TestChangeset.MySchema, Schema.Assoc())
changeset = Changeset.change(schema)
@test TestChangeset.MySchema == changeset.data.modul
