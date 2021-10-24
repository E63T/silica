require "nya_serializable"
require "./enumerated_value"
require "./child_of"

module Silica::Layout
  class Field
  end

  class EnumeratedValues
    include Nya::Serializable
    include ChildOf(Field)

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
  
    def empty?
      values.empty? && derived_from.empty?
    end
    
    

    def lookup_enumerated_values(gen)
      values = self.values.dup
      unless derived_from.empty?
        if m = derived_from.match /^([^\.]+)\.([^\.]+)\.([^\.]+)$/
          reg_name = m[0].downcase
          field_name = m[1].downcase
          ev_name = m[2].downcase
          parent! # field
            .parent! # register
            .parent! # periph
            .registers
            .select(&.name.downcase.==(reg_name))
            .flat_map(&.fields)
            .select(&.name.downcase.==(field_name))
            .flat_map(&.enumerated_values)
            .select(&.name.downcase.==(ev_name))
            .first?
            .try do |v|
              values += v.lookup_enumerated_values(gen)
            end
        else
          parent! # field
            .parent! # register
            .fields
            .map(&.enumerated_values)
            .select(&.name.downcase.==(derived_from.downcase))
            .first?
            .try do |v|
              values += v.lookup_enumerated_values(gen)
            end
        end
      end
      values
    end
  end
end