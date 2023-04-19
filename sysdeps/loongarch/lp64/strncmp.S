#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#ifndef STRNCMP
#define STRNCMP strncmp
#endif

/* int strncmp (const char *s1, const char *s2); */

LEAF(STRNCMP)
    .align      6
    beqz        a2, L(ret0)
    xor         a4, a0, a1
    lu12i.w     t5, 0x01010
    lu12i.w     t6, 0x7f7f7

    andi        a3, a0, 0x7
    ori         t5, t5, 0x101
    andi        a4, a4, 0x7
    ori         t6, t6, 0xf7f

    bstrins.d   t5, t5, 63, 32
    bstrins.d   t6, t6, 63, 32

    bnez        a4, L(unalign)
    bnez        a3, L(mutual_align)

L(a_loop):
    ld.d        t0, a0, 0
    ld.d        t1, a1, 0
    addi.d      a0, a0, 8
    addi.d      a1, a1, 8


    sltui       t7, a2, 9

L(start_realign):
    sub.d       t2, t0, t5
    nor         t3, t0, t6
    xor         t4, t0, t1

    and         t2, t2, t3
    addi.d      a2, a2, -8

    or          t2, t2, t4
    or          t3, t2, t7
    beqz        t3, L(a_loop)

L(end):
    bge         zero, t7, L(out)
    andi        t4, a2, 7
    li.d        t3, -1
    addi.d      t4, t4, -1
    slli.d      t4, t4, 3
    sll.d       t3, t3, t4
    or          t2, t2, t3


L(out):
    ctz.d       t3, t2
    bstrins.d   t3, zero, 2, 0
    srl.d       t0, t0, t3
    srl.d       t1, t1, t3

    andi        t0, t0, 0xff
    andi        t1, t1, 0xff
    sub.d       a0, t0, t1
    jr          ra

L(mutual_align):
    bstrins.d   a0, zero, 2, 0
    bstrins.d   a1, zero, 2, 0
    slli.d      a5, a3, 0x3
    li.d        t2, -1

    ld.d        t0, a0, 0
    ld.d        t1, a1, 0

    li.d        t3, 9
    sll.d       t2, t2, a5

    sub.d       t3, t3, a3
    addi.d      a0, a0, 8

    sltu        t7, a2, t3
    addi.d      a1, a1, 8

    add.d       a2, a2, a3
    orn         t0, t0, t2
    orn         t1, t1, t2
    b           L(start_realign)

L(ret0):
    move        a0, zero
    jr          ra

L(unalign):
    li.d        t8, 8
    blt         a2, t8, L(short_cmp)

    # swap a0 and a1 in case a3 > a4
    andi        a4, a1, 0x7
    sltu        t8, a4, a3
    xor         a6, a0, a1
    maskeqz     a6, a6, t8
    xor         a0, a0, a6
    xor         a1, a1, a6

    andi        a3, a0, 0x7
    andi        a4, a1, 0x7

    bstrins.d   a0, zero, 2, 0
    bstrins.d   a1, zero, 2, 0

    li.d        t2, -1
    li.d        t3, 9

    ld.d        t0, a0, 0
    ld.d        t1, a1, 0

    sub.d       t3, t3, a4
    sub.d       a3, a4, a3

    slli.d      t4, a4, 3
    slli.d      a6, a3, 3

    sub.d       a5, zero, a6
    sltu        t7, a2, t3

    rotr.d      a7, t0, a5
    sll.d       t4, t2, t4 # mask for first num

    add.d       a2, a2, a4
    sll.d       a4, t2, a6 # mask for a7

    orn         t0, a7, t4
    orn         t1, t1, t4

    sub.d       t2, t0, t5
    nor         t4, t0, t6
    and         t2, t2, t4

    xor         t3, t0, t1
    or          t2, t2, t3

    or          t3, t2, t7
    bnez        t3, L(un_end)

    andn        a7, a7, a4
    addi.d      a3, a3, 1

L(un_loop):
    addi.d      a2, a2, -8
    # in case remaining part has '\0', no more load instructions should be executed on a0 address
    or          t0, a7, a4
    sltu        t7, a2, a3

    sub.d       t2, t0, t5
    nor         t3, t0, t6
    and         t2, t2, t3

    or          t3, t2, t7
    bnez        t3, L(check_remaining)

    ld.d        t7, a0, 8
    ld.d        t1, a1, 8
    addi.d      a0, a0, 8
    addi.d      a1, a1, 8

    sll.d       t4, t7, a6
    sub.d       t2, t1, t5
    nor         t3, t1, t6

    or          t0, t4, a7
    srl.d       a7, t7, a5

    and         t2, t2, t3
    xor         t3, t0, t1

    sltui       t7, a2, 9
    or          t2, t2, t3

    or          t3, t2, t7
    beqz        t3, L(un_loop)
    b           L(un_end)

L(check_remaining):
    ld.d        t1, a1, 8
    xor         t3, t1, a7
    or          t2, t2, t3

L(un_end):
    bge         zero, t7, L(un_out)
    andi        t4, a2, 7
    li.d        t3, -1

    addi.d      t4, t4, -1
    slli.d      t4, t4, 3
    sll.d       t3, t3, t4
    or          t2, t2, t3

L(un_out):
    ctz.d       t3, t2
    bstrins.d   t3, zero, 2, 0
    srl.d       t0, t0, t3
    srl.d       t1, t1, t3

    andi        t0, t0, 0xff
    andi        t1, t1, 0xff

    sub.d       a4, t0, t1
    sub.d       a5, t1, t0

    maskeqz     a6, a5, t8
    masknez     a0, a4, t8

    or          a0, a0, a6
    jr          ra

L(short_cmp):
    ld.bu       t0, a0, 0
    ld.bu       t1, a1, 0
    addi.d      a2, a2, -1

    xor         t2, t0, t1
    masknez     t2, t0, t2
    maskeqz     t2, a2, t2

    beqz        t2, L(short_out)

    ld.bu       t0, a0, 1
    ld.bu       t1, a1, 1

    addi.d      a2, a2, -1
    addi.d      a0, a0, 2

    addi.d      a1, a1, 2
    xor         t2, t0, t1
    masknez     t2, t0, t2
    maskeqz     t2, a2, t2

    bnez        t2, L(short_cmp)

L(short_out):
    sub.d       a0, t0, t1
    jr ra

END(STRNCMP)
#ifdef _LIBC
libc_hidden_builtin_def (STRNCMP)
#endif
