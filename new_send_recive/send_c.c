/*
 * Инициализация уарта 1 на Orange Pi Zero
 */
#include <stdio.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>

#define ccu_base_addr  0x01C20000
#define uart_base_addr 0x01C28000	// общий адрес для всех uart-ов

#define uart1_offset 0x0400		// uart1
#define uart1_bit    17

volatile unsigned *ccu_regs;
volatile unsigned *uart_regs;
//
// getche() - ввод одного символа + эхо
//
int getche() {
	int ch;
	struct termios oldt, newt;
	tcgetattr( STDIN_FILENO, &oldt );
	newt = oldt;
	newt.c_lflag &= ~( ICANON );
//	newt.c_lflag &= ~( ICANON | ECHO );
	tcsetattr( STDIN_FILENO, TCSANOW, &newt );
	ch = getchar();
	tcsetattr( STDIN_FILENO, TCSANOW, &oldt );
	return ch;
}
//
// getch() - ввод одного символа без эхо
//
int getch() {
	int ch;
	struct termios oldt, newt;
	tcgetattr( STDIN_FILENO, &oldt );
	newt = oldt;
//	newt.c_lflag &= ~( ICANON );
	newt.c_lflag &= ~( ICANON | ECHO );
	tcsetattr( STDIN_FILENO, TCSANOW, &newt );
	ch = getchar();
	tcsetattr( STDIN_FILENO, TCSANOW, &oldt );
	return ch;
}

int main()
{
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

	ccu_regs[0x006C/4] |= 1<<uart1_bit;      // включаем часы у uart1 
	ccu_regs[0x02D8/4] |= 1<<uart1_bit;      // делаем ему reset 

	uart_regs[(uart1_offset + 0x0C)/4] |= 0b10000011;
	uart_regs[(uart1_offset + 0x00)/4] = 78;
	uart_regs[(uart1_offset + 0x04)/4] = 0;
	uart_regs[(uart1_offset + 0x0C)/4] &= ~0b10000000;

	char a;

	while (a = getch()) {
		

		while ((uart_regs[(uart1_offset + 0x14)/4] & (1 << 5)) == 0);
		uart_regs[(uart1_offset + 0x00)/4] = a;
		//printf("%c", a);
		if (a =='\n') {
			uart_regs[(uart1_offset + 0x00)/4] = 0;
			break;
		}
	}

	return 0;
}