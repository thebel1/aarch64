            .global main
            .extern atoi
            .extern malloc
            .extern free
            .extern printf

            .data

template:   .asciz  "%d\t"
newline:    .asciz  "\n"

            .text

main:
            sub     sp, sp, 48
            str     x30, [sp, 32]
            str     x19, [sp, 24]
            str     x20, [sp, 16]
            str     x21, [sp, 8]
            str     x22, [sp]
            mov     x19, x0
            mov     x20, x1
            cmp     x19, 3
            b.lt    main_leave
            sub     x19, x19, 1
            mov     x21, 0
            mov     x0, x19
            mov     x9, 4
            mul     x0, x0, x9
            bl      malloc
            mov     x22, x0
main_inLoop:
            mov     x0, 8
            mul     x0, x0, x21
            add     x0, x0, 8
            add     x0, x0, x20
            ldr     x0, [x0]
            bl      atoi
            mov     x9, 4
            mul     x9, x9, x21
            add     x9, x9, x22
            str     x0, [x9]
            add     x21, x21, 1
            cmp     x21, x19
            b.lt    main_inLoop
            mov     x0, x22
            mov     x1, 0
            mov     x2, x19
            sub     x2, x2, 1
            bl      qsort
main_leave:
            .word   0
            ldr     x22, [sp]
            ldr     x21, [sp, 8]
            ldr     x20, [sp, 16]
            ldr     x19, [sp, 24]
            ldr     x30, [sp, 32]
            add     sp, sp, 48
            ret

partition:
            .word 0
            ret

qsort:
            sub     sp, sp, 32
            str     x30, [sp, 24]
            str     x0, [sp, 16]
            str     x1, [sp, 8]
            str     x19, [sp]
            .word 0
            ldr     x19, [sp]
            ldr     x1, [sp, 8]
            ldr     x0, [sp, 16]
            ldr     x30, [sp, 24]
            add     sp, sp, 32
            ret
