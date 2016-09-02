# module Ecto.Repo

module Schema

import ....Ecto
import ....Ecto: Changeset, InvalidChangesetError

## insert!
function insert!(repo::Base.Random.UUID, adapter, struct_or_changeset::Union{Ecto.Schema.t,Changeset.t}, opts::Dict)::Ecto.Schema.t
    (isok, schema_or_changeset) = insert(repo, adapter, struct_or_changeset, opts)
    :ok==isok ? schema_or_changeset : throw(Ecto.InvalidChangesetError(:insert, schema_or_changeset))
end

## update!
function update!(repo::Base.Random.UUID, adapter, struct_or_changeset::Union{Ecto.Schema.t,Changeset.t}, opts::Dict)
    (isok, schema_or_changeset) = update(repo, adapter, struct_or_changeset, opts)
    :ok==isok ? schema_or_changeset : throw(Ecto.InvalidChangesetError(:update, schema_or_changeset))
end

## insert_or_update!
function insert_or_update!(repo::Base.Random.UUID, adapter, changeset::Union{Ecto.Schema.t,Changeset.t}, opts::Dict)
    state = get_state(changeset)
    if :built == state
        insert!(repo, adapter, changeset, opts)
    elseif :loaded == state
        update!(repo, adapter, changeset, opts)
    else
        throw(ArgumentError("the changeset has an invalid state for Repo.insert_or_update!: $state"))
    end
end

## delete!
function delete!(repo::Base.Random.UUID, adapter, struct_or_changeset::Union{Ecto.Schema.t,Changeset.t}, opts::Dict)
    (isok, schema_or_changeset) = delete(repo, adapter, struct_or_changeset, opts)
    :ok==isok ? schema_or_changeset : throw(Ecto.InvalidChangesetError(:delete, schema_or_changeset))
end


function insert(repo::Base.Random.UUID, adapter, changeset::Changeset.t, opts::Dict)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    do_insert(repo, adapter, changeset, opts)
end

function insert(repo::Base.Random.UUID, adapter, struct::Ecto.Schema.t, opts::Dict)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    changeset = Ecto.Changeset.change(struct)
    do_insert(repo, adapter, changeset, opts)
end


function update(repo::Base.Random.UUID, adapter, changeset::Changeset.t, opts::Dict)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    do_update(repo, adapter, changeset, opts)
end

function insert_or_update(repo::Base.Random.UUID, adapter, changeset::Changeset.t, opts::Dict)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    if changeset.valid
        (:ok, changeset.data)
    else
        (:error, changeset)
    end
end

function delete(repo::Base.Random.UUID, adapter, changeset::Changeset.t, opts::Dict)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    do_delete(repo, adapter, changeset, opts)
end

function delete(repo::Base.Random.UUID, adapter, struct::Ecto.Schema.t, opts::Dict)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    changeset = Ecto.Changeset.change(struct)
    do_delete(repo, adapter, changeset, opts)
end

function do_insert(repo::Base.Random.UUID, adapter, changeset::Changeset.t, opts::Dict)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    do_action(:insert, repo, adapter, changeset, opts)
end

function do_update(repo::Base.Random.UUID, adapter, changeset::Changeset.t, opts::Dict)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    do_action(:upate, repo, adapter, changeset, opts)
end

function do_delete(repo::Base.Random.UUID, adapter, changeset::Changeset.t, opts::Dict)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    do_action(:delete, repo, adapter, changeset, opts)
end

function do_action(action::Symbol, repo::Base.Random.UUID, adapter, changeset::Changeset.t, opts::Dict)::Tuple{Symbol,Union{Changeset.t,Ecto.Schema.t}}
    prepare = changeset.prepare
    struct = struct_from_changeset!(action, changeset)
    schema = struct
    fields = schema[:fields]
    assocs = schema[:associations]
    retur = schema[:read_after_writes]
    changeset = put_repo_and_action(changeset, action, repo)
    if changeset.valid
        metadata = schema.metadata
        changes = changeset.changes
        (changes, extra) = autogenerate_id(metadata, changeset.changes, retur, adapter)
        dump_changes!(action, changes, schema, extra, changeset.types, adapter)
        if :insert != action
            filters = add_pk_filter!(changeset.filters, struct)
        end
        values = []
        extra = []
        autogen = []
        changeset = load_changes(changeset, :delete==action ? :deleted : :loaded, vcat(values, extra), autogen, adapter)
        (:ok, changeset.data)
    else
        (:error, changeset)
    end
end

function load_changes(changeset, state, values, autogen, adapter)::Changeset.t
    types = changeset.types
    changes = changeset.changes
    schema = changeset.data
    changeset.data = schema
    changeset
end

function put_repo_and_action(changeset::Changeset.t, action::Symbol, repo::Base.Random.UUID)::Changeset.t
     changeset.action = action
     changeset.repo = repo
     changeset.types = changeset.data[:types]
     changeset.changes = changeset.data.struct
     changeset
end

function struct_from_changeset!(action, changeset::Changeset.t)::Ecto.Schema.t
    isa(changeset.data, Void) && throw(ArgumentError("cannot $action a changeset without :data"))
    changeset.data
end

function dump_field!(action::Symbol, schema::Ecto.Schema.t, field::Symbol, typ, value, adapter)
    (isok, value) = Ecto.Typ.adapter_dump(adapter, typ, value)
    if :ok == isok
        (field, value)
    else
        throw(Ecto.ChangeError("value $value for $field in $action does not match type $typ"))
    end
end

function dump_fields!(action::Symbol, schema::Ecto.Schema.t, kw::Ecto.Assoc, types, adapter)
    typedict = Dict(types)
    for (field, value) in kw
        typ = typedict[field]
        dump_field!(action, schema, field, typ, value, adapter)
    end
end

function dump_changes!(action, changes, schema, extra, types, adapter)
    dumped = []
    autogen = []
    dump_fields!(action, schema, changes, types, adapter)
    (dumped, autogen)
end

function autogenerate_id(metadata, changes, retur, adapter)
    (changes, [], retur)
end

get_state(changeset::Changeset.t)::Symbol = changeset.data.metadata.state

function add_pk_filter!(filters, schema::Ecto.Schema.t)
    pks = Changeset.Relation.primary_keys!(schema)
    !issubset(pks, keys(schema.struct)) && throw(Ecto.NoPrimaryKeyValueError(""))
end

end # module Ecto.Repo.Schema
