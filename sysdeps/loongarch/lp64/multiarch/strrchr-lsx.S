#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <regdef.h>
#include <sys/asm.h>
#endif

#if IS_IN (libc)

#define STRRCHR __strrchr_lsx

LEAF(STRRCHR)
    .align          6
    andi            t1, a0, 0x1f
    bstrins.d       a0, zero, 4, 0
    vld             $vr0, a0, 0
    vld             $vr1, a0, 16

    vreplgr2vr.b    $vr4, a1
    li.d            t2, -1
    move            a2, zero
    addi.d          a0, a0, 31

    vseq.b          $vr2, $vr0, $vr4
    vseq.b          $vr3, $vr1, $vr4
    vmsknz.b        $vr0, $vr0
    vmsknz.b        $vr1, $vr1

    vmsknz.b        $vr2, $vr2
    vmsknz.b        $vr3, $vr3
    vilvl.h         $vr0, $vr1, $vr0
    vilvl.h         $vr1, $vr3, $vr2


    movfr2gr.s      t0, $f0
    sll.d           t3, t2, t1
    movfr2gr.s      t1, $f1
    orn             t0, t0, t3

    and             t1, t1, t3
    bne             t0, t2, L(end)
L(loop):
    vld             $vr0, a0, 1
    vld             $vr1, a0, 17

    clz.w           t0, t1
    sub.d           t0, a0, t0
    addi.d          a0, a0, 32
    maskeqz         t0, t0, t1

    masknez         t1, a2, t1
    or              a2, t0, t1
    vseq.b          $vr2, $vr0, $vr4
    vseq.b          $vr3, $vr1, $vr4


    vmsknz.b        $vr2, $vr2
    vmsknz.b        $vr3, $vr3
    vmin.bu         $vr5, $vr0, $vr1
    vilvl.h         $vr2, $vr3, $vr2

    vsetanyeqz.b    $fcc0, $vr5
    movfr2gr.s      t1, $f2
    bceqz           $fcc0, L(loop)
    vmsknz.b        $vr0, $vr0

    vmsknz.b        $vr1, $vr1
    vilvl.h         $vr0, $vr1, $vr0
    movfr2gr.s      t0, $f0
L(end):
    slli.d          t3, t2, 1   # shift one more for the last '\0'

    cto.w           t0, t0
    sll.d           t3, t3, t0
    andn            t1, t1, t3
    clz.w           t0, t1


    sub.d           a0, a0, t0
    maskeqz         t0, a0, t1
    masknez         t1, a2, t1
    or              a0, t0, t1

    jr              ra
END(STRRCHR)

#ifdef _LIBC
libc_hidden_builtin_def(STRRCHR)
#endif

#endif
