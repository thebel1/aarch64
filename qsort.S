            .global main
            .extern atoi
            .extern malloc
            .extern free
            .extern printf

            .data

format:     .asciz  "%d "
newline:    .asciz  "\n"

            .text

main:
            sub     sp, sp, 48
            str     x30, [sp, 40]
        	cmp     x0, 2
            b.le    main_leave
            str     x19, [sp, 32]
            str     x20, [sp, 24]
            str     x21, [sp, 16]
            str     x22, [sp, 8]
            sub 	x0, x0, 1
            mov     x19, x0
            mov     x20, x1
            mov     x21, 0
            mov     x9, 4
            mul     x0, x0, x9
            bl      malloc
            mov     x22, x0
main_sortLoop:
            mov     x9, x21
            add     x9, x9, 1
            mov     x10, 8
            mul     x9, x9, x10
            ldr     x0, [x20, x9]
            bl      atoi
            mov     x9, x21
            mov     x10, 4
            mul     x9, x9, x10
            str     w0, [x22, x9]
            add     x21, x21, 1
            cmp     x21, x19
            b.lt    main_sortLoop
            mov     x0, x22
            mov     x1, 0
            mov     x2, x19
            sub     x2, x2, 1
            bl      qsort
            mov     x21, 0
main_printLoop:
            ldr     x0, =format
            mov     x1, x21
            mov     x2, 4
            mul     x1, x1, x2
            add     x1, x1, x22
            ldr     w1, [x1]
            bl      printf
            add     x21, x21, 1
            cmp     x21, x19
            b.lt    main_printLoop
            ldr     x0, =newline
            bl      printf
main_leave:
            ldr     x22, [sp, 8]
            ldr     x21, [sp, 16]
            ldr     x20, [sp, 24]
            ldr     x19, [sp, 32]
            ldr     x30, [sp, 40]
            add     sp, sp, 48
            ret

qsort:
            sub     sp, sp, 48
            cmp     x1, x2
            b.ge    qsort_leave
            str     x30, [sp, 40]
            str     x19, [sp, 32]
            str     x20, [sp, 24]
            str     x21, [sp, 16]
            str     x22, [sp, 8]
            mov     x19, x0
            mov     x20, x1
            mov     x21, x2
            bl      partition
            mov     x22, x0
            mov     x0, x19
            mov     x1, x20
            mov     x2, x22
            sub     x2, x2, 1
            bl      qsort
            mov     x0, x19
            mov     x1, x22
            add     x1, x1, 1
            mov     x1, x21
            bl      qsort
            ldr     x22, [sp, 8]
            ldr     x21, [sp, 16]
            ldr     x20, [sp, 24]
            ldr     x19, [sp, 32]
            ldr     x30, [sp, 40]
qsort_leave:
            add     sp, sp, 48
            ret

partition:
            sub     sp, sp, 32
            str     x30, [sp, 24]
            str     x19, [sp, 16]
            str     x20, [sp, 8]
            str     x21, [sp]
            mov     x19, x0
            mov     x20, x1
            mov     x21, x2
            mov     x9, x21
            mov     x10, 4
            mul     x9, x9, x10
            add     x9, x9, x19
            ldr     w7, [x9]
            mov     x10, x20
            sub     x10, x10, 1
            mov     x11, x20
partition_loop:
            mov     x12, x11
            mov     x13, 4
            mul     x12, x12, x13
            add     x12, x12, x19
            ldr     w13, [x12]
            cmp     w13, w7
            b.gt    partition_skip
            add     x10, x10, 1
            mov     x14, x10
            mov     x15, 4
            mul     x14, x14, x15
            add     x14, x14, x19
            ldr     w15, [x14]
            str     w13, [x14]
            str     w15, [x12]
partition_skip:
            add     x11, x11, 1
            cmp     x11, x21
            b.lt    partition_loop
            add     x10, x10, 1
            mov     x14, x10
            mov     x15, 4
            mul     x14, x14, x15
            add     x14, x14, x19
            ldr     w15, [x14]
            str     w7, [x14]
            str     w15, [x9]
            mov     x0, x10
            ldr     x21, [sp]
            ldr     x20, [sp, 8]
            ldr     x19, [sp, 16]
            ldr     x30, [sp, 24]
            add     sp, sp, 32
            ret
