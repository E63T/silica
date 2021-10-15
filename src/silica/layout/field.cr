require "nya_serializable"
require "./enumerated_values"

module Silica::Layout
    class Field
        include Nya::Serializable

        property name = "", description = ""

        @[Rename("bitOffset")]
        property bit_offset = 0u64

        @[Rename("bitWidth")]
        property bit_width = 0u64

        @[Rename("enumeratedValues")]
        property enumerated_values = EnumeratedValues.new


        # TODO : writeConstraint

        serializable name : String, 
            description : String,
            bit_offset : UInt64,
            bit_width : UInt64

        deserializator do |this, xml|
            xml.xpath_node("enumeratedValues").try do |node|
                this.enumerated_values = EnumeratedValues.deserialize node
            end
        end

        # Serializator can be omitted because this class should not be use to serialize into SVD file

        also_known_as field
    end
end