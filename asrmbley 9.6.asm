גרסא 2
.MODEL small
.STACK 100h
.DATA
msg0 db '           _____      _                  _   _                 _                ',13,10,           
    db '          |  __ \    (_)                | \ | |               | |               ',13,10,
    db '          | |__) | __ _ _ __ ___   ___  |  \| |_   _ _ __ ___ | |__   ___ _ __  ',13,10,
    db '          |  ___/ '__| | '_ ` _ \ / _ \ | . ` | | | | '_ ' _ \| '_ \ / _ \ '__| ',13,10,
    db '          | |   | |  | | | | | | |  __/ | |\  | |_| | | | | | | |_) |  __/ |    ',13,10,
    db '          |_|   |_|  |_|_| |_| |_|\___| |_| \_|\__,_|_| |_| |_|_.__/ \___|_|    ',13,10,'$'

    msg1 db "Supported values from up to 65520", 0Dh,0Ah
    db "Enter the number, and press ENTER: $"
    num dw ?    
    msg2 db 13,10,'The number IS a prime number.$'
    msg3 db 13,10,'The number is NOT a prime number.$' 
    msg4 db 13,10,'The next prime number is: $' 
    msg5 db 13,10,'END OF PROGRAM$' 
    msg6 db 13,10,'THANK YOU FOR USING OUR SYSTEM.$'
    gb dw ?
    sum dw ?
    temp dw ?
    temp2 dw ?
.CODE
start:
    mov ax,@data
    mov ds,ax
    xor ax,ax 
    
    lea dx,msg0
    push dx
    call print 
    
    lea dx,msg1
    push dx
    call print
    
    call scan_num ;get the number to cx.(the code was taken from the example in emu8086)(Tobin.asm).
    
    push cx
    call checkPrime
    
    push dx
    call priAns
    
    xor ax,ax
    mov ax,num
    push ax
    call nextPrime
    
    lea dx,msg5
    push dx
    call print
    
    lea dx,msg6
    push dx
    call print
    
    jmp finalExit
    

;Entry claim: dx (contains the message I want to print).
;Exit claim: (prints what dx contains).
proc print
        pop cx
        pop dx
        push ax
        mov ah,09
        int 21h 
        pop ax
        push cx
        ret
endp print 

;Entry claim: cx (contains my number).
;Exit claim: puts in dx '0' when the number is prime and puts in dx '1' when the number isn't prime.    
proc checkPrime
    pop bx
    pop ax
    mov temp,ax
    mov num,ax
    xor ch,ch
    mov cx,num
    loopPrime:
        xor ah,ah 
        mov ax,num 
        xor dx,dx
        div temp
        cmp dx,0
        je zero  
        jmp cnt
        
        zero:
            add sum,1 
        cnt:
            sub temp,1
        loop loopPrime
    
    cmp sum,2
    je prime
    jmp cont
    
    prime:
        mov dx,0
        jmp exit
    cont:
        mov dx,1
    exit: 
        mov sum,0
        push bx
        ret
endp checkPrime

;Entry claim: dx (contains the value '0' or '1')
;Exit claim: prints to the console whether the number is prime or not, by the value of dx
proc priAns
    pop gb 
    pop cx
    cmp cx,0
    je priPrime
    
    lea dx,msg3
    push dx
    call print
    jmp exit2
    
    priPrime:
        lea dx,msg2
        push dx
        call print
    exit2:
        push gb
        ret
endp priAns

;Entry claim: ax (contains the number the user entered).
;Exit claim: gets the next prime number and prints in into the console.
proc nextPrime
    pop gb
    pop ax 
    loopnext:
        add ax,1
        push ax
        call checkPrime
        cmp dx,0
        je nextPrime2
        jmp cntLoop
        
        nextPrime2:
            lea dx,msg4
            push dx
            call print
            push ax
            call print_ax ;prints the number in ax (the code was taken from the example in emu8086)(print_AX.asm).
            jmp exit3
        cntLoop:
            loop loopnext
    exit3:
        push gb
        ret
endp nextPrime

putc    macro   char
        push    ax
        mov     al, char
        mov     ah, 0eh
        int     10h     
        pop     ax
endm

;Entry claim: doesn't have one.
;Exit claim: perceiving a number from the user.
scan_num        proc    near
        push    dx
        push    ax
        push    si
        
        mov     cx, 0

        ; reset flag:
        mov     cs:make_minus, 0

next_digit:

        ; get char from keyboard
        ; into al:
        mov     ah, 00h
        int     16h
        ; and print it:
        mov     ah, 0eh
        int     10h

        ; check for minus:
        cmp     al, '-'
        je      set_minus

        ; check for enter key:
        cmp     al, 13  ; carriage return?
        jne     not_cr
        jmp     stop_input
not_cr:


        cmp     al, 8                   ; 'backspace' pressed?
        jne     backspace_checked
        mov     dx, 0                   ; remove last digit by
        mov     ax, cx                  ; division:
        div     cs:ten                  ; ax = dx:ax / 10 (dx-rem).
        mov     cx, ax
        putc    ' '                     ; clear position.
        putc    8                       ; backspace again.
        jmp     next_digit
backspace_checked:


        ; allow only digits:
        cmp     al, '0'
        jae     ok_ae_0
        jmp     remove_not_digit
ok_ae_0:        
        cmp     al, '9'
        jbe     ok_digit
remove_not_digit:       
        putc    8       ; backspace.
        putc    ' '     ; clear last entered not digit.
        putc    8       ; backspace again.        
        jmp     next_digit ; wait for next input.       
ok_digit:


        ; multiply cx by 10 (first time the result is zero)
        push    ax
        mov     ax, cx
        mul     cs:ten                  ; dx:ax = ax*10
        mov     cx, ax
        pop     ax

        ; check if the number is too big
        ; (result should be 16 bits)
        cmp     dx, 0
        jne     too_big

        ; convert from ascii code:
        sub     al, 30h

        ; add al to cx:
        mov     ah, 0
        mov     dx, cx      ; backup, in case the result will be too big.
        add     cx, ax
        jc      too_big2    ; jump if the number is too big.

        jmp     next_digit

set_minus:
        mov     cs:make_minus, 1
        jmp     next_digit

too_big2:
        mov     cx, dx      ; restore the backuped value before add.
        mov     dx, 0       ; dx was zero before backup!
too_big:
        mov     ax, cx
        div     cs:ten  ; reverse last dx:ax = ax*10, make ax = dx:ax / 10
        mov     cx, ax
        putc    8       ; backspace.
        putc    ' '     ; clear last entered digit.
        putc    8       ; backspace again.        
        jmp     next_digit ; wait for enter/backspace.
        
        
stop_input:
        ; check flag:
        cmp     cs:make_minus, 0
        je      not_minus
        neg     cx
not_minus:

        pop     si
        pop     ax
        pop     dx
        ret
make_minus      db      ?       ; used as a flag.
ten             dw      10      ; used as multiplier.
scan_num        endp
                                 
;Enter claim: ax (contains the next prime number).
;Exit claim: prints ax (the next prime number) into the console.
print_ax proc
cmp ax, 0
jne print_ax_r
    push ax
    mov al, '0'
    mov ah, 0eh
    int 10h
    pop ax
    ret 
print_ax_r:
    pusha
    mov dx, 0
    cmp ax, 0
    je pn_done
    mov bx, 10
    div bx    
    call print_ax_r
    mov ax, dx
    add al, 30h
    mov ah, 0eh
    int 10h    
    jmp pn_done
pn_done:
    popa  
    ret  
endp
    
    finalExit:
        mov ah,4ch
        int 21h   
END start


