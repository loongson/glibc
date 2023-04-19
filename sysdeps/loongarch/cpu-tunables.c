/* LoongArch CPU feature tuning.
   This file is part of the GNU C Library.
   Copyright (C) 2017-2018 Free Software Foundation, Inc.

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

#if HAVE_TUNABLES
# define TUNABLE_NAMESPACE cpu
# include <stdbool.h>
# include <stdint.h>
# include <unistd.h>		/* Get STDOUT_FILENO for _dl_printf.  */
# include <elf/dl-tunables.h>
# include <string.h>
# include <cpu-features.h>
# include <ldsodefs.h>
# include <sys/auxv.h>

# define HWCAP_LOONGARCH_IFUNC \
  (HWCAP_LOONGARCH_UAL | HWCAP_LOONGARCH_LSX | HWCAP_LOONGARCH_LASX)

# define CHECK_GLIBC_IFUNC_CPU_OFF(f, name, len)			\
  if (!memcmp (f, #name, len))						\
    {									\
      if ((GLRO (dl_hwcap) & HWCAP_LOONGARCH_##name))			\
      {									\
	GLRO (dl_hwcap) &= (HWCAP_LOONGARCH_##name |			\
			   (~HWCAP_LOONGARCH_IFUNC));			\
	return;								\
      }									\
      else								\
	_dl_fatal_printf ("%s is not supported on this machine!!\n",	\
			#name);						\
    }

attribute_hidden
void
TUNABLE_CALLBACK (set_hwcaps) (tunable_val_t *valp)
{
  const char *p = valp->strval;
  size_t len;

  len = strlen(p);

  CHECK_GLIBC_IFUNC_CPU_OFF (p, LSX, len);
  CHECK_GLIBC_IFUNC_CPU_OFF (p, UAL, len);
  CHECK_GLIBC_IFUNC_CPU_OFF (p, LASX, len);

  _dl_fatal_printf ("The valid values of glibc.cpu.hwcaps is UAL, LASX, LSX!!\n"
	);
}

#endif
