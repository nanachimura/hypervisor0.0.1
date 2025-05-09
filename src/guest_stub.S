; guest_stub.S — код, выполняемый внутри виртуальной машины

    .section .text
    .global guest_start
guest_start:
    ; Минимальный гость: бесконечный цикл с HLT
.loop:
    hlt
    jmp .loop