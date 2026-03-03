
draw:
	pusha					; push AX CX DX BX SP BP SI DI
	mov	bp, sp				; bp -> di
	add	bp, 3*2
	add	word ptr ss:[bp], 3*2		; correct sp value

	mov	bp, sp				; bp -> di
	add	bp, 8*2 + 1*2			; bp -> cs (next: ip ax cx dx ...)

	push	ss:[bp] ss:[bp-2] ss ds es	; push cs ip ds es ss

	; FINALLY: ax cx dx bx sp bp si di cs ip ds es ss PUSHED
	;------------------------------------------------------

	in	al, 60h				; input scancode

	push	ax
	in	al, 61h
	or	al, 80h
	out	61h, al				; confirm receipt
	and	al, not 80h
	out	61h, al
	pop	ax

	cmp	al, HK_SHOW
	jne	@@if_fold			; execute old interrupt if there isn't HOTKEY
	cmp	cs:status, NOT_DISP
	jne	@@exit

	call	dump
	mov	cs:status, DRW_DISP
	jmp	@@exit

@@if_fold:
	cmp	al, HK_FOLD
	jne	@@old_int

	mov	cs:status, RES_DISP


@@exit:
	mov	al, 20h				; notify dos about terminating
	out	20h, al

	pop	es ds
	add	sp, 3*2				; skip ip and cs
	popa

	iret
;------------------------------------------------------



; calling old interrupt
;------------------------------------------------------
@@old_int:                                       
	pop	es ds                          
	add	sp, 3*2			; skip ip, cs
	popa                                   

			db	0eah	; jmp far
	kb_oldadr	dw	0	;        :[old_adr]
	kb_oldseg	dw	0	; old_seg:
;------------------------------------------------------
;------------------------------------------------------

; dump function
;------------------------------------------------------
dump	proc

	mov	bp, sp
	add	bp, N_REGS*2			; set bp to ax (ss:[bp] == ax)

	push	cs
	pop	ds
	lea	si, reg_msg			; ds:[si] -> "ax = ", "bx = ", ...

	push	cs
	pop	es
	lea	bx, drw_buf[V_STARTPOS*LINE_SIZE]	; bx -> line beginning

	@@loop:
		mov	di, bx
		add	di, X_STARTPOS		; set di to new line

		mov	cx, MSG_LEN
		call	strncpy			; si -> new reg msg, di -> end of printing

		add	bx, LINE_SIZE

		mov	dx, ss:[bp]		; get register value
		sub	bp, 2

		push	bx
		call	itoa			; print dx on the screen
		pop	bx

		cmp	bp, sp
	ja	@@loop

	lea	di, drw_buf[(V_STARTPOS - 1)*LINE_SIZE + (X_STARTPOS - 2)] ; bx -> line beginning
	push	(MSG_LEN+4)
	push	N_REGS
	call	print_box			; print box
	ret

dump	endp
;------------------------------------------------------
;------------------------------------------------------

