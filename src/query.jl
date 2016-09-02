# module Ecto

import Base: in
import .MirrorTypes: schema_to_mirrorstruct, mirrorstruct_to_mirror
import .MirrorTypes: MirrorModel
import .Schema: Assoc

function in(modul::Module)
    struct = schema_to_mirrorstruct(modul)
    mirrorstruct_to_mirror(struct)
end

function from{Model<:MirrorModel}(model::Model; kw...)::Query.t
    vector = Assoc(kw)
    prefix = haskey(vector, :prefix) ? vector[:prefix] : nothing
    sources = [v for (k,v) in vector if :source==k]
    from = model
    joins = [v for (k,v) in vector if :join==k]
    wheres = [v for (k,v) in vector if :where==k]
    select = haskey(vector, :select) ? vector[:select] : nothing
    order_bys = [v for (k,v) in vector if :order_by==k]
    limit = haskey(vector, :limit) ? vector[:limit] : nothing
    offset = haskey(vector, :offset) ? vector[:offset] : nothing
    group_bys = [v for (k,v) in vector if :group_by==k]
    updates = [v for (k,v) in vector if :update==k]
    havings = [v for (k,v) in vector if :having==k]
    preloads = [v for (k,v) in vector if :preload==k]
    assocs = [v for (k,v) in vector if :assoc==k]
    distinct = haskey(vector, :distinct) ? vector[:distinct] : nothing
    Query.t(prefix, sources, from, joins, wheres, select, order_bys, limit, offset, group_bys, updates, havings, preloads, assocs, distinct, lock)
end

function and
end

function set
end

## Errors
type QueryError
    message
end


module Query

import Base: |>, isempty

abstract Queryable

type Applicable
end

type t <: Queryable
    prefix
    sources::Vector
    from
    joins::Vector
    wheres::Vector
    select
    order_bys::Vector
    limit
    offset
    group_bys::Vector
    updates::Vector
    havings::Vector
    preloads::Vector
    assocs::Vector
    distinct
    lock
    t() = new(nothing,[],nothing,[],[],nothing,[],nothing,nothing,[],[],[],[],[],nothing,nothing)
    t(prefix, sources, from, joins, wheres, select, order_bys, limit, offset, group_bys, updates, havings, preloads, assocs, distinct, lock) = new(prefix, sources, from, joins, wheres, select, order_bys, limit, offset, group_bys, updates, havings, preloads, assocs, distinct, lock)
end

## Errors
type CastError
    message
end

function |>(queryable::Query.t, applicable::Query.Applicable)::Query.t
    queryable
end

function isempty(queryable::Query.t, key::Symbol)::Bool
    value = getfield(queryable, key)
    isa(value, Vector) ? isempty(value) : isa(value, Void)
end

end # module Ecto.Query
