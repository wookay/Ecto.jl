# module Ecto.Changeset

module Relation

import ....Ecto

function primary_keys!(schema::Ecto.Schema.t)
    pks = schema[:primary_key]
    isempty(pks) ? throw(Ecto.NoPrimaryKeyFieldError(schema)) : pks
end

end # Ecto.Changeset.Relation
