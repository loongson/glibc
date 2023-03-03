#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#define MEMCMP  __memcmp_lsx

L(magic_num):
    .align          6
    .dword          0x0706050403020100
    .dword          0x0f0e0d0c0b0a0908
    nop
    nop
ENTRY_NO_ALIGN(MEMCMP)
    beqz            a2, L(out)
    pcaddi          t0, -7

    andi            a3, a0, 0xf
    vld             $vr5, t0, 0
    andi            a4, a1, 0xf
    bne             a3, a4, L(unaligned)

    bstrins.d       a0, zero, 3, 0
    xor             a1, a1, a4
    vld             $vr0, a0, 0
    vld             $vr1, a1, 0


    li.d            t0, 16
    vreplgr2vr.b    $vr3, a3
    sub.d           t1, t0, a3
    vadd.b          $vr3, $vr3, $vr5

    vshuf.b         $vr0, $vr3, $vr0, $vr3
    vshuf.b         $vr1, $vr3, $vr1, $vr3
    vseq.b          $vr4, $vr0, $vr1
    bgeu            t1, a2, L(al_end)

    vsetanyeqz.b    $fcc0, $vr4
    bcnez           $fcc0, L(al_found)
    sub.d           a2, a2, t1
    andi            t1, a2, 31

    beq             a2, t1, L(al_less_32bytes)
    sub.d           t2, a2, t1
    move            a2, t1
    add.d           a4, a0, t2


L(al_loop):
    vld             $vr0, a0, 16
    vld             $vr1, a1, 16
    vld             $vr2, a0, 32
    vld             $vr3, a1, 32

    addi.d          a0, a0, 32
    addi.d          a1, a1, 32
    vseq.b          $vr4, $vr0, $vr1
    vseq.b          $vr6, $vr2, $vr3

    vand.v          $vr6, $vr4, $vr6
    vsetanyeqz.b    $fcc0, $vr6
    bcnez           $fcc0, L(al_pair_end)
    bne             a0, a4, L(al_loop)

L(al_less_32bytes):
    bgeu            t0, a2, L(al_less_16bytes)
    vld             $vr0, a0, 16
    vld             $vr1, a1, 16
    vld             $vr2, a0, 32


    vld             $vr3, a1, 32
    addi.d          a2, a2, -16
    vreplgr2vr.b    $vr6, a2
    vslt.b          $vr5, $vr5, $vr6

    vseq.b          $vr4, $vr0, $vr1
    vseq.b          $vr6, $vr2, $vr3
    vorn.v          $vr6, $vr6, $vr5
L(al_pair_end):
    vsetanyeqz.b    $fcc0, $vr4

    bcnez           $fcc0, L(al_found)
    vnori.b         $vr4, $vr6, 0
    vfrstpi.b       $vr4, $vr4, 0
    vshuf.b         $vr0, $vr2, $vr2, $vr4

    vshuf.b         $vr1, $vr3, $vr3, $vr4
    vpickve2gr.bu   t0, $vr0, 0
    vpickve2gr.bu   t1, $vr1, 0
    sub.d           a0, t0, t1


    jr              ra
L(al_less_16bytes):
    beqz            a2, L(out)
    vld             $vr0, a0, 16
    vld             $vr1, a1, 16

    vseq.b          $vr4, $vr0, $vr1
L(al_end):
    vreplgr2vr.b    $vr6, a2
    vslt.b          $vr5, $vr5, $vr6
    vorn.v          $vr4, $vr4, $vr5

L(al_found):
    vnori.b         $vr4, $vr4, 0
    vfrstpi.b       $vr4, $vr4, 0
    vshuf.b         $vr0, $vr0, $vr0, $vr4
    vshuf.b         $vr1, $vr1, $vr1, $vr4

    vpickve2gr.bu   t0, $vr0, 0
    vpickve2gr.bu   t1, $vr1, 0
    sub.d           a0, t0, t1
    jr              ra


