# module Ecto

module Changeset

import ..Schema
import ..Schema: Assoc

type t
    valid::Bool
    repo
    data::Union{Void,Schema.t}
    params::Dict{String,Any}
    changes::Assoc
    required::Vector{Symbol}
    prepare::Vector
    errors::Vector
    constraints::Vector
    validations::Assoc
    filters::Dict{Symbol,Any}
    action
    types::Vector
    t(data) = new(true, nothing, data, Dict{String,Any}(), Assoc([]), Vector{Symbol}(), [], [], [], Assoc([]), Dict{Symbol,Any}(), nothing, [])
end

function change(schema::Schema.t; kw...)::Changeset.t
    changeset = Changeset.t(schema)
    changeset.changes = setdiff(Assoc(kw), schema.struct)
    changeset
end

function change(changeset::Changeset.t; kw...)::Changeset.t
    changeset
end

function change(typ::Type; kw...)::Changeset.t
    mirror = plain_to_mirrorstruct(typ)
    schema = mirrorstruct_to_schema(mirror)
    Changeset.t(schema)
end

function cast(schema::Schema.t, params, allowed)::Changeset.t
    Changeset.t(schema)
end

function cast(assoc::Assoc, params)::Function
    (schema) -> Changeset.t(schema)
end

include("changeset/relation.jl")

end # module Ecto.Changeset


import Base: rem
import .MirrorTypes: plain_to_mirrorstruct, mirrorstruct_to_schema

function rem(schema::Ecto.Schema.t; kw...)::Changeset.t
    changes = Assoc([])
    changeset = Changeset.t(schema)
    changeset.changes = changes
    changeset
end

function rem(::Type{Changeset.t}; kw...)::Changeset.t
    opts = Dict(kw)
    data = opts[:data]
    changeset = Changeset.t(data)
    pop!(opts, :data)
    for (k,v) in kw
        setfield!(changeset, k, v)
    end
    changeset
end

function rem(changeset::Changeset.t; kw...)::Changeset.t
    opts = Dict(kw)
    for (k,v) in opts
        setfield!(changeset, k, v)
    end
    changeset
end

## Errors
type InvalidChangesetError
    messsage
    function InvalidChangesetError(action::Symbol, changeset::Changeset.t)
        new("could not perform $action because changeset is invalid")
    end
end
