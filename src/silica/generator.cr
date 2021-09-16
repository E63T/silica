require "xml"
require "silica_core"

module Silica
    class Generator
        def initialize(@in : IO, @gen : SilicaCore::Generator)
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
                generate_cpu! xml
                generate_platform! xml
                generate_periph! xml
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
        end

        @peripherals = {} of String => Tuple(UInt64, String)

        def generate_periph!(xml)
            @gen.namespace "periph" do
                xml.xpath_nodes("/device/peripherals/*").each do |periph|
                    gen_pdef! xml, periph
                    separator
                end
            end

            @peripherals.each do |name, data|
                @gen.instance "#{data.last}_type", name, ["0x#{data.first.to_s(16)}"]
            end
        end

        def get_node(xml, p, name)
            # TODO
        end

        def gen_pdef!(xml, p : XML::Node)
            name = p.xpath_node("name").not_nil!.text.downcase
            derived_from = p["derivedFrom"]?

            skip_class = p.xpath_nodes("self::peripheral/*[not(self::name or self::baseAddress)]").empty?

            unless skip_class
               

                @gen.block "struct #{name}_type : public #{derived_from.nil? ? "silica::periph" : derived_from.downcase}", separator: true do
                    block "struct registers", separator: true do 
                        # TODO
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
                p.xpath_node("baseAddress").not_nil!.text.lchop("0x").to_u64(16),
                (skip_class && !derived_from.nil?) ? derived_from.to_s.downcase : name
            }
        end
    end
end