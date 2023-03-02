#include <sysdep.h>
#include <sys/asm.h>

#if IS_IN (libc)

# define RAWMEMCHR __rawmemchr_lasx

LEAF(RAWMEMCHR)
    .align          6
    move            a2, a0
    bstrins.d       a0, zero, 4, 0
    xvld            $xr0, a0, 0
    xvreplgr2vr.b   $xr1, a1

    xvseq.b         $xr0, $xr0, $xr1
    xvmsknz.b       $xr0, $xr0
    xvpickve.w      $xr2, $xr0, 4
    vilvl.h         $vr0, $vr2, $vr0

    movfr2gr.s      t0, $f0
    sra.w           t0, t0, a2
    beqz            t0, L(loop)
    ctz.w           t0, t0

    add.d           a0, a2, t0
    jr              ra
    nop
    nop

L(loop):
    xvld            $xr0, a0, 32
    addi.d          a0, a0, 32
    xvseq.b         $xr0, $xr0, $xr1
    xvseteqz.v      $fcc0, $xr0

    bcnez           $fcc0, L(loop)
    xvmsknz.b       $xr0, $xr0
    xvpickve.w      $xr1, $xr0, 4
    vilvl.h         $vr0, $vr1, $vr0

    movfr2gr.s      t0, $f0
    ctz.w           t0, t0
    add.d           a0, a0, t0
    jr              ra
END(RAWMEMCHR)

#ifdef _LIBC
libc_hidden_builtin_def (RAWMEMCHR)
#endif

#endif
