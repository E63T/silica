module Silica::ConstantGenerator
  def auto_constant(gen, name, value : String)
    case value
    when "big", "little"
      gen.constant "auto", name.underscore, "silica::endian::#{value}"
    when "true", "false", /^[0-9]+$/, /^0x[0-9a-fA-F]+$/, /^0b[01]+$/
      gen.constant "auto", name.underscore, value
    else
      gen.constant "char*", name.underscore, gen.escape(value)
    end
  end 

  def auto_constant(gen, name, value)
    auto_constant gen, name, "0x#{value.to_s(16)}"
  end
end