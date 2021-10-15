require "nya_serializable"

module Silica::Layout
    class AddressBlock
        include Nya::Serializable

        property offset = 0u64, size = 0u64, usage = "registers"

        serializable offset : UInt64, size : UInt64, usage : String

        also_known_as addressBlock
    end
end