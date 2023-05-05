.MODEL small
.STACK 100h
.DATA
    msg1 db 13,10,'pls enter your first number: $'
    msg2 db 13,10,'pls enter your second number: $'
    var1 dw ?
    var2 dw ?
    max dw ?    
.CODE
    proc high
        push bp
        mov bp,sp 
        
        mov ax,[bp+6]
        cmp ax,[bp+8]
        ja first
        
        cmp ax,[bp+8]
        jb second
        
        first:
            mov bx,[bp+4]
            mov cx,[bp+6]
            mov [bx],cx
            jmp cnt
        second:
            mov bx,[bp+4]
            mov cx,[bp+8]
            mov [bx],cx
        cnt:
        pop bp
        ret 6
    endp high 
    
start:
    mov ax,@data
    mov ds,ax
    xor ax,ax
    
    lea dx,msg1
    mov ah,09
    int 21h
    
    mov ah,01
    int 21h
    xor ah,ah
    sub al,48
    mov var1,ax
    
    lea dx,msg2
    mov ah,09
    int 21h
    
    mov ah,01
    int 21h
    xor ah,ah
    sub al,48
    mov var2,ax
    
    push var1
    push var2
    push offset max
    
    call high
    jmp exit         
exit:
end start


