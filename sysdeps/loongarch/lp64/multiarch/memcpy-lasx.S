/* Multiple versions of memcpy. LoongArch64 version.
   Copyright (C) 2022 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library.  If not, see
   <https://www.gnu.org/licenses/>.  */

#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <regdef.h>
#include <sys/asm.h>
#endif

#if IS_IN (libc)

#define MEMCPY_NAME __memcpy_lasx

#ifdef ANDROID_CHANGES
LEAF(MEMCPY_NAME, 0)
#else
LEAF(MEMCPY_NAME)
#endif

#define XVXOR_V(xd,xj,xk)       .word(0x1d<<26|0x09<<21|0x0E<<15|(xk&0x1f)<<10|(xj&0x1f)<<5|(xd&0x1f))
#define XVREPLVE0_B(xd,xj)      .word(0x1d<<26|0x18<<21|0x0E<<15|0x0<<10|(xj&0x1f)<<5|(xd&0x1f))
#define XVST(xd,rj,si12)        .word(0x0b<<26|0x3<<22|(si12&0xfff)<<10|(rj&0x1f)<<5|(xd&0x1f))
#define XVLD(xd,rj,si12)        .word(0x0b<<26|0x2<<22|(si12&0xfff)<<10|(rj&0x1f)<<5|(xd&0x1f))
#define VST(vd,rj,si12)         .word(0x0b<<26|0x1<<22|(si12&0xfff)<<10|(rj&0x1f)<<5|(vd&0x1f))
#define VLD(vd,rj,si12)         .word(0x0b<<26|0x0<<22|(si12&0xfff)<<10|(rj&0x1f)<<5|(vd&0x1f))
#define VSTELM_D(vd,rj,si8,idx) .word(0x31<<24|0x2<<19|(idx&0x1)<<18|(si8&0xff)<<10|(rj&0x1f)<<5|(vd&0x1f))
#define VSTELM_W(vd,rj,si8,idx) .word(0x31<<24|0x2<<20|(idx&0x3)<<18|(si8&0xff)<<10|(rj&0x1f)<<5|(vd&0x1f))
#define VSTELM_H(vd,rj,si8,idx) .word(0x31<<24|0x2<<21|(idx&0x7)<<18|(si8&0xff)<<10|(rj&0x1f)<<5|(vd&0x1f))
#define VSTELM_B(vd,rj,si8,idx) .word(0x31<<24|0x2<<22|(idx&0xf)<<18|(si8&0xff)<<10|(rj&0x1f)<<5|(vd&0x1f))
#define VLDREPL_D(vd,rj,si9)    .word(0x30<<24|0x2<<19|(si9&0x1ff)<<10|(rj&0x1f)<<5|(vd&0x1f))
#define VLDREPL_W(vd,rj,si10)   .word(0x30<<24|0x2<<20|(si10&0x3ff)<<10|(rj&0x1f)<<5|(vd&0x1f))
#define VLDREPL_H(vd,rj,si11)   .word(0x30<<24|0x2<<21|(si11&0x7ff)<<10|(rj&0x1f)<<5|(vd&0x1f))
#define VLDREPL_B(vd,rj,si12)   .word(0x30<<24|0x2<<22|(si12&0xfff)<<10|(rj&0x1f)<<5|(vd&0x1f))

/* 1st var: dest ptr: void *str1 $r4.
 * 2nd var: src  ptr: void *str2 $r5.
 * 3rd var: size_t num.  */

	add.d	t3, a1, a2		# src end, 2st var, 3rd var t3->$r15
	add.d	t2, a0, a2		# dest end, 1st var, 3rd var t2->$r14
	move	t0, a0			# $2 is func return value
	srai.d	t8, a2, 4		# num/16
	beqz	t8, less_16bytes       	# num<16
	nop
	srai.d	t8, a2, 8		# num/256
	bnez	t8, eqormore_256bytes  	# num>256
	nop
	srai.d	t8, a2, 7
	beqz	t8, less_128bytes	# num<128
	nop

	XVLD(0, 5, 0)
	XVLD(1, 5, 32)
	XVLD(2, 5, 64)
	XVLD(3, 5, 96)
	XVLD(4, 15, -128)
	XVLD(5, 15, -96)
	XVLD(6, 15, -64)
	XVLD(7, 15, -32)
	XVST(0, 4, 0)
	XVST(1, 4, 32)
	XVST(2, 4, 64)
	XVST(3, 4, 96)
	XVST(4, 14, -128)
	XVST(5, 14, -96)
	XVST(6, 14, -64)
	XVST(7, 14, -32)

	jr	ra
	nop

