require "xml"
require "silica_core"

module Silica
    class Generator
        def initialize(@in : IO, @gen : SilicaCore::Generator)
            @width = 32u64
        end

        def run!
            xml = XML.parse @in 
            @gen.include_guard
            @gen.require_support

            @gen.separator

            @gen.doc do 
                emit "Hardware description\n\nGenerated with Silica.cr\nVersion #{VERSION}"
            end
            @gen.namespace "hw" do
                emit "enum class interrupt_id"
                generate_cpu! xml
                generate_platform! xml
                generate_periph! xml

                @gen.separator

                @gen.block "enum class interrupt_id", separator: true do
                    @interrupts.each do |iname, _|
                        emit "#{iname},", no_sep: true
                    end
                end

                @interrupts.each do |iname, name|
                    @gen.separator

                    @gen.block %(extern "C" void #{iname}_IRQ_Handler()) do 
                        block %(if(periph::#{name.downcase}.interrupt_handler)) do
                            emit %(periph::#{name.downcase}.interrupt_handler(&periph::#{name.downcase}, interrupt_id::#{iname}))
                        end
                    end
                end
            end
        end

        def auto_constant(node : XML::Node)

            prev = node.previous_sibling

            unless prev.nil?
                @gen.doc { emit prev.to_s } if prev.comment?
            end

            text = node.text
            case text
            when "big", "little"
                @gen.constant "auto", node.name.underscore, "silica::endian::#{text}"
            when "true","false", /^[0-9]+$/, /^0x[0-9a-fA-F]+$/
                @gen.constant "auto", node.name.underscore, text
            else
                @gen.constant "char*", node.name.underscore, @gen.escape(text)
            end
        end

        def auto_constant(node : Nil)
        end

        def generate_cpu!(xml)
            @gen.namespace "cpu" do
                xml.xpath_nodes("/device/cpu/*").each do |node|
                    auto_constant node
                end
            end
        end

        def generate_platform!(xml)
            %w(name description version width addressUnitBits size resetMask resetValue).each do |word|
                auto_constant xml.xpath_node("/device/#{word}")
            end

            xml.xpath_node("/device/width").try do |w|
                @width = parse_number w.text
            end
        end

        @peripherals = {} of String => Tuple(UInt64, String)

        def generate_periph!(xml)
            @gen.namespace "periph" do
                xml.xpath_nodes("/device/peripherals/*").each do |periph|
                    gen_pdef! xml, periph
                    separator
                end

                @peripherals.each do |name, data|
                    @gen.instance "#{data.last}_type", name, ["0x#{data.first.to_s(16)}"]
                end
            end

            
        end

        def get_node(xml, p, name)
            # TODO
        end

        @padding_ctr = 0

        def gen_padding!(bytes)
            width = @width

            while width >= 8
                break if bytes.divisible_by?((width / 8).to_u64)
                width /= 2
            end

            @gen.emit "uint#{width}_t _padding_#{@padding_ctr}[#{(bytes / (width / 8).to_u64).to_u64}]"
        
            @padding_ctr += 1
        end

        @interrupts = {} of String => String

        def gen_pdef!(xml, p : XML::Node)
            name = p.xpath_node("name").not_nil!.text.downcase
            derived_from = p["derivedFrom"]?

            skip_class = p.xpath_nodes("self::peripheral/*[not(self::name or self::baseAddress or self::interrupt)]").empty?

            interrupts = p.xpath_nodes("self::peripheral/interrupt")
            interrupts.each do |node|
                iname = p.xpath_node("name").not_nil!.text
                @interrupts[iname] = name 
            end
 
            unless skip_class
                @gen.block "struct #{name}_type : public #{derived_from.nil? ? "silica::periph" : "#{derived_from.downcase}_type" }", separator: true do
                    block "struct registers", separator: true do 
                        registers = {} of UInt64 => Tuple(String, UInt64)
                        p.xpath_nodes("self::peripheral/registers/*").each do |reg|
                            reg_name = reg.xpath_node("name").not_nil!.text.downcase
                            offset = parse_number(reg.xpath_node("addressOffset").not_nil!.text)
                            size = parse_number(reg.xpath_node("size").not_nil!.text)

                            if size % 8 != 0
                                raise "Incorrect size of register #{name}->#{reg_name} : #{size}"
                            end

                            registers[offset] = {reg_name, (size / 8).to_u64}
                        end


                        prev_reg_end = 0u64
                        registers.keys.sort.each do |offset|
                            reg = registers[offset]

                            if offset > prev_reg_end
                                gen_padding! offset - prev_reg_end    
                            elsif offset < prev_reg_end
                                raise "Register #{name}->#{reg.first} overlaps previous register"
                            end

                            instance "uint#{reg.last * 8}_t", reg.first

                            prev_reg_end = offset + reg.last
                        end
                    end
                    
                    separator

                    block "#{name}_type (size_t address)" do
                        emit "m_base = (registers*)address"
                    end

                    separator

                    instance "registers*", "m_base"
                end

                @gen.separator
            end

            @peripherals[name] = {
                parse_number(p.xpath_node("baseAddress").not_nil!.text),
                (skip_class && !derived_from.nil?) ? derived_from.to_s.downcase : name
            }
        end

        def parse_number(text : String)
            if text.starts_with? "0x"
                text.lchop("0x").to_u64(16)
            elsif text.starts_with? "0b"
                text.lchop("0b").to_u64(2)
            elsif text.starts_with? "0"
                text.to_u64(8)
            else
                text.to_u64
            end
        end
    end
end