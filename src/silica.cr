require "./silica/generator"
require "option_parser"

input_file = nil
config_file = nil
verbose = true
env : String? = nil

OptionParser.parse do |opt|
  opt.banner = "Usage : silica [-fFILE ][-cFILE ][-v ] OUTPUT_DIR"
  opt.on("-f FILE", "--input-file=FILE", "Specify input file (override config)") do |f|
    input_file = File.open f
  end

  opt.on("-c FILE", "--config=FILE", "Specify config file (OUTPUT/silica.json by default)") do |f|
    config_file = f
  end

  opt.on("-v", "--verbose", "Verbose mode (default)") do
    verbose = true
  end

  opt.on("-q", "--quiet", "Quiet mode") do
    verbose = false
  end

  opt.on("-e ENV", "--env=ENV", "Specify environment") do |e|
    env = e
  end

  opt.on("-h", "--help", "Print help") do
    puts opt
    exit
  end
end

output_dir = ARGV.pop

config_file = config_file || File.join output_dir, "silica.json"

Silica::Generator.new(input_file, SilicaCore::CppGenerator, output_dir, config_file.not_nil!, env, verbose).run!
