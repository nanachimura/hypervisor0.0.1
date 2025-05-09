# Makefile для гипервизора

# Путь до тулчейна
CC      := /c/msys64/mingw64/bin/x86_64-w64-mingw32-gcc
LD      := /c/msys64/mingw64/bin/x86_64-w64-mingw32-ld
OBJCOPY := /c/msys64/mingw64/bin/x86_64-w64-mingw32-objcopy
NASM    := /c/msys64/mingw64/bin/nasm

# Флаги
CFLAGS  := -ffreestanding -m64 -Iinclude
LDFLAGS := -T linker.ld -nostdlib -static

# Исходники
ASM_SRC := boot.S vmx.S guest_stub.S monitor.S
C_SRC   := utils.c vmx.c pci.c keyboard.c

# Объекты
ASM_OBJ := $(ASM_SRC:%.S=build/%.o)
C_OBJ   := $(C_SRC:%.c=build/%.o)
OBJ     := $(ASM_OBJ) $(C_OBJ)

# Главная цель
all: build/kernel.bin

# Правило для .S через NASM
build/%.o: src/%.S
<tab>@mkdir -p build
<tab>$(NASM) -f elf64 -i src/ -o $@ $<

# Правило для .c через GCC
build/%.o: src/%.c
<tab>@mkdir -p build
<tab>$(CC) $(CFLAGS) -c $< -o $@

# Линковка ELF
build/kernel.elf: $(OBJ) linker.ld
<tab>$(LD) $(LDFLAGS) $(OBJ) -o $@

# Перевод в raw binary
build/kernel.bin: build/kernel.elf
<tab>$(OBJCOPY) -O binary $< $@

# Очистка
clean:
<tab>rm -rf build

.PHONY: all clean
