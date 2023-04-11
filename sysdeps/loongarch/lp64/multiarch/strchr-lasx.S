#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#ifndef AS_STRCHRNUL
#define STRCHR	__strchr_lasx
#endif

LEAF(STRCHR)
    .align          6
    andi            t1, a0, 0x1f
    bstrins.d       a0, zero, 4, 0
    xvld            $xr0, a0, 0
    li.d            t2, -1

    xvreplgr2vr.b   $xr1, a1
    sll.d           t1, t2, t1
    xvxor.v         $xr2, $xr0, $xr1
    xvmin.bu        $xr0, $xr0, $xr2

    xvmsknz.b       $xr0, $xr0
    xvpickve.w      $xr3, $xr0, 4
    vilvl.h         $vr0, $vr3, $vr0
    movfr2gr.s      t0, $f0

    orn             t0, t0, t1
    bne             t0, t2, L(end)
    addi.d          a0, a0, 32
    nop


L(loop):
    xvld            $xr0, a0, 0
    xvxor.v         $xr2, $xr0, $xr1
    xvmin.bu        $xr0, $xr0, $xr2
    xvsetanyeqz.b   $fcc0, $xr0

    bcnez           $fcc0, L(loop_end)
    xvld            $xr0, a0, 32
    addi.d          a0, a0, 64
    xvxor.v         $xr2, $xr0, $xr1

    xvmin.bu        $xr0, $xr0, $xr2
    xvsetanyeqz.b   $fcc0, $xr0
    bceqz           $fcc0, L(loop)
    addi.d          a0, a0, -32

L(loop_end):
    xvmsknz.b       $xr0, $xr0
    xvpickve.w      $xr1, $xr0, 4
    vilvl.h         $vr0, $vr1, $vr0
    movfr2gr.s      t0, $f0


L(end):
    cto.w           t0, t0
    add.d           a0, a0, t0
#ifndef AS_STRCHRNUL
    vreplgr2vr.b    $vr0, t0
    xvpermi.q       $xr3, $xr2, 1

    vshuf.b         $vr0, $vr3, $vr2, $vr0
    vpickve2gr.bu   t0, $vr0, 0
    masknez         a0, a0, t0
#endif
    jr              ra

END(STRCHR)

#ifdef _LIBC
libc_hidden_builtin_def(STRCHR)
#endif

#endif
