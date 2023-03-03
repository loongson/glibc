
#if IS_IN (libc)

#define MEMCMP_NAME __memcmp_aligned

#endif

#include "../memcmp.S"
# undef bcmp
weak_alias (MEMCMP_NAME, bcmp)

