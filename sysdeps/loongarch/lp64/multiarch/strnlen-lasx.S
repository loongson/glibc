#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#define STRNLEN	__strnlen_lasx

/* size_t strnlen (const char *s1, size_t maxlen); */

LEAF(STRNLEN)
    .align          6
    beqz            a1, L(ret0)
    andi            t1, a0, 0x3f
    li.d            t3, 65
    sub.d           a2, a0, t1

    xvld            $xr0, a2, 0
    xvld            $xr1, a2, 32
    sub.d           t1, t3, t1
    move            a3, a0

    sltu            t1, a1, t1
    xvmsknz.b       $xr0, $xr0
    xvmsknz.b       $xr1, $xr1
    xvpickve.w      $xr2, $xr0, 4

    xvpickve.w      $xr3, $xr1, 4
    vilvl.h         $vr0, $vr2, $vr0
    vilvl.h         $vr1, $vr3, $vr1
    vilvl.w         $vr0, $vr1, $vr0


    movfr2gr.d      t0, $f0
    sra.d           t0, t0, a0
    orn             t1, t1, t0
    bnez            t1, L(end)

    add.d           a4, a0, a1
    move            a0, a2
    addi.d          a4, a4, -1
    bstrins.d       a4, zero, 5, 0

L(loop):
    xvld            $xr0, a0, 64
    xvld            $xr1, a0, 96
    addi.d          a0, a0, 64
    beq             a0, a4, L(out)

    xvmin.bu        $xr2, $xr0, $xr1
    xvsetanyeqz.b   $fcc0, $xr2
    bceqz           $fcc0, L(loop)
L(out):
    xvmsknz.b       $xr0, $xr0


    xvmsknz.b       $xr1, $xr1
    xvpickve.w      $xr2, $xr0, 4
    xvpickve.w      $xr3, $xr1, 4
    vilvl.h         $vr0, $vr2, $vr0

    vilvl.h         $vr1, $vr3, $vr1
    vilvl.w         $vr0, $vr1, $vr0
    movfr2gr.d      t0, $f0
L(end):
    sub.d           a0, a0, a3

    cto.d           t0, t0
    add.d           a0, a0, t0
    sltu            t1, a0, a1
    masknez         t0, a1, t1

    maskeqz         t1, a0, t1
    or              a0, t0, t1
    jr              ra
L(ret0):
    move            a0, zero


    jr              ra
END(STRNLEN)

#ifdef _LIBC
libc_hidden_def (STRNLEN)
#endif

#endif
