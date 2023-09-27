option casemap:none

nl = 10
maxLen = 256
true = 1
false = 0

bool typedef ptr byte
.const
    ttlStr byte "Bad Bubble Sort", 0
    fmtStr byte "Sortme[%d] = %d", nl, 0

.data
    sortMe label dword
           dword 1, 2, 16, 14
           dword 3, 9, 4, 10
           dword 5, 7, 15, 12
           dword 8, 6, 11, 13
    sortSize = ($ - sortMe) / sizeof dword ; Number of elements
    ; didSwap - A Boolean value that indicates
    ; whether a swap occurred on the
    ; last loop iteration.
    didSwap bool ?

.code
    externdef printf:proc
    externdef puts:proc

    public getTitle

    public getTitle
    getTitle proc
        lea rax, ttlStr
        ret
    getTitle endp

    ; Sort(dword * array, qword count);
    sort proc
        push rax ; In pure assembly language
        push rbx ; it's always a good idea
        push rcx ; to preserve all registers
        push rdx ; you modify
        push r8
        dec rdx ; numElements - 1

    ; Outer loop:
    outer: mov didSwap, false
        
        xor rbx, rbx ; RBX = 0
    inner: cmp rbx, rdx ; while RBX < count - 1
        jnb xInner


        mov eax, [rcx + rbx*4] ; EAX = sortMe[RBX]
        cmp eax, [rcx + rbx*4 + 4] ; If EAX > sortMe[RBX + 1]
        jna dontSwap ; then swap

        ; sortMe[RBX] > sortMe[RBX + 1], so swap elemen:
        mov r8d, [rcx + rbx*4 + 4]
        mov [rcx + rbx*4 + 4], eax
        mov [rcx + rbx*4], r8d
        mov didSwap, true

    dontSwap:
        inc rbx
        jmp inner
    
    ; Exited from inner loop
    xInner: cmp didSwap, true
        je outer
        pop r8
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret
    sort endp

    public asmMain
    asmMain proc
        push rbx

        sub rsp, 40

        ; sort the sortme array
        lea rcx, sortMe
        mov rdx, sortSize
        call sort


        xor rbx, rbx
    dispLp: 
        lea rdx, sortMe
        mov r8d, [rdx + rbx * 4]
;       mov r8d, sortMe[rbx*4]
        mov rdx, rbx
        lea rcx, fmtStr
        call printf

        inc rbx
        cmp rbx, sortSize
        jb dispLp

        add rsp, 40
        pop rbx
        ret
    asmMain endp
            end
