
#if IS_IN (libc)

#define STRCPY __strcpy_aligned

#endif

#include "../strcpy.S"
