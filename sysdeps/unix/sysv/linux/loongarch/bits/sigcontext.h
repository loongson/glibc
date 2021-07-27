/* Copyright (C) 2021 Free Software Foundation, Inc.
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
   <http://www.gnu.org/licenses/>.  */

#ifndef _BITS_SIGCONTEXT_H
#define _BITS_SIGCONTEXT_H

/*
 * Keep this struct definition in sync with the sigcontext fragment
 * in arch/loongarch/kernel/asm-offsets.c
 *
 * Warning: this structure illdefined with sc_badvaddr being just an unsigned
 * int so it was changed to unsigned long in 2.6.0-test1.  This may break
 * binary compatibility - no prisoners.
 * DSP ASE in 2.6.12-rc4.  Turn sc_mdhi and sc_mdlo into an array of four
 * entries, add sc_dsp and sc_reserved for padding.  No prisoners.
 */

#define FPU_REG_WIDTH           256
#define FPU_ALIGN               __attribute__((aligned(32)))

struct sigcontext {
    unsigned long long   sc_pc;
    unsigned long long    sc_regs[32];
    unsigned int   sc_flags;

    unsigned int   sc_fcsr;
    unsigned int   sc_vcsr;
    unsigned long long    sc_fcc;

    unsigned long long    sc_scr[4];

    union {
                unsigned int        val32[FPU_REG_WIDTH / 32];
                unsigned long long  val64[FPU_REG_WIDTH / 64];
        } sc_fpregs[32] FPU_ALIGN;
    unsigned char   sc_reserved[4096] __attribute__((__aligned__(16)));

};


#endif /* _BITS_SIGCONTEXT_H */
