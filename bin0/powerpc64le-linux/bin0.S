.section .text
.global _start

_start:
    ld 3, 0(1) // get argc
    cmpdi 3, 3 // check if argc is 3
    blt exit // exit otherwise

    li 3, -100 // AT_FDCWD
    ld 4, 16(1) // first argument
    li 5, 0 // O_RDONLY
    li 6, 0 // no mode
    li 0, 286 // openat
    sc
    bso exit // exit otherwise
    mr 12, 3 // save file descriptor

    li 3, -100 // AT_FDCWD
    ld 4, 24(1) // second argument
    li 5, 577 // O_TRUNC | O_CREAT | O_WRONLY
    li 6, 493 // rwxr-xr-x
    li 0, 286 // openat
    sc
    bso exit // exit otherwise
    mr 13, 3 // save file descriptor

.Lloop_init:
    li 14, 0 // accumulator
    li 15, 32 // Counter
.Lread_loop:
    mr 3, 12 // source fd
    mr 4, 1 // destination buffer
    li 5, 1 // size
    li 0, 3 // read
    sc
    bso exit // exit otherwise
    cmpdi 3, 0 // check if eof
    beq exit

    lbz 3, 0(1) // get byte
    andi. 4, 3, 0xFE // clear bottom bit
    cmpwi 4, 0x30 // check if byte is a number
    bne .Lread_loop // loop if not

    andi. 3, 3, 1 // get the bottom bit
    rlwinm 14, 14, 1, 0, 30 // shift accumulator
    or 14, 14, 3 // add bottom bit to accumulator
    addi 15, 15, -1 // decrement counter
    cmpwi 15, 0 // check if counter is 0
    bne .Lread_loop // loop if not

    stw 14, 0(1) // store accumulator
    mr 3, 13 // dest fd
    mr 4, 1 // source buffer
    li 5, 4 // size
    li 0, 4 // write
    sc
    bso exit // exit otherwise
    b .Lloop_init // loop
exit:
    li 0, 1 // exit 
    sc
