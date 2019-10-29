@ Created by ocherisan

.globl _start
.data
msg: .ascii "Ошибка\n"
lmsg = . - msg

maxfilelen = 2000000
.bss
.lcomm filelen, 4
.lcomm outlen, 4
.lcomm filebuffer, maxfilelen   
.lcomm outbuffer, maxfilelen   
.lcomm color, 4
.text
typeerror:
        push    {lr}
        mov     r7, #4
        mov     r0, #1
        ldr     r1, =msg
        mov     r2, #lmsg 
        svc     #0
        pop     {r15}

exit:
        mov     r7, #1
        eor     r0, r0          @ eor - xor
        svc     #0
_start:
        mov     r7, #3          
        mov     r0, #5          @ мы отправляем файл в поток с номером 5, т.е. такой у нас файловы дескриптор
        ldr     r1, =filebuffer 
        ldr     r2, =maxfilelen 
        svc     #0              

        cmp     r0, #0          
        bgt     1f              
        bl      typeerror        
        b       exit              
1:
        ldr     r1, =filelen    
        str     r0, [r1]        

        bl      processing       

processing:
        bl      getch
        cmp     r0, #27
        beq     exit

        cmp     r0, #49
        ldr     r1, =color
        mov     r2, #0
        str     r2, [r1]
        bleq     standart_prog

        cmp     r0, #50
        ldr     r1, =color
        mov     r2, #1
        str     r2, [r1]
        bleq     standart_prog

        cmp     r0, #51
        bleq    reverse

        cmp     r0, #52
        bleq    first_str

        cmp     r0, #53
        bleq    last_str

        b       processing    
load_esc_blue:
        mov     r8, #0x1b
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x5b
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x33
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x34
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x6d
        strb    r8, [r4, r5]
        add     r5, #1
        bx      lr
load_esc_red:
        mov     r8, #0x1b
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x5b
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x33
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x31
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x6d
        strb    r8, [r4, r5]
        add     r5, #1
        bx      lr
load_esc_reset:
        mov     r8, #0x1b
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x5b
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x30
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x6d
        strb    r8, [r4, r5]
        add     r5, #1
        bx      lr
standart_prog:
        push    {lr}
        ldr     r0, =filebuffer
        ldr     r4, =outbuffer
        ldr     r1, =filelen
        ldr     r1, [r1]
    
        eor     r2, r2
        eor     r3, r3
        eor     r5, r5 
        eor     r6, r6
        eor     r7, r7
    
        mov     r6, #1
        mov     r7, #0

        eor     r8, r8

        ldr     r8, =color
        ldr     r8, [r8]
        cmp     r8, #0
        bleq    load_esc_blue  
        blne    load_esc_red  

        mov     r8, #0x1b
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x5b
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x31
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x6d
        strb    r8, [r4, r5]
        add     r5, #1
1:
        ldrb    r3, [r0, r2]   @ загрузка байта в r3 из r0 + r2

        cmp     r6, #1
        beq     2f
        b       3f
2:
        cmp     r3, #0xa
        bne     4f
        b       5f
3:  
        cmp     r7, #1
        beq     8f
        b       9f
4:  
        cmp     r3, #0x9
        beq     7f
        cmp     r3, #0x20
        beq     7f
        b       6f
5:
        mov     r6, #1

        eor     r8, r8

        ldr     r8, =color
        ldr     r8, [r8]
        cmp     r8, #0
        bleq    load_esc_blue  
        blne    load_esc_red  

        mov     r8, #0x1b
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x5b
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x31
        strb    r8, [r4, r5]
        add     r5, #1

        mov     r8, #0x6d
        strb    r8, [r4, r5]
        add     r5, #1

        b       7f
6:
        mov     r7, #1
        mov     r6, #0
        b       11f
