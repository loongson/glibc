#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#ifndef STRRCHR_NAME
#define STRRCHR_NAME strrchr
#endif

LEAF(STRRCHR_NAME)
	.align 6
	slli.d		t1, a0, 3
	bstrins.d	a0, zero, 2, 0
	lu12i.w		a2, 0x01010
	ld.d		t2, a0, 0       // t2 = "5ZZ21abc"

	ori		a2, a2, 0x101
	andi		a1, a1, 0xff	// a1 = "0000000Z"
	li.d		a5, -1
	bstrins.d	a2, a2, 63, 32	// a2 = 0x0101010101010101

	sll.d		t1, a5, t1	// t1 = 0xffffffffff000000
	mul.d		a1, a1, a2	// a1 = "ZZZZZZZZ"
	orn		t2, t2, t1	// t2 = "5ZZ21YYY"
	slli.d		a3, a2, 7	// a3 = 0x8080808080808080

	sub.d		a4, t2, a2
	andn		t0, a3, t2
	move		t3, zero
	and		t0, a4, t0


	xor		a4, t2, a1
	move		t5, zero
	orn		a4, a4, t1
	bnez		t0, L(found_end)

	sub.d		t1, a4, a2
	andn		t0, a3, a4
	and		t1, t1, t0

L(loop_8bytes):
	masknez		t4, t3, t1

	maskeqz		t3, t2, t1
	ld.d		t2, a0, 8
	masknez		t0, t5, t1
	maskeqz		t5, a0, t1

	or		t3, t3, t4
	or		t5, t0, t5
	sub.d		t0, t2, a2
	andn		t1, a3, t2


	xor		a4, t2, a1
	and		t0, t0, t1	//t0 hold diff pattern for '\0'
	sub.d		t1, a4, a2
	andn		t4, a3, a4

	and		t1, t1, t4	//t1 hold diff pattern for 'a1'
	addi.d		a0, a0, 8
	beqz		t0, L(loop_8bytes)	//ok, neither \0 nor found
L(found_end):
	ctz.d		t1, t0

	xor		t3, t3, a1
	orn		t1, zero, t1
	revb.d		t3, t3
	srl.d		t1, a5, t1  // mask for '\0'

	sub.d		t4, t3, a2
	orn		a4, a4, t1
	andn		t3, a3, t3
	revb.d		t2, a4

	sub.d		t0, t2, a2
	andn		t1, a3, t2
	and		t3, t3, t4
	and		t1, t0, t1

	li.d		t7, 7
	masknez		t4, t3, t1
	maskeqz		t3, t1, t1
	masknez		t5, t5, t1

	or		t3, t3, t4
	maskeqz		t6, a0, t1
	ctz.d		t0, t3
	or		t5, t6, t5

	srli.d		t0, t0, 3
	sub.d		t0, t7, t0
	add.d		a0, t5, t0
	maskeqz		a0, a0, t3

	jr		ra
END(STRRCHR_NAME)

#ifdef _LIBC
#undef rindex
weak_alias(STRRCHR_NAME, rindex)
libc_hidden_builtin_def(STRRCHR_NAME)
#endif
