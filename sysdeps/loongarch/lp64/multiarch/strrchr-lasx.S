#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#define STRRCHR __strrchr_lasx

LEAF(STRRCHR)
    .align          6
    andi            t1, a0, 0x3f
    bstrins.d       a0, zero, 5, 0
    xvld            $xr0, a0, 0
    xvld            $xr1, a0, 32

    li.d            t2, -1
    xvreplgr2vr.b   $xr4, a1
    move            a2, zero
    sll.d           t3, t2, t1

    addi.d          a0, a0, 63
    xvseq.b         $xr2, $xr0, $xr4
    xvseq.b         $xr3, $xr1, $xr4
    xvmsknz.b       $xr0, $xr0

    xvmsknz.b       $xr1, $xr1
    xvpickve.w      $xr5, $xr0, 4
    xvpickve.w      $xr6, $xr1, 4
    vilvl.h         $vr0, $vr5, $vr0


    vilvl.h         $vr1, $vr6, $vr1
    xvmsknz.b       $xr2, $xr2
    xvmsknz.b       $xr3, $xr3
    xvpickve.w      $xr5, $xr2, 4

    xvpickve.w      $xr6, $xr3, 4
    vilvl.h         $vr2, $vr5, $vr2
    vilvl.h         $vr3, $vr6, $vr3
    vilvl.w         $vr0, $vr1, $vr0

    vilvl.w         $vr1, $vr3, $vr2
    movfr2gr.d      t0, $f0
    movfr2gr.d      t1, $f1
    orn             t0, t0, t3

    and             t1, t1, t3
    bne             t0, t2, L(end)
L(loop):
    xvld            $xr0, a0, 1
    xvld            $xr1, a0, 33


    clz.d           t0, t1
    sub.d           t0, a0, t0
    addi.d          a0, a0, 64
    maskeqz         t0, t0, t1

    masknez         t1, a2, t1
    or              a2, t0, t1
    xvseq.b         $xr2, $xr0, $xr4
    xvseq.b         $xr3, $xr1, $xr4

    xvmsknz.b       $xr2, $xr2
    xvmsknz.b       $xr3, $xr3
    xvpickve.w      $xr5, $xr2, 4
    xvpickve.w      $xr6, $xr3, 4

    vilvl.h         $vr2, $vr5, $vr2
    vilvl.h         $vr3, $vr6, $vr3
    xvmin.bu        $xr5, $xr0, $xr1
    vilvl.w         $vr2, $vr3, $vr2


    xvsetanyeqz.b   $fcc0, $xr5
    movfr2gr.d      t1, $f2
    bceqz           $fcc0, L(loop)
    xvmsknz.b       $xr0, $xr0

    xvmsknz.b       $xr1, $xr1
    xvpickve.w      $xr5, $xr0, 4
    xvpickve.w      $xr6, $xr1, 4
    vilvl.h         $vr0, $vr5, $vr0

    vilvl.h         $vr1, $vr6, $vr1
    vilvl.w         $vr0, $vr1, $vr0
    movfr2gr.d      t0, $f0
L(end):
    slli.d          t3, t2, 1   # shift one more for the last '\0'

    cto.d           t0, t0
    sll.d           t3, t3, t0
    andn            t1, t1, t3
    clz.d           t0, t1

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
