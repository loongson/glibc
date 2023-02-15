#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#define MEMRCHR_NAME __memrchr_lsx

LEAF(MEMRCHR_NAME)
    .align          6
    beqz            a2, L(out)
    addi.d          a2, a2, -1
    add.d           a0, a0, a2
    andi            t0, a0, 0x1f

    sub.d           a3, a0, t0
    addi.d          t2, t0, 1   # len for unaligned address
    vld             $vr0, a3, 0
    vld             $vr1, a3, 16

    sub.d           t3, zero, t2
    vreplgr2vr.b    $vr2, a1
    sltu            t1, a2, t2
    vseq.b          $vr0, $vr0, $vr2

    vseq.b          $vr1, $vr1, $vr2
    vmsknz.b        $vr0, $vr0
    vmsknz.b        $vr1, $vr1
    vilvl.h         $vr0, $vr1, $vr0


    movfr2gr.s      t0, $f0
    sll.w           t0, t0, t3
    or              t1, t0, t1
    bnez            t1, L(end)

    addi.d          a0, a3, 31
    sub.d           a2, a2, t2
L(loop):
    vld             $vr0, a0, -63
    vld             $vr1, a0, -47

    sltui           t1, a2, 32
    addi.d          a0, a0, -32
    addi.d          a2, a2, -32
    vseq.b          $vr0, $vr0, $vr2

    vseq.b          $vr1, $vr1, $vr2
    vmsknz.b        $vr0, $vr0
    vmsknz.b        $vr1, $vr1
    vilvl.h         $vr0, $vr1, $vr0


    movfr2gr.s      t0, $f0
    or              t1, t0, t1
    beqz            t1, L(loop)
    addi.d          a2, a2, 32

L(end):
    clz.w           t0, t0
    sltu            t1, a2, t0
    sub.d           a0, a0, t0
    masknez         a0, a0, t1

    jr              ra
L(out):
    move            a0, zero
    jr              ra
END(MEMRCHR_NAME)

#ifdef _LIBC
libc_hidden_builtin_def (MEMRCHR_NAME)
#endif

#endif
