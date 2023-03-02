#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#if IS_IN (libc)

#define MEMSET	__memset_lasx

LEAF(MEMSET)
    .align          6
    li.d            t1, 32
    move            a3, a0
    xvreplgr2vr.b   $xr0, a1
    add.d           a4, a0, a2

    bgeu            t1, a2, L(less_32bytes) # len <= 32
    li.d            t3, 128
    li.d            t2, 64
    blt             t3, a2, L(long_bytes)   # len > 128

L(less_128bytes):
    bgeu            t2, a2, L(less_64bytes) # len <= 64
    xvst            $xr0, a3, 0
    xvst            $xr0, a3, 32
    xvst            $xr0, a4, -32

    xvst            $xr0, a4, -64
    jr              ra
L(less_64bytes):
    xvst            $xr0, a3, 0
    xvst            $xr0, a4, -32


    jr              ra
L(less_32bytes):
    srli.d          t0, a2, 4
    beqz            t0, L(less_16bytes)
    vst             $vr0, a3, 0

    vst             $vr0, a4, -16
    jr              ra
L(less_16bytes):
    srli.d          t0, a2, 3
    beqz            t0, L(less_8bytes)

    vstelm.d        $vr0, a3, 0, 0
    vstelm.d        $vr0, a4, -8, 0
    jr              ra
L(less_8bytes):
    srli.d          t0, a2, 2

    beqz            t0, L(less_4bytes)
    vstelm.w        $vr0, a3, 0, 0
    vstelm.w        $vr0, a4, -4, 0
    jr              ra


L(less_4bytes):
    srli.d          t0, a2, 1
    beqz            t0, L(less_2bytes)
    vstelm.h        $vr0, a3, 0, 0
    vstelm.h        $vr0, a4, -2, 0

    jr              ra
L(less_2bytes):
    beqz            a2, L(less_1bytes)
    st.b            a1, a3, 0
L(less_1bytes):
    jr              ra

L(long_bytes):
    xvst            $xr0, a3, 0
    bstrins.d       a3, zero, 4, 0
    addi.d          a3, a3, 32
    sub.d           a2, a4, a3

    andi            t0, a2, 0xff
    beq             t0, a2, L(long_end)
    move            a2, t0
    sub.d           t0, a4, t0


L(loop_256):
    xvst            $xr0, a3, 0
    xvst            $xr0, a3, 32
    xvst            $xr0, a3, 64
    xvst            $xr0, a3, 96

    xvst            $xr0, a3, 128
    xvst            $xr0, a3, 160
    xvst            $xr0, a3, 192
    xvst            $xr0, a3, 224

    addi.d          a3, a3, 256
    bne             a3, t0, L(loop_256)
L(long_end):
    bltu            a2, t3, L(end_less_128)
    addi.d          a2, a2, -128

    xvst            $xr0, a3, 0
    xvst            $xr0, a3, 32
    xvst            $xr0, a3, 64
    xvst            $xr0, a3, 96


    addi.d          a3, a3, 128
L(end_less_128):
    bltu            a2, t2, L(end_less_64)
    addi.d          a2, a2, -64
    xvst            $xr0, a3, 0

    xvst            $xr0, a3, 32
    addi.d          a3, a3, 64
L(end_less_64):
    bltu            a2, t1, L(end_less_32)
    xvst            $xr0, a3, 0

L(end_less_32):
    xvst            $xr0, a4, -32
    jr              ra
END(MEMSET)

#ifdef _LIBC
libc_hidden_builtin_def (MEMSET)
#endif

#endif
