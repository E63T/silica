require "nya_serializable"
require "./address_block"
require "../constant_generator"
require "./interrupt"
require "./register"

module Silica::Layout
  class Device
  end

  class Peripheral
    include Nya::Serializable
    include ConstantGenerator
    include ChildOf(Device)

    property name = "", description = ""

    @[Rename("groupName")]
    property group_name = ""

    @[Rename("baseAddress")]
    property base_address = 0u64

    @[Rename("derivedFrom")]
    property derived_from : String? = nil

    property registers = [] of Register

    serializable name : String,
      group_name : String,
      base_address : UInt64,
      registers : Array(Register)

    attribute derived_from : String

    property interrupts : Array(Interrupt) = [] of Interrupt

    deserializator do |this, xml|
      xml.xpath_nodes("interrupt").each do |node|
        this.interrupts << Interrupt.deserialize node
      end
    end

    also_known_as peripheral

    def pre_generate(gen)
      registers.each &.parent=(self)
      registers.each &.pre_generate(gen)
    end

    def generate(gen : Silica::Generator)
      if gen.config.features.doxygen
        gen.gen.doc do |d|
          d.generate do 
            if description.empty?
              summary "#{name} module"
            else
              summary description
            end
          end
        end
      end

      gen.gen.g_module name.downcase, [(derived_from.nil? ? "silica::periph" : derived_from.not_nil!.downcase)] do
        
        if gen.config.features.doxygen
          doc do |d|
            d.generate do
              summary "Base address of #{name}"
            end
          end
        end
        gen.gen.g_constant "std::uint#{gen.width}_t", "base_address", "0x#{base_address.to_s(16)}"

        registers.each &.generate(gen, self)
      end

      interrupts.each do |int|
        gen.interrupts[int.name] = name 
      end
    end
  end
end

