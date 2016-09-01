# module Ecto.MirrorTypes

abstract MirrorModel

type MirrorField
    name::Symbol
    typ::Type
    opts::Dict
end

type MirrorPredicate
    body::Vector
end

type MirrorStatement
end

type MirrorNaming
   plain::Symbol
   mirror::Symbol
   schema::Symbol
   function MirrorNaming(::Type{Val{:plain}}, T::Type)
       plain = T.name.name
       MirrorNaming(plain)
   end
   function MirrorNaming(::Type{Val{:mirror}}, T::Type)
       mirror = T.name.name
       plain = Symbol(string(mirror)[2:end])
       MirrorNaming(plain)
   end
   function MirrorNaming(::Type{Val{:schema}}, M::Module)
       modulename = Base.module_name(M)
       plain = Symbol(replace(string(modulename), r"Schema", "") )
       MirrorNaming(plain)
   end
   function MirrorNaming(plain::Symbol)
       new(plain, Symbol(:_, plain), Symbol(plain, :Schema))
   end
end

type MirrorStruct
    naming::MirrorNaming
    fields::Vector{MirrorField}
end

type MirrorStructError
    message
end

function schema_to_mirrorstruct(modul::Module)::MirrorStruct
    if isdefined(modul, :schema) && isdefined(Ecto.Schema, :__attributes__)
        naming = MirrorNaming(Val{:schema}, modul)
        ecotofields = Ecto.Schema.get_attribute(modul, :ecto_fields)
        fields = Vector{MirrorField}()
        for (k,v) in ecotofields
            name = k
            typ = Ecto.Typ.julia_type(Val{v})
            opts = Dict()
            field = MirrorField(name, typ, opts)
            push!(fields, field)
        end
        MirrorStruct(naming, fields)
    else
        throw(MirrorStructError(""))
    end
end

function plain_to_mirrorstruct(T::Type)::MirrorStruct
    naming = MirrorNaming(Val{:plain}, T)
    names = fieldnames(T)
    fields = Vector{MirrorField}()
    if !in(:id, names)
        field = MirrorField(:id, Int, Dict())
        push!(fields, field)
    end
    for name in names
        typ = fieldtype(T, name)
        opts = Dict()
        field = MirrorField(name, typ, opts)
        push!(fields, field)
    end
    MirrorStruct(naming, fields)
end

function mirror_to_mirrorstruct{MM<:MirrorModel}(mirror::MM)::MirrorStruct
    T = typeof(mirror)
    naming = MirrorNaming(Val{:mirror}, T)
    names = fieldnames(T)
    fields = Vector{MirrorField}()
    if !in(:id, names)
        field = MirrorField(:id, Int, Dict())
        push!(fields, field)
    end
    for name in names
        field = getfield(mirror, name)
        push!(fields, field)
    end
    MirrorStruct(naming, fields)
end

function mirrorstruct_to_schema(struct::MirrorStruct)::Module
    modul = MirrorTypes
    typename = struct.naming.schema
    plural = Ecto.English.pluralize(string(struct.naming.plain))
    lines = String[]
    push!(lines, "module $typename")
    push!(lines, string("using ", Ecto.Schema))
    push!(lines, """schema("$plural") do""")
    for field in struct.fields
        push!(lines, string("    field(", repr(field.name), ", ", repr(Ecto.Typ.elixir_type(field.typ)), ")"))
    end
    push!(lines, "end")
    push!(lines, "end")
    schema_declaration = join(lines, '\n')
    # println(schema_declaration)
    eval(modul, parse(schema_declaration))
end

function mirrorstruct_to_plain(struct::MirrorStruct)::Type
    modul = MirrorTypes
    typename = struct.naming.plain
    lines = String[]
    push!(lines, "type $typename")
    for field in struct.fields
        push!(lines, string("    ", field.name, "::", field.typ))
    end
    push!(lines, "end")
    plain_declaration = join(lines, '\n')
    # println(plain_declaration)
    eval(modul, parse(plain_declaration))
    getfield(modul, typename)
end

function mirrorstruct_to_mirror(struct::MirrorStruct)
    modul = MirrorTypes
    typename = struct.naming.mirror
    lines = String[]
    push!(lines, "type $typename <: Ecto.MirrorTypes.MirrorModel")
    for field in struct.fields
        push!(lines, string("    ", field.name, "::", MirrorField))
    end
    push!(lines, "end")
    mirror_declaration = join(lines, '\n')
    # println(mirror_declaration)
    eval(modul, parse(mirror_declaration))
    T = getfield(modul, typename)
    T(struct.fields...)
end
