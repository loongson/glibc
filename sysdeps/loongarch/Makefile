ifeq ($(subdir),misc)
sysdep_headers += sys/asm.h
endif

# LoongArch's assembler also needs to know about PIC as it changes the definition
# of some assembler macros.
ASFLAGS-.os += $(pic-ccflag)
CFLAGS-elf-init.oS += -mcmodel=large
CFLAGS-atexit.oS += -mcmodel=large
CFLAGS-at_quick_exit.oS += -mcmodel=large
CFLAGS-stat.oS += -mcmodel=large
CFLAGS-fstat.oS += -mcmodel=large
CFLAGS-lstat.oS += -mcmodel=large
CFLAGS-stat64.oS += -mcmodel=large
CFLAGS-fstat64.oS += -mcmodel=large
CFLAGS-lstat64.oS += -mcmodel=large
CFLAGS-fstatat.oS += -mcmodel=large
CFLAGS-fstatat64.oS += -mcmodel=large
CFLAGS-mknod.oS += -mcmodel=large
CFLAGS-mknodat.oS += -mcmodel=large
CFLAGS-pthread_atfork.oS += -mcmodel=large
CFLAGS-warning-nop.oS += -mcmodel=large
CFLAGS-stack_chk_fail_local.oS += -mcmodel=large

abi-variants := lp32 lp64

ifeq (,$(filter $(default-abi),$(abi-variants)))
$(error Unknown ABI $(default-abi), must be one of $(abi-variants))
endif

abi-lp64-condition    := defined _ABILP64
abi-lp32-condition    := defined _ABILP32
