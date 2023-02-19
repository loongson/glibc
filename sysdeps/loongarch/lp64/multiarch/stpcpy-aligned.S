
#if IS_IN (libc)

#define STPCPY_NAME __stpcpy_aligned

#endif

#include "../stpcpy.S"
