require "nya_serializable"
require "./child_of"
require "./enumerated_values"


module Silica::Layout
  class Register
  end

  class Field
    include Nya::Serializable
    include ChildOf(Register)

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

    private def mask
      "0x#{(((1u64 << bit_width) - 1) << bit_offset).to_s(16)}"
    end

    # Serializator can be omitted because this class should not be use to serialize into SVD file

    also_known_as field

    def pre_generate(gen)
      enumerated_values.parent = self
    end

    def generate(gen : Silica::Generator)
      rname = parent!.name
      if gen.config.features.field_masks
        # TODO Doxygen
        gen.gen.g_enum_member "#{name}_msk", mask
      end 

      if gen.config.features.field_offsets
        gen.gen.g_enum_member "#{name}_offset", "0x#{bit_offset.to_s(16)}"
      end
      
      if gen.config.features.field_offsets
        gen.gen.g_enum_member "#{name}_width", "0x#{bit_width.to_s(16)}"
      end
        
      ev = enumerated_values.lookup_enumerated_values(gen)
      ev.each do |value|
        gen.gen.g_enum_member "#{name}_#{value.name}", "0x#{(value.value << bit_offset).to_s(16)}"
      end

      if gen.config.features.auto_enabled_value
        if ev.empty? && bit_width == 1
          gen.gen.g_enum_member "#{name}_Enabled", "0x#{(1u64 << bit_offset).to_s(16)}"
        end
      end
    end
  end
end