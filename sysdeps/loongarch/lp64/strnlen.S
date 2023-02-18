#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#ifndef STRNLEN
#define STRNLEN	__strnlen
#endif

#. before every load, a1(t5) must > 0;
#. first load with t1 != 0, need to adjust t5;
#. return the less one of both strlen(s) and a1;

LEAF(STRNLEN)
	.align 6
	beqz		a1, L(out)
	lu12i.w		a2, 0x01010
	andi		t1, a0, 0x7
	move		t4, a0

	bstrins.d	a0, zero, 2, 0
	ori		a2, a2, 0x101
	li.w		t0, -1
	ld.d		t2, a0, 0

	slli.d		t3, t1, 3
	bstrins.d	a2, a2, 63, 32
	li.w		t5, 8
	slli.d		a3, a2, 7

	sub.w		t1, t5, t1
	sll.d		t0, t0, t3
	nor		a3, zero, a3
	orn		t2, t2, t0


	sub.d		t0, t2, a2
	nor		t3, t2, a3
	and		t0, t0, t3
	bnez		t0, L(count_pos)

	sub.d		t5, a1, t1
	bgeu		t1, a1, L(out)
L(loop_8bytes):
	ld.d		t2, a0, 8
	addi.d		a0, a0, 8

	sub.d		t0, t2, a2
	nor 		t1, t2, a3
	sltui		t6, t5, 9
	and 		t0, t0, t1

	addi.d		t5, t5, -8
	or		t7, t0, t6
	beqz		t7, L(loop_8bytes)
L(count_pos):
	ctz.d		t1, t0


	sub.d		a0, a0, t4
	srli.d		t1, t1, 3
	add.d		a0, t1, a0
	sltu		t0, a0, a1

	masknez		t1, a1, t0
	maskeqz		a0, a0, t0
	or		a0, a0, t1
	jr		ra

L(out):
	move		a0, a1
	jr		ra

END(STRNLEN)

#ifdef _LIBC
weak_alias (STRNLEN, strnlen)
libc_hidden_builtin_def (STRNLEN)
#endif
