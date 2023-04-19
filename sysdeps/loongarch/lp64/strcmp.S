/* 2022\06\15  loongarch64 author: chenxiaolong.  */

#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#ifndef STRCMP_NAME
#define STRCMP_NAME strcmp
#endif

/* int strcmp (const char *s1, const char *s2); */

/* Parameters and Results */
#define src1	a0
#define	src2	a1
#define result	v0
LEAF(STRCMP_NAME)
    .align	6
    xor         a4, src1, src2
    lu12i.w     t5, 0x01010
    lu12i.w     t6, 0x7f7f7
    andi        a2, src1, 0x7

    ori         t5, t5, 0x101
    andi        a4, a4, 0x7
    ori         t6, t6, 0xf7f
    bstrins.d   t5, t5, 63, 32
    bstrins.d   t6, t6, 63, 32

    bnez        a4, 3f  // unaligned
    beqz        a2, 1f  // loop aligned

// mutual aligned
    bstrins.d   src1, zero, 2, 0
    bstrins.d   src2, zero, 2, 0
    slli.d      a4, a2, 0x3
    ld.d        t0, src1, 0

    sub.d       a4, zero, a4
    ld.d        t1, src2, 0
    addi.d      src1, src1, 8
    addi.d      src2, src2, 8

    nor         a5, zero, zero
    srl.d       a5, a5, a4
    or          t0, t0, a5

    or          t1, t1, a5
    b           2f  //start realigned

// loop aligned
1:
    ld.d        t0, src1, 0
    addi.d      src1, src1, 8
    ld.d        t1, src2, 0
    addi.d      src2, src2, 8

// start realigned:
2:
    sub.d       t2, t0, t5
    nor         t3, t0, t6
    and         t2, t2, t3

    xor         t3, t0, t1
    or          t2, t2, t3
    beqz        t2, 1b

    ctz.d       t7, t2
    bstrins.d   t7, zero, 2, 0
    srl.d       t0, t0, t7
    srl.d       t1, t1, t7

    andi        t0, t0, 0xff
    andi        t1, t1, 0xff
    sub.d       v0, t0, t1
    jr          ra

// unaligned
3:
    andi        a3, src2, 0x7
    slt         a5, a2, a3
    masknez     t8, a2, a5
    xor         a6, src1, src2
    maskeqz     a6, a6, t8
    xor         src1, src1, a6
    xor         src2, src2, a6

    andi        a2, src1, 0x7
    beqz        a2, 4f // src1 is aligned

//strcmp_unaligned:
    andi        a3, src2, 0x7
    bstrins.d   src1, zero, 2, 0
    bstrins.d   src2, zero, 2, 0
    nor         t3, zero, zero

    ld.d        t0, src1, 0
    ld.d        t1, src2, 0
    sub.d       a2, a3, a2
    addi.d      t2, zero, 8

    sub.d       a5, t2, a2
    sub.d       a6, t2, a3
    slli.d      a5, a5, 0x3
    slli.d      a6, a6, 0x3

    srl.d       t4, t3, a6
    srl.d       a4, t3, a5
    rotr.d      a7, t0, a5

    addi.d      src2, src2, 8
    addi.d      src1, src1, 8
    or          t1, t1, t4
    or          t0, a7, t4

    sub.d       t2, t0, t5
    nor         t3, t0, t6
    and         t2, t2, t3
    xor         t3, t0, t1
    or          t2, t2, t3
    bnez        t2, 7f

    and         a7, a7, a4
    slli.d      a6, a2, 0x3
    nor         a4, zero, a4
    b           5f

// src1 is aligned
4:
    andi        a3, src2, 0x7
    ld.d        t0, src1, 0

    bstrins.d   src2, zero, 2, 0
    nor         t2, zero, zero
    ld.d        t1, src2, 0

    addi.d      t3, zero, 0x8
    sub.d       a5, t3, a3
    slli.d      a5, a5, 0x3
    srl.d       a4, t2, a5
    rotr.d      t4, t0, a5

    addi.d      src2, src2, 8
    addi.d      src1, src1, 8
    or          t1, t1, a4
    or          t0, t4, a4

    sub.d       t2, t0, t5
    nor         t3, t0, t6
    and         t2, t2, t3
    xor         t3, t0, t1
    or          t2, t2, t3

    bnez        t2, 7f

    and         a7, t4, a4
    slli.d      a6, a3, 0x3
    nor         a4, zero, a4

// unaligned loop
// a7: remaining number
// a6: shift left number
// a5: shift right number
// a4: mask for checking remaining number
5:
    or          t0, a7, a4
    sub.d       t2, t0, t5
    nor         t3, t0, t6
    and         t2, t2, t3
    bnez        t2, 6f

    ld.d        t0, src1, 0
    addi.d      src1, src1, 8
    ld.d        t1, src2, 0
    addi.d      src2, src2, 8

    srl.d       t7, t0, a5
    sll.d       t0, t0, a6
    or          t0, a7, t0

    sub.d       t2, t0, t5
    nor         t3, t0, t6
    and         t2, t2, t3
    xor         t3, t0, t1
    or          t2, t2, t3
    bnez        t2, 7f

    or          a7, t7, zero
    b           5b

6:
    ld.bu       t1, src2, 0
    andi        t0, a7, 0xff
    xor         t2, t0, t1
    srli.d      a7, a7, 0x8
    masknez     t2, t0, t2
    addi.d      src2, src2, 1
    beqz        t2, 8f
    b           6b

7:
    ctz.d       t7, t2
    bstrins.d   t7, zero, 2, 0
    srl.d       t0, t0, t7
    srl.d       t1, t1, t7

    andi        t0, t0, 0xff
    andi        t1, t1, 0xff

8:
    sub.d       a4, t0, t1
    sub.d       a5, t1, t0
    maskeqz     a6, a5, t8
    masknez     result, a4, t8
    or          result, result, a6
    jr	ra

END(STRCMP_NAME)

#ifdef _LIBC
libc_hidden_builtin_def (STRCMP_NAME)
#endif

