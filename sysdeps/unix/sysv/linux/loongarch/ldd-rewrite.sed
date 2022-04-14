/LD_TRACE_LOADED_OBJECTS=1/a\
add_env="$add_env LD_LIBRARY_VERSION=\\$verify_out"
s_^\(RTLDLIST=\)\(.*lib\)\(\|64\|32\)\(/[^/]*\)\(-loongarch\)\(64\|32\)\(\.so\.[0-9.]*\)[[:blank:]]*$_\1"\2\4\7 \264\4-loongarch64\7 \232\4-loongarch32\7"_
