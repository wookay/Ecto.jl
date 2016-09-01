import Ecto.MirrorTypes: MirrorModel, MirrorField, MirrorStructError
import Ecto.MirrorTypes: schema_to_mirrorstruct, plain_to_mirrorstruct, mirror_to_mirrorstruct
import Ecto.MirrorTypes: mirrorstruct_to_schema, mirrorstruct_to_plain, mirrorstruct_to_mirror

# plain
type User
   name::String
   age::Int
end

# schema
module UserSchema
using Ecto.Schema
schema("users") do
    field(:name, :string)
    field(:age, :integer)
end
end

# mirror
type _User <: MirrorModel
    name::typeof(MirrorField(:name, String, Dict()))
    age::typeof(MirrorField(:name, Int, Dict()))
end


using Base.Test

name = MirrorField(:name, String, Dict())
age = MirrorField(:age, Int, Dict())
_user = _User(name, age)
for (func, typ) in [(schema_to_mirrorstruct, UserSchema),
                    (plain_to_mirrorstruct, User),
                    (mirror_to_mirrorstruct, _user)
                   ]
    struct = func(typ)
    @test :User == struct.naming.plain
    @test :_User == struct.naming.mirror
    @test :UserSchema == struct.naming.schema
    @test [:id, :name, :age] == map(field->field.name, struct.fields)
    @test [Int, String, Int] == map(field->field.typ, struct.fields)
end

struct = plain_to_mirrorstruct(User)

schema = mirrorstruct_to_schema(struct)
@test isa(schema, Module)
@test isdefined(schema, :schema)

mirror = mirrorstruct_to_mirror(struct)
@test isa(mirror, getfield(Ecto.MirrorTypes, :_User))

plain = mirrorstruct_to_plain(struct)
@test plain == getfield(Ecto.MirrorTypes, :User)

@test_throws MirrorStructError schema_to_mirrorstruct(Base)