less_128bytes:
	srai.d	t8, a2, 6 		# num/64
	beqz	t8, less_64bytes
	nop

	XVLD(0, 5, 0)
	XVLD(1, 5, 32)
	XVLD(6, 15, -64)
	XVLD(7, 15, -32)
	XVST(0, 4, 0)
	XVST(1, 4, 32)
	XVST(6, 14, -64)
	XVST(7, 14, -32)

	jr	ra
	nop

less_64bytes:
	srai.d	t8, a2, 5 		# num/32
	beqz	t8, less_32bytes
	nop

	XVLD(0, 5, 0)
	XVLD(7, 15, -32)
	XVST(0, 4, 0)
	XVST(7, 14, -32)

	jr	ra
	nop

less_32bytes:
	VLD(0, 5, 0)
	VLD(7, 15, -16)
	VST(0, 4, 0)
	VST(7, 14, -16)

	jr	ra
	nop

less_16bytes:
	srai.d	t8, a2, 3 		# num/8
	beqz	t8, less_8bytes
	nop
	VLDREPL_D(0, 5, 0)
	VLDREPL_D(7, 15, -1)
	VSTELM_D (0, 4, 0, 0)      	# store lower 8bytes to mem
	VSTELM_D (7, 14, -1, 0)	   	# store lower 8bytes to mem
	jr	ra
	nop

less_8bytes:
	srai.d	t8, a2, 2
	beqz	t8, less_4bytes
	nop
	VLDREPL_W(0, 5, 0)
	VLDREPL_W(7, 15, -1)
	VSTELM_W (0, 4,  0, 0)
	VSTELM_W (7, 14, -1, 0)
	jr	ra
	nop

less_4bytes:
	srai.d	t8, a2, 1
	beqz	t8, less_2bytes
	nop
	VLDREPL_H(0, 5, 0)
	VLDREPL_H(7, 15, -1)
	VSTELM_H (0, 4,  0, 0)
	VSTELM_H (7, 14, -1, 0)
	jr	ra
	nop

less_2bytes:
	beqz	a2, less_1bytes
	nop
	VLDREPL_B(0, 5, 0)
	VSTELM_B (0, 4,  0,  0)
	jr	ra
	nop

less_1bytes:
	jr	ra
	nop


eqormore_256bytes:
	srli.d	a0, a0, 5
	slli.d	a0, a0, 5
	addi.d	a0, a0,  0x20	 # a0:align dest start addr
	sub.d	t7, t0,  a0      # $2:dest start addr

	XVLD(0, 5, 0)

	sub.d	a1,  a1,  t7     # a1:newer src

	XVST(0, 12, 0)
	XVLD(19, 15, -128)
	XVLD(18, 15,  -96)
	XVLD(17, 15,  -64)
	XVLD(16, 15,  -32)

	add.d	t7, t7, a2   	# t7:num
	addi.d	t7, t7, -0x80
	srai.d	t8, t7, 22
	bnez	t8, loop_most	# >4MB; scache_size_half * 1/2
	nop
	srai.d	t8, t7, 12
	beqz	t8, loop_less	# <4096
	nop

loop_more:
	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	XVST(14, 4, 448)
	XVST(15, 4, 480)

	addi.d	a0,  a0,   512   #1
	addi.d	a1,  a1,   512   #1

	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	XVST(14, 4, 448)
	XVST(15, 4, 480)

	addi.d	a0,  a0,   512   #2
	addi.d	a1,  a1,   512   #2

	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	XVST(14, 4, 448)
	XVST(15, 4, 480)

	addi.d	a0,  a0,   512   #3
	addi.d	a1,  a1,   512   #3

	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	XVST(14, 4, 448)
	XVST(15, 4, 480)

	addi.d	a0,  a0,   512   #4
	addi.d	a1,  a1,   512   #4

	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	XVST(14, 4, 448)
	XVST(15, 4, 480)

	addi.d	a0,  a0,   512   #5
	addi.d	a1,  a1,   512   #5

	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	XVST(14, 4, 448)
	XVST(15, 4, 480)

	addi.d	a0,  a0,   512   #6
	addi.d	a1,  a1,   512   #6

	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	XVST(14, 4, 448)
	XVST(15, 4, 480)

	addi.d	a0,  a0,   512   #7
	addi.d	a1,  a1,   512   #7

	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	XVST(14, 4, 448)
	XVST(15, 4, 480)

	addi.d	a0,  a0,   512   #8
	addi.d	a1,  a1,   512   #8
	addi.d	t8, t8, -1
	bnez	t8, loop_more
	nop

  	lu12i.w t4, 1        #get imm 1<<12
  	addi.d	t4, t4, -1
  	and	t7, t7, t4

	b	loop_less
	nop

