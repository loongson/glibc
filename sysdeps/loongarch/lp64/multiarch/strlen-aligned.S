
#if IS_IN (libc)

#define STRLEN __strlen_aligned

#endif

#include "../strlen.S"
