#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#ifndef RAWMEMCHR_NAME
# define RAWMEMCHR_NAME __rawmemchr
#endif


LEAF(RAWMEMCHR_NAME)
    .align      6
    andi        t1, a0, 0x7
    bstrins.d   a0, zero, 2, 0
    lu12i.w     a2, 0x01010
    bstrins.d   a1, a1, 15, 8

    ld.d        t0, a0, 0
    slli.d      t1, t1, 3
    ori         a2, a2, 0x101
    bstrins.d   a1, a1, 31, 16

    li.w        t8, -1
    bstrins.d   a1, a1, 63, 32
    bstrins.d   a2, a2, 63, 32
    sll.d       t2, t8, t1

    sll.d       t3, a1, t1
    orn         t0, t0, t2
    slli.d      a3, a2, 7
    beqz        a1, L(find_zero)

    xor         t0, t0, t3
    sub.d       t1, t0, a2
    andn        t2, a3, t0
    and         t3, t1, t2

    bnez        t3, L(count_pos)
    addi.d      a0, a0, 8

L(loop):
    ld.d        t0, a0, 0
    xor         t0, t0, a1

    sub.d       t1, t0, a2
    andn        t2, a3, t0
    and         t3, t1, t2
    bnez        t3, L(count_pos)

    ld.d        t0, a0, 8
    addi.d      a0, a0, 16
    xor         t0, t0, a1
    sub.d       t1, t0, a2

    andn        t2, a3, t0
    and         t3, t1, t2
    beqz        t3, L(loop)
    addi.d      a0, a0, -8
L(count_pos):
    ctz.d       t0, t3
    srli.d      t0, t0, 3
    add.d       a0, a0, t0
    jr          ra

L(loop_7bit):
    ld.d        t0, a0, 0
L(find_zero):
    sub.d       t1, t0, a2
    and         t2, t1, a3
    bnez        t2, L(more_check)

    ld.d        t0, a0, 8
    addi.d      a0, a0, 16
    sub.d       t1, t0, a2
    and         t2, t1, a3

    beqz        t2, L(loop_7bit)
    addi.d      a0, a0, -8

L(more_check):
    andn        t2, a3, t0
    and         t3, t1, t2
    bnez        t3, L(count_pos)
    addi.d      a0, a0, 8

L(loop_8bit):
    ld.d        t0, a0, 0

    sub.d       t1, t0, a2
    andn        t2, a3, t0
    and         t3, t1, t2
    bnez        t3, L(count_pos)

    ld.d        t0, a0, 8
    addi.d      a0, a0, 16
    sub.d       t1, t0, a2

    andn        t2, a3, t0
    and         t3, t1, t2
    beqz        t3, L(loop_8bit)

    addi.d      a0, a0, -8
    b           L(count_pos)

END(RAWMEMCHR_NAME)

#ifdef _LIBC
weak_alias (__rawmemchr, rawmemchr)
libc_hidden_builtin_def (__rawmemchr)
#endif
