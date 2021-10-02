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
    auto moder = hw::periph::gpioc::moder();
    auto odr = hw::periph::gpioc::odr();

    ahbenr |= (std::uint32_t)hw::periph::rcc::ahbenr_v::IOPCEN_Enabled;

    moder |= (std::uint32_t)hw::periph::gpioc::moder_v::MODER8_Output;

    while(true)
    {
        ms_delay(500);
        odr ^= 1 << 8;
    }
}