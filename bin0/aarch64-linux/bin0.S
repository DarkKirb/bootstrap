.section .text
.global _start

_start:
    ldr x0, [sp] // Get argc
    cmp x0, #3 // Check if argc is 3
    blt exit // exit otherwise

    mov x0, #-100 // AT_FDCWD
    ldr x1, [sp, 16] // First argument
    mov x2, #0 // O_RDONLY
    mov x3, #0 // no mode
    mov x8, #56 // openat
    svc #0
    cmp x0, #0 // Check if openat succeeded
    blt exit // exit otherwise
    mov x9, x0 // Save fd

    mov x0, #-100 // AT_FDCWD
    ldr x1, [sp, 24] // Second argument
    mov x2, #577 // O_TRUNC | O_CREAT | O_WRONLY
    mov x3, #493 // rwxr-xr-x
    mov x8, #56 // openat
    svc #0
    cmp x0, #0 // Check if openat succeeded
    blt exit // exit otherwise
    mov x10, x0 // Save fd

.Lloop_init:
    mov x11, #0 // load accumulator
    mov x12, #32 // Counter
.Lread_loop:
    mov x0, x9 // source fd
    mov x1, sp // destination buffer
    mov x2, #1 // size
    mov x8, #63 // read
    svc #0
    cmp x0, #0 // Check if read succeeded
    ble exit // exit otherwise

    // read the byte
    ldrb w0, [sp]
    and w0, w0, #0xFE // clear the bottom bit
    cmp w0, #0x30 // Check if the byte is a number
    bne .Lread_loop // if not, loop again

    ldrb w0, [sp]
    and w0, w0, #1 // get the bottom bit
    orr w11, w0, w11, lsl #1 // add the bit to the accumulator
    subs x12, x12, #1 // decrement counter
    bne .Lread_loop // we haven’t finished looping

    str w11, [sp] // store the accumulator
    mov x0, x10 // destination fd
    mov x1, sp // source buffer
    mov x2, #4 // size
    mov x8, #64 // write
    svc #0
    cmp x0, #0 // Check if write succeeded
    blt exit // exit otherwise
    b .Lloop_init

exit:
    mov x8, #93
    svc #0
