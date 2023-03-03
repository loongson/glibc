#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <regdef.h>
#include <sys/asm.h>
#endif

#if IS_IN (libc)

#define STRCMP	__strcmp_lsx

/* int strcmp (const char *s1, const char *s2); */
L(magic_num):
    .align          6
    .dword          0x0706050403020100
    .dword          0x0f0e0d0c0b0a0908

ENTRY_NO_ALIGN(STRCMP)
    pcaddi          t0, -4
    andi            a2, a0, 0xf
    vld             $vr2, t0, 0
    andi            a3, a1, 0xf

    bne             a2, a3, L(unaligned)
    bstrins.d       a0, zero, 3, 0
    bstrins.d       a1, zero, 3, 0
    vld             $vr0, a0, 0

    vld             $vr1, a1, 0
    vreplgr2vr.b    $vr3, a2
    vslt.b          $vr2, $vr2, $vr3
    vseq.b          $vr3, $vr0, $vr1


    vmin.bu         $vr3, $vr0, $vr3
    vor.v           $vr3, $vr3, $vr2
    vsetanyeqz.b    $fcc0, $vr3
    bcnez           $fcc0, L(al_out)

L(al_loop):
    vld             $vr0, a0, 16
    vld             $vr1, a1, 16
    addi.d          a0, a0, 16
    addi.d          a1, a1, 16

    vseq.b          $vr3, $vr0, $vr1
    vmin.bu         $vr3, $vr0, $vr3
    vsetanyeqz.b    $fcc0, $vr3
    bceqz           $fcc0, L(al_loop)

L(al_out):
    vseqi.b         $vr3, $vr3, 0
    vfrstpi.b       $vr3, $vr3, 0
    vshuf.b         $vr0, $vr0, $vr0, $vr3
    vshuf.b         $vr1, $vr1, $vr1, $vr3


    vpickve2gr.bu   t0, $vr0, 0
    vpickve2gr.bu   t1, $vr1, 0
    sub.d           a0, t0, t1
    jr              ra

    nop
    nop
    nop
L(unaligned):
    slt             a4, a2, a3

    xor             t0, a0, a1
    maskeqz         t0, t0, a4
    xor             a0, a0, t0   # a0 hold the larger one
    xor             a1, a1, t0   # a1 hold the small one

    andi            a2, a0, 0xf
    andi            a3, a1, 0xf
    bstrins.d       a0, zero, 3, 0
    bstrins.d       a1, zero, 3, 0


    vld             $vr0, a0, 0
    vld             $vr3, a1, 0
    vreplgr2vr.b    $vr4, a2
    vreplgr2vr.b    $vr5, a3

    vslt.b          $vr7, $vr2, $vr4
    vsub.b          $vr4, $vr4, $vr5
    vaddi.bu        $vr6, $vr2, 16
    vsub.b          $vr6, $vr6, $vr4

    vshuf.b         $vr1, $vr3, $vr3, $vr6
    vseq.b          $vr4, $vr0, $vr1
    vmin.bu         $vr4, $vr0, $vr4
    vor.v           $vr4, $vr4, $vr7

    vsetanyeqz.b    $fcc0, $vr4
    bcnez           $fcc0, L(un_end)
    vslt.b          $vr5, $vr2, $vr5
    vor.v           $vr3, $vr3, $vr5


L(un_loop):
    vld             $vr0, a0, 16
    vsetanyeqz.b    $fcc0, $vr3
    bcnez           $fcc0, L(remaining_end)
    vor.v           $vr1, $vr3, $vr3

    vld             $vr3, a1, 16
    addi.d          a0, a0, 16
    addi.d          a1, a1, 16
    vshuf.b         $vr1, $vr3, $vr1, $vr6

    vseq.b          $vr4, $vr0, $vr1
    vmin.bu         $vr4, $vr0, $vr4
    vsetanyeqz.b    $fcc0, $vr4
    bceqz           $fcc0, L(un_loop)

L(un_end):
    vseqi.b         $vr4, $vr4, 0
    vfrstpi.b       $vr4, $vr4, 0
    vshuf.b         $vr0, $vr0, $vr0, $vr4
    vshuf.b         $vr1, $vr1, $vr1, $vr4


    vpickve2gr.bu   t0, $vr0, 0
    vpickve2gr.bu   t1, $vr1, 0
    sub.d           t3, t0, t1
    sub.d           t4, t1, t0

    masknez         t0, t3, a4
    maskeqz         t1, t4, a4
    or              a0, t0, t1
    jr              ra

L(remaining_end):
    vshuf.b         $vr1, $vr3, $vr3, $vr6
    vseq.b          $vr4, $vr0, $vr1
    vmin.bu         $vr4, $vr4, $vr0
    b               L(un_end)
END(STRCMP)

#ifdef _LIBC
libc_hidden_builtin_def (STRCMP)
#endif

#endif
