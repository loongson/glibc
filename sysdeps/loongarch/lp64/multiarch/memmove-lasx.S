#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <regdef.h>
#include <sys/asm.h>
#endif

#if IS_IN (libc)

#ifndef MEMCPY_NAME
#define MEMCPY_NAME __memcpy_lasx
#endif

#ifndef MEMMOVE_NAME
#define MEMMOVE_NAME __memmove_lasx
#endif

LEAF(MEMCPY_NAME)
    .align          6
    li.d            t6, 32
    add.d           a3, a0, a2
    add.d           a4, a1, a2
    bgeu            t6, a2, L(less_32bytes) # a2 <= 32

    li.d            t8, 128
    li.d            t7, 64
    bltu            t8, a2, L(copy_long)    # a2 > 128
    bltu            t7, a2, L(more_64bytes) # a2 > 64

    xvld            $xr0, a1, 0
    xvld            $xr1, a4, -32
    xvst            $xr0, a0, 0
    xvst            $xr1, a3, -32

    jr              ra
L(more_64bytes):
    xvld            $xr0, a1, 0
    xvld            $xr1, a1, 32
    xvld            $xr2, a4, -64


    xvld            $xr3, a4, -32
    xvst            $xr0, a0, 0
    xvst            $xr1, a0, 32
    xvst            $xr2, a3, -64

    xvst            $xr3, a3, -32
    jr              ra
L(less_32bytes):
    srli.d          t0, a2, 4
    beqz            t0, L(less_16bytes)

    vld             $vr0, a1, 0
    vld             $vr1, a4, -16
    vst             $vr0, a0, 0
    vst             $vr1, a3, -16

    jr              ra
L(less_16bytes):
    srli.d          t0, a2, 3
    beqz            t0, L(less_8bytes)
    vldrepl.d       $vr0, a1, 0


    vldrepl.d       $vr1, a4, -8
    vstelm.d        $vr0, a0, 0, 0
    vstelm.d        $vr1, a3, -8, 0
    jr              ra

L(less_8bytes):
    srli.d          t0, a2, 2
    beqz            t0, L(less_4bytes)
    vldrepl.w       $vr0, a1, 0
    vldrepl.w       $vr1, a4, -4

    vstelm.w        $vr0, a0, 0, 0
    vstelm.w        $vr1, a3, -4, 0
    jr              ra
L(less_4bytes):
    srli.d          t0, a2, 1

    beqz            t0, L(less_2bytes)
    vldrepl.h       $vr0, a1, 0
    vldrepl.h       $vr1, a4, -2
    vstelm.h        $vr0, a0, 0, 0


    vstelm.h        $vr1, a3, -2, 0
    jr              ra
L(less_2bytes):
    beqz            a2, L(less_1bytes)
    ld.b            t0, a1, 0

    st.b            t0, a0, 0
L(less_1bytes):
    jr              ra
    nop
    nop
END(MEMCPY_NAME)

LEAF(MEMMOVE_NAME)
    li.d            t6, 32
    add.d           a3, a0, a2
    add.d           a4, a1, a2
    bgeu            t6, a2, L(less_32bytes) # a2 <= 32

    li.d            t8, 128
    li.d            t7, 64
    bltu            t8, a2, L(move_long)    # a2 > 128
    bltu            t7, a2, L(more_64bytes) # a2 > 64


    xvld            $xr0, a1, 0
    xvld            $xr1, a4, -32
    xvst            $xr0, a0, 0
    xvst            $xr1, a3, -32

    jr              ra
    nop
L(move_long):
    sub.d           t0, a0, a1
    bltu            t0, a2, L(copy_back)

L(copy_long):
    xvld            $xr1, a1, 0
    andi            t0, a0, 0x1f
    sub.d           t0, t6, t0
    add.d           a1, a1, t0

    sub.d           a2, a2, t0
    xvld            $xr0, a1, 0
    addi.d          t1, a2, -32
    add.d           a5, a0, t0


    andi            a2, t1, 0xff
    xvst            $xr1, a0, 0
    beq             t1, a2, L(long_end)
    sub.d           t0, t1, a2

    add.d           a6, a1, t0
