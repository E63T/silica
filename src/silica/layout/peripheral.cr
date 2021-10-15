require "nya_serializable"
require "./address_block"
require "./register"

module Silica::Layout
    class Peripheral
        include Nya::Serializable

        property name = "", description = ""

        @[Rename("groupName")]
        property group_name = ""

        @[Rename("baseAddress")]
        property base_address = 0u64

        property registers = [] of Register

        serializable name : String,
            group_name : String,
            base_address : UInt64,
            registers : Array(Register)

        also_known_as peripheral
    end
end