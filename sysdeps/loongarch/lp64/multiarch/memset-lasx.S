#ifdef _LIBC
#include <sysdep.h>
#include <sys/regdef.h>
#include <sys/asm.h>
#else
#include <sys/asm.h>
#include <sys/regdef.h>
#endif

#define XVXOR_V(xd,xj,xk)       .word(0x1d<<26|0x09<<21|0x0E<<15|(xk&0x1f)<<10|(xj&0x1f)<<5|(xd&0x1f))
#define XVREPLVE0_B(xd,xj)      .word(0x1d<<26|0x18<<21|0x0E<<15|0x0<<10|(xj&0x1f)<<5|(xd&0x1f))
#define XVST(xd,rj,si12)        .word(0x0b<<26|0x3<<22|(si12&0xfff)<<10|(rj&0x1f)<<5|(xd&0x1f))
#define VST(vd,rj,si12)         .word(0x0b<<26|0x1<<22|(si12&0xfff)<<10|(rj&0x1f)<<5|(vd&0x1f))
#define VSTELM_D(vd,rj,si8,idx) .word(0x31<<24|0x2<<19|(idx&0x1)<<18|(si8&0xff)<<10|(rj&0x1f)<<5|(vd&0x1f))
#define VSTELM_W(vd,rj,si8,idx) .word(0x31<<24|0x2<<20|(idx&0x3)<<18|(si8&0xff)<<10|(rj&0x1f)<<5|(vd&0x1f))
#define VSTELM_H(vd,rj,si8,idx) .word(0x31<<24|0x2<<21|(idx&0x7)<<18|(si8&0xff)<<10|(rj&0x1f)<<5|(vd&0x1f))
#define VSTELM_B(vd,rj,si8,idx) .word(0x31<<24|0x2<<22|(idx&0xf)<<18|(si8&0xff)<<10|(rj&0x1f)<<5|(vd&0x1f))

//offset(10b) -> si12

//1st var: void *str  $4 a0
//2nd var: int val  $5   a1
//3rd var: size_t num  $6  a2

#if IS_IN (libc)

/* Allow the routine to be named something else if desired.  */
#ifndef MEMSET_NAME
#define MEMSET_NAME __memset_lasx
#endif

#ifdef ANDROID_CHANGES
LEAF(MEMSET_NAME, 0)
#else
LEAF(MEMSET_NAME)
#endif

	.align	6
	XVXOR_V(0,0,0)
	XVXOR_V(1,1,1)
  	#dmtc1	a1, $f1  # 32bit, 2nd var; or use FILL.d inst  ###use FILL.d inst, replacing dmtc1 inst probably needs multiple insts
  	#FILL.D $w0, a1
  	#XVREPLGR2VR.B $w1, a1
  	.word(0x1da7c0<<10|(0x5&0x1f)<<5|(0x1&0x1f))

	add.d	t7, a0, a2 # dest, 1st var, 3rd var
	move	t0, a0      # $2, func return value  "v0->a0 v1->a1" need another register to store original parameters
	XVREPLVE0_B(0,1)  # w0 <- w1
	srai.d	t8, a2, 4  #num/16
	beqz	t8, less_16bytes       # num<16
	nop
	srai.d	t8, a2, 8  #num/256
	bnez	t8, eqormore_256bytes  #num>256
	nop
	srai.d	t8, a2, 7
	beqz	t8, less_128bytes	#num<128_
	nop
	XVST( 0, 4, 0 )  # 128<num<256
	XVST( 0, 4, 32 )
	XVST( 0, 4, 64 )
	XVST( 0, 4, 96 )
	XVST( 0, 19, -128 )
	XVST( 0, 19, -96 )
	XVST( 0, 19, -64 )
	XVST( 0, 19, -32 )

	jr	ra
	nop

less_128bytes:
	srai.d	t8, a2, 6  #num/64
	beqz	t8, less_64bytes
	nop
	XVST( 0, 4, 0 )
	XVST( 0, 4, 32 )
	XVST( 0, 19, -64 )
	XVST( 0, 19, -32 )

	jr	ra
	nop

less_64bytes:
	srai.d	t8, a2, 5 #num/32
	beqz	t8, less_32bytes
	nop
	XVST( 0, 4, 0 )
	XVST( 0, 19, -32 )

	jr	ra
	nop

less_32bytes:
	VST( 0, 4, 0 )
	VST( 0, 19, -16 )
	jr	ra
	nop

