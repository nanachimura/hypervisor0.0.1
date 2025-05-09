#ifndef UTILS_H
#define UTILS_H

#include <stdint.h>

// I/O порты
static inline void outb(uint16_t port, uint8_t value) {
    __asm__ volatile ("outb %0, %1" :: "a"(value), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

void delay_ms(uint32_t ms);
void print_str(const char* s);
int  get_password_input(char* buf, int maxlen);

#endif // UTILS_H