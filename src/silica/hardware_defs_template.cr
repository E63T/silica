module Silica
    SilicaCore.ecr_template HardwareDefsTemplate, "src/silica/hardware_defs.cpp.ecr" do 
        property irq_names : Array(String)

        def initialize(@irq_names)
        end
    end
end