/* Machine-dependent signal context structure for Linux.
   Copyright (C) 2021 Free Software Foundation, Inc.
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

#ifndef _BITS_SIGCONTEXT_H
#define _BITS_SIGCONTEXT_H

#if !defined _SIGNAL_H && !defined _SYS_UCONTEXT_H
# error "Never use <bits/sigcontext.h> directly; include <signal.h> instead."
#endif

#define FPU_REG_WIDTH 256
#define FPU_ALIGN __attribute__ ((aligned (32)))

struct sigcontext
{
  unsigned long long sc_pc;
  unsigned long long sc_regs[32];
  unsigned int sc_flags;

  unsigned int sc_fcsr;
  unsigned int sc_vcsr;
  unsigned long long sc_fcc;

  /* For Binary Translation */
  unsigned long long sc_scr[4];
  unsigned int sc_eflags;

  union
  {
    unsigned int val32[FPU_REG_WIDTH / 32];
    unsigned long long val64[FPU_REG_WIDTH / 64];
  } sc_fpregs[32] FPU_ALIGN;

  /* Reserved for future scalable vectors */
  unsigned int sc_svsize;
  unsigned long long sc_svregs[0] __attribute__((__aligned__(16)));
};

#endif /* _BITS_SIGCONTEXT_H */
