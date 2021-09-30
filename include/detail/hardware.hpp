#pragma once

#include <cstdint>
#include <iohw.h>
#include <type_traits>

/*
Implementation of TR18015:2006 Chapter 8
WIP, aiming to run mostly on STM32 family microcontrollers
*/
namespace std
{
    namespace hardware
    {
        struct hw_base
        {
            enum access_mode {random, read_write, read, write};
            enum device_bus {device32 = 1};
            enum byte_order {msb_high = 1};
            enum processor_bus {bus32 = 1};

            typedef uint32_t address_type;
            enum address_kind {is_static, is_dynamic};

            // TODO : Bus names
        };

        template<hw_base::address_type val>
        struct static_address
        {
            enum {value_ = val, kind_ = hw_base::is_static};

            constexpr hw_base::address_type value() const { return (val); }
        };

        struct dynamic_address
        {
            enum {kind_ = hw_base::is_dynamic};

            hw_base::address_type value_;
            
            dynamic_address(hw_base::address_type addr) :
                value_(addr)
                {}

            hw_base::address_type value() const { return (value_); }
        };

        struct platform_traits
        {
            typedef static_address<0> address_holder;
            /* TODO */
        };

        struct register_traits
        {
            typedef ::ioreg_t value_type;
            typedef hw_base::static_address<0> address_holder;

            enum
            {
                address_mode = hw_base::is_static,
                access_mode = hw_base::random
            };
        };

        template<hw_base::address_type Addr>
        struct static_register_traits : register_traits
        {
            typedef hw_base::static_address<Addr> address_holder;
        };

        template<
            typename RegTraits = register_traits, 
            typename PlatformTraits = platform_traits
        >
        class register_access
        {
        public:
            typedef typename RegTraits::value_type value_type;
            typedef typename RegTraits::address_holder reg_address_holder;
            typedef typename PlatformTraits::address_holder platform_address_holder;

            register_access(
                reg_address_holder const &rAddr = reg_address_holder(),
                platform_address_holder const &pAddr = platform_address_holder()) :
                m_raddr(rAddr),
                m_paddr(pAddr)
                {}

            operator value_type() const
            {
                if constexpr(RegTraits::address_mode == hw_base::is_static)
                {
                    return *reinterpret_cast<value_type*>(reg_address_holder::value_);
                }
                else
                {
                    return *reinterpret_cast<value_type*>(m_raddr.value());
                }
            }

            void operator = (value_type val)
            {
                if constexpr(RegTraits::address_mode == hw_base::is_static)
                {
                    *reinterpret_cast<value_type*>(reg_address_holder::value_) = val;
                }
                else
                {
                    *reinterpret_cast<value_type*>(m_raddr.value()) = val;
                }
            }

            void operator |= (value_type val)
            {
                if constexpr(RegTraits::address_mode == hw_base::is_static)
                {
                    *reinterpret_cast<value_type*>(reg_address_holder::value_) |= val;
                }
                else
                {
                    *reinterpret_cast<value_type*>(m_raddr.value()) |= val;
                }
            }

            void operator &= (value_type val)
            {
                if constexpr(RegTraits::address_mode == hw_base::is_static)
                {
                    *reinterpret_cast<value_type*>(reg_address_holder::value_) &= val;
                }
                else
                {
                    *reinterpret_cast<value_type*>(m_raddr.value()) &= val;
                }
            }

            void operator ^= (value_type val)
            {
                if constexpr(RegTraits::address_mode == hw_base::is_static)
                {
                    *reinterpret_cast<value_type*>(reg_address_holder::value_) ^= val;
                }
                else
                {
                    *reinterpret_cast<value_type*>(m_raddr.value()) ^= val;
                }
            }
            
            // TODO : Function-style interface

        private:
            reg_address_holder m_raddr;
            platform_address_holder m_paddr;
        };
        
        
    }
}