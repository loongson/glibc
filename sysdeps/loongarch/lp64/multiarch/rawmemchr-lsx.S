#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <regdef.h>
#include <sys/asm.h>
#endif

#if IS_IN (libc)

# define RAWMEMCHR __rawmemchr_lsx

LEAF(RAWMEMCHR)
    .align          6
    move            a2, a0
    bstrins.d       a0, zero, 4, 0
    vld             $vr0, a0, 0
    vld             $vr1, a0, 16

    vreplgr2vr.b    $vr2, a1
    vseq.b          $vr0, $vr0, $vr2
    vseq.b          $vr1, $vr1, $vr2
    vmsknz.b        $vr0, $vr0

    vmsknz.b        $vr1, $vr1
    vilvl.h         $vr0, $vr1, $vr0
    movfr2gr.s      t0, $f0
    sra.w           t0, t0, a2

    beqz            t0, L(loop)
    ctz.w           t0, t0
    add.d           a0, a2, t0
    jr              ra


L(loop):
    vld             $vr0, a0, 32
    addi.d          a0, a0, 16
    vseq.b          $vr0, $vr0, $vr2
    vseteqz.v       $fcc0, $vr0

    bcnez           $fcc0, L(loop)
    addi.d          a0, a0, 16
    vfrstpi.b       $vr0, $vr0, 0
    vpickve2gr.bu   t0, $vr0, 0

    add.d           a0, a0, t0
    jr              ra
END(RAWMEMCHR)

#ifdef _LIBC
libc_hidden_builtin_def (RAWMEMCHR)
#endif

#endif
