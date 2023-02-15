
#if IS_IN (libc)
#define MEMCHR_NAME __memchr_aligned
#endif

#include "../memchr.S"

