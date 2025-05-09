#ifndef KEYBOARD_H
#define KEYBOARD_H

#include <stdint.h>

// Преобразование scancode -> ASCII
char scancode_to_ascii(uint8_t sc);

#endif // KEYBOARD_H