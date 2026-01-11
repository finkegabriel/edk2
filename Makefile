ARCH            := aarch64
CROSS_COMPILE   := aarch64-linux-gnu-

CC       := $(CROSS_COMPILE)gcc
LD       := $(CROSS_COMPILE)ld
OBJCOPY  := $(CROSS_COMPILE)objcopy

EFIINC   := /usr/include/efi
EFIARCH  := $(EFIINC)/arm64
EFILIB   := /usr/lib/gnu-efi/arm64
CRT0     := $(EFILIB)/crt0-efi-aarch64.o

# Auto-detect linker script
LDSCRIPT := $(shell find /usr/lib/gnu-efi -name 'elf_*_efi.lds' | head -n 1)

CFLAGS   := -I$(EFIINC) -I$(EFIARCH) \
            -fpic -fshort-wchar \
            -Wall -Wextra

TARGET   := BOOTAA64.EFI

all: checklds $(TARGET)

checklds:
	@test -n "$(LDSCRIPT)" || (echo "ERROR: EFI linker script not found"; exit 1)
	@echo "Using linker script: $(LDSCRIPT)"

main.o: main.c
	$(CC) $(CFLAGS) -c $< -o $@

main.so: main.o
	$(LD) -shared -Bsymbolic \
	      $(CRT0) main.o \
	      -T $(LDSCRIPT) \
	      -o $@

$(TARGET): main.so
	$(OBJCOPY) \
	  -j .text -j .sdata -j .data -j .dynamic \
	  -j .dynsym -j .rel -j .rela -j .reloc \
	  --target=efi-app-$(ARCH) \
	  $< $@

clean:
	rm -f *.o *.so $(TARGET)
