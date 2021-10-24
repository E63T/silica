require "nya_serializable"

module Silica::Layout
    class Interrupt
        include Nya::Serializable

        property name = "", description = ""
        property value = 0u32

        serializable name : String, description : String, value : UInt32

        also_known_as interrupt
    end
end