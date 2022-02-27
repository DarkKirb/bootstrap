.section .text
.global _start

_start:
    ldr r0, [sp, 0] // Get argc
    cmp r0, #3 // Check if argc is 3
    movlt r7, #1 // exit(1)
    svclt #0

    mov r0, #-100 // AT_FDCWD
    ldr r1, [sp, 8] // first argument
    mov r2, #0 // O_RDONLY
    mov r3, #0 // no mode
    mov r7, #322 // openat
    svc #0
    cmp r0, #0 // Check if failed
    movlt r7, #1 // exit(1)
    svclt #0
    mov r8, r0

    mov r0, #-100 // AT_FDCWD
    ldr r1, [sp, 12] // second argument
    mov r2, #577 // O_TRUNC | O_CREAT | O_WRONLY
    mov r3, #493 // rwxr-xr-x
    mov r7, #322 // openat
    svc #0
    cmp r0, #0 // Check if failed
    movlt r0, #3 // Return an error otherwise
    movlt r7, #1 // exit(1)
    svclt #0
    mov r9, r0

.Lloop_init:
    mov r10, #1 // load accumulator
.Lread_loop:
    mov r0, r8 // Source FD
    mov r1, sp // Destination buffer
    mov r2, #1 // Number of bytes to read
    mov r7, #3 // read()
    svc #0
    cmp r0, #0 // Check if failed or end of file
    movle r7, #1 
    svcle #0 // exit

    // read the byte
    ldrb r0, [sp]
    and r0, r0, #0xFE // remove bottom bit
    cmp r0, #0x30 // Check if it's a number
    bne .Lread_loop // If not, go back to read again

    ldrb r0, [sp]
    and r0, r0, #0x1 // Mask the bottom bit
    orrs r10, r0, r10, lsl #1 // Add the number to the accumulator
    bcc .Lread_loop // We haven’t finished reading

    str r10, [sp] // Store the accumulator
    mov r0, r9 // Destination FD
    mov r1, sp // Source buffer
    mov r2, #4 // Number of bytes to write
    mov r7, #4 // write()
    svc #0
    cmp r0, #0 // Check if failed
    movlt r7, #1 // exit(1)
    svclt #0

    b .Lloop_init
