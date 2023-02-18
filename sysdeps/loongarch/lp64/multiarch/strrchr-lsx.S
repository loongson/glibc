#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#define STRRCHR_NAME __strrchr_lsx

LEAF(STRRCHR_NAME)
    .align          6
    andi            t0, a0, 0x1f
    bstrins.d       a0, zero, 4, 0
    vld             $vr0, a0, 0
    vld             $vr1, a0, 16

    vreplgr2vr.b    $vr4, a1
    li.d            t2, -1
    move            a2, zero
    addi.d          a0, a0, 31

    vxor.v          $vr2, $vr0, $vr4
    vxor.v          $vr3, $vr1, $vr4
    vmsknz.b        $vr0, $vr0
    vmsknz.b        $vr1, $vr1

    vmsknz.b        $vr2, $vr2
    vmsknz.b        $vr3, $vr3
    vilvl.h         $vr0, $vr1, $vr0
    vilvl.h         $vr1, $vr3, $vr2


    sll.d           t3, t2, t0
    movfr2gr.s      t0, $f0
    movfr2gr.s      t1, $f1
    orn             t0, t0, t3

    orn             t1, t1, t3
    bne             t0, t2, L(end)
L(loop):
    vld             $vr0, a0, 1
    vld             $vr1, a0, 17

    clo.w           t0, t1
    orn             t1, zero, t1
    sub.d           t0, a0, t0
    addi.d          a0, a0, 32

    maskeqz         t0, t0, t1
    masknez         t1, a2, t1
    or              a2, t0, t1
    vxor.v          $vr2, $vr0, $vr4

    vxor.v          $vr3, $vr1, $vr4
    vmsknz.b        $vr0, $vr0
    vmsknz.b        $vr1, $vr1
    vmsknz.b        $vr2, $vr2

    vmsknz.b        $vr3, $vr3
    vilvl.h         $vr0, $vr1, $vr0
    vilvl.h         $vr1, $vr3, $vr2
    movfr2gr.s      t0, $f0

    movfr2gr.s      t1, $f1
    beq             t0, t2, L(loop)
L(end):
    slli.d          t3, t2, 1   # shift one more for the last '\0'
    cto.w           t0, t0

    sll.d           t3, t3, t0
    or              t1, t1, t3
    clo.w           t0, t1
    orn             t1, zero, t1

    sub.d           a0, a0, t0
    maskeqz         t0, a0, t1
    masknez         t1, a2, t1
    or              a0, t0, t1

    jr              ra
END(STRRCHR_NAME)

#ifdef _LIBC
#undef rindex
weak_alias(strrchr,rindex)
libc_hidden_builtin_def(STRRCHR_NAME)
#endif

#endif
