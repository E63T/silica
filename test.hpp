#pragma once
#include <silica.hpp>

/**
Hardware description

Generated with Silica.cr
Version 0.1.0
*/
namespace hw
{
  enum class interrupt_id;
  namespace cpu
  {
    constexpr static char* name = "CM0";
    constexpr static char* revision = "r1p1";
    constexpr static auto endian = silica::endian::little;
    constexpr static auto fpu_present = false;
    constexpr static auto mpu_present = false;
    constexpr static auto vtor_present = true;
    constexpr static auto nvic_prio_bits = 2;
    constexpr static auto vendor_systick_config = false;
  }
  constexpr static char* name = "STM32F0x2";
  constexpr static char* description = "STM32F072";
  constexpr static char* version = "1.0";
  constexpr static auto width = 32;
  constexpr static auto address_unit_bits = 8;
  constexpr static auto size = 0x20;
  constexpr static auto reset_mask = 0xFFFFFFFF;
  constexpr static auto reset_value = 0x0;
  namespace periph
  {
    struct crc_type : public silica::periph
    {
      struct registers
      {
        uint32_t dr;
        uint32_t idr;
        uint32_t cr;
        uint32_t init;
      };
      
      crc_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct gpiof_type : public silica::periph
    {
      struct registers
      {
        uint32_t moder;
        uint32_t otyper;
        uint32_t ospeedr;
        uint32_t pupdr;
        uint32_t idr;
        uint32_t odr;
        uint32_t bsrr;
        uint32_t lckr;
        uint32_t afrl;
        uint32_t afrh;
        uint32_t brr;
      };
      
      gpiof_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    
    
    
    
    struct gpioa_type : public silica::periph
    {
      struct registers
      {
        uint32_t moder;
        uint32_t otyper;
        uint32_t ospeedr;
        uint32_t pupdr;
        uint32_t idr;
        uint32_t odr;
        uint32_t bsrr;
        uint32_t lckr;
        uint32_t afrl;
        uint32_t afrh;
        uint32_t brr;
      };
      
      gpioa_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct spi1_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr1;
        uint32_t cr2;
        uint32_t sr;
        uint32_t dr;
        uint32_t crcpr;
        uint32_t rxcrcr;
        uint32_t txcrcr;
        uint32_t i2scfgr;
        uint32_t i2spr;
      };
      
      spi1_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    
    struct dac_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr;
        uint32_t swtrigr;
        uint32_t dhr12r1;
        uint32_t dhr12l1;
        uint32_t dhr8r1;
        uint32_t dhr12r2;
        uint32_t dhr12l2;
        uint32_t dhr8r2;
        uint32_t dhr12rd;
        uint32_t dhr12ld;
        uint32_t dhr8rd;
        uint32_t dor1;
        uint32_t dor2;
        uint32_t sr;
      };
      
      dac_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct pwr_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr;
        uint32_t csr;
      };
      
      pwr_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct i2c1_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr1;
        uint32_t cr2;
        uint32_t oar1;
        uint32_t oar2;
        uint32_t timingr;
        uint32_t timeoutr;
        uint32_t isr;
        uint32_t icr;
        uint32_t pecr;
        uint32_t rxdr;
        uint32_t txdr;
      };
      
      i2c1_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    
    struct iwdg_type : public silica::periph
    {
      struct registers
      {
        uint32_t kr;
        uint32_t pr;
        uint32_t rlr;
        uint32_t sr;
        uint32_t winr;
      };
      
      iwdg_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct wwdg_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr;
        uint32_t cfr;
        uint32_t sr;
      };
      
