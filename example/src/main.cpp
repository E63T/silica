#include <hardware>
#include <detail/hardware_defs.hpp>

extern "C" void __libc_init_array();

void ms_delay(int ms)
{
   while (ms-- > 0) {
      volatile int x=500;
      while (x-- > 0)
         __asm("nop");
   }
}

int main()
{
    __libc_init_array();

    auto ahbenr = hw::periph::rcc::ahbenr();
    auto moder = hw::periph::gpioa::moder();
    auto odr = hw::periph::gpioa::odr();

    ahbenr |= (std::uint32_t)hw::periph::rcc::ahbenr_v::IOPAEN_Enabled;

    moder |= 1 << (std::uint32_t)hw::periph::gpioc::moder_v::MODER0_offset;

    while(true)
    {
        ms_delay(500);
        odr ^= 1 << 0;
    }
}