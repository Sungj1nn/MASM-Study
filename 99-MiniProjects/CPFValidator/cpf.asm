option casemap:none

nl  = 10
nll = 0
maxLen = 512

.const
    ttlStr     byte  "CPF Validator",nll
    promptStr  byte  "Type your CPF: ",nll
    isValid    byte  "Your CPF is valid! =D",nl,nll
    isInvalid  byte  "Your CPF is invalid! =c",nl,nll
    sizeWrong  byte  "Size of string is invalid! =(",nl,nll
    divis      dword   0bh
    mult       dword   0ah

.data
    input byte maxLen dup (?)

.code
    externdef printf:proc
	externdef readLine:proc
	externdef atoi:proc
    externdef puts:proc

    public getTitle
    getTitle proc
        lea rax, ttlStr
        ret
    getTitle endp

    strlen proc

        sub rsp, 48

        xor rax, rax

        mov rdi, rdx

        repne scasb

        sub rdi, rdx

        mov rax, rdi

        add rsp, 48
        ret

    strlen endp

    valCPF proc

        sub rsp, 56

        push rcx
        push rdi

        mov rdx, rcx

        call strlen
        pop rdi

        cmp eax, 0ch
        je sizeRight

        pop rcx
        lea rcx, sizeWrong
        call printf
        jmp allDone

    sizeRight:
        xor rax, rax
        mov r8, 0ah
        xor r9, r9

    loop1: mov al, [rcx]
        sub al, 30h
        imul r8

        inc rcx
        dec r8

        add r9, rax

        cmp r8, 2
        jae loop1
        
        mov rax, r9
        imul mult
        idiv divis

        xor rax, rax
        mov al, [rcx]
        sub al, 30h
        cmp al, dl
        jne invalidCpf

        pop rcx

        xor rax, rax
        mov r8, 0bh
        xor r9, r9

    loop2: mov al, [rcx]
        sub al, 30h
        imul r8

        inc rcx
        dec r8

        add r9, rax

        cmp r8, 2
        jae loop2

        mov rax, r9
        imul mult
        idiv divis
        
        xor rax, rax
        mov al, [rcx]
        sub al, 30h
        cmp al, dl
        jne invalidCpf

        lea rcx, isValid
        call printf
        jmp allDone

invalidCpf: 
        pop rcx
        lea rcx, isInvalid
        call printf

        mov rax, -1
        
    allDone: add rsp, 56
        ret

    valCPF endp

    readCPF proc
        sub rsp, 56

        ; prompt has been passed per parameter
        call printf

        lea rcx, input
        mov rdx, maxLen
        call readLine

        cmp rax, nll
        je badInput

        lea rcx, input
        call valCPF

    badInput: add rsp, 56
        ret
    readCPF endp

    public asmMain

    asmMain proc
        sub rsp, 38h

        lea rcx, promptStr
        call readCPF

        add rsp, 38h
        ret
    asmMain endp
            end