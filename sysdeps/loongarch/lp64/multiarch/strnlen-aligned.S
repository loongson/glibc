
#if IS_IN (libc)

#define STRNLEN __strnlen_aligned

#endif

#include "../strnlen.S"
