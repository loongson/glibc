
#if IS_IN (libc)

#define STRNCMP __strncmp_aligned

#endif

#include "../strncmp.S"
