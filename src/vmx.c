#include "vmx.h"
#include <stdint.h>

// Чтение MSR
static inline uint64_t read_msr(uint32_t msr) {
    uint32_t low, high;
    __asm__ volatile ("rdmsr"
                      : "=a"(low), "=d"(high)
                      : "c"(msr));
    return ((uint64_t)high << 32) | low;
}

// Запись MSR
static inline void write_msr(uint32_t msr, uint64_t value) {
    uint32_t low  = (uint32_t)value;
    uint32_t high = (uint32_t)(value >> 32);
    __asm__ volatile ("wrmsr"
                      :: "a"(low), "d"(high), "c"(msr));
}

int check_vmx_support(void) {
    uint64_t ctrl = read_msr(IA32_FEATURE_CONTROL);
    // бит [2] == VMX enabled inside SMX
    return (ctrl & (1ULL << 2)) != 0;
}

void enable_vmx(void) {
    uint64_t ctrl = read_msr(IA32_FEATURE_CONTROL);
    if (!(ctrl & 0x1)) {
        // устанавливаем LOCK(0) и VMXON-enabled(2)
        ctrl |= (1ULL << 0) | (1ULL << 2);
        write_msr(IA32_FEATURE_CONTROL, ctrl);
    }
}

int vmxon(uint64_t region_pa) {
    int r;
    __asm__ volatile ("vmxon %1; setna %0"
                      : "=r"(r)
                      : "m"(region_pa));
    return r;
}

int vmclear(uint64_t vmcs_pa) {
    int r;
    __asm__ volatile ("vmclear %1; setna %0"
                      : "=r"(r)
                      : "m"(vmcs_pa));
    return r;
}

int vmptrld(uint64_t vmcs_pa) {
    int r;
    __asm__ volatile ("vmptrld %1; setna %0"
                      : "=r"(r)
                      : "m"(vmcs_pa));
    return r;
}

int vmlaunch(void) {
    int r;
    __asm__ volatile ("vmlaunch; setna %0"
                      : "=r"(r));
    return r;
}

int vmresume(void) {
    int r;
    __asm__ volatile ("vmresume; setna %0"
                      : "=r"(r));
    return r;
}

uint64_t vmread(uint64_t field) {
    uint64_t value;
    __asm__ volatile ("vmread %1, %0"
                      : "=r"(value)
                      : "r"(field));
    return value;
}

void vmwrite(uint64_t field, uint64_t value) {
    __asm__ volatile ("vmwrite %1, %0"
                      :: "r"(value), "r"(field));
}