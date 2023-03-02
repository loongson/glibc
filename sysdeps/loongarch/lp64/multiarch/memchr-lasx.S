#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#define MEMCHR	__memchr_lasx

LEAF(MEMCHR)
    .align          6
    beqz            a2, L(ret0)
    add.d           a3, a0, a2
    andi            t0, a0, 0x3f
    bstrins.d       a0, zero, 5, 0

    xvld            $xr0, a0, 0
    xvld            $xr1, a0, 32
    li.d            t1, -1
    li.d            t2, 64

    xvreplgr2vr.b   $xr2, a1
    sll.d           t3, t1, t0
    sub.d           t2, t2, t0
    xvseq.b         $xr0, $xr0, $xr2

    xvseq.b         $xr1, $xr1, $xr2
    xvmsknz.b       $xr0, $xr0
    xvmsknz.b       $xr1, $xr1
    xvpickve.w      $xr3, $xr0, 4


    xvpickve.w      $xr4, $xr1, 4
    vilvl.h         $vr0, $vr3, $vr0
    vilvl.h         $vr1, $vr4, $vr1
    vilvl.w         $vr0, $vr1, $vr0

    movfr2gr.d      t0, $f0
    and             t0, t0, t3
    bgeu            t2, a2, L(end)
    bnez            t0, L(found)

    addi.d          a4, a3, -1
    bstrins.d       a4, zero, 5, 0
L(loop):
    xvld            $xr0, a0, 64
    xvld            $xr1, a0, 96

    addi.d          a0, a0, 64
    xvseq.b         $xr0, $xr0, $xr2
    xvseq.b         $xr1, $xr1, $xr2
    beq             a0, a4, L(out)


    xvmax.bu        $xr3, $xr0, $xr1
    xvseteqz.v      $fcc0, $xr3
    bcnez           $fcc0, L(loop)
    xvmsknz.b       $xr0, $xr0

    xvmsknz.b       $xr1, $xr1
    xvpickve.w      $xr3, $xr0, 4
    xvpickve.w      $xr4, $xr1, 4
    vilvl.h         $vr0, $vr3, $vr0

    vilvl.h         $vr1, $vr4, $vr1
    vilvl.w         $vr0, $vr1, $vr0
    movfr2gr.d      t0, $f0
L(found):
    ctz.d           t1, t0

    add.d           a0, a0, t1
    jr              ra
L(ret0):
    move            a0, zero
    jr              ra


L(out):
    xvmsknz.b       $xr0, $xr0
    xvmsknz.b       $xr1, $xr1
    xvpickve.w      $xr3, $xr0, 4
    xvpickve.w      $xr4, $xr1, 4

    vilvl.h         $vr0, $vr3, $vr0
    vilvl.h         $vr1, $vr4, $vr1
    vilvl.w         $vr0, $vr1, $vr0
    movfr2gr.d      t0, $f0

L(end):
    sub.d           t2, zero, a3
    srl.d           t1, t1, t2
    and             t0, t0, t1
    ctz.d           t1, t0

    add.d           a0, a0, t1
    maskeqz         a0, a0, t0
    jr              ra
END(MEMCHR)

#ifdef _LIBC
libc_hidden_builtin_def (MEMCHR)
#endif

#endif
