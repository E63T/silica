require "nya_serializable"
require "silica_core"
require "version/requirement_set"
require "xml"
require "./config"
require "./hardware_defs_template"
require "./iohw_template"
require "./layout/device"
require "./version"

module Silica
  class Generator
    property gen : SilicaCore::Generator
    property gen_iohw : SilicaCore::Generator
    property config_set : ConfigFile = ConfigFile.new
    property env : String
    property config : Config
    property device = Layout::Device.new
    property interrupts = {} of String => String
    property width = 32u32
    property src_dir : String

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

      @device = Layout::Device.deserialize xml.xpath_node("device").not_nil!
      
      @width = device.width

      puts "Generating #{@hardware_defs_path}"
      @gen.include_guard
      @gen.require_support
      @gen.require_file "iohw.h"
      @gen.require_file "hardware"

      @gen.separator

      @gen.doc do |d|
        d.brief "Hardware description"
      end

      device.pre_generate self
      device.generate self

      Dir.mkdir_p @src_dir

      irq_impl_path = File.expand_path File.join(@src_dir, "hardware_defs.cpp")  

      File.open(irq_impl_path, "w") do |irq_impl|
        puts "Generating #{irq_impl_path}"
        puts "\tGenerating IRQ handlers"
        top_claim irq_impl

        HardwareDefsTemplate.new(@interrupts.keys).to_s(irq_impl)
      end

      a_width = device.address_unit_bits.to_u64
      r_width = device.width.to_u64

      iohw_t = IoHwTemplate.new r_width,a_width

      iohw_t.to_s @gen_iohw.io

      @gen.close
      @gen_iohw.close
    end
  end
end