      wwdg_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct tim1_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr1;
        uint32_t cr2;
        uint32_t smcr;
        uint32_t dier;
        uint32_t sr;
        uint32_t egr;
        uint32_t ccmr1_input;
        uint32_t ccmr2_input;
        uint32_t ccer;
        uint32_t cnt;
        uint32_t psc;
        uint32_t arr;
        uint32_t rcr;
        uint32_t ccr1;
        uint32_t ccr2;
        uint32_t ccr3;
        uint32_t ccr4;
        uint32_t bdtr;
        uint32_t dcr;
        uint32_t dmar;
      };
      
      tim1_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct tim2_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr1;
        uint32_t cr2;
        uint32_t smcr;
        uint32_t dier;
        uint32_t sr;
        uint32_t egr;
        uint32_t ccmr1_input;
        uint32_t ccmr2_input;
        uint32_t ccer;
        uint32_t cnt;
        uint32_t psc;
        uint32_t arr;
        uint32_t _padding_0[1];
        uint32_t ccr1;
        uint32_t ccr2;
        uint32_t ccr3;
        uint32_t ccr4;
        uint32_t _padding_1[1];
        uint32_t dcr;
        uint32_t dmar;
      };
      
      tim2_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    
    struct tim14_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr1;
        uint32_t _padding_2[2];
        uint32_t dier;
        uint32_t sr;
        uint32_t egr;
        uint32_t ccmr1_input;
        uint32_t _padding_3[1];
        uint32_t ccer;
        uint32_t cnt;
        uint32_t psc;
        uint32_t arr;
        uint32_t _padding_4[1];
        uint32_t ccr1;
        uint32_t _padding_5[6];
        uint32_t _or;
      };
      
      tim14_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct tim6_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr1;
        uint32_t cr2;
        uint32_t _padding_6[1];
        uint32_t dier;
        uint32_t sr;
        uint32_t egr;
        uint32_t _padding_7[3];
        uint32_t cnt;
        uint32_t psc;
        uint32_t arr;
      };
      
      tim6_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    
    struct exti_type : public silica::periph
    {
      struct registers
      {
        uint32_t imr;
        uint32_t emr;
        uint32_t rtsr;
        uint32_t ftsr;
        uint32_t swier;
        uint32_t pr;
      };
      
      exti_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct nvic_type : public silica::periph
    {
      struct registers
      {
        uint32_t iser;
        uint32_t _padding_8[31];
        uint32_t icer;
        uint32_t _padding_9[31];
        uint32_t ispr;
        uint32_t _padding_10[31];
        uint32_t icpr;
        uint32_t _padding_11[95];
        uint32_t ipr0;
        uint32_t ipr1;
        uint32_t ipr2;
        uint32_t ipr3;
        uint32_t ipr4;
        uint32_t ipr5;
        uint32_t ipr6;
        uint32_t ipr7;
      };
      
      nvic_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct dma1_type : public silica::periph
    {
      struct registers
      {
        uint32_t isr;
        uint32_t ifcr;
        uint32_t ccr1;
        uint32_t cndtr1;
        uint32_t cpar1;
        uint32_t cmar1;
        uint32_t _padding_12[1];
        uint32_t ccr2;
        uint32_t cndtr2;
        uint32_t cpar2;
        uint32_t cmar2;
        uint32_t _padding_13[1];
        uint32_t ccr3;
        uint32_t cndtr3;
        uint32_t cpar3;
        uint32_t cmar3;
        uint32_t _padding_14[1];
        uint32_t ccr4;
        uint32_t cndtr4;
        uint32_t cpar4;
        uint32_t cmar4;
        uint32_t _padding_15[1];
        uint32_t ccr5;
        uint32_t cndtr5;
        uint32_t cpar5;
        uint32_t cmar5;
        uint32_t _padding_16[1];
        uint32_t ccr6;
        uint32_t cndtr6;
        uint32_t cpar6;
        uint32_t cmar6;
        uint32_t _padding_17[1];
        uint32_t ccr7;
        uint32_t cndtr7;
        uint32_t cpar7;
        uint32_t cmar7;
      };
      
      dma1_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct rcc_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr;
        uint32_t cfgr;
        uint32_t cir;
        uint32_t apb2rstr;
        uint32_t apb1rstr;
        uint32_t ahbenr;
        uint32_t apb2enr;
        uint32_t apb1enr;
        uint32_t bdcr;
        uint32_t csr;
        uint32_t ahbrstr;
        uint32_t cfgr2;
        uint32_t cfgr3;
        uint32_t cr2;
      };
      
      rcc_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct syscfg_comp_type : public silica::periph
    {
      struct registers
      {
        uint32_t syscfg_cfgr1;
        uint32_t _padding_18[1];
        uint32_t syscfg_exticr1;
        uint32_t syscfg_exticr2;
        uint32_t syscfg_exticr3;
        uint32_t syscfg_exticr4;
        uint32_t syscfg_cfgr2;
        uint32_t comp_csr;
      };
      
      syscfg_comp_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct adc_type : public silica::periph
    {
      struct registers
      {
        uint32_t isr;
        uint32_t ier;
        uint32_t cr;
        uint32_t cfgr1;
        uint32_t cfgr2;
        uint32_t smpr;
        uint32_t _padding_19[2];
        uint32_t tr;
        uint32_t _padding_20[1];
        uint32_t chselr;
        uint32_t _padding_21[5];
        uint32_t dr;
        uint32_t _padding_22[177];
        uint32_t ccr;
      };
      
      adc_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct usart1_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr1;
        uint32_t cr2;
        uint32_t cr3;
        uint32_t brr;
        uint32_t gtpr;
        uint32_t rtor;
        uint32_t rqr;
        uint32_t isr;
        uint32_t icr;
        uint32_t rdr;
        uint32_t tdr;
      };
      
      usart1_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    
    
    
    struct rtc_type : public silica::periph
    {
      struct registers
      {
        uint32_t tr;
        uint32_t dr;
        uint32_t cr;
        uint32_t isr;
        uint32_t prer;
        uint32_t _padding_23[2];
        uint32_t alrmar;
        uint32_t _padding_24[1];
        uint32_t wpr;
        uint32_t ssr;
        uint32_t shiftr;
        uint32_t tstr;
        uint32_t tsdr;
        uint32_t tsssr;
        uint32_t calr;
        uint32_t tafcr;
        uint32_t alrmassr;
        uint32_t _padding_25[2];
        uint32_t bkp0r;
        uint32_t bkp1r;
        uint32_t bkp2r;
        uint32_t bkp3r;
        uint32_t bkp4r;
      };
      
      rtc_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct tim15_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr1;
        uint32_t cr2;
        uint32_t smcr;
        uint32_t dier;
        uint32_t sr;
        uint32_t egr;
        uint32_t ccmr1_input;
        uint32_t _padding_26[1];
        uint32_t ccer;
        uint32_t cnt;
        uint32_t psc;
        uint32_t arr;
        uint32_t rcr;
        uint32_t ccr1;
        uint32_t ccr2;
        uint32_t _padding_27[2];
        uint32_t bdtr;
        uint32_t dcr;
        uint32_t dmar;
      };
      
      tim15_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct tim16_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr1;
        uint32_t cr2;
        uint32_t _padding_28[1];
        uint32_t dier;
        uint32_t sr;
        uint32_t egr;
        uint32_t ccmr1_input;
        uint32_t _padding_29[1];
        uint32_t ccer;
        uint32_t cnt;
        uint32_t psc;
        uint32_t arr;
        uint32_t rcr;
        uint32_t ccr1;
        uint32_t _padding_30[3];
        uint32_t bdtr;
        uint32_t dcr;
        uint32_t dmar;
      };
      
      tim16_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    
    struct tsc_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr;
        uint32_t ier;
        uint32_t icr;
        uint32_t isr;
        uint32_t iohcr;
        uint32_t _padding_31[1];
        uint32_t ioascr;
        uint32_t _padding_32[1];
        uint32_t ioscr;
        uint32_t _padding_33[1];
        uint32_t ioccr;
        uint32_t _padding_34[1];
        uint32_t iogcsr;
        uint32_t iog1cr;
        uint32_t iog2cr;
        uint32_t iog3cr;
        uint32_t iog4cr;
        uint32_t iog5cr;
        uint32_t iog6cr;
      };
      
      tsc_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct cec_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr;
        uint32_t cfgr;
        uint32_t txdr;
        uint32_t rxdr;
        uint32_t isr;
        uint32_t ier;
      };
      
      cec_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct flash_type : public silica::periph
    {
      struct registers
      {
        uint32_t acr;
        uint32_t keyr;
        uint32_t optkeyr;
        uint32_t sr;
        uint32_t cr;
        uint32_t ar;
        uint32_t _padding_35[1];
        uint32_t obr;
        uint32_t wrpr;
      };
      
      flash_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct dbgmcu_type : public silica::periph
    {
      struct registers
      {
        uint32_t idcode;
        uint32_t cr;
        uint32_t apb1_fz;
        uint32_t apb2_fz;
      };
      
      dbgmcu_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct usb_type : public silica::periph
    {
      struct registers
      {
        uint32_t ep0r;
        uint32_t ep1r;
        uint32_t ep2r;
        uint32_t ep3r;
        uint32_t ep4r;
        uint32_t ep5r;
        uint32_t ep6r;
        uint32_t ep7r;
        uint32_t _padding_36[8];
        uint32_t cntr;
        uint32_t istr;
        uint32_t fnr;
        uint32_t daddr;
        uint32_t btable;
        uint32_t lpmcsr;
        uint32_t bcdr;
      };
      
      usb_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct crs_type : public silica::periph
    {
      struct registers
      {
        uint32_t cr;
        uint32_t cfgr;
        uint32_t isr;
        uint32_t icr;
      };
      
      crs_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    struct can_type : public silica::periph
    {
      struct registers
      {
        uint32_t can_mcr;
        uint32_t can_msr;
        uint32_t can_tsr;
        uint32_t can_rf0r;
        uint32_t can_rf1r;
        uint32_t can_ier;
        uint32_t can_esr;
        uint32_t can_btr;
        uint32_t _padding_37[88];
        uint32_t can_ti0r;
        uint32_t can_tdt0r;
        uint32_t can_tdl0r;
        uint32_t can_tdh0r;
        uint32_t can_ti1r;
        uint32_t can_tdt1r;
        uint32_t can_tdl1r;
        uint32_t can_tdh1r;
        uint32_t can_ti2r;
        uint32_t can_tdt2r;
        uint32_t can_tdl2r;
        uint32_t can_tdh2r;
        uint32_t can_ri0r;
        uint32_t can_rdt0r;
        uint32_t can_rdl0r;
        uint32_t can_rdh0r;
        uint32_t can_ri1r;
        uint32_t can_rdt1r;
        uint32_t can_rdl1r;
        uint32_t can_rdh1r;
        uint32_t _padding_38[12];
        uint32_t can_fmr;
        uint32_t can_fm1r;
        uint32_t _padding_39[1];
        uint32_t can_fs1r;
        uint32_t _padding_40[1];
        uint32_t can_ffa1r;
        uint32_t _padding_41[1];
        uint32_t can_fa1r;
        uint32_t _padding_42[8];
        uint32_t f0r1;
        uint32_t f0r2;
        uint32_t f1r1;
        uint32_t f1r2;
        uint32_t f2r1;
        uint32_t f2r2;
        uint32_t f3r1;
        uint32_t f3r2;
        uint32_t f4r1;
        uint32_t f4r2;
        uint32_t f5r1;
        uint32_t f5r2;
        uint32_t f6r1;
        uint32_t f6r2;
        uint32_t f7r1;
        uint32_t f7r2;
        uint32_t f8r1;
        uint32_t f8r2;
        uint32_t f9r1;
        uint32_t f9r2;
        uint32_t f10r1;
        uint32_t f10r2;
        uint32_t f11r1;
        uint32_t f11r2;
        uint32_t f12r1;
        uint32_t f12r2;
        uint32_t f13r1;
        uint32_t f13r2;
        uint32_t f14r1;
        uint32_t f14r2;
        uint32_t f15r1;
        uint32_t f15r2;
        uint32_t f16r1;
        uint32_t f16r2;
        uint32_t f17r1;
        uint32_t f17r2;
        uint32_t f18r1;
        uint32_t f18r2;
        uint32_t f19r1;
        uint32_t f19r2;
        uint32_t f20r1;
        uint32_t f20r2;
        uint32_t f21r1;
        uint32_t f21r2;
        uint32_t f22r1;
        uint32_t f22r2;
        uint32_t f23r1;
        uint32_t f23r2;
        uint32_t f24r1;
        uint32_t f24r2;
        uint32_t f25r1;
        uint32_t f25r2;
        uint32_t f26r1;
        uint32_t f26r2;
        uint32_t f27r1;
        uint32_t f27r2;
      };
      
      can_type (size_t address)
      {
        m_base = (registers*)address;
      }
      
      registers* m_base;
    };
    
    
    crc_type crc(0x40023000);
    gpiof_type gpiof(0x48001400);
    gpiof_type gpiod(0x48000c00);
    gpiof_type gpioc(0x48000800);
    gpiof_type gpiob(0x48000400);
    gpiof_type gpioe(0x48001000);
    gpioa_type gpioa(0x48000000);
    spi1_type spi1(0x40013000);
    spi1_type spi2(0x40003800);
    dac_type dac(0x40007400);
    pwr_type pwr(0x40007000);
    i2c1_type i2c1(0x40005400);
    i2c1_type i2c2(0x40005800);
    iwdg_type iwdg(0x40003000);
    wwdg_type wwdg(0x40002c00);
    tim1_type tim1(0x40012c00);
    tim2_type tim2(0x40000000);
    tim2_type tim3(0x40000400);
    tim14_type tim14(0x40002000);
    tim6_type tim6(0x40001000);
    tim6_type tim7(0x40001400);
    exti_type exti(0x40010400);
    nvic_type nvic(0xe000e100);
    dma1_type dma1(0x40020000);
    rcc_type rcc(0x40021000);
    syscfg_comp_type syscfg_comp(0x40010000);
    adc_type adc(0x40012400);
    usart1_type usart1(0x40013800);
    usart1_type usart2(0x40004400);
    usart1_type usart3(0x40004800);
    usart1_type usart4(0x40004c00);
    rtc_type rtc(0x40002800);
    tim15_type tim15(0x40014000);
    tim16_type tim16(0x40014400);
    tim16_type tim17(0x40014800);
    tsc_type tsc(0x40024000);
    cec_type cec(0x40007800);
    flash_type flash(0x40022000);
    dbgmcu_type dbgmcu(0x40015800);
    usb_type usb(0x40005c00);
    crs_type crs(0x40006c00);
    can_type can(0x40006400);
  }
  
  enum class interrupt_id
  {
    SPI1,
    SPI2,
    DAC,
    I2C1,
    I2C2,
    WWDG,
    TIM1,
    TIM2,
    TIM3,
    TIM14,
    TIM7,
    EXTI,
    DMA1,
    RCC,
    ADC,
    USART1,
    USART2,
    USART3,
    RTC,
    TIM15,
    TIM16,
    TIM17,
    TSC,
    CEC,
    Flash,
    USB,
  };
  
  extern "C" void SPI1_IRQ_Handler()
  {
    if(periph::spi1.interrupt_handler)
    {
      periph::spi1.interrupt_handler(&periph::spi1, interrupt_id::SPI1);
    }
  }
  
  extern "C" void SPI2_IRQ_Handler()
  {
    if(periph::spi2.interrupt_handler)
    {
      periph::spi2.interrupt_handler(&periph::spi2, interrupt_id::SPI2);
    }
  }
  
  extern "C" void DAC_IRQ_Handler()
  {
    if(periph::dac.interrupt_handler)
    {
      periph::dac.interrupt_handler(&periph::dac, interrupt_id::DAC);
    }
  }
  
  extern "C" void I2C1_IRQ_Handler()
  {
    if(periph::i2c1.interrupt_handler)
    {
      periph::i2c1.interrupt_handler(&periph::i2c1, interrupt_id::I2C1);
    }
  }
  
  extern "C" void I2C2_IRQ_Handler()
  {
    if(periph::i2c2.interrupt_handler)
    {
      periph::i2c2.interrupt_handler(&periph::i2c2, interrupt_id::I2C2);
    }
  }
  
  extern "C" void WWDG_IRQ_Handler()
  {
    if(periph::wwdg.interrupt_handler)
    {
      periph::wwdg.interrupt_handler(&periph::wwdg, interrupt_id::WWDG);
    }
  }
  
  extern "C" void TIM1_IRQ_Handler()
  {
    if(periph::tim1.interrupt_handler)
    {
      periph::tim1.interrupt_handler(&periph::tim1, interrupt_id::TIM1);
    }
  }
  
  extern "C" void TIM2_IRQ_Handler()
  {
    if(periph::tim2.interrupt_handler)
    {
      periph::tim2.interrupt_handler(&periph::tim2, interrupt_id::TIM2);
    }
  }
  
  extern "C" void TIM3_IRQ_Handler()
  {
    if(periph::tim3.interrupt_handler)
    {
      periph::tim3.interrupt_handler(&periph::tim3, interrupt_id::TIM3);
    }
  }
  
  extern "C" void TIM14_IRQ_Handler()
  {
    if(periph::tim14.interrupt_handler)
    {
      periph::tim14.interrupt_handler(&periph::tim14, interrupt_id::TIM14);
    }
  }
  
  extern "C" void TIM7_IRQ_Handler()
  {
    if(periph::tim7.interrupt_handler)
    {
      periph::tim7.interrupt_handler(&periph::tim7, interrupt_id::TIM7);
    }
  }
  
  extern "C" void EXTI_IRQ_Handler()
  {
    if(periph::exti.interrupt_handler)
    {
      periph::exti.interrupt_handler(&periph::exti, interrupt_id::EXTI);
    }
  }
  
  extern "C" void DMA1_IRQ_Handler()
  {
    if(periph::dma1.interrupt_handler)
    {
      periph::dma1.interrupt_handler(&periph::dma1, interrupt_id::DMA1);
    }
  }
  
  extern "C" void RCC_IRQ_Handler()
  {
    if(periph::rcc.interrupt_handler)
    {
      periph::rcc.interrupt_handler(&periph::rcc, interrupt_id::RCC);
    }
  }
  
  extern "C" void ADC_IRQ_Handler()
  {
    if(periph::adc.interrupt_handler)
    {
      periph::adc.interrupt_handler(&periph::adc, interrupt_id::ADC);
    }
  }
  
  extern "C" void USART1_IRQ_Handler()
  {
    if(periph::usart1.interrupt_handler)
    {
      periph::usart1.interrupt_handler(&periph::usart1, interrupt_id::USART1);
    }
  }
  
  extern "C" void USART2_IRQ_Handler()
  {
    if(periph::usart2.interrupt_handler)
    {
      periph::usart2.interrupt_handler(&periph::usart2, interrupt_id::USART2);
    }
  }
  
  extern "C" void USART3_IRQ_Handler()
  {
    if(periph::usart3.interrupt_handler)
    {
      periph::usart3.interrupt_handler(&periph::usart3, interrupt_id::USART3);
    }
  }
  
  extern "C" void RTC_IRQ_Handler()
  {
    if(periph::rtc.interrupt_handler)
    {
      periph::rtc.interrupt_handler(&periph::rtc, interrupt_id::RTC);
    }
  }
  
  extern "C" void TIM15_IRQ_Handler()
  {
    if(periph::tim15.interrupt_handler)
    {
      periph::tim15.interrupt_handler(&periph::tim15, interrupt_id::TIM15);
    }
  }
  
  extern "C" void TIM16_IRQ_Handler()
  {
    if(periph::tim16.interrupt_handler)
    {
      periph::tim16.interrupt_handler(&periph::tim16, interrupt_id::TIM16);
    }
  }
  
  extern "C" void TIM17_IRQ_Handler()
  {
    if(periph::tim17.interrupt_handler)
    {
      periph::tim17.interrupt_handler(&periph::tim17, interrupt_id::TIM17);
    }
  }
  
  extern "C" void TSC_IRQ_Handler()
  {
    if(periph::tsc.interrupt_handler)
    {
      periph::tsc.interrupt_handler(&periph::tsc, interrupt_id::TSC);
    }
  }
  
  extern "C" void CEC_IRQ_Handler()
  {
    if(periph::cec.interrupt_handler)
    {
      periph::cec.interrupt_handler(&periph::cec, interrupt_id::CEC);
    }
  }
  
  extern "C" void Flash_IRQ_Handler()
  {
    if(periph::flash.interrupt_handler)
    {
      periph::flash.interrupt_handler(&periph::flash, interrupt_id::Flash);
    }
  }
  
  extern "C" void USB_IRQ_Handler()
  {
    if(periph::usb.interrupt_handler)
    {
      periph::usb.interrupt_handler(&periph::usb, interrupt_id::USB);
    }
  }
}
