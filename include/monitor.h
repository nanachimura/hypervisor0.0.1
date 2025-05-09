#ifndef MONITOR_H
#define MONITOR_H

// Показывает экран ввода пароля
void show_emergency_screen(void);

// Ожидаемый пароль (объявлен в monitor.S)
extern const char expected_password[];

#endif // MONITOR_H