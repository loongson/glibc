#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#define STRNLEN	__strnlen_lsx

/* size_t strnlen (const char *s1, size_t maxlen); */

LEAF(STRNLEN)
    .align          6
    beqz            a1, L(ret0)
    andi            t1, a0, 0x1f
    li.d            t3, 32
    sub.d           t2, a0, t1

    vld             $vr0, t2, 0
    vld             $vr1, t2, 16
    sub.d           t3, t3, t1
    move            a2, a0

    sltu            t1, t3, a1
    vmsknz.b        $vr0, $vr0
    vmsknz.b        $vr1, $vr1
    sltui           t1, t1, 1

    vilvl.h         $vr0, $vr1, $vr0
    movfr2gr.s      t0, $f0
    sra.w           t0, t0, a2
    orn             t1, t1, t0


    bnez            t1, L(end)
    move            a0, t2
    sub.d           t2, a1, t3
L(loop):
    vld             $vr0, a0, 32

    vld             $vr1, a0, 48
    sltui           t1, t2, 33
    addi.d          a0, a0, 32
    addi.d          t2, t2, -32

    vmsknz.b        $vr0, $vr0
    vmsknz.b        $vr1, $vr1
    vilvl.h         $vr0, $vr1, $vr0
    movfr2gr.s      t0, $f0

    orn             t1, t1, t0
    beqz            t1, L(loop)
L(end):
    sub.d           a0, a0, a2
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
libc_hidden_builtin_def (STRNLEN)
#endif

#endif
