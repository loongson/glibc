#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#ifndef MEMCHR_NAME
#define MEMCHR_NAME memchr
#endif

#ifdef ANDROID_CHANGES
LEAF(MEMCHR_NAME, 0)
#else
LEAF(MEMCHR_NAME)
#endif
    .align      6
    beqz        a2, L(out)
    andi        t1, a0, 0x7
    lu12i.w     a3, 0x01010
    sub.d       a5, a0, t1

    bstrins.d   a1, a1, 15, 8
    ld.d        t0, a5, 0
    slli.d      t2, t1, 3
    ori         a3, a3, 0x101

    bstrins.d   a1, a1, 31, 16
    li.w        t7, -1
    li.w        t8, 9
    bstrins.d   a3, a3, 63, 32

    srl.d       t3, t7, t2
    bstrins.d   a1, a1, 63, 32
    sub.d       t4, t8, t1
    orn         t3, a1, t3

    srl.d       t0, t0, t2
    slli.d      a4, a3, 7   # 0x8080808080808080
    sltu        t4, a2, t4
    xor         t2, t0, t3

    sub.d       a6, t2, a3
    andn        a7, a4, t2
    and         t2, a6, a7
    or          t3, t2, t4

    bnez        t3, L(count_pos)
    addi.d      a2, a2, -8
    addi.d      a0, a5, 8
    add.d       a2, a2, t1

L(loop):
    ld.d        t0, a0, 0
    sltui       t4, a2, 9
    xor         t2, t0, a1
    sub.d       a6, t2, a3

    andn        a7, a4, t2
    and         t2, a6, a7
    or          t3, t2, t4
    bnez        t3, L(count_pos)

    ld.d        t1, a0, 8
    addi.d      a0, a0, 16
    sltui       t4, a2, 17
    xor         t2, t1, a1

    sub.d       a6, t2, a3
    andn        a7, a4, t2
    and         t2, a6, a7
    addi.d      a2, a2, -16

    or          t3, t2, t4
    beqz        t3, L(loop)
    addi.d      a0, a0, -8
    addi.d      a2, a2, 8

L(count_pos):
    ctz.d       t0, t2
    srli.d      t0, t0, 3
    sltu        t1, t0, a2
    add.d       a0, a0, t0

    maskeqz     a0, a0, t1
    jr          ra

L(out):
    move        a0, zero
    jr          ra
END(MEMCHR_NAME)

#ifndef ANDROID_CHANGES
#ifdef _LIBC
libc_hidden_builtin_def (MEMCHR_NAME)
#endif
#endif
