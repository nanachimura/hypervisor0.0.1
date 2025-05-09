#!/usr/bin/env bash
set -euo pipefail

# Пути
GCC=/c/msys64/mingw64/bin/x86_64-w64-mingw32-gcc
LD=/c/msys64/mingw64/bin/x86_64-w64-mingw32-ld
OBJCOPY=/c/msys64/mingw64/bin/x86_64-w64-mingw32-objcopy

# Флаги
CFLAGS="-ffreestanding -m64 -Iinclude"
LDFLAGS="-T linker.ld -nostdlib -static"

# Чистим и готовим папку
rm -rf build
mkdir -p build

# 1) Ассемблерные модули (GAS, AT&T‐стиль)
for f in boot.S vmx.S guest_stub.S monitor.S; do
  echo "GCC-ASM → $f"
  "$GCC" -x assembler-with-cpp $CFLAGS -c src/$f -o build/"${f%.S}.o"
done

# 2) C‐модули
for f in utils.c vmx.c pci.c keyboard.c; do
  echo "GCC-C   → $f"
  "$GCC" $CFLAGS -c src/$f -o build/"${f%.c}.o"
done

# 3) Линковка
echo "LD      → kernel.elf"
"$LD" $LDFLAGS build/*.o -o build/kernel.elf

# 4) raw-bin
echo "OBJCOPY → kernel.bin"
"$OBJCOPY" -O binary build/kernel.elf build/kernel.bin

echo "Сборка завершена: build/kernel.bin"
