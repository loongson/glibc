#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#define MEMSET_NAME __memset_lsx

LEAF(MEMSET_NAME)
    .align          6
    li.d            t1, 16
    move            a3, a0
    vreplgr2vr.b    $vr0, a1
    add.d           a4, a0, a2

    bgeu            t1, a2, L(less_16bytes) # len <= 16
    li.d            t3, 64
    li.d            t2, 32
    bgeu            a2, t3, L(long_bytes) # len > 64

L(less_64bytes):
    bgeu            t2, a2, L(less_32bytes) # len <= 32
    vst             $vr0, a3, 0
    vst             $vr0, a3, 16
    vst             $vr0, a4, -32

    vst             $vr0, a4, -16
    jr              ra
L(less_32bytes):
    vst             $vr0, a3, 0
    vst             $vr0, a4, -16


    jr              ra
L(less_16bytes):
    srli.d          t0, a2, 3
    beqz            t0, L(less_8bytes)
    vstelm.d        $vr0, a3, 0, 0

    vstelm.d        $vr0, a4, -8, 0
    jr              ra
L(less_8bytes):
    srli.d          t0, a2, 2
    beqz            t0, L(less_4bytes)

    vstelm.w        $vr0, a3, 0, 0
    vstelm.w        $vr0, a4, -4, 0
    jr              ra
L(less_4bytes):
    srli.d          t0, a2, 1

    beqz            t0, L(less_2bytes)
    vstelm.h        $vr0, a3, 0, 0
    vstelm.h        $vr0, a4, -2, 0
    jr              ra


L(less_2bytes):
    beqz            a2, L(less_1bytes)
    vstelm.b        $vr0, a3, 0, 0
L(less_1bytes):
    jr              ra
L(long_bytes):
    vst             $vr0, a3, 0

    bstrins.d       a3, zero, 3, 0
    addi.d          a3, a3, 16
    sub.d           a2, a4, a3
    andi            t0, a2, 0x7f

    beq             t0, a2, L(long_end)
    move            a2, t0
    sub.d           t0, a4, t0

L(loop_128):
    vst             $vr0, a3, 0

    vst             $vr0, a3, 16
    vst             $vr0, a3, 32
    vst             $vr0, a3, 48
    vst             $vr0, a3, 64


    vst             $vr0, a3, 80
    vst             $vr0, a3, 96
    vst             $vr0, a3, 112
    addi.d          a3, a3, 128

    bne             a3, t0, L(loop_128)
L(long_end):
    bltu            a2, t3, L(end_less_64)
    addi.d          a2, a2, -64
    vst             $vr0, a3, 0

    vst             $vr0, a3, 16
    vst             $vr0, a3, 32
    vst             $vr0, a3, 48
    addi.d          a3, a3, 64

L(end_less_64):
    bltu            a2, t2, L(end_less_32)
    addi.d          a2, a2, -32
    vst             $vr0, a3, 0
    vst             $vr0, a3, 16

    addi.d          a3, a3, 32
L(end_less_32):
    bltu            a2, t1, L(end_less_16)
    vst             $vr0, a3, 0

L(end_less_16):
    vst             $vr0, a4, -16
    jr              ra
END(MEMSET_NAME)

#ifdef _LIBC
libc_hidden_builtin_def (MEMSET_NAME)
#endif

#endif
