#include <efi.h>
#include <efilib.h>

EFI_STATUS
efi_main(EFI_HANDLE image, EFI_SYSTEM_TABLE *systab)
{
    InitializeLib(image, systab);
    Print(L"ARM64 UEFI app started successfully\r\n");
    return EFI_SUCCESS;
}
