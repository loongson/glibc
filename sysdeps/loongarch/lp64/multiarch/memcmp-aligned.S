
#if IS_IN (libc)

#define MEMCMP_NAME __memcmp_aligned

#endif

#include "../memcmp.S"

