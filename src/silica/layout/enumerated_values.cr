require "nya_serializable"
require "./enumerated_value"

module Silica::Layout
    class EnumeratedValues
        include Nya::Serializable

        @[Rename("derivedFrom")]
        property derived_from = ""

        property name = "", values = [] of EnumeratedValue

        serializable name : String
        attribute derived_from : String

        deserializator do |this, xml|
            xml.xpath_nodes("enumeratedValue").each do |node|
                this.values << EnumeratedValue.deserialize node
            end
        end

        serializator do |this, xml|
            this.values.each do |value|
                value.serialize xml
            end
        end

        also_known_as enumeratedValues
    end
end