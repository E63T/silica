require "nya_serializable"
require "./child_of"
require "./field"

module Silica::Layout
  class Peripheral
  end

  class Register
    include Nya::Serializable
    include ChildOf(Peripheral)

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

    def pre_generate(gen)
      fields.each &.parent=(self)
      fields.each &.pre_generate(gen)
    end

    def generate(gen : Silica::Generator, periph : Peripheral)

      gen.gen.g_enum "#{name.downcase}_v", "uint#{gen.width}_t" do 
        fields.each &.generate(gen)  
      end

      gen.gen.separator
      
      gen.gen.g_module "#{name.downcase}_traits", ["std::hardware::static_register_traits<0x#{(periph.base_address + address_offset).to_s(16)}>"] do
        g_alias "field_type", "#{name.downcase}_v"
      end
      
      gen.gen.separator

      gen.gen.g_alias gen.gen.escape_keywords(name.downcase), gen.gen.generic(gen.gen.path(%w(std hardware register_access)), "#{name.downcase}_traits")
    
      gen.gen.separator
    end
  end
end
