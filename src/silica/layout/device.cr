require "nya_serializable"
require "./cpu"
require "./peripheral"

module Silica::Layout
  class Device
    include Nya::Serializable
    include ConstantGenerator

    property name = "", version = "", description = "", width = 32u32, size = 32u32           
    
    @[Rename("addressUnitBits")]
    property address_unit_bits = 8u32

    @[Rename("resetValue")]
    property reset_value = 0u32

    @[Rename("resetMask")]
    property reset_mask = 0u32

    property peripherals = [] of Peripheral

    property cpu = CPU.new

    serializable name : String, 
    version : String, 
    description : String,
    width : UInt32, 
    address_unit_bits : UInt32, 
    reset_value : UInt32,
    reset_mask : UInt32,
    peripherals : Array(Peripheral)

    deserializator do |this, xml|
      xml.xpath_node("cpu").try do |node|
        {% for name in %w(name revision) %}
          node.xpath_node({{name}}).try do |prop|
            this.cpu.{{name.underscore.id}} = prop.text
          end
        {% end %}
        
        {% for name in %w(fpuPresent mpuPresent vtorPresent vendorSystickConfig) %}
          node.xpath_node({{name}}).try do |prop|
            this.cpu.{{name.underscore.id}} = prop.text.downcase == "false"
          end
        {% end %}
        
        node.xpath_node("endian").try do |prop|
          this.cpu.endian = case prop.text.downcase
          when "big", "be", "b"
            IO::ByteFormat::BigEndian
          else
            IO::ByteFormat::LittleEndian
          end
        end

        node.xpath_node("nvicPrioBits").try do |prop|
          this.cpu.nvic_prio_bits = Nya::Serializable.parse_number(prop.text, UInt32)
        end
      end
    end

    also_known_as device

    def pre_generate(gen)
      peripherals.each &.parent=(self)
      peripherals.each &.pre_generate(gen)
    end

    def generate(gen : Silica::Generator)
      gen.gen.namespace "hw" do
        {% for prop in %w(name version description width size address_unit_bits reset_value reset_mask) %}
          auto_constant gen.gen, {{prop}}, @{{prop.id}}
        {% end %}

        separator

        namespace "cpu" do 
          @cpu.generate gen
        end

        separator

        g_module "periph" do 
          @peripherals.each do |periph|
            periph.generate gen
          end
        end

        separator

        puts "\tGenerating interrupt ID enumeration"

        if gen.config.features.doxygen
          gen.gen.doc do |d|
            d.generate do
              summary "Interrupt ID"
            end
          end
        end
        
        gen.gen.g_enum "interrupt_id" do
          gen.interrupts.each do |iname, _|
            g_enum_member iname
          end
          g_enum_member "MAX_VALUE"
        end

        gen.gen.emit "extern silica::interrupt_handler irq_handlers[(int)interrupt_id::MAX_VALUE]"


      end
    end
  end
end