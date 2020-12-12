            .global main
            .extern printf

            .data

message:    .asciz  "Hello, world!\n"

            .text

main:
            sub     sp, sp, 16
            str     x30, [sp, 8]
            ldr     x0, =message
            bl      printf
            ldr     x30, [sp, 8]
            add     sp, sp, 16
            ret
