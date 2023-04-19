/* Copyright 2016 Loongson Technology Corporation Limited.  */

/* Author: Songyuekun songyuekun@loongson.cn
 * ISA: MIPS64R2
 * ABI: N64
 * basic algorithm :
	+. use ld.d and mask for the first 8 bytes or less;
	+. build a1 with 8c with dins;
	+. use xor from a1 and v0 to check if is found;
	+. if (v0 - 0x0101010101010101) & (~(v0 | 0x7f7f7f7f7f7f7f7f)!= 0, v0 has
	one byte is \0, else has no \0
*/

#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#define L_ADDIU  addi.d
#define L_ADDU   add.d
#define L_SUBU   sub.d

#define STRCHRNUL_NAME	__strchrnul_unaligned

#define MOVN(rd,rs,rt) \
	maskeqz t6, rs, rt;\
	masknez rd, rd, rt;\
	or	rd, rd, t6

#define MOVZ(rd,rs,rt) \
	masknez t6, rs, rt;\
	maskeqz rd, rd, rt;\
	or	rd, rd, t6


#define MOVN2(rd,rt) \
	masknez rd, rd, rt;\
	or	rd, rd, rt


/* char * strchrnul (const char *s1, int c); */

LEAF(STRCHRNUL_NAME)
	.align		6
	li.w		t4, 0x7
	lu12i.w		a2, 0x01010
	bstrins.d	a1, a1, 15, 8
	andi		t0, a0, 0x7

	ori		a2, a2, 0x101
	andn		t4, a0, t4
	slli.w		t1, t0, 3
	ld.d		t4, t4, 0


	nor		t8, zero, zero
	bstrins.d	a1, a1, 31, 16
	srl.d		t4, t4, t1

	preld		0, a0, 32
	bstrins.d	a1, a1, 63, 32
	bstrins.d	a2, a2, 63, 32
	srl.d		a7, t8, t1

	nor		t8, a7, zero
	slli.d		a3, a2, 7
	or		t5, t8, t4
	and		t3, a7, a1

	nor		a3, a3, zero
	xor		t2, t5, t3
	sub.d		a7, t5, a2
	nor		a6, t5, a3

	li.w		t1, 8
	sub.d		a5, t2, a2
	nor		a4, t2, a3

	and		a6, a7, a6
	and		a5, a5, a4
	or		a7, a6, a5
	bnez		a7, L(_mc8_a)


	sub.w		t1, t1, t0
	L_ADDU		a0, a0, t1
L(_aloop):
	ld.d		t4, a0, 0

	xor		t2, t4, a1
	sub.d		a7, t4, a2
	nor		a6, t4, a3
	sub.d		a5, t2, a2

	nor		a4, t2, a3
	and		a6, a7, a6
	and		a5, a5, a4

	or		a7, a6, a5
	bnez		a7, L(_mc8_a)

	ld.d		t4, a0, 8
	L_ADDIU		a0, a0, 16

	xor		t2, t4, a1
	sub.d		a7, t4, a2
	nor		a6, t4, a3
	sub.d		a5, t2, a2

	nor		a4, t2, a3
	and		a6, a7, a6
	and		a5, a5, a4

	or		a7, a6, a5
	beqz		a7, L(_aloop)

	L_ADDIU		a0, a0, -8
L(_mc8_a):

    	ctz.d       	t0, a5
    	ctz.d       	t2, a6

	srli.w		t0, t0, 3
	srli.w		t2, t2, 3
	slt 		t1, t0, t2

    MOVZ(t0,t2,t1)

	L_ADDU		v0, a0, t0
	jr		ra
END(STRCHRNUL_NAME)

#ifndef ANDROID_CHANGES
#ifdef _LIBC
weak_alias(STRCHRNUL_NAME, strchrnul)
libc_hidden_builtin_def (STRCHRNUL_NAME)
#endif
#endif

#endif
