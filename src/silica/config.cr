require "json"

module Silica
    class Config
        class Features
            include JSON::Serializable

            property copy_includes = false
            property doxygen = true
            property field_masks = true
            property field_widths = true

            def initialize
            end
        end

        include JSON::Serializable

        property silica_version : String?
        property silica_core_version : String?
        property include_dir : String = "include"
        property src_dir : String = "src"
        property input_file : String? = nil
        property features : Features = Features.new
    end

    class ConfigFile
        include JSON::Serializable

        property default_env : String = ""
        property envs = {} of String => Config

        def initialize
        end
    end
end