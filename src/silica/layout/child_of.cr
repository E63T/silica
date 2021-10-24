module Silica::Layout
    module ChildOf(T)
        property parent : T? = nil

        def parent!
            parent.not_nil!
        end
    end
end