

#if IS_IN (libc)

#ifndef MEMCPY_NAME
#define MEMCPY_NAME __memcpy_aligned
#endif

#ifndef MEMMOVE_NAME
#define MEMMOVE_NAME __memmove_aligned
#endif

#endif

#include "../memcpy.S"

