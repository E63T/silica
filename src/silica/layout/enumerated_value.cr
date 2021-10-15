require "nya_serializable"

module Silica::Layout

    class EnumeratedValue
        include Nya::Serializable

        property name = "", description = "", value = 0u64

        serializable name : String, description : String, value : UInt64

        also_known_as enumeratedValue
    end
end