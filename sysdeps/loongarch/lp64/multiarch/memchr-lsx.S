#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#define MEMCHR	__memchr_lsx

LEAF(MEMCHR)
    .align          6
    beqz            a2, L(ret0)
    add.d           a3, a0, a2
    andi            t0, a0, 0x1f
    bstrins.d       a0, zero, 4, 0

    vld             $vr0, a0, 0
    vld             $vr1, a0, 16
    li.d            t1, -1
    li.d            t2, 32

    vreplgr2vr.b    $vr2, a1
    sll.d           t3, t1, t0
    sub.d           t2, t2, t0
    vseq.b          $vr0, $vr0, $vr2

    vseq.b          $vr1, $vr1, $vr2
    vmsknz.b        $vr0, $vr0
    vmsknz.b        $vr1, $vr1
    vilvl.h         $vr0, $vr1, $vr0


    movfr2gr.s      t0, $f0
    and             t0, t0, t3
    bgeu            t2, a2, L(end)
    bnez            t0, L(found)

    addi.d          a4, a3, -1
    bstrins.d       a4, zero, 4, 0
L(loop):
    vld             $vr0, a0, 32
    vld             $vr1, a0, 48

    addi.d          a0, a0, 32
    vseq.b          $vr0, $vr0, $vr2
    vseq.b          $vr1, $vr1, $vr2
    beq             a0, a4, L(out)

    vmax.bu         $vr3, $vr0, $vr1
    vseteqz.v       $fcc0, $vr3
    bcnez           $fcc0, L(loop)
    vmsknz.b        $vr0, $vr0


    vmsknz.b        $vr1, $vr1
    vilvl.h         $vr0, $vr1, $vr0
    movfr2gr.s      t0, $f0
L(found):
    ctz.w           t0, t0

    add.d           a0, a0, t0
    jr              ra
L(ret0):
    move            a0, zero
    jr              ra

L(out):
    vmsknz.b        $vr0, $vr0
    vmsknz.b        $vr1, $vr1
    vilvl.h         $vr0, $vr1, $vr0
    movfr2gr.s      t0, $f0

L(end):
    sub.d           t2, zero, a3
    srl.w           t1, t1, t2
    and             t0, t0, t1
    ctz.w           t1, t0


    add.d           a0, a0, t1
    maskeqz         a0, a0, t0
    jr              ra
END(MEMCHR)

#ifdef _LIBC
libc_hidden_builtin_def (MEMCHR)
#endif

#endif
