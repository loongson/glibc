#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <regdef.h>
#include <sys/asm.h>
#endif

#if IS_IN (libc)

#define MEMCPY_NAME __memcpy_unaligned

#define LD_64(reg, n) \
	ld.d    t0, reg, n;    \
	ld.d    t1, reg, n+8;  \
	ld.d    t2, reg, n+16; \
	ld.d    t3, reg, n+24; \
	ld.d    t4, reg, n+32; \
	ld.d    t5, reg, n+40; \
	ld.d    t6, reg, n+48; \
	ld.d    t7, reg, n+56;

#define ST_64(reg, n) \
	st.d    t0, reg, n;    \
	st.d    t1, reg, n+8;  \
	st.d    t2, reg, n+16; \
	st.d    t3, reg, n+24; \
	st.d    t4, reg, n+32; \
	st.d    t5, reg, n+40; \
	st.d    t6, reg, n+48; \
	st.d    t7, reg, n+56;

#ifdef ANDROID_CHANGES
LEAF(MEMCPY_NAME, 0)
#else
LEAF(MEMCPY_NAME)
#endif

//1st var: dst ptr: void *a1 $r4 a0
//2nd var: src ptr: void *a2 $r5 a1
//3rd var: size_t len $r6 a2
//t0~t9 registers as temp

	add.d   a4, a1, a2
	add.d   a3, a0, a2
	li.w    a6, 16
	bge     a6, a2, less_16bytes
	li.w    a6, 128
	blt     a6, a2, long_bytes
	li.w    a6, 64
	blt     a6, a2, more_64bytes
	li.w    a6, 32
	blt     a6, a2, more_32bytes

	/* 17...32 */
	ld.d    t0, a1, 0
	ld.d    t1, a1, 8
	ld.d    t2, a4, -16
	ld.d    t3, a4, -8
	st.d    t0, a0, 0
	st.d    t1, a0, 8
	st.d    t2, a3, -16
	st.d    t3, a3, -8
	jr  ra

more_64bytes:
	srli.d	t8, a0, 3
	slli.d	t8, t8, 3
	addi.d	t8, t8,  0x8
	sub.d	a7, a0, t8
	ld.d	t0, a1, 0
	sub.d	a1, a1, a7
	st.d	t0, a0, 0

	add.d	a7, a7, a2
	addi.d	a7, a7, -0x20
loop_32:
	ld.d	t0, a1, 0
	ld.d	t1, a1, 8
	ld.d	t2, a1, 16
	ld.d	t3, a1, 24
	st.d	t0, t8, 0
	st.d	t1, t8, 8
	st.d	t2, t8, 16
	st.d	t3, t8, 24

	addi.d	t8,  t8,   0x20
	addi.d	a1,  a1,   0x20
	addi.d	a7,  a7,  -0x20
	blt     zero, a7, loop_32

	ld.d	t4, a4, -32
	ld.d	t5, a4, -24
	ld.d	t6, a4, -16
	ld.d	t7, a4, -8
	st.d	t4, a3, -32
	st.d	t5, a3, -24
	st.d	t6, a3, -16
	st.d	t7, a3, -8

	jr	ra

more_32bytes:
	/* 33...64 */
	ld.d    t0, a1, 0
	ld.d    t1, a1, 8
	ld.d    t2, a1, 16
	ld.d    t3, a1, 24
	ld.d    t4, a4, -32
	ld.d    t5, a4, -24
	ld.d    t6, a4, -16
	ld.d    t7, a4, -8
	st.d    t0, a0, 0
	st.d    t1, a0, 8
	st.d    t2, a0, 16
	st.d    t3, a0, 24
	st.d    t4, a3, -32
	st.d    t5, a3, -24
	st.d    t6, a3, -16
	st.d    t7, a3, -8
	jr  ra

less_16bytes:
	srai.d  a6, a2, 3
	beqz    a6, less_8bytes

	/* 8...16 */
	ld.d    t0, a1, 0
	ld.d    t1, a4, -8
	st.d    t0, a0, 0
	st.d    t1, a3, -8

	jr  ra

less_8bytes:
	srai.d  a6, a2, 2
	beqz    a6, less_4bytes

	/* 4...7 */
	ld.w    t0, a1, 0
	ld.w    t1, a4, -4
	st.w    t0, a0, 0
	st.w    t1, a3, -4
	jr  ra

less_4bytes:
	srai.d  a6, a2, 1
	beqz    a6, less_2bytes

	/* 2...3 */
	ld.h    t0, a1, 0
	ld.h    t1, a4, -2
	st.h    t0, a0, 0
	st.h    t1, a3, -2
	jr  ra

less_2bytes:
	beqz    a2, less_1bytes

	ld.b    t0, a1, 0
	st.b    t0, a0, 0
	jr  ra

less_1bytes:
	jr  ra

long_bytes:
	srli.d  t8, a0, 3
	slli.d  t8, t8, 3
	beq     a0, t8, start

	ld.d    t0, a1, 0
	addi.d  t8, t8, 0x8
	st.d    t0, a0, 0
	sub.d   a7, a0, t8
	sub.d   a1, a1, a7

start:
	addi.d  a5, a3, -0x80
	blt     a5, t8, align_end_proc

loop_128:
	LD_64(a1, 0)
	ST_64(t8, 0)
	LD_64(a1, 64)
	addi.d  a1, a1,  0x80
	ST_64(t8, 64)
	addi.d  t8, t8,  0x80
	bge     a5, t8, loop_128

align_end_proc:
	sub.d   a2, a3, t8

	pcaddi  t1, 34
	andi    t2, a2, 0x78
	sub.d   t1, t1, t2
	jirl    zero, t1, 0

end_120_128_unalign:
	ld.d    t0, a1, 112
	st.d    t0, t8, 112
end_112_120_unalign:
	ld.d    t0, a1, 104
	st.d    t0, t8, 104
end_104_112_unalign:
	ld.d    t0, a1, 96
	st.d    t0, t8, 96
end_96_104_unalign:
	ld.d    t0, a1, 88
	st.d    t0, t8, 88
end_88_96_unalign:
	ld.d    t0, a1, 80
	st.d    t0, t8, 80
end_80_88_unalign:
	ld.d    t0, a1, 72
	st.d    t0, t8, 72
end_72_80_unalign:
	ld.d    t0, a1, 64
	st.d    t0, t8, 64
end_64_72_unalign:
	ld.d    t0, a1, 56
	st.d    t0, t8, 56
end_56_64_unalign:
	ld.d    t0, a1, 48
	st.d    t0, t8, 48
end_48_56_unalign:
	ld.d    t0, a1, 40
	st.d    t0, t8, 40
end_40_48_unalign:
	ld.d    t0, a1, 32
	st.d    t0, t8, 32
end_32_40_unalign:
	ld.d    t0, a1, 24
	st.d    t0, t8, 24
end_24_32_unalign:
	ld.d    t0, a1, 16
	st.d    t0, t8, 16
end_16_24_unalign:
	ld.d    t0, a1, 8
	st.d    t0, t8, 8
end_8_16_unalign:
	ld.d    t0, a1, 0
	st.d    t0, t8, 0
end_0_8_unalign:
	ld.d    t0, a4, -8
	st.d    t0, a3, -8

	jr  ra

END(MEMCPY_NAME)

#ifndef ANDROID_CHANGES
#ifdef _LIBC
libc_hidden_builtin_def (MEMCPY_NAME)
#endif
#endif

#endif
