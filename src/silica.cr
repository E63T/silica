require "./silica/generator"
module Silica
  VERSION = "0.1.0"
end

Silica::Generator.new(STDIN, SilicaCore::CppGenerator.new(STDOUT)).run!
