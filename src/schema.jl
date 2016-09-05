# module Ecto

module Schema

export primary_key, schema, field
import Base: getindex, ==

include("assoc.jl")

type Metadata
    state::Symbol # :built :loaded :deleted
    prefix::String # ""
    source::String # "source"
    context::Void
end

immutable t
    modul::Module
    struct::Assoc
    metadata::Metadata
    function t(modul::Module, struct::Assoc)
        metadata = Metadata(:built, "", "source", nothing)
        new(modul, struct, metadata)
    end
end
type PutMeta
    opts::Dict
end

type PrimaryKey
    name::Symbol
    typ::Symbol
    opts::Dict{Symbol,Any}
end

function ==(lhs::Schema.t, rhs::Schema.t)
    lhs.struct == lhs.struct
end

function getindex(schema::Schema.t, key::Symbol)
    if :fields == key
        get_attribute(schema.modul, :ecto_fields)
    elseif :associations == key
        get_attribute(schema.modul, :ecto_assocs)
    elseif :read_after_writes == key
        get_attribute(schema.modul, :ecto_fields)
    elseif :primary_key == key
        get_attribute(schema.modul, :ecto_primary_keys)
    elseif :types == key
        get_attribute(schema.modul, :ecto_fields)
    end
# `__schema__(:source)` - Returns the source as given to `schema/2`;
# `__schema__(:prefix)` - Returns optional prefix for source provided by
# `@schema_prefix` schema attribute;
# `__schema__(:primary_key)` - Returns a list of primary key fields (empty if there is none);
#
# `__schema__(:fields)` - Returns a list of all non-virtual field names;
# `__schema__(:type, field)` - Returns the type of the given non-virtual field;
# `__schema__(:types)` - Returns a map of all non-virtual
# field names and their type;
#
# `__schema__(:associations)` - Returns a list of all association field names;
# `__schema__(:association, assoc)` - Returns the association reflection of the given assoc;
#
# `__schema__(:embeds)` - Returns a list of all embedded field names;
# `__schema__(:embed, embed)` - Returns the embedding reflection of the given embed;
#
# `__schema__(:read_after_writes)` - Non-virtual fields that must be read back
# from the database after every write (insert or update);
#
# `__schema__(:autogenerate_id)` - Primary key that is auto generated on insert;
end

function primary_key(pk::Bool)
    __MODULE__ = current_module()
    __init_attributes__(__MODULE__)
    __attributes__[__MODULE__][:primary_key] = pk
end

function schema(block::Function, source::String)
    schema(block, source, true, :id)
end

function schema(block::Function, source::String, meta::Bool, typ::Symbol)
    __MODULE__ = current_module()
    __init_attributes__(__MODULE__)
    register_attribute(__MODULE__, :changeset_fields, accumulate= true)
    register_attribute(__MODULE__, :struct_fields, accumulate= true)
    prefix = get_attribute(__MODULE__, :schema_prefix)
    if meta
        put_struct_field(__MODULE__, :__meta__, Metadata(:built, prefix, source, nothing))
    end
    primary_key = get_attribute(__MODULE__, :primary_key)
    if primary_key == nothing
        primary_key = PrimaryKey(:id, typ, Dict(:autogenerate=>true))
    end
    if false == primary_key
        primary_key_fields = []
    else
        (name, typ, opts) = (primary_key.name, primary_key.typ, primary_key.opts)
        Schema.__field__(__MODULE__, name, typ, merge(Dict(:primary_key=>true), opts))
        primary_key_fields = [name]
    end
    block()
end

## API
function field(name::Symbol, typ::Symbol; kw...)
    __MODULE__ = current_module()
    opts = Dict(kw)
    Schema.__field__(__MODULE__, name, typ, opts)
end

function timestamps
end

function has_many
end

function has_one
end

function belongs_to
end

function many_to_many
end

