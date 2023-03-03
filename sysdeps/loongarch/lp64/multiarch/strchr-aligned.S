
#if IS_IN (libc)

#define STRCHR_NAME __strchr_aligned

#endif

#include "../strchr.S"

weak_alias (STRCHR_NAME, index)
