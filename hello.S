            .global main
            .extern printf

            .data

message:    .asciz  "Hello, world!\n"

            .text

main:
            sub     sp, sp, 16
            str     x30, [sp]
            ldr     x0, =message
            bl      printf
            mov     w0, #0
            ldr     x30, [sp]
            add     sp, sp, 16
            ret
