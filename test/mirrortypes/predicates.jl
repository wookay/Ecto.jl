import Ecto.MirrorTypes: join_with
using Base.Test

@test [:a, ' ', :b] == join_with([:a,:b], ' ')
