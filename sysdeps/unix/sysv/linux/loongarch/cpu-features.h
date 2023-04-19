/* Initialize CPU feature data.  LoongArch64 version.
   This file is part of the GNU C Library.
   Copyright (C) 2022 Free Software Foundation, Inc.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */

#ifndef _CPU_FEATURES_LOONGARCH64_H
#define _CPU_FEATURES_LOONGARCH64_H

#include <stdint.h>
#include <sys/auxv.h>

#define LA264 0x14a000
#define LA364 0x14b000
#define LA464 0x14c011

struct cpu_features
{
  uint64_t cpucfg_prid;
  uint64_t cpucfg_word_idx2;
};

/* Get a pointer to the CPU features structure.  */
extern const struct cpu_features *_dl_larch_get_cpu_features (void)
     __attribute__ ((pure));

#define __cpucfg(ret, index)  \
  asm volatile ("or	%1, %0, $zero\n"	\
		"cpucfg %0, %0\n"		\
		:"=r"(ret)			\
		:"r"(index));

#define IS_LA264(prid) (prid == LA264)
#define IS_LA364(prid) (prid == LA364)
#define IS_LA464(prid) (prid == LA464)
#define SUPPORT_UAL (GLRO (dl_hwcap) & HWCAP_LOONGARCH_UAL)
#define SUPPORT_LSX (GLRO (dl_hwcap) & HWCAP_LOONGARCH_LSX)
#define SUPPORT_LASX (GLRO (dl_hwcap) & HWCAP_LOONGARCH_LASX)

#endif /* _CPU_FEATURES_LOONGARCH64_H  */

