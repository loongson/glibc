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

#include <cpu-features.h>
#include <elf/dl-hwcaps.h>

static inline void
init_cpu_features (struct cpu_features *cpu_features)
{
  register uint64_t cpucfg_word = UINT64_MAX;

  __cpucfg(cpucfg_word, 0);
  cpu_features->cpucfg_prid = cpucfg_word;

  __cpucfg(cpucfg_word, 2);
  cpu_features->cpucfg_word_idx2 = cpucfg_word;
}
