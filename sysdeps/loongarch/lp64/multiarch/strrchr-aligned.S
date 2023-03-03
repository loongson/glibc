
#if IS_IN (libc)

#define STRRCHR_NAME __strrchr_aligned

#endif

#include "../strrchr.S"

#undef rindex
weak_alias(STRRCHR_NAME, rindex)