L(loop_256):
    xvld            $xr1, a1, 32
    xvld            $xr2, a1, 64
    xvld            $xr3, a1, 96

    xvld            $xr4, a1, 128
    xvld            $xr5, a1, 160
    xvld            $xr6, a1, 192
    xvld            $xr7, a1, 224

    xvst            $xr0, a5, 0
    xvld            $xr0, a1, 256
    addi.d          a1, a1, 256
    xvst            $xr1, a5, 32


    xvst            $xr2, a5, 64
    xvst            $xr3, a5, 96
    xvst            $xr4, a5, 128
    xvst            $xr5, a5, 160

    xvst            $xr6, a5, 192
    xvst            $xr7, a5, 224
    addi.d          a5, a5, 256
    bne             a1, a6, L(loop_256)

L(long_end):
    bltu            a2, t8, L(end_less_128)
    xvld            $xr1, a1, 32
    xvld            $xr2, a1, 64
    xvld            $xr3, a1, 96

    addi.d          a2, a2, -128
    xvst            $xr0, a5, 0
    xvld            $xr0, a1, 128
    addi.d          a1, a1, 128


    xvst            $xr1, a5, 32
    xvst            $xr2, a5, 64
    xvst            $xr3, a5, 96
    addi.d          a5, a5, 128

L(end_less_128):
    blt             a2, t7, L(end_less_64)
    xvld            $xr1, a1, 32
    addi.d          a2, a2, -64
    xvst            $xr0, a5, 0

    xvld            $xr0, a1, 64
    addi.d          a1, a1, 64
    xvst            $xr1, a5, 32
    addi.d          a5, a5, 64

L(end_less_64):
    blt             a2, t6, L(end_less_32)
    xvst            $xr0, a5, 0
    xvld            $xr0, a1, 32
    addi.d          a5, a5, 32


L(end_less_32):
    xvld            $xr1, a4, -32
    xvst            $xr0, a5, 0
    xvst            $xr1, a3, -32
    jr              ra

L(copy_back):
    xvld            $xr1, a4, -32
    andi            t0, a3, 0x1f
    sub.d           a4, a4, t0
    sub.d           a2, a2, t0

    xvld            $xr0, a4, -32
    addi.d          t1, a2, -32
    xvst            $xr1, a3, -32
    sub.d           a3, a3, t0

    andi            a2, t1, 0xff
    beq             t1, a2, L(back_long_end)
    sub.d           t1, t1, a2
    sub.d           a6, a4, t1


L(back_loop_256):
    xvld            $xr1, a4, -64
    xvld            $xr2, a4, -96
    xvld            $xr3, a4, -128
    xvld            $xr4, a4, -160

    xvld            $xr5, a4, -192
    xvld            $xr6, a4, -224
    xvld            $xr7, a4, -256
    xvst            $xr0, a3, -32

    xvld            $xr0, a4, -288
    addi.d          a4, a4, -256
    xvst            $xr1, a3, -64
    xvst            $xr2, a3, -96

    xvst            $xr3, a3, -128
    xvst            $xr4, a3, -160
    xvst            $xr5, a3, -192
    xvst            $xr6, a3, -224


    xvst            $xr7, a3, -256
    addi.d          a3, a3, -256
    bne             a4, a6, L(back_loop_256)
L(back_long_end):
    blt             a2, t8, L(back_end_less_128)

    xvld            $xr1, a4, -64
    xvld            $xr2, a4, -96
    xvld            $xr3, a4, -128
    addi.d          a2, a2, -128

    xvst            $xr0, a3, -32
    xvld            $xr0, a4, -160
    addi.d          a4, a4, -128
    xvst            $xr1, a3, -64

    xvst            $xr2, a3, -96
    xvst            $xr3, a3, -128
    addi.d          a3, a3, -128
L(back_end_less_128):
    blt             a2, t7, L(back_end_less_64)


    xvld            $xr1, a4, -64
    addi.d          a2, a2, -64
    xvst            $xr0, a3, -32
    xvld            $xr0, a4, -96

    addi.d          a4, a4, -64
    xvst            $xr1, a3, -64
    addi.d          a3, a3, -64
L(back_end_less_64):
    blt             a2, t6, L(back_end_less_32)

    xvst            $xr0, a3, -32
    xvld            $xr0, a4, -64
    addi.d          a3, a3, -32
L(back_end_less_32):
    xvld            $xr1, a1, 0

    xvst            $xr0, a3, -32
    xvst            $xr1, a0, 0
    jr              ra
END(MEMMOVE_NAME)

#ifdef _LIBC
libc_hidden_builtin_def (MEMCPY_NAME)
libc_hidden_builtin_def (MEMMOVE_NAME)
#endif

#endif
