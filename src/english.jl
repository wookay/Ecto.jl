# module Ecto

module English

function pluralize(word::String)
    string(lowercase(word), "s")
end

function singularize(word::String)
    endswith(word, "es") ? word[1:end-2] : endswith(word, "s") ? word[1:end-1] : word
end

end # module Ecto.English
