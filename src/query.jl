# module Ecto

import Base: in
import .MirrorTypes: schema_to_mirrorstruct, mirrorstruct_to_mirror
import .MirrorTypes: MirrorModel

function in(modul::Module)
    struct = schema_to_mirrorstruct(modul)
    mirrorstruct_to_mirror(struct)
end

function from{MM<:MirrorModel}(mm::MM; kw...)
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

## Errors
type CastError
    message
end

end # module Ecto.Query