less_16bytes:
	srai.d	t8, a2, 3 #num/8
	beqz	t8, less_8bytes
	nop
	//sdc1	$f0, 0(a0)	#store lower 8bytes to mem
	//sdc1	$f0, -8($15)	#store lower 8bytes to mem
	VSTELM_D (0, 4,  0,  0)      #store lower 8bytes to mem
	VSTELM_D (0, 19, -1, 0)	#store lower 8bytes to mem
	jr	ra
	nop

less_8bytes:
	srai.d	t8, a2, 2
	beqz	t8, less_4bytes
	nop
	//swc1	$f0, 0(a0)	#store lower 4bytes to mem
	//swc1	$f0, -4($15)	#store lower 4bytes to mem
	VSTELM_W (0, 4,  0,  0)      #store lower 4bytes to mem
	VSTELM_W (0, 19, -1, 0)	#store lower 4bytes to mem
	jr	ra
	nop

less_4bytes:
	//mfc1	$25, $f0   #uesless
	srai.d	t8, a2, 1
	beqz	t8, less_2bytes
	nop
	//sh	$25, 0(a0)	#store lower 2bytes to mem
	//sh	$25, -2($15)	#store lower 2bytes to mem
	VSTELM_H (0, 4,  0,  0)      #store lower 2bytes to mem
	VSTELM_H (0, 19, -1, 0)	#store lower 2bytes to mem
	jr	ra
	nop

less_2bytes:
	//beqz	t8, less_1bytes
	beqz	a2, less_1bytes
	nop
	//sb	$25, 0(a0)	#store lower 1bytes to mem
	VSTELM_B (0, 4,  0,  0)      #store lower 1bytes to mem
	jr	ra
	nop

less_1bytes:
	jr	ra
	nop


eqormore_256bytes:
	// andi	a0, a0, -0x20
	srli.d	a0, a0, 5
	slli.d	a0, a0, 5     # a0:
	addi.d	a0, a0,  0x20  #align to 32   no implememt for daddi
	XVST( 0, 12, 0 )    # unaligned data
	sub.d	t2, t0,  a0    # $2:start addr a0 > t0   t0-a0 < 0  no operation for overflow
	add.d	t2, t2, a2     # a2:num
	addi.d	t2, t2, -0x80    # used in loop_less
	srai.d	t8, t2, 12     #t2/4096
	beqz	t8, loop_less
	nop

