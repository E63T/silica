require "../constant_generator"

module Silica::Layout
  class CPU
    include ConstantGenerator
    alias Endian = IO::ByteFormat::LittleEndian.class | IO::ByteFormat::BigEndian.class

    property name = "", revision = ""
    property endian : Endian = IO::ByteFormat::LittleEndian
    property fpu_present = false, mpu_present = false, vtor_present = false
    property nvic_prio_bits = 0u32
    property vendor_systick_config = false

    def generate(gen : Silica::Generator)
      {% for id in %w(name revision endian fpu_present mpu_present vtor_present nvic_prio_bits vendor_systick_config) %}
        auto_constant gen.gen, {{id}}, self.{{id.id}}.to_s
      {% end %}
    end
  end
end