#pragma once
#include <cstdint>
#include <cstddef>

namespace hw
{
    enum class interrupt_id;
}

namespace silica
{
    struct periph;

    template<typename T>
    using ptr = T*;

    template<typename ID>
    using interrupt_handler = ptr<void(periph*, ID)>;

    struct periph
    {
        interrupt_handler<hw::interrupt_id> interrupt_handler;
        void* user_data;
    };
    

    enum class endian
    {
        little,
        big
    };
}