ICANON          = 10
ICANON_AND_ECHO = 2

.global	getche
getche:
	mov	r9, #ICANON_AND_ECHO
	b	action

.global	getch
getch:
	mov	r9, #ICANON
	b 	action


action:
	push	{r4, r5, r6, r7, r8, lr}
	sub	sp, sp, #120

	add	r4, sp, #60     @ R4 newt
	mov	r6, sp		@ R6 oldt

	movs	r0, #0  	@ STDIN_FILENO
	mov	r1, r6 		@ R1 oldt
	mov	r5, r6		@ R5 oldt
	bl	tcgetattr(PLT)

	@copy struct
	ldmia	r5!, {r0, r1, r2, r3}
	stmia	r4!, {r0, r1, r2, r3}

	ldmia	r5!, {r0, r1, r2, r3}
	stmia	r4!, {r0, r1, r2, r3}

	ldmia	r5!, {r0, r1, r2, r3}
	stmia	r4!, {r0, r1, r2, r3}

	ldm	r5, {r0, r1, r2}
	stm	r4, {r0, r1, r2}
	
	@set flag
	ldr	r7, [sp, #72]
	bic	r7, r7, r9
	str	r7, [sp, #72]

	@t set attr
	movs	r0, #0
	mov	r1, #0
	add	r2, sp, #60
	bl	tcsetattr(PLT)

	@getc
	mov	r0, #0
	bl	getchar(PLT)

	mov	r4, r0

	mov	r1, #0
	mov 	r0, #0
	mov	r2, r6
	bl	tcsetattr(PLT)

	mov	r0, r4
	add	sp, sp, #120
	pop	{r4, r5, r6, r7, r8, pc}

