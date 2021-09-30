require "./silica/generator"
require "version"
module Silica
  VERSION = Version.fetch
end

Silica::Generator.new(STDIN, SilicaCore::CppGenerator, ARGV.shift).run!
