
#if IS_IN (libc)

#define MEMRCHR __memrchr_generic

#endif

#include <string/memrchr.c>
weak_alias (__memrchr_generic, __memrchr)
