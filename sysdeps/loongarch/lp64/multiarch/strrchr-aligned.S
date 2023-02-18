
#if IS_IN (libc)

#define STRRCHR_NAME __strrchr_aligned

#endif

#include "../strrchr.S"