L(unaligned):
    xor             t2, a0, a1
    sltu            a5, a3, a4
    masknez         t2, t2, a5
    xor             a0, a0, t2      # a0 point to string with smaller offset 2

    xor             a1, a1, t2      # a1 point to string with larger 4
    andi            a3, a0, 0xf     # a3 = 2
    andi            a4, a1, 0xf     # a4 = 4
    bstrins.d       a0, zero, 3, 0

    xor             a1, a1, a4
    vld             $vr4, a0, 0
    vld             $vr1, a1, 0
    li.d            t0, 16

    vreplgr2vr.b    $vr2, a4
    sub.d           a6, a4, a3  # a6 hold the diff
    sub.d           t1, t0, a4
    sub.d           t2, t0, a6


    vadd.b          $vr2, $vr2, $vr5 # [4, 5, 6, ...]
    vreplgr2vr.b    $vr6, t2
    vadd.b          $vr6, $vr6, $vr5 # [14, 15, 16, ... ]
    vshuf.b         $vr0, $vr4, $vr4, $vr6  # make data be in the same position

    vshuf.b         $vr1, $vr2, $vr1, $vr2
    vshuf.b         $vr0, $vr2, $vr0, $vr2
    vseq.b          $vr7, $vr0, $vr1
    bgeu            t1, a2, L(un_end)

    vsetanyeqz.b    $fcc0, $vr7
    bcnez           $fcc0, L(un_found)
    sub.d           a2, a2, t1
    andi            t1, a2, 31

    beq             a2, t1, L(un_less_32bytes)
    sub.d           t2, a2, t1
    move            a2, t1
    add.d           a4, a1, t2


L(un_loop):
    vld             $vr2, a0, 16
    vld             $vr1, a1, 16
    vld             $vr3, a1, 32
    addi.d          a1, a1, 32

    addi.d          a0, a0, 32
    vshuf.b         $vr0, $vr2, $vr4, $vr6
    vld             $vr4, a0, 0
    vseq.b          $vr7, $vr0, $vr1

    vshuf.b         $vr2, $vr4, $vr2, $vr6
    vseq.b          $vr8, $vr2, $vr3
    vand.v          $vr8, $vr7, $vr8
    vsetanyeqz.b    $fcc0, $vr8

    bcnez           $fcc0, L(un_pair_end)
    bne             a1, a4, L(un_loop)
L(un_less_32bytes):
    bltu            a2, t0, L(un_less_16bytes)
    vld             $vr2, a0, 16


    vld             $vr1, a1, 16
    addi.d          a0, a0, 16
    addi.d          a1, a1, 16
    addi.d          a2, a2, -16

    vshuf.b         $vr0, $vr2, $vr4, $vr6
    vor.v           $vr4, $vr2, $vr2
    vseq.b          $vr7, $vr0, $vr1
    vsetanyeqz.b    $fcc0, $vr7

    bcnez           $fcc0, L(un_found)
L(un_less_16bytes):
    beqz            a2, L(out)
    vld             $vr1, a1, 16
    bgeu            a6, a2, 1f

    vld             $vr2, a0, 16
1:
    vshuf.b         $vr0, $vr2, $vr4, $vr6
    vseq.b          $vr7, $vr0, $vr1
L(un_end):
    vreplgr2vr.b    $vr3, a2


    vslt.b          $vr3, $vr5, $vr3
    vorn.v          $vr7, $vr7, $vr3
L(un_found):
    vnori.b         $vr7, $vr7, 0
    vfrstpi.b       $vr7, $vr7, 0

    vshuf.b         $vr0, $vr0, $vr0, $vr7
    vshuf.b         $vr1, $vr1, $vr1, $vr7
L(calc_result):
    vpickve2gr.bu   t0, $vr0, 0
    vpickve2gr.bu   t1, $vr1, 0

    sub.d           t2, t0, t1
    sub.d           t3, t1, t0
    masknez         t0, t3, a5
    maskeqz         t1, t2, a5

    or              a0, t0, t1
    jr              ra
L(un_pair_end):
    vsetanyeqz.b    $fcc0, $vr7
    bcnez           $fcc0, L(un_found)


    vnori.b         $vr7, $vr8, 0
    vfrstpi.b       $vr7, $vr7, 0
    vshuf.b         $vr0, $vr2, $vr2, $vr7
    vshuf.b         $vr1, $vr3, $vr3, $vr7

    b               L(calc_result)
L(out):
    move            a0, zero
    jr              ra

END(MEMCMP)

#ifdef _LIBC
libc_hidden_builtin_def (MEMCMP)
#endif

#endif