## Callbacks
function __field__(modul::Module, name::Symbol, typ::Symbol, opts::Dict)
    pk = haskey(opts, :primary_key) ? opts[:primary_key] : false
    default = default_for_type(typ, opts)
    put_attribute(modul, :changeset_fields, (name, typ))
    put_struct_field(modul, name, default)
    virtual = haskey(opts, :virtual) ? opts[:virtual] : false
    if !virtual
        raw = haskey(opts, :read_after_writes) ? opts[:read_after_writes] : false
        raw && put_attribute(modul, :ecto_raw, name)
        gen = haskey(opts, :autogenerate) ? opts[:autogenerate] : false
        if isa(gen, Bool)
            gen && store_type_autogenerate!(modul, name, typ, pk)
        else
            store_mfa_autogenerate!(mod, name, typ, gen)
        end
        pk && put_attribute(modul, :ecto_primary_keys, name)
        put_attribute(modul, :ecto_fields, (name, typ))
    end
end

function store_mfa_autogenerate!(modul::Module, name::Symbol, typ::Symbol, mfa)
    put_attribute(modul, :ecto_autogenerate, (name, mfa))
end

function store_type_autogenerate!(modul::Module, name::Symbol, typ::Symbol, pk::Bool)
    id = autogenerate_id(typ)
    put_attribute(modul, :ecto_autogenerate_id, (name, id))
    put_attribute(modul, :ecto_autogenerate, (name, (:typ, :autogenerate, [])))
end

function autogenerate_id(id)
    id in [:id, :binary_id] ? id : nothing
end

function default_for_type(typ, opts)
    haskey(opts, :default) ? opts[:default] : nothing
end

## attributes
__attributes__ = Dict{Module, Any}()

function register_attribute(modul::Module, key::Symbol; kw...)
end

function put_attribute(modul::Module, key::Symbol, obj::Any)
    push!(__attributes__[modul][key], obj)
end

function get_attribute(modul::Module, key::Symbol)
    __attributes__[modul][key]
end

function put_struct_field(modul::Module, name::Symbol, assoc::Any)
    put_attribute(modul, :struct_fields, (name,assoc))
end

function __init_attributes__(modul::Module)
    if !haskey(__attributes__, modul)
        __attributes__[modul] = Dict{Symbol,Any}(
            # beforehands
            :primary_key => nothing,
            :schema_prefix => "",
            :foreign_key_type => nothing,
            :timestamps_opts => nothing,
            :derive => nothing,
            # attributes
            :changeset_fields => Vector{Tuple{Symbol,Any}}(),
            :struct_fields => Vector{Tuple{Symbol,Any}}(),
            :ecto_primary_keys => Vector(),
            :ecto_fields => Vector{Tuple{Symbol,Any}}(),
            :ecto_assocs => Vector(),
            :ecto_embeds => Vector(),
            :ecto_raw => Vector(),
            :ecto_autogenerate => Vector{Tuple{Symbol,Any}}(),
            :ecto_autoupdate => Vector(),
            :ecto_autogenerate_id => Vector{Tuple{Symbol,Any}}()
        )
    end
end

end # module Ecto.Schema


import Base: rem, |>
import .MirrorTypes: plain_to_mirrorstruct, mirrorstruct_to_schema

function rem(modul::Module; vec...)::Schema.t
    Schema.t(modul, Schema.Assoc(vec))
end

function rem(typ::Type; kw...)::Schema.t
    data = nothing
    mirror = plain_to_mirrorstruct(typ)
    modul = mirrorstruct_to_schema(mirror)
    struct = Assoc(kw)
    Schema.t(modul, struct)
end

function |>(schema::Schema.t, func::Function, args...; kw...)
    func(schema, args...; kw...)
end

function |>(schema::Schema.t, meta::Schema.PutMeta)::Schema.t
    for (k,v) in meta.opts
        setfield!(schema.metadata, k, v)
    end
    schema
end

function put_meta(; kw...)::Schema.PutMeta
    Schema.PutMeta(Dict(kw))
end


## Errors
type NoPrimaryKeyFieldError
    message
    NoPrimaryKeyFieldError(schema::Schema.t) = new("schema has no primary key")
end

type NoPrimaryKeyValueError
    message
end

type ChangeError
    message
end
