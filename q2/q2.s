.section .data
fmt: .asciz "%ld "
fmt_end:.asciz "%ld\n"

.section .bss
    .align 3
A:      .skip 256
RES:    .skip 256
STACK:  .skip 256

.section .text
.globl main
.extern atoi
.extern printf


#   x8  = n (argc - 1)
#   x9  = argv
#   x18 = base of A
#   x19 = base of RES
#   x20 = base of STACK
#   x21 = stack top index
#   x22 = loop counter i

main:

    addi x2, x2, -64
    sd   x1,  0(x2)
    sd   x8,  8(x2)
    sd   x9,  16(x2)
    sd   x18, 24(x2)
    sd   x19, 32(x2)
    sd   x20, 40(x2)
    sd   x21, 48(x2)
    sd   x22, 56(x2)

    addi x8, x10, -1       # x8 = n = argc - 1
    mv   x9, x11           # x9 = argv

    la   x18, A
    la   x19, RES
    la   x20, STACK


    li   x22, 1            # i = 1

read_loop:
    blt  x8, x22, done_read

    slli x5, x22, 3
    add  x6, x9, x5
    ld   x10, 0(x6)        # x10 = argv[i]
    call atoi              # x10 = atoi(argv[i])

    addi x5, x22, -1
    slli x5, x5, 3
    add  x6, x18, x5
    sd   x10, 0(x6)        # A[i-1] = result

    addi x22, x22, 1
    jal  x0, read_loop


done_read:
    li   x22, 0

init_loop:
    bge  x22, x8, init_done

    slli x5, x22, 3
    add  x6, x19, x5
    li   x7, -1
    sd   x7, 0(x6)         # RES[i] = -1

    addi x22, x22, 1
    jal  x0, init_loop


init_done:
    li   x21, -1           # stack top = -1
    addi x22, x8, -1       # i = n - 1

main_loop:
    blt  x22, x0, print_result

    slli x5, x22, 3
    add  x6, x18, x5
    ld   x7, 0(x6)         # x7 = A[i]


while_loop:
    blt  x21, x0, after_while

    slli x5, x21, 3
    add  x6, x20, x5
    ld   x28, 0(x6)        # x28 = STACK[top]

    slli x5, x28, 3
    add  x6, x18, x5
    ld   x29, 0(x6)        # x29 = A[STACK[top]]

    bgt  x29, x7, after_while

    addi x21, x21, -1      # pop
    jal  x0, while_loop


after_while:
    blt  x21, x0, skip_set

    slli x5, x22, 3
    add  x6, x19, x5       # &RES[i]

    slli x5, x21, 3
    add  x30, x20, x5
    ld   x28, 0(x30)       # STACK[top]

    sd   x28, 0(x6)        # RES[i] = STACK[top]


skip_set:
    addi x21, x21, 1
    slli x5, x21, 3
    add  x6, x20, x5
    sd   x22, 0(x6)        # STACK[top] = i

    addi x22, x22, -1
    jal  x0, main_loop


print_result:
    li   x22, 0

print_loop:
    bge  x22, x8, done

    slli x5, x22, 3
    add  x6, x19, x5
    ld   x11, 0(x6)        # x11 = RES[i]

    addi x5, x8, -1        # x5 = n-1
    beq  x22, x5, use_end_fmt
    la   x10, fmt          # "%ld "
    j    do_print
use_end_fmt:
    la   x10, fmt_end      # "%ld\n"
do_print:
    call printf

    addi x22, x22, 1
    jal  x0, print_loop


done:
    ld   x1,  0(x2)
    ld   x8,  8(x2)
    ld   x9,  16(x2)
    ld   x18, 24(x2)
    ld   x19, 32(x2)
    ld   x20, 40(x2)
    ld   x21, 48(x2)
    ld   x22, 56(x2)
    addi x2, x2, 64

    li   x10, 0
    ret