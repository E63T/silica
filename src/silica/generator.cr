require "xml"
require "silica_core"
require "./iohw_template"
require "./hardware_defs_template"
require "./config"
require "version/requirement_set"
require "nya_serializable"
require "./version"

module Silica
  class Generator
    @gen : SilicaCore::Generator
    @gen_iohw : SilicaCore::Generator
    @config_set : ConfigFile = ConfigFile.new
    @env : String
    @config : Config

    def initialize(
      io : IO?,
      generator_class : SilicaCore::Generator.class,
      @out_dir : String,
      @config_path : String,
      env : String?,
      @verbose : Bool = true
    )
      if File.exists? @config_path
        File.open(@config_path) do |file|
          @config_set = ConfigFile.from_json file
        end
      else
        raise "Config file #{@config_path} does not exist"
      end

      @env = if env.nil?
               if @config_set.default_env.empty?
                 raise "Default env is empty or not specified, please specify it or use --env=ENV"
               else
                 @config_set.default_env
               end
             else
               env
             end

      puts "Env: #{@env}, $env : #{env}"

      @config = @config_set.envs[@env]

      @width = 32u64

      unless @config.silica_version.nil?
        req_set = Version::RequirementSet.parse @config.silica_version.not_nil!

        unless req_set.matches? VERSION
          raise "Silica v#{VERSION} does not match version requirement #{@config.silica_version}"
        end
      end

      unless @config.silica_core_version.nil?
        req_set = Version::RequirementSet.parse @config.silica_core_version.not_nil!

        unless req_set.matches? SilicaCore::VERSION
          raise "SilicaCore v#{SilicaCore::VERSION} does not match version requirement #{@config.silica_version}"
        end
      end

      @in = if io.nil?
              if @config.input_file.nil? || @config.input_file.not_nil!.empty?
                raise "Input file is not specified"
              else
                File.open File.expand_path File.join(@out_dir, @config.input_file.not_nil!)
              end
            else
              io.not_nil!
            end

      @out_dir = File.expand_path @out_dir
      @include_dir = File.join @out_dir, @config.include_dir
      @src_dir = File.join @out_dir, @config.src_dir

      puts @config.to_json

      @hardware_defs_path = File.expand_path File.join(@include_dir, "/detail/hardware_defs.hpp")
      @iohw_path = File.expand_path File.join(@include_dir, "iohw.h")

      Dir.mkdir_p File.join(@include_dir, "detail") unless File.exists? File.join(@include_dir, "detail")
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

      @gen.doc do |d|
        d.brief "Hardware description"
      end

      xml.xpath_node("/device/width").try do |w|
        @width = parse_number w.text
      end

      @gen.namespace "hw" do
        puts "\tGenerating CPU info"
        generate_cpu! xml
        puts "\tGenerating platform info"
        generate_platform! xml
        puts "\tGenerating peripheral info"
        generate_periph! xml

        @gen.separator

        puts "\tGenerating interrupt ID enumeration"

        if @config.features.doxygen
          @gen.doc do |d|
            d.generate do
              summary "Interrupt ID"
            end
          end
        end
        @gen.g_enum "interrupt_id" do
          @interrupts.each do |iname, _|
            g_enum_member iname
          end
          g_enum_member "MAX_VALUE"
        end

        Dir.mkdir_p @src_dir

        irq_impl_path = File.expand_path File.join(@src_dir, "hardware_defs.cpp")

        @gen.emit "extern silica::interrupt_handler irq_handlers[(int)interrupt_id::MAX_VALUE]"

        # TODO : Use template
        File.open(irq_impl_path, "w") do |irq_impl|
          puts "Generating #{irq_impl_path}"
          puts "\tGenerating IRQ handlers"
          top_claim irq_impl

          HardwareDefsTemplate.new(@interrupts.keys).to_s(irq_impl)
        end
      end

      @gen.close
      @gen_iohw.close
    end

    def auto_constant(node : XML::Node)
      prev = node.previous_sibling

      unless prev.nil?
        if @config.features.doxygen
          @gen.doc { |d| d.summary prev.to_s } if prev.comment?
        end
      end

      text = node.text
      case text
      when "big", "little"
        @gen.constant "auto", node.name.underscore, "silica::endian::#{text}"
      when "true", "false", /^[0-9]+$/, /^0x[0-9a-fA-F]+$/
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

      @width = r_width

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

      interrupts = p.xpath_nodes("self::peripheral/interrupt")
      interrupts.each do |node|
        iname = node.xpath_node("name").not_nil!.text
        @interrupts[iname] = name
      end

      if @config.features.doxygen
        @gen.doc do |d|
          d.generate do
            desc = p.xpath_node("description")
            if desc.nil?
              summary name.upcase
            else
              summary desc.text
            end
          end
        end
      end
      @gen.g_module name, [(derived_from.nil? ? "silica::periph" : derived_from.downcase)] do
        base_addr = parse_number(p.xpath_node("baseAddress").not_nil!.text)
        p.xpath_nodes("self::peripheral/registers/*").each do |reg|
          orig_reg_name = reg.xpath_node("name").not_nil!.text
          reg_name = orig_reg_name.downcase

          puts "\t\t\tGenerating info for #{reg_name.upcase}"

          offset = parse_number(reg.xpath_node("addressOffset").not_nil!.text)
          size = parse_number(reg.xpath_node("size").not_nil!.text)

          traits = generic(path(%w(std hardware static_register_traits)), [(base_addr + offset).to_s])

          if @config.features.doxygen
            doc do |d|
              d.generate do
                d.summary "Values and masks for #{name}.#{reg_name}"
              end
            end
          end
          g_enum "#{reg_name}_v", "uint#{@width}_t" do
            reg_enum_values = {} of String => EnumeratedValue

            declared_values = [] of String
            reg.xpath_nodes("fields/field").each do |field|
              field_name = field.xpath_node("name").not_nil!.text
              field_width = parse_number field.xpath_node("bitWidth").not_nil!.text
              field_offset = parse_number field.xpath_node("bitOffset").not_nil!.text
              field_desc = field.xpath_node("description")

              if @config.features.field_masks
                g_enum_member "#{field_name}_msk", mask_for(field_width, field_offset) do
                  if @config.features.doxygen
                    doc do |d|
                      d.generate do
                        summary "Mask for #{field_name}"

                        field_desc.try do |f|
                          separator
                          summary "Field description: #{f.text}"
                        end
                      end
                    end
                  end
                end
              end

              if @config.features.field_offsets
                g_enum_member "#{field_name}_offset", field_offset.to_s do
                  if @config.features.doxygen
                    doc do |d|
                      d.generate do
                        summary "Offset of #{field_name}"

                        field_desc.try do |f|
                          separator
                          summary "Field description: #{f.text}"
                        end
                      end
                    end
                  end
                end
              end

              if @config.features.field_widths
                g_enum_member "#{field_name}_width", field_width.to_s do
                  if @config.features.doxygen
                    doc do |d|
                      d.generate do
                        summary "Width of #{field_name}"

                        field_desc.try do |f|
                          separator
                          summary "Field description: #{f.text}"
                        end
                      end
                    end
                  end
                end
              end

              e_values = field.xpath_nodes("enumeratedValues")

              if e_values.empty? && @config.features.auto_enabled_value && field_width == 1
                value_name = "#{field_name}_Enabled"
                declared_values << value_name
                g_enum_member value_name, "(uint#{@width}_t)1 << #{field_offset}" do
                  doc do |d|
                    d.generate do
                      summary "[Autogenerated] Enabled value for #{field_name}"
                    end
                  end
                end
              end

              e_values.each do |value_set|
                value_set_name = value_set.xpath_node("name").try(&.text)
                values = enumerated_values(p, orig_reg_name, field_name, value_set)

                unless value_set_name.nil?
                  values.each do |value|
                    reg_enum_values["#{value_set_name}_#{value[:name]}"] = value
                  end
                end

                values.each do |value|
                  value_name = "#{field_name}_#{value[:name]}"
                  unless declared_values.includes? value_name
                    declared_values << value_name
                    g_enum_member(value_name.delete("()"), "(uint#{@width}_t)#{value[:value]} << #{field_offset}") do
                      if @config.features.doxygen
                        doc do |d|
                          d.generate do
                            summary value[:description]
                          end
                        end
                      end
                    end
                  end
                end
              end
            end

            if @config.features.field_common_values
              reg_enum_values.each do |k, v|
                unless declared_values.includes? k
                  g_enum_member(k, v[:value]) do
                    if @config.features.doxygen
                      doc do |d|
                        d.summary v[:description]
                      end
                    end
                  end
                end
              end
            end

            g_enum_member "NONE", "0"
          end

          separator

          if @config.features.doxygen
            doc do |d|
              d.generate do
                desc = reg.xpath_node("description")
                summary "Register traits for #{name}.#{reg_name}"

                unless desc.nil?
                  separator
                  summary desc.text
                end
              end
            end
          end
          g_module "#{reg_name}_traits", [traits] do
            if size != @width
              g_alias "value_type", "std::uint#{size}_t"
            end
            g_alias "field_type", "#{reg_name}_v"
          end

          if @config.features.doxygen
            separator

            doc do |d|
              d.generate do
                desc = reg.xpath_node("description")
                summary "Register access for #{name}.#{reg_name}"

                unless desc.nil?
                  separator
                  summary desc.text
                end
              end
            end
          end

          g_alias escape_keywords(reg_name), generic(path(%w(std hardware register_access)), "#{reg_name}_traits")

          separator
        end

        separator

        if @config.features.doxygen
          doc do |d|
            d.generate do
              summary "Base address of #{name}"
            end
          end
        end
        g_constant "std::uint#{@width}_t", "base_address", "0x#{base_addr.to_s(16)}"
      end
    end

    # DEPRECATED: Use `Nya::Serializable.parse_number(text, UInt64)`
    def parse_number(text : String)
      Nya::Serializable.parse_number(text, UInt64)
    end
  end
end
