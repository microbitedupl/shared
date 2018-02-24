[BITS 16]
%define BLSTART 0x3E
%define BLLEN 448

cli
mov ax, 07C0h
add ax, 288
mov ss, ax
mov sp, 4096
mov ax, 07C0h
mov ds, ax
mov si,message+BLSTART
call print
jmp $

printc:
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    ret

print:
    nextc:
        mov al, [si]
        inc si
        or al, al
        jz return
        call printc
        jmp nextc
    return:
        ret

message db 'PLEASE REMOVE THE ARM MBED DAPLINK USB DEVICE AND REBOOT THE SYSTEM..', 0

times BLLEN-($-$$) db 0
