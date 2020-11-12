            .global main
            .extern atoi
            .extern malloc
            .extern free
            .extern printf

            .set    ListNode_next, 0
            .set    ListNode_val, 8
            .set    sizeof_ListNode, 12

            .data

format:     .asciz  "%d "
newline:    .asciz  "\n"

            .text

main:
            sub     sp, sp, 48
            str     x30, [sp, 40]
            str     x19, [sp, 32]
            str     x20, [sp, 24]
            str     x21, [sp, 16]
            str     x22, [sp, 8]
            cmp     x0, 2
            b.le    main_leave
            mov     x19, x0
            mov     x20, x1
            mov     x21, 0
            mov     x22, sp
            mov     x9, 0
            str     x9, [sp]
            sub     x19, x19, 1
main_listLoop:
            mov     x9, x21
            add     x9, x9, 1
            mov     x10, 8
            mul     x9, x9, x10
            add     x9, x9, x20
            ldr     x0, [x9]
            bl      atoi
            mov     x1, x0
            mov     x0, x22
            bl      appendNode
            ldr     x22, [x22, ListNode_next]
            add     x21, x21, 1
            cmp     x21, x19
            b.lt    main_listLoop
            ldr     x22, [sp]
main_printLoop:
            ldr     x0, =format
            ldr     w1, [x22, ListNode_val]
            bl      printf
            ldr     x22, [x22, ListNode_next]
            cmp     x22, 0
            b.ne    main_printLoop
            ldr     x0, =newline
            bl      printf
main_leave:
            ldr     x0, [sp]
            bl      freeList
            ldr     x22, [sp, 8]
            ldr     x21, [sp, 16]
            ldr     x20, [sp, 24]
            ldr     x19, [sp, 32]
            ldr     x30, [sp, 40]
            add     sp, sp, 48
            ret

appendNode:
            sub     sp, sp, 32
            str     x30, [sp, 24]
            str     x19, [sp, 16]
            str     x20, [sp, 8]
            mov     x19, x0
            mov     x20, x1
            cmp     x19, 0
            b.eq    appendNode_leave
            ldr     x9, [x19]
            cmp     x9, 0
            b.ne    appendNode_leave
            mov     x0, sizeof_ListNode
            bl      malloc
            str     x0, [x19]
            mov     x9, 0
            str     x9, [x0, ListNode_next]
            str     w20, [x0, ListNode_val]
appendNode_leave:            
            ldr     x20, [sp, 8]
            ldr     x19, [sp, 16]
            ldr     x30, [sp, 24]
            add     sp, sp, 32
            ret

freeList:   
            sub     sp, sp, 32
            str     x30, [sp, 24]
            str     x19, [sp, 16]
            str     x20, [sp, 8]
            mov     x19, x0
            cmp     x19, 0
            b.eq    freeList_leave
            ldr     x20, [x19, ListNode_next]
            mov     x0, x20
            bl      freeList
            mov     x0, x19
            bl      free
freeList_leave:
            ldr     x20, [sp, 8]
            ldr     x19, [sp, 16]
            ldr     x30, [sp, 24]
            add     sp, sp, 32
            ret