7:
        strb    r3, [r4, r5]
        add     r5, #1
        add     r2, #1
        subs    r1, #1         @ subs - sub, который выставляет флаги
        bne     1b
        ldr     r1, =outlen    @ кладём ссылку на выделенные 4 байта по количество символов в r1
        str     r5, [r1]
        @bx     lr               @ прыгаем на сохранённое место в регистр lr 
        mov     r7, #4          
        mov     r0, #1          
        ldr     r1, =outbuffer 
        ldr     r2, =outlen    
        ldr     r2, [r2]
        svc     #0 
        pop     {r15}
        @bx     lr
8:
        cmp     r3, #0xa
        beq     5b
        b       10f
9:
        cmp     r3, #0xa
        beq     5b
        b       7b
10:
        cmp     r3, #0x9
        beq     12f
        cmp     r3, #0x20
        beq     12f
        b       11f
11:
        cmp     r3, #0x61       @ сравниваем сивол из r3 с 0x61
        bmi     7b              @ если цифра меньше, то прыгаем на вторую метку
        cmp     r3, #0x7b       
        submi   r3, #0x20     @ вычесть 20, если r3 < 0x7b
        b       7b
12:
        mov     r7, #0
        eor     r8, r8

        bl      load_esc_reset

        b       7b
first_str:
        push    {lr}
        ldr     r0, =filebuffer
        ldr     r4, =outbuffer
        eor     r2, r2
        eor     r3, r3
        eor     r5, r5 

        bl      load_esc_reset
1:
        ldrb    r3, [r0, r2]   @ загрузка байта в r3 из r0 + r2
        cmp     r3, #0xa
        beq     3f
2:  
        strb    r3, [r4, r5]
        add     r5, #1
        add     r2, #1
        b       1b
3:
        strb    r3, [r4, r5]
        add     r5, #1
        add     r2, #1

        ldr     r1, =outlen    @ кладём ссылку на выделенные 4 байта по количество символов в r1
        str     r5, [r1]

        mov     r7, #4          
        mov     r0, #1          
        ldr     r1, =outbuffer 
        ldr     r2, =outlen    
        ldr     r2, [r2]
        svc     #0 
        pop     {r15}

reverse:
        push    {lr}
        ldr     r0, =filebuffer
        ldr     r4, =outbuffer
        ldr     r1, =filelen
        ldr     r1, [r1]
    
        mov     r2, r1 
        eor     r3, r3
        eor     r5, r5 

        bl      load_esc_reset
1:
        ldrb    r3, [r0, r2]   @ загрузка байта в r3 из r0 + r2
        strb    r3, [r4, r5]
        add     r5, #1
        sub     r2, #1
        subs    r1, #1         @ subs - sub, который выставляет флаги
        bne     1b

        ldr     r1, =outlen    @ кладём ссылку на выделенные 4 байта по количество символов в r1
        str     r5, [r1]

        mov     r7, #4          
        mov     r0, #1          
        ldr     r1, =outbuffer 
        ldr     r2, =outlen    
        ldr     r2, [r2]
        svc     #0 
        pop     {r15}

last_str:
        push    {lr}
        ldr     r0, =filebuffer
        ldr     r4, =outbuffer
        ldr     r1, =filelen
        ldr     r1, [r1]
    
        mov     r2, r1 
        eor     r3, r3
        eor     r5, r5 
        sub     r2, #1
        bl      load_esc_reset

        sub     r2, #1
1:
        ldrb    r3, [r0, r2]
        cmp     r3, #0xa
        beq     3f
2:  
        sub     r2, #1
        b       1b
3:
        add     r2, #1
4:    
        ldrb    r3, [r0, r2]
        strb    r3, [r4, r5]
        add     r5, #1
        add     r2, #1
5:
        cmp     r2, r1
        beq     6f
        b       4b
6:
        ldr     r1, =outlen    @ кладём ссылку на выделенные 4 байта по количество символов в r1
        str     r5, [r1]

        mov     r7, #4          
        mov     r0, #1          
        ldr     r1, =outbuffer 
        ldr     r2, =outlen    
        ldr     r2, [r2]
        svc     #0 
        pop     {r15}
