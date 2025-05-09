#include "utils.h"
#include "pci.h"
#include "keyboard.h"
#include <stdint.h>
#include <string.h>
#include "monitor.h"
#include "utils.h"

void show_emergency_screen(void) {
    print_str("!== EMERGENCY MODE ==!\n");
    print_str("Enter password: ");
}

// 32-битные операции I/O, если нужны
static inline void outl(uint16_t port, uint32_t val) {
    __asm__ volatile("outl %0, %1" :: "a"(val), "Nd"(port));
}
static inline uint32_t inl(uint16_t port) {
    uint32_t ret;
    __asm__ volatile("inl %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

// Задержка простейшим циклом (~1 ms)
void delay_ms(uint32_t ms) {
    volatile uint64_t count;
    while (ms--) {
        count = 100000;
        while (count--) {
            __asm__ volatile ("nop");
        }
    }
}

// Вывод строки в VGA text mode (0xB8000)
void print_str(const char* s) {
    volatile uint16_t* vga = (uint16_t*)0xB8000;
    for (size_t i = 0; s[i]; ++i) {
        vga[i] = (uint8_t)s[i] | (0x07 << 8);  // белый на чёрном
    }
}

// Ввод пароля через перехват scancode
// Возвращает 1, если введённый пароль совпал с expected_password из monitor.S
int get_password_input(char* buf, int maxlen) {
    int len = 0;
    buf[0] = '\0';

    while (1) {
        uint8_t sc = inb(0x60);
        // игнорируем release (high bit)
        if (sc & 0x80) continue;

        char c = scancode_to_ascii(sc);
        if (c == '\r') break;            // Enter завершает ввод
        if (c == '\b') {                 // Backspace
            if (len > 0) buf[--len] = '\0';
        } else if (c >= ' ' && c <= '~' && len < maxlen) {
            buf[len++] = c;
            buf[len] = '\0';
        }
        // по желанию: можно вывести '*' через print_str
    }

    extern const char expected_password[];  // из monitor.S
    return strcmp(buf, expected_password) == 0;
}