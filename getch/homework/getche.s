.globl	getche
.text
getche:
	@ args = 0, pretend = 0, frame = 128
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, r9, lr}
	sub	sp, sp, #132
	ldr	r8, .L6
	add	r6, sp, #4
	ldr	r3, .L6+4
	movs	r0, #0
.LPIC0:
	add	r8, pc
	mov	r1, r6
	mov	r5, r6
	add	r4, sp, #64
	ldr	r9, [r8, r3]
	ldr	r3, [r9]
	str	r3, [sp, #124]
	bl	tcgetattr(PLT)
	ldmia	r5!, {r0, r1, r2, r3}
	stmia	r4!, {r0, r1, r2, r3}
	ldmia	r5!, {r0, r1, r2, r3}
	ldr	r7, [sp, #76]
	bic	r7, r7, #2
	str	r7, [sp, #76]
	stmia	r4!, {r0, r1, r2, r3}
	ldmia	r5!, {r0, r1, r2, r3}
	stmia	r4!, {r0, r1, r2, r3}
	ldm	r5, {r0, r1, r2}
	stm	r4, {r0, r1, r2}
	movs	r1, #0
	mov	r0, r1
	add	r2, sp, #64
	bl	tcsetattr(PLT)
	ldr	r3, .L6+8
	ldr	r3, [r8, r3]
	ldr	r0, [r3]
	bl	_IO_getc(PLT)
	movs	r1, #0
	mov	r2, r6
	mov	r4, r0
	mov	r0, r1
	bl	tcsetattr(PLT)
	ldr	r2, [sp, #124]
	ldr	r3, [r9]
	cmp	r2, r3
	bne	.L5
	mov	r0, r4
	add	sp, sp, #132
	@ sp needed
	pop	{r4, r5, r6, r7, r8, r9, pc}
.L5:
	bl	__stack_chk_fail(PLT)
.L7:
	.align	2
.L6:
	.word	_GLOBAL_OFFSET_TABLE_-(.LPIC0+4)
	.word	__stack_chk_guard(GOT)
	.word	stdin(GOT)
