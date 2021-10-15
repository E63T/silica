require "nya_serializable"
require "./field"

module Silica::Layout
    class Register
        include Nya::Serializable

        property name = "", description = "", size = 0u64, access = "read-write"

        @[Rename("displayName")]
        property display_name = ""

        @[Rename("addressOffset")]
        property address_offset = 0u64

        @[Rename("resetValue")]
        property reset_value = 0u64

        property fields = [] of Field

        serializable name : String,
            description : String,
            size : UInt64,
            access : String,
            display_name : String,
            address_offset : UInt64,
            reset_value : UInt64,
            fields : Array(Field)

        also_known_as register
    end
end