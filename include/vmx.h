#ifndef VMX_H
#define VMX_H

#include <stdint.h>

// MSR адреса
#define IA32_FEATURE_CONTROL 0x3A
#define IA32_VMX_BASIC      0x480

// Функции и обёртки
int check_vmx_support(void);
void enable_vmx(void);
int vmxon(uint64_t region_pa);
int vmclear(uint64_t vmcs_pa);
int vmptrld(uint64_t vmcs_pa);
int vmlaunch(void);
int vmresume(void);
uint64_t vmread(uint64_t field);
void vmwrite(uint64_t field, uint64_t value);

#endif // VMX_H