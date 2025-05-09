; vmx.S — инициализация VT-x и запуск виртуальной машины

    .section .text
    .global kernel_main
kernel_main:
    ; Проверка поддержки VMX
    call check_vmx_support
    ; Разрешение VMXON
    call enable_vmx
    ; Выделение vmxon_region (виртуально)
    ; Здесь должна быть реализация alloc_page / физ. адресации
    mov rdi, vmxon_region_physical_address
    call vmxon

    ; Инициализация VMCS
    mov rdi, vmcs_physical_address
    call vmclear
    mov rdi, vmcs_physical_address
    call vmptrld

    ; Заполнение полей VMCS (пример):
    ; vmwrite(GUEST_CR0, <value>)
    ; vmwrite(GUEST_CR3, <value>)
    ; vmwrite(GUEST_CR4, <value>)
    ; vmwrite(GUEST_RIP, guest_entry)

    ; Настройка host-state (адрес vmexit_handler)

    ; Запуск гостя
    call vmlaunch

vmexit_handler:
    ; Обработка VM-exit: чтение причины, логика монитора
    hlt
    jmp vmexit_handler

    .data
vmxon_region_physical_address: .quad 0x0000000000200000
vmcs_physical_address:      .quad 0x0000000000201000

guest_entry:
    ; Переход гостя в guest_stub.S
    mov rax, guest_start
    jmp rax
```asm
; boot.S — запуск и переход в Long Mode (64-bit)

    .section .text
    .global start
start:
    cli                     # запретить прерывания

    # Загрузка GDT для Protected Mode
    lgdt [gdtr]
    mov eax, cr0
    or  eax, 1
    mov cr0, eax            # включить Protected Mode

    # Переключение на Protected Mode
    jmp CODE_SEL:pmode_entry

pmode_entry:
    # Установка сегментов
    mov ax, DATA_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    # Включение Long Mode (EFER.LME)
    mov ecx, 0xC0000080     # MSR EFER
    rdmsr
    or  eax, (1 << 8)
    wrmsr

    mov eax, cr4
    or  eax, (1 << 5)       # включить PAE
    mov cr4, eax

    mov eax, cr0
    or  eax, (1 << 31)      # включить PG
    mov cr0, eax

    # Переключаемся на 64-bitCS
    jmp LONG_SEL:long_mode_entry

.long_mode_entry:
    ; установка сегментов 64-bit
    mov ax, DATA_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; установка стека
    mov rsp, stack_top

    ; вызов kernel_main (в vmx.S)
    extern kernel_main
    call kernel_main

.hang:
    hlt
    jmp .hang

# GDT описание
.align 8
gdtr:
    .word gdt_end - gdt - 1
    .quad gdt

gdt:
    .quad 0x0000000000000000  # NULL
    .quad 0x00AF9A000000FFFF  # CODE_SEL: Kernel Code, 64-bit
    .quad 0x00AF92000000FFFF  # DATA_SEL: Kernel Data, RW
gdt_end:

# Селекторы
#define CODE_SEL 0x08
#define DATA_SEL 0x10

# Стек
    .bss
    .align 16
stack_bottom:
    .space 8192
stack_top: