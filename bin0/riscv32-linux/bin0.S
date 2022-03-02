.section .text
.global _start

_start:
    lw a0, 0(sp) // get argc
    slti t0, a0, 3 // check if argc < 3
    bnez t0, exit // if so, exit

    li a0, -100 // AT_FDCWD
    lw a1, 8(sp) // first argument
    li a2, 0 // O_RDONLY
    li a3, 0 // no mode
    li a7, 56 // openat
    ecall
    bltz a0, exit // if error, exit
    mv s0, a0 // save file descriptor

    li a0, -100 // AT_FDCWD
    lw a1, 12(sp) // second argument
    li a2, 577 // O_TRUNC | O_CREAT | O_WRONLY
    li a3, 493 // rwxr-xr-x
    li a7, 56 // openat
    ecall
    bltz a0, exit // if error, exit
    mv s1, a0 // save file descriptor

.Lloop_init:
    li s2, 0 // Load accumulator
    li s3, 32 // Counter
.Lread_loop:
    mv a0, s0 // source fd
    mv a1, sp // dest buffer
    li a2, 1 // size
    li a7, 63 // read
    ecall
    slti t0, a0, 1 // check if read was successful
    bnez t0, exit // if not, exit
    
    lbu a0, 0(sp) // read the byte
    andi a1, a0, 0xFE // clear the bottom bit
    xori a1, a1, 0x30 // Invert the number bit mask
    bnez a1, .Lread_loop // if it’s not a number, loop
    andi a0, a0, 0x01 // get the number bit
    slli s2, s2, 1 // shift the number bit into the accumulator
    or s2, s2, a0
    addi s3, s3, -1 // decrement counter
    bnez s3, .Lread_loop // if counter is not zero, loop

    sw s2, 0(sp) // store the number in the buffer
    mv a0, s1 // destination fd
    mv a1, sp // source buffer
    li a2, 4 // size
    li a7, 64 // write
    ecall
    bltz a0, exit // if error, exit
    j .Lloop_init // loop
exit:
    li a7, 93
    ecall
