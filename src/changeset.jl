# module Ecto

module Changeset

import ..Schema

type t
    schema::Schema.t
end

function change(schema::Schema.t)::Changeset.t
    Changeset.t(schema)
end

end # module Ecto.Changeset
