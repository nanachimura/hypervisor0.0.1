; monitor.S — проверка статуса сетевого линка и управление ребутом

    .section .text
    .global monitor_link
monitor_link:
    ; Параметры PCI-устройства
    movzx ecx, byte [network_bus]
    movzx edx, byte [network_slot]
    movzx ebx, byte [network_func]
    mov esi, LINK_STATUS_OFFSET

    ; Считать статус
    push rax
    push rdi
    mov edi, ecx
    mov esi, edx
    mov edx, ebx
    mov eax, esi
    call pci_config_read       ; возвращает значение в EAX
    mov ebx, eax
    pop rdi
    pop rax

    ; Проверить бит "link up"
    test ebx, LINK_UP_MASK
    jnz monitor_end            ; если link_up — выход

    ; link down: показать окно
    call show_emergency_screen
    call get_password_input
    test al, al
    jnz monitor_end            ; если пароль верный — выход

    ; иначе перезагрузка
    mov al, 0x02
    out 0xCF9, al

monitor_end:
    ret

    .data
network_bus:   .byte 0x00            ; надо заполнить вашей картой
network_slot:  .byte 0x03            ; пример (bus 0, slot 3)
network_func:  .byte 0x0
LINK_STATUS_OFFSET: .equ 0x78        ; оффсет PCI-статуса
LINK_UP_MASK:       .equ 0x0001

; Ожидаемый пароль для разблокировки
expected_password: .asciz "admin123"  ; введите "admin123"
max_password_len:  .equ 9             ; длина строки без нуля