#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <regdef.h>
#include <sys/asm.h>
#endif

#if IS_IN (libc)

#define STRNLEN	__strnlen_lsx

/* size_t strnlen (const char *s1, size_t maxlen); */

LEAF(STRNLEN)
    .align          6
    beqz            a1, L(ret0)
    andi            t1, a0, 0x1f
    li.d            t3, 33
    sub.d           a2, a0, t1

    vld             $vr0, a2, 0
    vld             $vr1, a2, 16
    sub.d           t1, t3, t1
    move            a3, a0

    sltu            t1, a1, t1
    vmsknz.b        $vr0, $vr0
    vmsknz.b        $vr1, $vr1
    vilvl.h         $vr0, $vr1, $vr0

    movfr2gr.s      t0, $f0
    sra.w           t0, t0, a0
    orn             t1, t1, t0
    bnez            t1, L(end)


    add.d           a4, a0, a1
    move            a0, a2
    addi.d          a4, a4, -1
    bstrins.d       a4, zero, 4, 0

L(loop):
    vld             $vr0, a0, 32
    vld             $vr1, a0, 48
    addi.d          a0, a0, 32
    beq             a0, a4, L(out)

    vmin.bu         $vr2, $vr0, $vr1
    vsetanyeqz.b    $fcc0, $vr2
    bceqz           $fcc0, L(loop)
L(out):
    vmsknz.b        $vr0, $vr0

    vmsknz.b        $vr1, $vr1
    vilvl.h         $vr0, $vr1, $vr0
    movfr2gr.s      t0, $f0
L(end):
    sub.d           a0, a0, a3


    cto.w           t0, t0
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
libc_hidden_builtin_def (STRNLEN)
#endif

#endif
