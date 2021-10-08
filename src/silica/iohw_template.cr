require "silica_core/template"

module Silica
  SilicaCore.ecr_template IoHwTemplate, "src/silica/iohw.h.ecr" do
    property register_width : UInt64, address_width : UInt64

    def initialize(@register_width, @address_width)
    end
  end
end
