.MODEL small
.STACK 100h
.DATA
    num db ? 
    msg1 db 13,10,'Enter your number: $'   
    msg2 db 13,10,'Prime number$'
    msg3 db 13,10,'Not a prime number$' 
    msg4 db 13,10,'The next prime number is: $' 
    gb dw ? ;I used this variable because I didn't have enough registers
    sum db ?
    temp db ?
    temp2 db ?;I used another one because otherwise it would have changed in the procedure I called from the inside 
.CODE
start:
    mov ax,@data
    mov ds,ax
    xor ax,ax 
    
    lea dx,msg1
    push dx
    call print
    
    mov ah,01
    int 21h 
    sub al,48
    xor ah,ah 
    push ax
    call checkPrime
    
    push dx
    call priAns
    
    xor ax,ax
    mov al,num
    push ax
    call nextPrime
    
    jmp finalExit
    
    
;A procedure that prints what I enter to it
proc print
        pop cx
        pop dx
        mov ah,09
        int 21h
        push cx
        ret
endp print    
;A procedure that checks if the number I entered is a prime number    
proc checkPrime
    pop bx
    pop ax
    mov temp,al
    mov num,al
    mov cl,num
    xor ch,ch
    
    loopPrime:
        xor ah,ah 
        mov al,num
        div temp
        cmp ah,0
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
;A procedure that prints whether the number is prime or not
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
;A procedure that finds the next prime number
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
            mov temp2,al
            lea dx,msg4
            push dx
            call print
            add temp2,48
            mov dl,temp2
            mov ah,02
            int 21h
            jmp exit3
        cntLoop:
            loop loopnext
    exit3:
        push gb
        ret
endp nextPrime
    
    finalExit:
        mov ah,4ch
        int 21h   
END start


