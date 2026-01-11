ARCH            := aarch64
CROSS_COMPILE   := aarch64-linux-gnu-

CC       := $(CROSS_COMPILE)gcc
LD       := $(CROSS_COMPILE)ld
OBJCOPY  := $(CROSS_COMPILE)objcopy

EFIINC   := /usr/include/efi
EFIARCH  := $(EFIINC)/arm64

# Possible gnu-efi library roots (Ubuntu, Debian, multiarch)
GNUEFI_DIRS := \
  /usr/lib/aarch64-linux-gnu/gnu-efi \
  /usr/lib/gnu-efi \
  /usr/lib64/gnu-efi \
  /usr/lib

CRT0 := $(firstword $(wildcard \
  $(addsuffix /crt0-efi-aarch64.o,$(GNUEFI_DIRS))))

LDSCRIPT := $(firstword $(wildcard \
  $(addsuffix /elf_*_efi.lds,$(GNUEFI_DIRS))))

CFLAGS   := -I$(EFIINC) -I$(EFIARCH) \
            -fpic -fshort-wchar \
            -Wall -Wextra

TARGET   := BOOTAA64.EFI

all: check $(TARGET)

check:
	@test -n "$(CRT0)" || (echo "ERROR: crt0-efi-aarch64.o not found"; exit 1)
	@test -n "$(LDSCRIPT)" || (echo "ERROR: EFI linker script not found"; exit 1)
	@echo "Using CRT0: $(CRT0)"
	@echo "Using LDSCRIPT: $(LDSCRIPT)"

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
