
#ifndef __JTAG_ADC_REGS_H__
#define __JTAG_ADC_REGS_H__

#include <io.h>

#define JTAG_ADC_INSTR_REG                    0x0
#define JTAG_ADC_DATA_REG                     0x1
#define JTAG_ADC_RESET_REG                    0x3

// Read
#define IORD_JTAG_ADC_DATA(base)              IORD(base, JTAG_ADC_DATA_REG)
#define IORD_JTAG_ADC_INSTR(base)             IORD(base, JTAG_ADC_INSTR_REG)

// Write
#define IOWR_JTAG_ADC_DATA(base, data)        IOWR(base, JTAG_ADC_DATA_REG, data)
#define IOWR_JTAG_ADC_INSTR(base, data)       IOWR(base, JTAG_ADC_INSTR_REG, data)

// Reset
#define JTAG_ADC_RESET_ON(base)          IORD(base, JTAG_ADC_RESET_REG)
#define JTAG_ADC_RESET_OFF(base)         IORD(base, JTAG_ADC_DATA_REG)

#endif /* __JTAG_ADC_REGS_H__ */

