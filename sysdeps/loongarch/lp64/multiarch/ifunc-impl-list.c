/* Enumerate available IFUNC implementations of a function.  LoongArch64 version.
   Copyright (C) 2017-2018 Free Software Foundation, Inc.
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
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */

#include <assert.h>
#include <string.h>
#include <wchar.h>
#include <ldsodefs.h>
#include <ifunc-impl-list.h>
#include <init-arch.h>
#include <stdio.h>

/* Maximum number of IFUNC implementations.  */
#define MAX_IFUNC	4

size_t
__libc_ifunc_impl_list (const char *name, struct libc_ifunc_impl *array,
			size_t max)
{
  assert (max >= MAX_IFUNC);

  size_t i = 0;

  IFUNC_IMPL (i, name, memcpy,
	      IFUNC_IMPL_ADD (array, i, memcpy, 1, __memcpy_lasx)
	      IFUNC_IMPL_ADD (array, i, memcpy, 1, __memcpy_lsx)
	      IFUNC_IMPL_ADD (array, i, memcpy, 1, __memcpy_aligned)
	      IFUNC_IMPL_ADD (array, i, memcpy, 1, __memcpy_unaligned)
	      )

  IFUNC_IMPL (i, name, memmove,
	      IFUNC_IMPL_ADD (array, i, memmove, 1, __memmove_lasx)
	      IFUNC_IMPL_ADD (array, i, memmove, 1, __memmove_lsx)
	      IFUNC_IMPL_ADD (array, i, memmove, 1, __memmove_aligned)
	      IFUNC_IMPL_ADD (array, i, memmove, 1, __memmove_unaligned)
	      )

  IFUNC_IMPL (i, name, memset,
	      IFUNC_IMPL_ADD (array, i, memset, 1, __memset_lasx)
	      IFUNC_IMPL_ADD (array, i, memset, 1, __memset_lsx)
	      IFUNC_IMPL_ADD (array, i, memset, 1, __memset_aligned)
	      IFUNC_IMPL_ADD (array, i, memset, 1, __memset_unaligned)
	      )

  IFUNC_IMPL (i, name, memchr,
	      IFUNC_IMPL_ADD (array, i, memchr, 1, __memchr_lasx)
	      IFUNC_IMPL_ADD (array, i, memchr, 1, __memchr_lsx)
	      IFUNC_IMPL_ADD (array, i, memchr, 1, __memchr_aligned)
	      )

  IFUNC_IMPL (i, name, memrchr,
	      IFUNC_IMPL_ADD (array, i, memrchr, 1, __memrchr_lasx)
	      IFUNC_IMPL_ADD (array, i, memrchr, 1, __memrchr_lsx)
	      IFUNC_IMPL_ADD (array, i, memrchr, 1, __memrchr_generic)
	      )

  IFUNC_IMPL (i, name, memcmp,
	      IFUNC_IMPL_ADD (array, i, memcmp, 1, __memcmp_lasx)
	      IFUNC_IMPL_ADD (array, i, memcmp, 1, __memcmp_lsx)
	      IFUNC_IMPL_ADD (array, i, memcmp, 1, __memcmp_aligned)
	      )

  IFUNC_IMPL (i, name, rawmemchr,
	      IFUNC_IMPL_ADD (array, i, rawmemchr, 1, __rawmemchr_lasx)
	      IFUNC_IMPL_ADD (array, i, rawmemchr, 1, __rawmemchr_lsx)
	      IFUNC_IMPL_ADD (array, i, rawmemchr, 1, __rawmemchr_aligned)
	      )

  IFUNC_IMPL (i, name, strchr,
	      IFUNC_IMPL_ADD (array, i, strchr, 1, __strchr_lasx)
	      IFUNC_IMPL_ADD (array, i, strchr, 1, __strchr_lsx)
	      IFUNC_IMPL_ADD (array, i, strchr, 1, __strchr_aligned)
	      IFUNC_IMPL_ADD (array, i, strchr, 1, __strchr_unaligned)
	      )

  IFUNC_IMPL (i, name, strrchr,
	      IFUNC_IMPL_ADD (array, i, strrchr, 1, __strrchr_lasx)
	      IFUNC_IMPL_ADD (array, i, strrchr, 1, __strrchr_lsx)
	      IFUNC_IMPL_ADD (array, i, strrchr, 1, __strrchr_aligned)
	      )

  IFUNC_IMPL (i, name, strlen,
	      IFUNC_IMPL_ADD (array, i, strlen, 1, __strlen_lasx)
	      IFUNC_IMPL_ADD (array, i, strlen, 1, __strlen_lsx)
	      IFUNC_IMPL_ADD (array, i, strlen, 1, __strlen_aligned)
	      IFUNC_IMPL_ADD (array, i, strlen, 1, __strlen_unaligned)
	      )

  IFUNC_IMPL (i, name, strnlen,
	      IFUNC_IMPL_ADD (array, i, strnlen, 1, __strnlen_lasx)
	      IFUNC_IMPL_ADD (array, i, strnlen, 1, __strnlen_lsx)
	      IFUNC_IMPL_ADD (array, i, strnlen, 1, __strnlen_aligned)
	      IFUNC_IMPL_ADD (array, i, strnlen, 1, __strnlen_unaligned)
	      )

  IFUNC_IMPL (i, name, strchrnul,
	      IFUNC_IMPL_ADD (array, i, strchrnul, 1, __strchrnul_lasx)
	      IFUNC_IMPL_ADD (array, i, strchrnul, 1, __strchrnul_lsx)
	      IFUNC_IMPL_ADD (array, i, strchrnul, 1, __strchrnul_aligned)
	      IFUNC_IMPL_ADD (array, i, strchrnul, 1, __strchrnul_unaligned)
	      )

  IFUNC_IMPL (i, name, strncmp,
	      IFUNC_IMPL_ADD (array, i, strncmp, 1, __strncmp_lsx)
	      IFUNC_IMPL_ADD (array, i, strncmp, 1, __strncmp_aligned)
	      IFUNC_IMPL_ADD (array, i, strncmp, 1, __strncmp_unaligned)
	      )

  IFUNC_IMPL (i, name, strcpy,
	      IFUNC_IMPL_ADD (array, i, strcpy, 1, __strcpy_lsx)
	      IFUNC_IMPL_ADD (array, i, strcpy, 1, __strcpy_aligned)
	      IFUNC_IMPL_ADD (array, i, strcpy, 1, __strcpy_unaligned)
	      )

  IFUNC_IMPL (i, name, stpcpy,
	      IFUNC_IMPL_ADD (array, i, stpcpy, 1, __stpcpy_lsx)
	      IFUNC_IMPL_ADD (array, i, stpcpy, 1, __stpcpy_aligned)
	      )

  IFUNC_IMPL (i, name, strcmp,
	      IFUNC_IMPL_ADD (array, i, strcmp, 1, __strcmp_lsx)
	      IFUNC_IMPL_ADD (array, i, strcmp, 1, __strcmp_aligned)
	      IFUNC_IMPL_ADD (array, i, strcmp, 1, __strcmp_unaligned)
	      )

  return i;
}

