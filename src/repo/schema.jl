# module Ecto.Repo

module Schema

import ....Ecto

## get
function get(adapter, modul::Module, id::Any)
end

get(adapter, modul::Module, id::Void)   = throw(ArgumentError(""))
get(adapter, modul::Module, id::Symbol) = throw(Ecto.Query.CastError(""))
get(adapter, modul::Any, id::Symbol)    = throw(Ecto.QueryError(""))


## get_by
function get_by(adapter, modul::Module, opts::Dict)
end

get_by(adapter, modul::Module, opts::Dict{Symbol,Void})   = throw(ArgumentError(""))
get_by(adapter, modul::Module, opts::Dict{Symbol,Symbol}) = throw(Ecto.Query.CastError(""))
get_by(adapter, modul::Any, opts::Dict{Symbol,Symbol})    = throw(Ecto.QueryError(""))

## insert!
function insert!(adapter, schema::Ecto.Schema.t, opts::Dict)
    modul = schema.modul
    primary_keys = Ecto.Schema.get_attribute(modul, :ecto_primary_keys)
    isempty(primary_keys) && throw(Ecto.NoPrimaryKeyFieldError(""))
    changeset_fields = Dict(Ecto.Schema.get_attribute(modul, :changeset_fields))
    for (k,v) in schema.struct
        typ = changeset_fields[k]
        :error == Ecto.Typ.dump(Val{typ}, v) && throw(Ecto.ChangeError(""))
    end
end


## update!
function update!(adapter, changeset::Ecto.Changeset.t, opts::Dict)
    schema = changeset.schema
    modul = schema.modul
    primary_keys = Ecto.Schema.get_attribute(modul, :ecto_primary_keys)
    isempty(primary_keys) && throw(Ecto.NoPrimaryKeyFieldError(""))
    !issubset(primary_keys, keys(schema.struct)) && throw(Ecto.NoPrimaryKeyValueError(""))
end


## delete!
function delete!(adapter, schema::Ecto.Schema.t, opts::Dict)
    modul = schema.modul
    primary_keys = Ecto.Schema.get_attribute(modul, :ecto_primary_keys)
    isempty(primary_keys) && throw(Ecto.NoPrimaryKeyFieldError(""))
    !issubset(primary_keys, keys(schema.struct)) && throw(Ecto.NoPrimaryKeyValueError(""))
end

end # module Ecto.Repo.Schema
