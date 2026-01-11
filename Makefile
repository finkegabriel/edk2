ARCH            := aarch64
CROSS_COMPILE   := aarch64-linux-gnu-

EFIINC   := /usr/include/efi
EFIARCH  := $(EFIINC)/arm64
EFILIB   := /usr/lib/gnu-efi/arm64
CRT0     := $(EFILIB)/crt0-efi-aarch64.o
LDSCRIPT := /usr/lib/gnu-efi/elf_aarch64_efi.lds

CFLAGS   := -I$(EFIINC) -I$(EFIARCH) \
            -fpic -fshort-wchar \
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
