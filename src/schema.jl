# module Ecto

module Schema

export primary_key, schema, field

type Metadata
    state::Symbol # :built :loaded :deleted
    prefix::String # ""
    source::String # "source"
    context::Void
end

type t
    modul::Module
    struct::Dict{Symbol,Any}
    metadata::Metadata
    function t(modul::Module, struct::Dict{Symbol,Any})
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

function put_attribute(modul::Module, key::Symbol, kv::Tuple{Symbol,Any})
    merge!(__attributes__[modul][key], Dict(Pair(kv...)))
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
            :changeset_fields => Dict{Symbol,Any}(),
            :struct_fields => Dict{Symbol,Any}(),
            :ecto_primary_keys => Vector(),
            :ecto_fields => Dict{Symbol,Any}(),
            :ecto_assocs => Vector(),
            :ecto_embeds => Vector(),
            :ecto_raw => Vector(),
            :ecto_autogenerate => Dict{Symbol,Any}(),
            :ecto_autoupdate => Vector(),
            :ecto_autogenerate_id => Dict{Symbol,Any}()
        )
    end
end

end # module Ecto.Schema


import Base: rem, |>

function rem(modul::Module; kw...)::Schema.t
    Schema.t(modul, Dict{Symbol,Any}(kw))
end

function |>(schema::Schema.t, func::Function; kw...)
    if Changeset.change == func
        Changeset.t(schema)
    end
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
end

type NoPrimaryKeyValueError
    message
end

type ChangeError
    message
end
