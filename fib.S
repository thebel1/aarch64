            .global main
            .extern atoi
            .extern printf

            .data

format:     .asciz  "%d\n"

            .text

main:
            sub     sp, sp, 16
            str     x30, [sp]
            cmp     x0, 2
            b.lt    main_leave
            ldr     x0, [x1, 8]
            bl      atoi
            mov     x2, x0
            mov     x1, 1
            mov     x0, 0
            bl      fib
main_leave:
            ldr     x30, [sp]
            add     sp, sp, 16
            ret

fib:
            sub     sp, sp, 32
            str 	x30, [sp, 24]
            cmp     x2, 0
            b.le    fib_leave
            str     x0, [sp, 16]
            str     x1, [sp, 8]
            str     x2, [sp]
            ldr     x0, =format
            ldr     x1, [sp, 16]
            bl      printf
            ldr     x2, [sp]
            sub     x2, x2, 1
            ldr     x9, [sp, 16]
            ldr     x0, [sp, 8]
            ldr     x10, [sp, 8]
            add     x1, x10, x9
            bl      fib
fib_leave:
            ldr 	x30, [sp, 32]
            add     sp, sp, 48
            ret
