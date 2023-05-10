#include <stdint.h>
#include <stdbool.h>

typedef struct {
    volatile uint32_t DATA;
    volatile uint32_t CLKDIV;
} PICOUART;

typedef struct {
    volatile uint32_t OUT;
    volatile uint32_t IN;
    volatile uint32_t OE;
} PICOGPIO;

typedef struct {
    union {
        volatile uint32_t REG;
        volatile uint16_t IOW;
        struct {
            volatile uint8_t IO;
            volatile uint8_t OE;
            volatile uint8_t CFG;
            volatile uint8_t EN; 
        };
    };
} PICOQSPI;

#define QSPI0 ((PICOQSPI*)0x81000000)
#define GPIO0 ((PICOGPIO*)0x82000000)
#define UART0 ((PICOUART*)0x83000000)

// --------------------------------------------------------

inline uint8_t uart_getchar() {
    int rdata;
    do {
        rdata = UART0->DATA;
    } while (rdata < 0);
    return rdata;
}

inline void uart_putchar(uint8_t wdata) {
    UART0->DATA = wdata;
}

void print(const char *p)
{
    while (*p)
        uart_putchar(*(p++));
}

void print_hex(uint32_t v, int digits)
{
    for (int i = 7; i >= 0; i--) {
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
        if (c == '0' && i >= digits) continue;
        uart_putchar(c);
        digits = i;
    }
}

#define CLK_FREQ        25000000
#define UART_BAUD       115200

int main()
{
    UART0->CLKDIV = CLK_FREQ / UART_BAUD - 2;
	GPIO0->OE = 0xFF;
    GPIO0->OUT = 0x55;
	
	{
		char Msg[]="\n\rHello PICORV32 on Marsohod3GW board!!!\n\r";
		print(Msg);
		while(1) {
			char c = uart_getchar();
			GPIO0->OUT = c;
			print_hex(c,2);
			uart_putchar(0xD);
			uart_putchar(0xA);
		}
	}
}