loop_more:                   # t8 >0
	XVST( 0, 4, 0 )
	XVST( 0, 4, 32 )
	XVST( 0, 4, 64 )
	XVST( 0, 4, 96 )
	XVST( 0, 4, 128 )
	XVST( 0, 4, 160 )
	XVST( 0, 4, 192 )
	XVST( 0, 4, 224 )
	XVST( 0, 4, 256 )
	XVST( 0, 4, 288 )
	XVST( 0, 4, 320 )
	XVST( 0, 4, 352 )
	XVST( 0, 4, 384 )
	XVST( 0, 4, 416 )
	XVST( 0, 4, 448 )
	XVST( 0, 4, 480 )
	addi.d	a0,  a0,   512   #1
	XVST( 0, 4, 0 )
	XVST( 0, 4, 32 )
	XVST( 0, 4, 64 )
	XVST( 0, 4, 96 )
	XVST( 0, 4, 128 )
	XVST( 0, 4, 160 )
	XVST( 0, 4, 192 )
	XVST( 0, 4, 224 )
	XVST( 0, 4, 256 )
	XVST( 0, 4, 288 )
	XVST( 0, 4, 320 )
	XVST( 0, 4, 352 )
	XVST( 0, 4, 384 )
	XVST( 0, 4, 416 )
	XVST( 0, 4, 448 )
	XVST( 0, 4, 480 )
	addi.d	a0,  a0,   512  #2
	XVST( 0, 4, 0 )
	XVST( 0, 4, 32 )
	XVST( 0, 4, 64 )
	XVST( 0, 4, 96 )
	XVST( 0, 4, 128 )
	XVST( 0, 4, 160 )
	XVST( 0, 4, 192 )
	XVST( 0, 4, 224 )
	XVST( 0, 4, 256 )
	XVST( 0, 4, 288 )
	XVST( 0, 4, 320 )
	XVST( 0, 4, 352 )
	XVST( 0, 4, 384 )
	XVST( 0, 4, 416 )
	XVST( 0, 4, 448 )
	XVST( 0, 4, 480 )
	addi.d	a0,  a0,   512  #3
	XVST( 0, 4, 0 )
	XVST( 0, 4, 32 )
	XVST( 0, 4, 64 )
	XVST( 0, 4, 96 )
	XVST( 0, 4, 128 )
	XVST( 0, 4, 160 )
	XVST( 0, 4, 192 )
	XVST( 0, 4, 224 )
	XVST( 0, 4, 256 )
	XVST( 0, 4, 288 )
	XVST( 0, 4, 320 )
	XVST( 0, 4, 352 )
	XVST( 0, 4, 384 )
	XVST( 0, 4, 416 )
	XVST( 0, 4, 448 )
	XVST( 0, 4, 480 )
	addi.d	a0,  a0,   512  #4
	XVST( 0, 4, 0 )
	XVST( 0, 4, 32 )
	XVST( 0, 4, 64 )
	XVST( 0, 4, 96 )
	XVST( 0, 4, 128 )
	XVST( 0, 4, 160 )
	XVST( 0, 4, 192 )
	XVST( 0, 4, 224 )
	XVST( 0, 4, 256 )
	XVST( 0, 4, 288 )
	XVST( 0, 4, 320 )
	XVST( 0, 4, 352 )
	XVST( 0, 4, 384 )
	XVST( 0, 4, 416 )
	XVST( 0, 4, 448 )
	XVST( 0, 4, 480 )
	addi.d	a0,  a0,   512  #5
	XVST( 0, 4, 0 )
	XVST( 0, 4, 32 )
	XVST( 0, 4, 64 )
	XVST( 0, 4, 96 )
	XVST( 0, 4, 128 )
	XVST( 0, 4, 160 )
	XVST( 0, 4, 192 )
	XVST( 0, 4, 224 )
	XVST( 0, 4, 256 )
	XVST( 0, 4, 288 )
	XVST( 0, 4, 320 )
	XVST( 0, 4, 352 )
	XVST( 0, 4, 384 )
	XVST( 0, 4, 416 )
	XVST( 0, 4, 448 )
	XVST( 0, 4, 480 )
	addi.d	a0,  a0,   512  #6
	XVST( 0, 4, 0 )
	XVST( 0, 4, 32 )
	XVST( 0, 4, 64 )
	XVST( 0, 4, 96 )
	XVST( 0, 4, 128 )
	XVST( 0, 4, 160 )
	XVST( 0, 4, 192 )
	XVST( 0, 4, 224 )
	XVST( 0, 4, 256 )
	XVST( 0, 4, 288 )
	XVST( 0, 4, 320 )
	XVST( 0, 4, 352 )
	XVST( 0, 4, 384 )
	XVST( 0, 4, 416 )
	XVST( 0, 4, 448 )
	XVST( 0, 4, 480 )
	addi.d	a0,  a0,   512  #7
	XVST( 0, 4, 0 )
	XVST( 0, 4, 32 )
	XVST( 0, 4, 64 )
	XVST( 0, 4, 96 )
	XVST( 0, 4, 128 )
	XVST( 0, 4, 160 )
	XVST( 0, 4, 192 )
	XVST( 0, 4, 224 )
	XVST( 0, 4, 256 )
	XVST( 0, 4, 288 )
	XVST( 0, 4, 320 )
	XVST( 0, 4, 352 )
	XVST( 0, 4, 384 )
	XVST( 0, 4, 416 )
	XVST( 0, 4, 448 )
	XVST( 0, 4, 480 )
	addi.d	a0,  a0,   512  #8
	addi.d	t8, t8, -1
	bnez	t8, loop_more
	nop
  #andi	t2, t2, 4095   replaced with two insts
  lu12i.w t3, 1        #get imm 1<<12
  addi.d t3, t3, -1
  and t2, t2, t3

loop_less:			# t8 = 0
	XVST( 0, 4, 0 )
	XVST( 0, 4, 32 )
	XVST( 0, 4, 64 )
	XVST( 0, 4, 96 )
	addi.d	a0,  a0,   0x80
	addi.d	t2, t2, -0x80
	slt	t8, t2, zero
	beqz	t8, loop_less
	nop
	XVST( 0, 19, -128 )
	XVST( 0, 19, -96 )
	XVST( 0, 19, -64 )
	XVST( 0, 19, -32 )

  move	v0, t0  #change a0 only in eqormore_256bytes fragmemt, need restore from t0
	jr	ra
	nop
END(MEMSET_NAME)

#ifndef ANDROID_CHANGES
#ifdef _LIBC
libc_hidden_builtin_def (MEMSET_NAME)
#endif
#endif

#endif
