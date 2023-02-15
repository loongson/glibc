#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#define MEMCHR_NAME __memchr_lsx

LEAF(MEMCHR_NAME)
    .align          6
    beqz            a2, L(out)
    andi            t1, a0, 0x1f
    li.d            t2, 32
    sub.d           a3, a0, t1

    vld             $vr0, a3, 0
    vld             $vr1, a3, 16
    sub.d           t2, t2, t1
    vreplgr2vr.b    $vr2, a1

    sltu            t3, t2, a2
    vxor.v          $vr0, $vr0, $vr2
    vxor.v          $vr1, $vr1, $vr2
    vmsknz.b        $vr0, $vr0

    vmsknz.b        $vr1, $vr1
    sltui           t3, t3, 1
    vilvl.h         $vr0, $vr1, $vr0
    movfr2gr.s      t0, $f0


    sra.w           t0, t0, t1
    orn             t1, t3, t0
    bnez            t1, L(end)
    sub.d           a2, a2, t2

    move            a0, a3
L(loop):
    vld             $vr0, a0, 32
    vld             $vr1, a0, 48
    addi.d          a0, a0, 32

    sltui           t3, a2, 33
    addi.d          a2, a2, -32
    vxor.v          $vr0, $vr0, $vr2
    vxor.v          $vr1, $vr1, $vr2

    vmsknz.b        $vr0, $vr0
    vmsknz.b        $vr1, $vr1
    vilvl.h         $vr0, $vr1, $vr0
    movfr2gr.s      t0, $f0


    orn             t1, t3, t0
    beqz            t1, L(loop)
    addi.d          a2, a2, 32
L(end):
    cto.w           t0, t0

    sltu            t1, t0, a2
    add.d           a0, a0, t0
    maskeqz         a0, a0, t1
    jr              ra

L(out):
    move            a0, zero
    jr              ra
END(MEMCHR_NAME)

#ifdef _LIBC
libc_hidden_builtin_def (MEMCHR_NAME)
#endif

#endif
