

#if IS_IN (libc)

#define MEMCPY_NAME __memcpy_aligned
#define MEMMOVE_NAME __memmove_aligned

#endif

#include "../memcpy.S"

