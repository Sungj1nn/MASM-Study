option casemap:none


maxLen = 0100h
NULL   = 0
nl     = 0ah

; New data declaration section
; .const holds data values for read-only constants.
.const
	ttlStr      byte  'Packing Data',0
	moPrompt    byte  'Enter current month: ',0
	dayPrompt   byte  'Enter current day: ',0
	yearPrompt  byte  'Enter current year '
				byte  '(last 2 digits only): ',0
	
	packed      byte  'Packed date is %04x',nl,0
	
	theDate     byte  'The date is %02d/%02d/%02d',nl,0
	
	badDayStr   byte  'Bad day value was entered '
				byte  '(expected 1-31)',nl,0
	
	badMonthStr byte  'Bad month value was entered '
				byte  '(expected 1-12)',nl,0
	
	badYearStr  byte  'Bad year value was entered '
				byte  '(expected 00-99)',nl,0

.data
	month  byte  ?
	year   word  ?
	day    byte  ?
	date   dword  ?
	
	input  byte  maxLen dup (?)

.code
	externdef printf:proc
	externdef readLine:proc
	externdef atoi:proc

	public getTitle
	
	getTitle proc
		
		lea rax, ttlStr
		ret
		
	getTitle endp
	
	readNum proc
		
		; Must set up stack properly (using this "magic" instruction) before
		; we can call any C/C++ functions:
		sub rsp, 038h
		
		; Print the prompt message. Note that the prompt message was passed to
		; this procedure in RCX, we're just passing it on to printf:
		call printf
		
		; Set up args for readLine
		lea rcx, input
		mov rdx, maxLen
		call readLine
		
		; Test for a bad input string
		cmp rax, NULL
		je badInput
		
		; Try Convert string to an integer by calling atoi
		lea rcx, input
		call atoi
		
		badInput:
			add rsp, 038h
			ret
		
	readNum endp
	
	public asmMain
	
	asmMain proc
		
		; Prepare stack
		sub rsp, 038h
		
		; Read month from user
		lea rcx, moPrompt
		call readNum
		
		; Verify the month is in the range 1..12:
		cmp rax, 1
		jl  badMonth
		cmp rax, 12
		jg  badMonth
		
		;Good Month, Save it for now
		mov month, al    ; 1..12 fits in a byte
		
		; Read the day
		lea rcx, dayPrompt
		call readNum
		
		; Verify the day is in the range 1..31:
		cmp rax, 1
		jl  badDay
		cmp rax, 31
		ja  badDay
		
		;Good day, Save it for now
		mov day, al         ; fits in a byte
		
		; Read the year
		lea rcx, yearPrompt
		call readNum
		
		; Verify the year is in the range 00..65,536
		cmp rax, 0
		jl  badYear
		cmp rax, 10000h
		jg  badYear
		
		; Good year, save it for now
		mov year, ax  ; 0..99 fits in a byte
		
		; Pack the data
		movzx eax, year
		shl   eax, 8
		or    al, month
		shl   eax, 8
		or    al, day
		mov   date, eax
		
		; Print the packed date:
		lea rcx, packed
		mov edx, date
		call printf
		
		; Unpack the date and print it:
		mov edx, date
		mov   r9, rdx
		and   r9, 0ffff0000h   ; keep LO 16 bits (year)
		shr   r9, 10h
		and   rdx,0000ffffh   ; remove HO 16 bits
		mov   r8, rdx
		and   r8, 0000ff00h   ; keep  LO 8 bits (month)
		shr   r8, 8
		and   rdx,0ffh     ; keep  LO 8 bits (day)
		lea   rcx, theDate
		call printf
		
		; rcx, rdx, r8, r9
		
		jmp allDone
		
		
		; Come down here if a bad day was entered:
		badDay:
			lea rcx, badDayStr
			call printf
			jmp allDone
		
		; Come down here if a bad month was entered:
		badMonth:
			lea rcx, badMonthStr
			call printf
			jmp allDone
		
		; Come down here if a bad year was entered:
		badYear:
			lea rcx, badYearStr
			call printf
		
		allDone:
			add rsp, 38h
			ret
		
	asmMain endp
			end

