ifeq ($(subdir),misc)
sysdep_headers += sys/asm.h
endif

# LoongArch's assembler also needs to know about PIC as it changes the definition
# of some assembler macros.
ASFLAGS-.os += $(pic-ccflag)

abi-variants := lp32 lp64

ifeq (,$(filter $(default-abi),$(abi-variants)))
$(error Unknown ABI $(default-abi), must be one of $(abi-variants))
endif

abi-lp64-condition    := defined _ABILP64
abi-lp32-condition    := defined _ABILP32
