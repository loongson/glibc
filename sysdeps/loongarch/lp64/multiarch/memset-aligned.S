
#if IS_IN (libc)

#ifndef MEMSET_NAME
#define MEMSET_NAME __memset_aligned
#endif

#endif

#include "../memset.S"

