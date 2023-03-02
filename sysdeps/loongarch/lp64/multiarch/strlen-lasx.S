#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#define STRLEN	__strlen_lasx

/* size_t strlen(const char *s1); */

LEAF(STRLEN)
    .align          6
    move            a1, a0
    bstrins.d       a0, zero, 4, 0
    li.d            t1, -1
    xvld            $xr0, a0, 0

    xvmsknz.b       $xr0, $xr0
    xvpickve.w      $xr1, $xr0, 4
    vilvl.h         $vr0, $vr1, $vr0
    movfr2gr.s      t0, $f0  # sign extend

    sra.w           t0, t0, a1
    beq             t0, t1, L(loop)
    cto.w           a0, t0
    jr              ra

L(loop):
    xvld            $xr0, a0, 32
    addi.d          a0, a0, 32
    xvsetanyeqz.b   $fcc0, $xr0
    bceqz           $fcc0, L(loop)


    xvmsknz.b       $xr0, $xr0
    sub.d           a0, a0, a1
    xvpickve.w      $xr1, $xr0, 4
    vilvl.h         $vr0, $vr1, $vr0

    movfr2gr.s      t0, $f0
    cto.w           t0, t0
    add.d           a0, a0, t0
    jr              ra
END(STRLEN)

#ifdef _LIBC
libc_hidden_builtin_def (STRLEN)
#endif

#endif
