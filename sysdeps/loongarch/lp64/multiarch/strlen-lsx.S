#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <regdef.h>
#include <sys/asm.h>
#endif

#if IS_IN (libc)

#define STRLEN	__strlen_lsx

/* size_t strlen(const char *s1); */

LEAF(STRLEN)
    .align          6
    move            a1, a0
    bstrins.d       a0, zero, 4, 0
    vld             $vr0, a0, 0
    vld             $vr1, a0, 16

    li.d            t1, -1
    vmsknz.b        $vr0, $vr0
    vmsknz.b        $vr1, $vr1
    vilvl.h         $vr0, $vr1, $vr0

    movfr2gr.s      t0, $f0
    sra.w           t0, t0, a1
    beq             t0, t1, L(loop)
    cto.w           a0, t0

    jr              ra
    nop
    nop
    nop


L(loop):
    vld             $vr0, a0, 32
    vld             $vr1, a0, 48
    addi.d          a0, a0, 32
    vmin.bu         $vr2, $vr0, $vr1

    vsetanyeqz.b    $fcc0, $vr2
    bceqz           $fcc0, L(loop)
    vmsknz.b        $vr0, $vr0
    vmsknz.b        $vr1, $vr1

    vilvl.h         $vr0, $vr1, $vr0
    sub.d           a0, a0, a1
    movfr2gr.s      t0, $f0
    cto.w           t0, t0

    add.d           a0, a0, t0
    jr              ra
END(STRLEN)

#ifdef _LIBC
libc_hidden_builtin_def (STRLEN)
#endif

#endif
