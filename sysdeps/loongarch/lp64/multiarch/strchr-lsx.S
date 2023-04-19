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
#define STRCHR_NAME __strchr_lsx
#endif

LEAF(STRCHR_NAME)
    .align          6
    andi            t1, a0, 0xf
    bstrins.d       a0, zero, 3, 0
    vld             $vr0, a0, 0
    li.d            t2, -1

    vreplgr2vr.b    $vr1, a1
    sll.d           t3, t2, t1
    vxor.v          $vr2, $vr0, $vr1
    vmin.bu         $vr0, $vr0, $vr2

    vmsknz.b        $vr0, $vr0
    movfr2gr.s      t0, $f0
    ext.w.h         t0, t0
    orn             t0, t0, t3

    beq             t0, t2, L(loop)
L(found):
    cto.w           t0, t0
    add.d           a0, a0, t0
#ifndef AS_STRCHRNUL
    vreplve.b       $vr2, $vr2, t0
    vpickve2gr.bu   t1, $vr2, 0
    masknez         a0, a0, t1
#endif
    jr              ra


L(loop):
    vld             $vr0, a0, 16
    addi.d          a0, a0, 16
    vxor.v          $vr2, $vr0, $vr1
    vmin.bu         $vr0, $vr0, $vr2

    vsetanyeqz.b    $fcc0, $vr0
    bceqz           $fcc0, L(loop)
    vmsknz.b        $vr0, $vr0
    movfr2gr.s      t0, $f0

    b               L(found)
END(STRCHR_NAME)

#ifndef AS_STRCHRNUL
libc_hidden_builtin_def (STRCHR_NAME)
#endif

#endif
