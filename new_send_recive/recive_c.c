/*
 * Инициализация уарта 1 на Orange Pi Zero
 */
#include <stdio.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <fcntl.h>

#define ccu_base_addr  0x01C20000
#define uart_base_addr 0x01C28000	// общий адрес для всех uart-ов

#define uart1_offset 0x0800		// uart1
#define uart1_bit    18

volatile unsigned *ccu_regs;
volatile unsigned *uart_regs;

int main()
{
	printf("\x1b[H\x1b[2J");
	int memfd = open("/dev/mem", O_RDWR | O_DSYNC);
	if(memfd == -1)
	{
		printf("Ошибка открытия файла /dev/mem\n");
		return 1;
	}

	ccu_regs = (volatile unsigned *)mmap(
	                                     NULL, 4096, PROT_READ | PROT_WRITE,
	                                     MAP_SHARED, memfd, ccu_base_addr);
	uart_regs = (volatile unsigned *)mmap(
	                                     NULL, 4096, PROT_READ | PROT_WRITE,
	                                     MAP_SHARED, memfd, uart_base_addr);

    ccu_regs[0x02D8/4] &= ~(1<<uart1_bit);
	ccu_regs[0x006C/4] |= 1<<uart1_bit;      // включаем часы у uart1 
	ccu_regs[0x02D8/4] |= 1<<uart1_bit;      // делаем ему reset 

	uart_regs[(uart1_offset + 0x0C)/4] |= 0b10000011;
	uart_regs[(uart1_offset + 0x00)/4] = 78;
	uart_regs[(uart1_offset + 0x04)/4] = 0;
	uart_regs[(uart1_offset + 0x0C)/4] &= ~0b10000000;

	char symbol;
	char prev_symbol = 0;
	for (; ;) {
		while ((uart_regs[(uart1_offset + 0x14)/4]  & (1 << 0)) == 0);
        symbol = uart_regs[(uart1_offset + 0x00)/4];
		//printf("%02d\n", symbol);
		switch (symbol + prev_symbol) {
			case 10:
				return 0;
				break;
			case 156:					// up
				printf("\x1b[1A");
				break;
			case 157:					// down
				printf("\x1b[1B");
				break;
			case 158:					// right
				printf("\x1b[1C");
				break;
			case 159:					// left
				printf("\x1b[1D");
				break;
			/////////////////////////////////
			case 175:					// f1
				return 0;
				break;
			/////////////////////////////////	
			case 176:					// f2 fg-w
				printf("\x1b[37m");
				break;
			case 177:					// f3 fg-r
				printf("\x1b[31m");
				break;
			case 178:					// f4 fg-g
				printf("\x1b[32m");
				break;
			case 179:					// f5 fg-y
				printf("\x1b[33m");
				break;
			/////////////////////////////////
			case 181:					// f6 bg-black
				printf("\x1b[40m");
				break;
			case 182:					// f7 bg-blue
				printf("\x1b[44m");
				break;
			case 183:					// f8 bg-w
				printf("\x1b[47m");
				break;
			/////////////////////////////////
			case 174:					// f9 clear
				printf("\x1b[0m\x1b[H\x1b[2J");
				break;
			default:
				printf("%c", symbol);
				break;
		}
		fflush(0);
		prev_symbol = symbol;
	}
    printf("\n");
	return 0;
}
