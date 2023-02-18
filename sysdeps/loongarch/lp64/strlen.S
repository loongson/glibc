#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#ifndef STRLEN
#define STRLEN	strlen
#endif

LEAF(STRLEN)
	.align 6
	move		a1, a0
	bstrins.d	a0, zero, 2, 0
	lu12i.w		a2, 0x01010
	li.w		t0, -1

	ld.d		t2, a0, 0
	andi		t1, a1, 0x7
	ori		a2, a2, 0x101
	slli.d		t1, t1, 3

	bstrins.d	a2, a2, 63, 32
	sll.d		t1, t0, t1
	slli.d		t3, a2, 7
	nor		a3, zero, t3

	orn		t2, t2, t1
	sub.d		t0, t2, a2
	nor		t1, t2, a3
	and		t0, t0, t1


	bnez		t0, L(count_pos)
	addi.d          a0, a0, 8
L(loop_16_7bit):
	ld.d		t2, a0, 0
	sub.d		t1, t2, a2

	and 		t0, t1, t3
	bnez		t0, L(more_check)
	ld.d		t2, a0, 8
	addi.d      	a0, a0, 16

	sub.d		t1, t2, a2
	and 		t0, t1, t3
	beqz        	t0, L(loop_16_7bit)
	addi.d          a0, a0, -8
L(more_check):
	nor		t0, t2, a3

	and		t0, t1, t0
	bnez		t0, L(count_pos)
	addi.d          a0, a0, 8
L(loop_16_8bit):
	ld.d		t2, a0, 0

	sub.d		t1, t2, a2
	nor		t0, t2, a3
	and		t0, t0, t1
	bnez		t0, L(count_pos)

	ld.d		t2, a0, 8
	addi.d      	a0, a0, 16
	sub.d		t1, t2, a2
	nor		t0, t2, a3

	and		t0, t0, t1
	beqz		t0, L(loop_16_8bit)
	addi.d          a0, a0, -8
L(count_pos):
	ctz.d		t1, t0
	sub.d		a0, a0, a1

	srli.d		t1, t1, 3
	add.d		a0, a0, t1
	jr		ra

END(STRLEN)

#ifdef _LIBC
libc_hidden_builtin_def (STRLEN)
#endif
