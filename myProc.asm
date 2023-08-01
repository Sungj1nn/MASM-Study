option casemap:none

.data
	fmtStr byte 'Hello, World!'

.code
	
	externdef printf:proc
	
	public printFunc
	
	printFunc PROC
		
		; Add space in the stack for our parameters?
		sub rsp, 56
		
		lea rcx, fmtStr
		call printf
		
		add rsp, 56 ; restore the stack
		
		ret
	printFunc endp
		end