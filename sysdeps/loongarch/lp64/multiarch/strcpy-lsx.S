#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <regdef.h>
#include <sys/asm.h>
#endif

#if IS_IN (libc)

#define STRCPY __strcpy_lsx

/* int strcpy (const char *s1, const char *s2); */

L(magic_num):
    .align          6
    .dword          0x0706050403020100
    .dword          0x0f0e0d0c0b0a0908
ENTRY_NO_ALIGN(STRCPY)
    pcaddi          t0, -4
    andi            a4, a1, 0xf
    vld             $vr1, t0, 0
    move            a2, a0

    beqz            a4, L(load_start)
    xor             t0, a1, a4
    vld             $vr0, t0, 0
    vreplgr2vr.b    $vr2, a4

    vadd.b          $vr2, $vr2, $vr1
    vshuf.b         $vr0, $vr2, $vr0, $vr2
    vsetanyeqz.b    $fcc0, $vr0
    bcnez           $fcc0, L(end)


L(load_start):
    vld             $vr0, a1, 0
    li.d            t1, 16
    andi            a3, a2, 0xf
    vsetanyeqz.b    $fcc0, $vr0

    sub.d           t0, t1, a3
    bcnez           $fcc0, L(end)
    add.d           a1, a1, t0
    vst             $vr0, a2, 0

    andi            a3, a1, 0xf
    add.d           a2, a2, t0
    bnez            a3, L(unaligned)
    vld             $vr0, a1, 0

    vsetanyeqz.b    $fcc0, $vr0
    bcnez           $fcc0, L(end)
L(loop):
    vst             $vr0, a2, 0
    vld             $vr0, a1, 16


    addi.d          a2, a2, 16
    addi.d          a1, a1, 16
    vsetanyeqz.b    $fcc0, $vr0
    bceqz           $fcc0, L(loop)

    vmsknz.b        $vr1, $vr0
    movfr2gr.s      t0, $f1
    cto.w           t0, t0
    add.d           a1, a1, t0

    vld             $vr0, a1, -15
    add.d           a2, a2, t0
    vst             $vr0, a2, -15
    jr              ra

L(end):
    vmsknz.b        $vr1, $vr0
    movfr2gr.s      t0, $f1
    cto.w           t0, t0
    addi.d          t0, t0, 1


L(end_16):
    andi            t1, t0, 16
    beqz            t1, L(end_8)
    vst             $vr0, a2, 0
    jr              ra

L(end_8):
    andi            t2, t0, 8
    andi            t3, t0, 4
    andi            t4, t0, 2
    andi            t5, t0, 1

    beqz            t2, L(end_4)
    vstelm.d        $vr0, a2, 0, 0
    addi.d          a2, a2, 8
    vbsrl.v         $vr0, $vr0, 8

L(end_4):
    beqz            t3, L(end_2)
    vstelm.w        $vr0, a2, 0, 0
    addi.d          a2, a2, 4
    vbsrl.v         $vr0, $vr0, 4


L(end_2):
    beqz            t4, L(end_1)
    vstelm.h        $vr0, a2, 0, 0
    addi.d          a2, a2, 2
    vbsrl.v         $vr0, $vr0, 2

L(end_1):
    beqz            t5, L(out)
    vstelm.b        $vr0, a2, 0, 0
L(out):
    jr              ra
L(unaligned):
    bstrins.d      a1, zero, 3, 0

    vld            $vr2, a1, 0
    vreplgr2vr.b   $vr3, a3
    vslt.b         $vr4, $vr1, $vr3
    vor.v          $vr0, $vr2, $vr4

    vsetanyeqz.b   $fcc0, $vr0
    bcnez          $fcc0, L(un_first_end)
    vld            $vr0, a1, 16
    vadd.b         $vr3, $vr3, $vr1


    addi.d         a1, a1, 16
    vshuf.b        $vr4, $vr0, $vr2, $vr3
    vsetanyeqz.b   $fcc0, $vr0
    bcnez          $fcc0, L(un_end)

L(un_loop):
    vor.v          $vr2, $vr0, $vr0
    vld            $vr0, a1, 16
    vst            $vr4, a2, 0
    addi.d         a1, a1, 16

    addi.d         a2, a2, 16
    vshuf.b        $vr4, $vr0, $vr2, $vr3
    vsetanyeqz.b   $fcc0, $vr0
    bceqz          $fcc0, L(un_loop)

L(un_end):
    vsetanyeqz.b    $fcc0, $vr4
    bcnez           $fcc0, 1f
    vst             $vr4, a2, 0
1:
    vmsknz.b        $vr1, $vr0


    movfr2gr.s      t0, $f1
    cto.w           t0, t0
    add.d           a1, a1, t0
    vld             $vr0, a1, -15

    add.d           a2, a2, t0
    sub.d           a2, a2, a3
    vst             $vr0, a2, 1
    jr              ra

L(un_first_end):
    addi.d          a2, a2, -16
    b               1b
END(STRCPY)

#ifdef _LIBC
libc_hidden_builtin_def (STRCPY)
#endif

#endif
