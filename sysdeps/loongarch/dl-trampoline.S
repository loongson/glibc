/* PLT trampolines.
   Copyright (C) 2022-2023 Free Software Foundation, Inc.
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

#define USE_LASX
#define _dl_runtime_resolve _dl_runtime_resolve_lasx
#include "dl-trampoline.h"
#undef USE_LASX
#undef _dl_runtime_resolve

#define USE_LSX
#define _dl_runtime_resolve _dl_runtime_resolve_lsx
#include "dl-trampoline.h"
#undef USE_LSX
#undef _dl_runtime_resolve

#include "dl-trampoline.h"
