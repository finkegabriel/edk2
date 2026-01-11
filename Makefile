ARCH            := aarch64
CROSS_COMPILE   := aarch64-linux-gnu-

CC       := $(CROSS_COMPILE)gcc
LD       := $(CROSS_COMPILE)ld
OBJCOPY  := $(CROSS_COMPILE)objcopy

EFIINC   := /usr/include/efi
EFIARCH  := $(EFIINC)/$(ARCH)
EFILIB   := /usr/lib/gnu-efi/$(ARCH)
CRT0     := $(EFILIB)/crt0-efi-$(ARCH).o
LDSCRIPT := $(EFILIB)/elf_$(ARCH)_efi.lds

CFLAGS   := -I$(EFIINC) -I$(EFIARCH) \
            -fpic -fshort-wchar -mno-red-zone \
            -Wall -Wextra

TARGET   := BOOTAA64.EFI

all: $(TARGET)

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
