/*==============================================================================
 * hy_soc.h — HY-SoC Peripheral Access Layer
 *
 * Device header for HY-SoC (edu/ track), based on ARM Cortex-M0.
 * Follows CMSDK_CM0.h pattern: IRQn_Type -> core config -> core_cm0.h -> peripherals.
 *
 * Usage:
 *   #include "hy_soc.h"   // Single include for full CMSIS Core + peripheral API
 *
 * Memory map (edu/lab4):
 *   0x0000_0000 – 0x0000_FFFF : BROM 64KB  (remap=0) / SRAM_LO (remap=1)
 *   0x2000_0000 – 0x2000_FFFF : SRAM 64KB  (always accessible)
 *   0x4000_0000 – 0x4000_FFFF : SYSCTRL
 *   0x5000_0000 – 0x5000_FFFF : LED Controller
 *   0x5100_0000 – 0x5100_FFFF : UART
 *
 * Remap behavior:
 *   remap=0 (reset default): 0x0000_xxxx -> BROM  (bootloader execution)
 *   remap=1 (app running):   0x0000_xxxx -> SRAM_LO (app vector table access)
 *============================================================================*/

#ifndef HY_SOC_H
#define HY_SOC_H

#ifdef __cplusplus
extern "C" {
#endif

/*============================================================================
 * 1. IRQ Number Definitions — must be declared before including core_cm0.h
 *============================================================================*/
typedef enum IRQn {
    /* Cortex-M0 core exceptions */
    NonMaskableInt_IRQn = -14,  /*!< NMI                    */
    HardFault_IRQn      = -13,  /*!< Hard Fault             */
    SVCall_IRQn         = -5,   /*!< SV Call                */
    PendSV_IRQn         = -2,   /*!< Pend SV                */
    SysTick_IRQn        = -1,   /*!< SysTick                */
    /* HY-SoC device-specific IRQs */
    UART_IRQn           =  0,   /*!< UART combined          */
} IRQn_Type;

/*============================================================================
 * 2. Cortex-M0 Core Configuration — must be defined before including core_cm0.h
 *============================================================================*/
#define __CM0_REV              0x0000U  /*!< Core revision r0p0                 */
#define __NVIC_PRIO_BITS       2U       /*!< 2-bit NVIC priority (4 levels)     */
#define __Vendor_SysTickConfig 0U       /*!< Use standard SysTick_Config()       */
#define __MPU_PRESENT          0U       /*!< No MPU                              */

/*============================================================================
 * 3. CMSIS Core
 *    Provides SysTick_Config, NVIC_*, __set_MSP, __DSB, __ISB, __NOP, etc.
 *============================================================================*/
#include "core_cm0.h"

/*============================================================================
 * 4. Peripheral Register Structures
 *============================================================================*/

/*----------------------------------------------------------------------------
 * UART (CMSDK APB UART, based on cmsdk_apb_uart.v)
 *
 * ahb_uart.v wraps cmsdk_apb_uart internally, so
 * students only need to use it as an AHB-Lite slave.
 *
 *  +0x00  DATA           W: TX data [7:0]   R: RX data [7:0]
 *  +0x04  STATE          [3]=rx_ovr [2]=tx_ovr [1]=rx_full [0]=tx_full  (W1C ovr)
 *  +0x08  CTRL           [6]=HSTM [5:4]=ovr_int_en [3:2]=int_en [1:0]=en
 *  +0x0C  INTSTATUS(R)   [3:0] interrupt status (read-only)
 *         INTCLEAR(W)    [3:0] write-1-to-clear
 *  +0x10  BAUDDIV        [19:0] baud-rate divider (minimum 16)
 *
 *  High-speed simulation mode: CTRL[6]=1 -> baud tick every clock cycle
 *--------------------------------------------------------------------------*/
typedef struct {
    __IO uint32_t DATA;       /*!< +0x00 TX write / RX read                */
    __IO uint32_t STATE;      /*!< +0x04 {rx_ovr, tx_ovr, rx_full, tx_full} */
    __IO uint32_t CTRL;       /*!< +0x08 Control                           */
    union {
      __I  uint32_t INTSTATUS;/*!< +0x0C Interrupt Status (read-only)      */
      __O  uint32_t INTCLEAR; /*!< +0x0C Interrupt Clear (write-only)      */
    };
    __IO uint32_t BAUDDIV;    /*!< +0x10 Baud-rate divider [19:0]          */
} HY_UART_TypeDef;

/* STATE bits */
#define HY_UART_STATE_TX_FULL      (1u << 0)  /*!< TX buffer full           */
#define HY_UART_STATE_RX_FULL      (1u << 1)  /*!< RX buffer has data       */
#define HY_UART_STATE_TX_OVR       (1u << 2)  /*!< TX overrun (W1C)         */
#define HY_UART_STATE_RX_OVR       (1u << 3)  /*!< RX overrun (W1C)         */

/* CTRL bits */
#define HY_UART_CTRL_TX_EN         (1u << 0)  /*!< TX enable                */
#define HY_UART_CTRL_RX_EN         (1u << 1)  /*!< RX enable                */
#define HY_UART_CTRL_TXINT_EN      (1u << 2)  /*!< TX interrupt enable      */
#define HY_UART_CTRL_RXINT_EN      (1u << 3)  /*!< RX interrupt enable      */
#define HY_UART_CTRL_TXOVRINT_EN   (1u << 4)  /*!< TX overrun interrupt enable */
#define HY_UART_CTRL_RXOVRINT_EN   (1u << 5)  /*!< RX overrun interrupt enable */
#define HY_UART_CTRL_HIGHSPEED     (1u << 6)  /*!< High-speed simulation mode */

/* INTSTATUS / INTCLEAR bits */
#define HY_UART_INT_TX             (1u << 0)  /*!< TX interrupt             */
#define HY_UART_INT_RX             (1u << 1)  /*!< RX interrupt             */
#define HY_UART_INT_TX_OVR         (1u << 2)  /*!< TX overrun interrupt     */
#define HY_UART_INT_RX_OVR         (1u << 3)  /*!< RX overrun interrupt     */

/*----------------------------------------------------------------------------
 * LED Controller (ahb_led.v register map)
 *
 *  +0x00  DATA  [3:0] = LED[3:0]
 *--------------------------------------------------------------------------*/
typedef struct {
    __IO uint32_t DATA;     /*!< +0x00 LED output [3:0]                    */
} HY_LED_TypeDef;

/*----------------------------------------------------------------------------
 * SYSCTRL (ahb_sysctrl.v register map)
 *
 *  +0x00  REMAPCTRL  [0] = remap
 *           0: 0x0000_xxxx -> BROM  (reset default)
 *           1: 0x0000_xxxx -> SRAM  (set when running app)
 *  +0x04  SOC_ID     (RO) SoC identifier — build-time parameter
 *           [31:24] CORE_TYPE   0x00=CM0, 0x01=CM3, 0x02=CM4F, 0x10=RV32I
 *           [23]    HAS_VTOR    0=no VTOR (remap required), 1=VTOR available
 *           [15:8]  SRAM_SIZE_KB
 *           [7:0]   BROM_SIZE_KB
 *--------------------------------------------------------------------------*/
typedef struct {
    __IO uint32_t REMAPCTRL;  /*!< +0x00 Remap Control [0]=remap           */
    __I  uint32_t SOC_ID;     /*!< +0x04 SoC ID (read-only)                */
} HY_SYSCTRL_TypeDef;

/* SOC_ID field macros */
#define HY_SOC_ID_CORE_TYPE(id)   (((id) >> 24) & 0xFFu)
#define HY_SOC_ID_HAS_VTOR(id)    (((id) >> 23) & 0x01u)
#define HY_SOC_ID_SRAM_KB(id)     (((id) >>  8) & 0xFFu)
#define HY_SOC_ID_BROM_KB(id)     (((id)      ) & 0xFFu)

#define HY_CORE_CM0    0x00u
#define HY_CORE_CM3    0x01u
#define HY_CORE_CM4F   0x02u
#define HY_CORE_RV32I  0x10u

/*============================================================================
 * Base Address
 *============================================================================*/
#define HY_BROM_BASE        (0x00000000UL)  /*!< BROM (0x0 alias when remap=0) */
#define HY_SRAM_BASE        (0x20000000UL)  /*!< SRAM 64KB (always accessible) */
#define HY_SYSCTRL_BASE     (0x40000000UL)  /*!< SYSCTRL                     */
#define HY_LED_BASE         (0x50000000UL)  /*!< LED Controller              */
#define HY_UART_BASE        (0x51000000UL)  /*!< UART                        */

/*============================================================================
 * Peripheral Instance Pointers
 *============================================================================*/
#define HY_SYSCTRL  ((HY_SYSCTRL_TypeDef *) HY_SYSCTRL_BASE)
#define HY_LED      ((HY_LED_TypeDef      *) HY_LED_BASE)
#define HY_UART     ((HY_UART_TypeDef     *) HY_UART_BASE)

/*============================================================================
 * UART Inline Helpers
 *============================================================================*/

/** Wait until TX buffer is empty, then send one byte */
static inline void hy_uart_putc(uint8_t c)
{
    while (HY_UART->STATE & HY_UART_STATE_TX_FULL);
    HY_UART->DATA = (uint32_t)c;
}

/** Wait until RX buffer has data, then receive one byte */
static inline uint8_t hy_uart_getc(void)
{
    while (!(HY_UART->STATE & HY_UART_STATE_RX_FULL));
    return (uint8_t)(HY_UART->DATA & 0xFFu);
}

/** Initialize UART in high-speed simulation mode */
static inline void hy_uart_init_highspeed(void)
{
    HY_UART->BAUDDIV = 16u;
    HY_UART->CTRL    = HY_UART_CTRL_HIGHSPEED | HY_UART_CTRL_RX_EN | HY_UART_CTRL_TX_EN;
}

/*============================================================================
 * SYSCTRL Inline Helpers
 *============================================================================*/

/**
 * Set remap=1 and flush the pipeline.
 *
 * Note: This function must be called from a SRAM_HI trampoline, or
 *       only in architectures where BROM is accessible via a
 *       separate alias address.
 *       (Lab4 uses the trampoline approach -- see boot.c)
 */
static inline void hy_sysctrl_remap_set(void)
{
    HY_SYSCTRL->REMAPCTRL = 1u;
    __DSB();
    __ISB();
}

#ifdef __cplusplus
}
#endif

#endif /* HY_SOC_H */
