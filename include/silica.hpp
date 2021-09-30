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
    using interrupt_handler_t = ptr<void(void*, ID)>;

    struct interrupt_handler
    {
        interrupt_handler_t<hw::interrupt_id> handler;
        void* user_data;
    };

    struct periph
    {
        /* TODO */
    };
    

    enum class endian
    {
        little,
        big
    };
}