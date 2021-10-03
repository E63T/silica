require "./silica/generator"
require "version"
require "option_parser"

module Silica
  VERSION = Version.fetch
end

input_file = nil
config_file = nil
verbose = true
env : String? = nil

OptionParser.parse do |opt|
  opt.banner = "Usage : silica [-fFILE ][-cFILE ][-v ] OUTPUT_DIR"
  opt.on("-fFILE", "--input-file=FILE", "Specify input file (override config)") do |f|
    input_file = File.open f
  end

  opt.on("-cFILE", "--config=FILE", "Specify config file (OUTPUT/silica.json by default)") do |f|
    config_file = f
  end

  opt.on("-v", "--verbose", "Verbose mode (default)") do 
    verbose = true
  end

  opt.on("-q", "--quiet", "Quiet mode") do 
    verbose = false
  end

  opt.on("-eENV", "--env=ENV", "Specify environment") do |e|
    env = e
  end

  opt.on("-h", "--help", "Print help") do 
    puts opt 
    exit
  end
end

output_dir = ARGV.shift

config_file = config_file || File.join output_dir, "silica.json"

Silica::Generator.new(input_file, SilicaCore::CppGenerator, output_dir, config_file.not_nil!, env, verbose).run!
