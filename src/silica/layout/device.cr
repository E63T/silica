require "nya_serializable"
require "./peripheral"

module Silica
    module Layout

        class Device
            include Nya::Serializable

            property name = "", version = "", description = "", width = 32u32, size = 32u32           
            
            @[Rename("addressUnitBits")]
            property address_unit_bits = 8u32

            @[Rename("resetValue")]
            property reset_value = 0u32

            @[Rename("resetMask")]
            property reset_mask = 0u32

            property peripherals = [] of Peripheral

            serializable name : String, 
            version : String, 
            description : String,
            width : UInt32, 
            address_unit_bits : UInt32, 
            reset_value : UInt32,
            reset_mask : UInt32,
            peripherals : Array(Peripheral)


            also_known_as device
        end

    end
end