#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#ifndef STRCHR_NAME
#define STRCHR_NAME strchr
#endif

/* char * strchr (const char *s1, int c); */

LEAF(STRCHR_NAME)
	.align		6
	slli.d		t1, a0, 3
	bstrins.d	a0, zero, 2, 0
	lu12i.w		a2, 0x01010
	ld.d		t2, a0, 0

	ori		a2, a2, 0x101
	andi		a1, a1, 0xff
	bstrins.d	a2, a2, 63, 32
	li.w		t0, -1

	mul.d           a1, a1, a2 # "cccccccc"
	sll.d		t0, t0, t1
	slli.d		a3, a2, 7  # 0x8080808080808080
	orn             t2, t2, t0

	sll.d           t3, a1, t1
	xor             t4, t2, t3
	sub.d           a7, t2, a2
	andn            a6, a3, t2


	sub.d           a5, t4, a2
	andn            a4, a3, t4
	and		a6, a7, a6
	and		a5, a5, a4

	or		t0, a6, a5
	bnez		t0, L(_mc8_a)
	addi.d		a0, a0, 8
L(_aloop):
	ld.d		t4, a0, 0

	xor		t2, t4, a1
	sub.d		a7, t4, a2
	andn		a6, a3, t4
	sub.d		a5, t2, a2

	andn		a4, a3, t2
	and		a6, a7, a6
	and		a5, a5, a4
	or		a7, a6, a5


	bnez		a7, L(_mc8_a)
	ld.d		t4, a0, 8
	addi.d		a0, a0, 16
	xor		t2, t4, a1

	sub.d		a7, t4, a2
	andn		a6, a3, t4
	sub.d		a5, t2, a2
	andn		a4, a3, t2

	and		a6, a7, a6
	and		a5, a5, a4
	or		a7, a6, a5
	beqz		a7, L(_aloop)

	addi.d		a0, a0, -8

L(_mc8_a):
	ctz.d		t0, a5
	ctz.d		t2, a6
	srli.w		t0, t0, 3


	srli.w		t2, t2, 3
	sltu		t1, t2, t0
	add.d		a0, a0, t0
	masknez		a0, a0, t1

	jr		ra
END(STRCHR_NAME)
