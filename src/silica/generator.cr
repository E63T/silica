require "xml"
require "silica_core"
require "./iohw_template"

module Silica
    class Generator
        @gen : SilicaCore::Generator
        @gen_iohw : SilicaCore::Generator

        def initialize(
                @in : IO, 
                generator_class : SilicaCore::Generator.class, 
                @out_dir : String
            )           
            @width = 32u64
            @hardware_defs_path = File.expand_path File.join(@out_dir, "include/detail/hardware_defs.hpp")
            @iohw_path = File.expand_path File.join(@out_dir, "include/iohw.h")

            Dir.mkdir_p File.join(@out_dir, "include/detail") unless File.exists? File.join(@out_dir, "detail")
            @gen = generator_class.new File.open(@hardware_defs_path, "w")
            @gen_iohw = generator_class.new File.open(@iohw_path, "w")
        end

        protected def top_claim(io)
            io.puts "/* THIS FILE IS AUTOGENERATED WITH Silica.cr v#{VERSION}"
            io.puts " * It is probably useless to modify this file manually"
            io.puts " * If you need, feel free to contribute to https://github.com/unn4m3d/silica"
            io.puts " * Generated at #{Time.local}"
            io.puts " */"
        end

        def run!
            
            puts "Running Silica.cr v#{VERSION}"
            
            hardware_path = File.expand_path File.join(@out_dir, "include/hardware")
            puts "(Re)generating #{hardware_path}"

            File.open(hardware_path, "w") do |f|
                top_claim f
                f.puts "#include <detail/hardware.hpp>"
            end

            top_claim @gen.io
            @gen.separator

            top_claim @gen_iohw.io
            @gen_iohw.separator

            puts "Parsing SVD file"
            xml = XML.parse @in 

            puts "Generating #{@hardware_defs_path}"
            @gen.include_guard
            @gen.require_support
            @gen.require_file "iohw.h"
            @gen.require_file "hardware"

            @gen.separator

            @gen.doc do 
                emit "Hardware description"
            end

            xml.xpath_node("/device/width").try do |w|
                @width = parse_number w.text
            end

            @gen.namespace "hw" do
                emit "enum class interrupt_id"

                puts "\tGenerating CPU info"
                generate_cpu! xml
                puts "\tGenerating platform info"
                generate_platform! xml
                puts "\tGenerating peripheral info"
                generate_periph! xml

                @gen.separator

                puts "\tGenerating interrupt ID enumeration"
                @gen.block "enum class interrupt_id", separator: true do
                    @interrupts.each do |iname, _|
                        emit "#{iname},", no_sep: true
                    end
                    emit "MAX_VALUE", no_sep: true
                end

                puts "\tGenerating IRQ handler table"

                src_dir = File.expand_path File.join(@out_dir, "src")
                Dir.mkdir_p src_dir

                irq_impl_path = File.expand_path File.join(src_dir, "hardware_defs.cpp")
                @gen.emit "extern silica::interrupt_handler irq_handlers[(int)interrupt_id::MAX_VALUE]"

                # TODO : Use template
                File.open(irq_impl_path, "w") do |irq_impl|
                    puts "\t\tGenerating #{irq_impl_path}"
                    top_claim irq_impl
                    irq_impl.puts "#include <silica.hpp>"
                    irq_impl.puts "#include <detail/hardware_defs.hpp>"
                    irq_impl.puts
                    irq_impl.puts "namespace hw { extern silica::interrupt_handler irq_handlers[(int)interrupt_id::MAX_VALUE] = {{0, 0}}; }"
                end

                puts "\tGenerating IRQ handlers"
                @interrupts.each do |iname, _|
                    @gen.separator

                    @gen.block %(extern "C" void #{iname}_IRQ_Handler()) do 
                        emit "std::uint32_t irq_idx = (uint32_t)interrupt_id::#{iname}"
                        block %(if(irq_handlers[irq_idx].handler)) do
                            emit %(irq_handlers[irq_idx].handler(irq_handler[irq_idx].user_data, interrupt_id::#{iname}))
                        end
                    end
                end
            end

            @gen.close
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
            puts "\t\tGenerating #{@iohw_path}"
            a_width = parse_number xml.xpath_node("/device/addressUnitBits").not_nil!.text
            r_width = parse_number xml.xpath_node("/device/width").not_nil!.text

            iohw_template = IoHwTemplate.new r_width, a_width

            iohw_template.to_s @gen_iohw.io
 

            %w(name description version width addressUnitBits size resetMask resetValue).each do |word|
                auto_constant xml.xpath_node("/device/#{word}")
            end
        end

        @peripherals = {} of String => Tuple(UInt64, String)

        def generate_periph!(xml)
            @gen.block "struct periph", separator: true do
                xml.xpath_nodes("/device/peripherals/*").each do |periph|
                    gen_pdef! xml, periph
                    separator
                end

                # @peripherals.each do |name, data|
                #     @gen.instance "static #{data.last}_type", name, ["0x#{data.first.to_s(16)}"]
                # end
            end
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
        

        private def mask_for(bits, offset)
            "0x#{(((1u64 << bits) - 1) << offset).to_s(16)}"
        end

        alias EnumeratedValue = {name: String, description: String, value: String}
        @enumerated_values = {} of String => Array(EnumeratedValue)


        private def enumerated_values(periph, reg_name, field_name, enum_v : XML::Node)
            name_node = enum_v.xpath_node("name")

            name = if name_node.nil?
                "_anonymous_#{@enumerated_values.size}"
            else
                name_node.text
            end

            fully_qualified_name = "#{reg_name}.#{field_name}.#{name}"

            derived_from = enum_v["derivedFrom"]?

            @enumerated_values[fully_qualified_name] = [] of EnumeratedValue

            unless derived_from.nil?
                

                derived_from_bits = derived_from.split('.')

                ancestor_reg_name, ancestor_field_name = reg_name, field_name
                ancestor_name = derived_from_bits[-1]
                ancestor_field_name = derived_from_bits[-2] if derived_from_bits.size > 1
                ancestor_reg_name = derived_from_bits[-3] if derived_from_bits.size > 2

                ancestor_fq_name = [ancestor_reg_name, ancestor_field_name, ancestor_name].join('.')

                derived_values = if @enumerated_values.has_key? ancestor_fq_name
                    @enumerated_values[ancestor_fq_name]
                elsif key = @enumerated_values.keys.find(&.match(/^#{reg_name}\..*\.#{ancestor_name}$/i))
                    @enumerated_values[key.not_nil!]
                else
                    puts "Warning: enumerated value set #{fully_qualified_name} was declared before its ancestor #{ancestor_fq_name}"
                    
                    ancestor = 
                        periph.xpath_node("//register[name/text()='#{ancestor_reg_name}']/fields/field[name/text()='#{ancestor_field_name}']/enumeratedValues[name/text()='#{ancestor_name}']") ||
                        periph.xpath_node("//register[name/text()='#{reg_name}']/fields/field/enumeratedValues[name/text()='#{ancestor_name}']")


                    if ancestor.nil?
                        puts "Warning: ancestor #{derived_from} of enumerated value set #{name} is missing"
                        [] of EnumeratedValue
                    else
                        enumerated_values(periph, ancestor_reg_name, ancestor_field_name, ancestor)
                    end
                end

                @enumerated_values[fully_qualified_name] += derived_values
            end

            enum_v.xpath_nodes("enumeratedValue").each do |node|
                @enumerated_values[fully_qualified_name] << EnumeratedValue.new(
                    name: node.xpath_node("name").not_nil!.text,
                    description: node.xpath_node("description").not_nil!.text,
                    value: node.xpath_node("value").not_nil!.text
                )
            end

            @enumerated_values[fully_qualified_name]
        end

        def gen_pdef!(xml, p : XML::Node)
            name = p.xpath_node("name").not_nil!.text.downcase

            puts "\t\tGenerating peripheral definition for #{name.upcase}"

            derived_from = p["derivedFrom"]?

            skip_class = p.xpath_nodes("self::peripheral/*[not(self::name or self::baseAddress or self::interrupt)]").empty?

            interrupts = p.xpath_nodes("self::peripheral/interrupt")
            interrupts.each do |node|
                iname = node.xpath_node("name").not_nil!.text
                @interrupts[iname] = name 
            end

            @gen.block "struct #{name} : public #{derived_from.nil? ? "silica::periph" : derived_from.downcase }", separator: true do
                base_addr = parse_number(p.xpath_node("baseAddress").not_nil!.text)
                p.xpath_nodes("self::peripheral/registers/*").each do |reg|
                    
                    orig_reg_name = reg.xpath_node("name").not_nil!.text
                    reg_name = orig_reg_name.downcase

                    puts "\t\t\tGenerating info for #{reg_name.upcase}"

                    offset = parse_number(reg.xpath_node("addressOffset").not_nil!.text)
                    size = parse_number(reg.xpath_node("size").not_nil!.text)

                    if size == @width
                        emit "using #{reg_name}_traits = std::hardware::static_register_traits<#{base_addr + offset}>"
                    else
                        block "struct #{reg_name}_traits : public std::hardware::static_register_traits<#{base_addr + offset}>", separator: true do
                            emit "typedef std::uint#{size}_t value_type"
                        end
                    end

                    emit "using #{escape_keywords reg_name} = std::hardware::register_access<#{reg_name}_traits>"
                    
                    separator

                    
                    block "enum class #{reg_name}_v", separator: true do
                        reg_enum_values = {} of String => String
                        reg.xpath_nodes("fields/field").each do |field|
                            field_name = field.xpath_node("name").not_nil!.text
                            field_width = parse_number field.xpath_node("bitWidth").not_nil!.text
                            field_offset = parse_number field.xpath_node("bitOffset").not_nil!.text

                            emit "#{field_name}_msk = #{mask_for field_width, field_offset},", no_sep: true
                            emit "#{field_name}_offset = #{field_offset},", no_sep: true

                            field.xpath_nodes("enumeratedValues").each do |value_set|
                                value_set_name = value_set.xpath_node("name").try(&.text)
                                values = enumerated_values(p, orig_reg_name, field_name, value_set)
                               
                                unless value_set_name.nil?
                                    values.each do |value|
                                        reg_enum_values["#{value_set_name}_#{value[:name]}"] = value[:value] 
                                    end
                                end

                                values.each do |value|
                                    emit "#{field_name}_#{value[:name]} = #{value[:value]},", no_sep: true
                                end
                            end
                        end

                        reg_enum_values.each do |k, v|
                            emit "#{k} = #{v},", no_sep: true
                        end

                        emit "NONE = 0", no_sep: true
                    end

                    separator
                end

                emit "constexpr const static std::uint#{@width}_t base_address = 0x#{base_addr.to_s(16)}"
            end
 
            # unless skip_class
            #     @gen.block "struct #{name}_type : public #{derived_from.nil? ? "silica::periph" : "#{derived_from.downcase}_type" }", separator: true do
            #         block "struct registers", separator: true do 
            #             registers = {} of UInt64 => Tuple(String, UInt64)
            #             p.xpath_nodes("self::peripheral/registers/*").each do |reg|
            #                 reg_name = reg.xpath_node("name").not_nil!.text.downcase
            #                 offset = parse_number(reg.xpath_node("addressOffset").not_nil!.text)
            #                 size = parse_number(reg.xpath_node("size").not_nil!.text)

            #                 if size % 8 != 0
            #                     raise "Incorrect size of register #{name}->#{reg_name} : #{size}"
            #                 end

            #                 registers[offset] = {reg_name, (size / 8).to_u64}
            #             end


            #             prev_reg_end = 0u64
            #             registers.keys.sort.each do |offset|
            #                 reg = registers[offset]

            #                 if offset > prev_reg_end
            #                     gen_padding! offset - prev_reg_end    
            #                 elsif offset < prev_reg_end
            #                     raise "Register #{name}->#{reg.first} overlaps previous register"
            #                 end

            #                 instance "uint#{reg.last * 8}_t", reg.first

            #                 prev_reg_end = offset + reg.last
            #             end
            #         end
                    
            #         separator

            #         block "#{name}_type (size_t address)" do
            #             emit "m_base = (registers*)address"
            #         end

            #         separator

            #         instance "registers*", "m_base"
            #     end

            #     @gen.separator
            # end

            # @peripherals[name] = {
            #     parse_number(p.xpath_node("baseAddress").not_nil!.text),
            #     (skip_class && !derived_from.nil?) ? derived_from.to_s.downcase : name
            # }


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