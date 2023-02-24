
#if IS_IN (libc)

#define MEMSET_NAME __memset_aligned

#endif

#include "../memset.S"