loop_most:
	srai.d	t8, t7, 12
        lu12i.w t5, 1	     # load imm 4096
        add.d 	t6, t5, a0   #t6 = a0 + 4096
        add.d 	t5, t5, a1   #t5 = a1 + 4096

loop_most_loop:
	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	preld 0, t5, 0       #imm in pref inst is 16b, but 12b in preld.
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	preld 0, t5, 64      #prefech for next loop cache data
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	preld 0, t5, 128
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	preld 0, t5, 192
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	preld 0, t5, 256
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	preld 0, t5, 320
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	preld 0, t5, 384
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	preld 0, t5, 448
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	preld 8, t6, 0
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	preld 8, t6, 64
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	preld 8, t6, 128
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	preld 8, t6, 192
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	preld 8, t6, 256
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	preld 8, t6, 320
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	preld 8, t6, 384
	XVST(14, 4, 448)
	XVST(15, 4, 480)
	preld 8, t6, 448
	addi.d	a0,  a0,   512   #1
	addi.d	a1,  a1,   512   #1
	addi.d  t5,  t5,   512
   	addi.d  t6,  t6,   512
	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	preld 0, t5, 0
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	preld 0, t5, 64
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	preld 0, t5, 128
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	preld 0, t5, 192
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	preld 0, t5, 256
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	preld 0, t5, 320
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	preld 0, t5, 384
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	preld 0, t5, 448
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	preld 8, t6, 0
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	preld 8, t6, 64
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	preld 8, t6, 128
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	preld 8, t6, 192
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	preld 8, t6, 256
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	preld 8, t6, 320
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	preld 8, t6, 384
	XVST(14, 4, 448)
	XVST(15, 4, 480)
	preld 8, t6, 448
	addi.d	a0,  a0,   512   #2
	addi.d	a1,  a1,   512   #2
	addi.d  t5,  t5,   512
   	addi.d  t6,  t6,   512
	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	preld 0, t5, 0
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	preld 0, t5, 64
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	preld 0, t5, 128
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	preld 0, t5, 192
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	preld 0, t5, 256
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	preld 0, t5, 320
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	preld 0, t5, 384
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	preld 0, t5, 448
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	preld 8, t6, 0
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	preld 8, t6, 64
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	preld 8, t6, 128
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	preld 8, t6, 192
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	preld 8, t6, 256
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	preld 8, t6, 320
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	preld 8, t6, 384
	XVST(14, 4, 448)
	XVST(15, 4, 480)
	preld 8, t6, 448
	addi.d	a0,  a0,   512   #3
	addi.d	a1,  a1,   512   #3
	addi.d  t5,  t5,   512
   	addi.d  t6,  t6,   512
	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	preld 0, t5, 0
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	preld 0, t5, 64
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	preld 0, t5, 128
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	preld 0, t5, 192
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	preld 0, t5, 256
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	preld 0, t5, 320
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	preld 0, t5, 384
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	preld 0, t5, 448
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	preld 8, t6, 0
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	preld 8, t6, 64
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	preld 8, t6, 128
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	preld 8, t6, 192
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	preld 8, t6, 256
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	preld 8, t6, 320
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	preld 8, t6, 384
	XVST(14, 4, 448)
	XVST(15, 4, 480)
	preld 8, t6, 448
	addi.d	a0,  a0,   512   #4
	addi.d	a1,  a1,   512   #4
	addi.d  t5,  t5,   512
   	addi.d  t6,  t6,   512
	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	preld 0, t5, 0
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	preld 0, t5, 64
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	preld 0, t5, 128
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	preld 0, t5, 192
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	preld 0, t5, 256
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	preld 0, t5, 320
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	preld 0, t5, 384
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	preld 0, t5, 448
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	preld 8, t6, 0
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	preld 8, t6, 64
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	preld 8, t6, 128
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	preld 8, t6, 192
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	preld 8, t6, 256
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	preld 8, t6, 320
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	preld 8, t6, 384
	XVST(14, 4, 448)
	XVST(15, 4, 480)
	preld 8, t6, 448
	addi.d	a0,  a0,   512   #5
	addi.d	a1,  a1,   512   #5
	addi.d  t5,  t5,   512
   	addi.d  t6,  t6,   512
	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	preld 0, t5, 0
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	preld 0, t5, 64
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	preld 0, t5, 128
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	preld 0, t5, 192
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	preld 0, t5, 256
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	preld 0, t5, 320
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	preld 0, t5, 384
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	preld 0, t5, 448
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	preld 8, t6, 0
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	preld 8, t6, 64
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	preld 8, t6, 128
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	preld 8, t6, 192
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	preld 8, t6, 256
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	preld 8, t6, 320
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	preld 8, t6, 384
	XVST(14, 4, 448)
	XVST(15, 4, 480)
	preld 8, t6, 448
	addi.d	a0,  a0,   512   #6
	addi.d	a1,  a1,   512   #6
	addi.d  t5,  t5,   512
   	addi.d  t6,  t6,   512
	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	preld 0, t5, 0
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	preld 0, t5, 64
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	preld 0, t5, 128
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	preld 0, t5, 192
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	preld 0, t5, 256
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	preld 0, t5, 320
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	preld 0, t5, 384
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	preld 0, t5, 448
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	preld 8, t6, 0
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	preld 8, t6, 64
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	preld 8, t6, 128
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	preld 8, t6, 192
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	preld 8, t6, 256
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	preld 8, t6, 320
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	preld 8, t6, 384
	XVST(14, 4, 448)
	XVST(15, 4, 480)
	preld 8, t6, 448
	addi.d	a0,  a0,   512   #7
	addi.d	a1,  a1,   512   #7
	addi.d  t5,  t5,   512
   	addi.d  t6,  t6,   512
	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	preld 0, t5, 0
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	preld 0, t5, 64
	XVLD( 4, 5, 128)
	XVLD( 5, 5, 160)
	preld 0, t5, 128
	XVLD( 6, 5, 192)
	XVLD( 7, 5, 224)
	preld 0, t5, 192
	XVLD( 8, 5, 256)
	XVLD( 9, 5, 288)
	preld 0, t5, 256
	XVLD(10, 5, 320)
	XVLD(11, 5, 352)
	preld 0, t5, 320
	XVLD(12, 5, 384)
	XVLD(13, 5, 416)
	preld 0, t5, 384
	XVLD(14, 5, 448)
	XVLD(15, 5, 480)
	preld 0, t5, 448
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	preld 8, t6, 0
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	preld 8, t6, 64
	XVST( 4, 4, 128)
	XVST( 5, 4, 160)
	preld 8, t6, 128
	XVST( 6, 4, 192)
	XVST( 7, 4, 224)
	preld 8, t6, 192
	XVST( 8, 4, 256)
	XVST( 9, 4, 288)
	preld 8, t6, 256
	XVST(10, 4, 320)
	XVST(11, 4, 352)
	preld 8, t6, 320
	XVST(12, 4, 384)
	XVST(13, 4, 416)
	preld 8, t6, 384
	XVST(14, 4, 448)
	XVST(15, 4, 480)
	preld 8, t6, 448
	addi.d	a0,  a0,   512   #8
	addi.d	a1,  a1,   512   #8
	addi.d  t5,  t5,   512
   	addi.d  t6,  t6,   512
	addi.d	t8, t8, -1
	bnez	t8, loop_most_loop
	nop

  	lu12i.w t4, 1		 #get imm 1<<12
  	addi.d	t4, t4, -1
  	and	t7, t7, t4

loop_less:
	XVLD( 0, 5, 0)
	XVLD( 1, 5, 32)
	XVLD( 2, 5, 64)
	XVLD( 3, 5, 96)
	XVST( 0, 4, 0)
	XVST( 1, 4, 32)
	XVST( 2, 4, 64)
	XVST( 3, 4, 96)
	addi.d	a0,  a0,  0x80
	addi.d	a1,  a1,  0x80
	addi.d	t7, t7,	  -0x80
	slt	t8, t7,	  zero
	beqz	t8, loop_less
	nop
	XVST(19, 14, -128)
	XVST(18, 14, -96)
	XVST(17, 14, -64)
	XVST(16, 14, -32)

	move	v0, t0
	jr	ra
	nop

END(MEMCPY_NAME)
#ifndef ANDROID_CHANGES
#ifdef _LIBC
libc_hidden_builtin_def (MEMCPY_NAME)
#endif
#endif

#endif
