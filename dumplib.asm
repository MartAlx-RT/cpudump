
;------------------------------------------------------
;-----------------PRINT_BOX  FUNCTION------------------
; SETS ES:[DI] to (bl, bh) TO PRINT CENTERING
;-------------------EXPECTED---------------------------
; !! PASCAL CONVENTION !!
; 1st arg(word) - box width
; 2nd arg(word) - box height
;-------------------RETURNS----------------------------
; prints box with left-top at es:[di]
;-------------------DESTROYS---------------------------
; cx, ax and input parameters
;------------------------------------------------------
print_box proc
	push bp
	mov bp, sp

	mov ah, CLR_ATTR

	cmp word ptr [bp+6], 0
		jz @@terminate_print_box			; if you wanna print empty box, go fuck yourself

	xor cx, cx						; set counter (cx) to zero

	cld								; forward 'stosw' mode

	mov al, LTOP					; draw left-top corner
	stosw

	mov cx, [bp+6]
	mov al, HLINE					; draw upper horizontal line
	rep stosw

	mov al, RTOP					; draw right-top corner
	stosw
	add di, LINE_SIZE-2				; -2 because 'stosw' adds 2 to di

	mov cx, [bp+4]
	mov al, VLINE
	@@right:						; draw right line
		stosw
		add di, LINE_SIZE-2
	loop @@right

	std								; reverse 'stosw' mode

	mov al, RBTM					; draw right-bottom corner
	stosw

	mov cx, [bp+6]
	mov al, HLINE					; draw lower horizontal line
	rep stosw
	
	mov al, LBTM					; draw left-bottom corner
	stosw
	sub di, LINE_SIZE-2

	mov cx, [bp+4]
	mov al, VLINE
	@@left:							; draw left line
		stosw
		sub di, LINE_SIZE-2
	loop @@left

	@@terminate_print_box:
	pop bp
	ret 4
print_box endp
;------------------------------------------------------
;------------------------------------------------------



;------------------------------------------------------
;-----------------CLEAR SHELL FUNCTION-----------------
; clears the screen and set default video-mode (number 3)
;-------------------EXPECTED---------------------------
;-------------------RETURNS----------------------------
; cleared screen =)
;-------------------DESTROYS---------------------------
; nothing
;------------------------------------------------------
cls proc
	push ax cx es di

	mov cx, 80*25
	mov ax, VIDEOSEG
	mov es, ax
	xor di, di
	xor ax, ax
	mov ah, 07h
	cld
	rep stosw

	pop di es cx ax
	ret
cls endp
;------------------------------------------------------
;------------------------------------------------------




;------------------------------------------------------
;-----------------STRNCPY       FUNCTION---------------
; copy n bytes from 
;-------------------EXPECTED---------------------------
; cx - strlen
; si - source string
; es:[di] - address for copy to
;-------------------RETURNS----------------------------
; si/di - end of the copied/writed string
;-------------------DESTROYS---------------------------
; ax, cx, df
;------------------------------------------------------
strncpy proc
	mov	ah, CLR_ATTR

	test	cx, cx
	jz	@@strncpy_exit			; length = 0 => exit

	cld
	@@cpy_loop:
		lodsb
		stosw						; copy to es:[di]
	loop	@@cpy_loop

	@@strncpy_exit:
	ret
strncpy endp





;------------------------------------------------------
;-----------------ITOA------FUNCTION-------------------
; writes converted number (0..ffff) to hex as a string
;-------------------EXPECTED---------------------------
; dx - number
; di - end of string for writing to
;-------------------RETURNS----------------------------
; none
;-------------------DESTROYS---------------------------
; ax, cx and input parameters
;------------------------------------------------------
itoa	proc
	mov	cx, 4			; print 4 symbols
	add	di, 6			; set di at the end of the line
	mov	ah, CLR_ATTR

	std
@@itoa_loop:
	mov	al, 0fh
	and	al, dl			; al = lowest nibble

;	cmp	al, 0ah			; print digit or hex-letter
;	jl	@@is_digit
;	add	al, 'A' - '0' - 0ah
;@@is_digit:
;	add	al, '0'
	mov	al, byte ptr hex_dgt[al]

	stosw				; write to VRAM

	shr	dx, 4			; next nibble
loop	@@itoa_loop

	ret
itoa	endp
;------------------------------------------------------------------------------------


; TODO he


;------------------------------------------------------
;-----------------DUMP      FUNCTION-------------------
; dumps registers to the screen in pretty box
;-------------------EXPECTED---------------------------
; nothing
;-------------------RETURNS----------------------------
; none
;-------------------DESTROYS---------------------------
; nothing
;------------------------------------------------------
dump	proc

	pusha					; push AX, CX, DX, BX, SP, BP, SI, DI
	push	ds es				; save all registers

	mov	bp, sp
	add	bp, N_REGS*2			; set bp to ax (ss:[bp] == ax)

	push	cs
	pop	ds
	mov	si, offset reg_msg		; set ds:[si] to reg_msg

	push	VIDEOSEG
	pop	es
	mov	bx, V_STARTPOS * LINE_SIZE	; bx always points to beginning of the line

@@dump_loop:
	mov	di, bx
	add	di, X_STARTPOS			; set di to new line
	mov	cx, MSG_LEN
	call	strncpy				; si -> new reg msg, di -> end of printing

	add	bx, LINE_SIZE

	sub	bp, 2
	mov	dx, [bp]			; get register value
	call	itoa

	cmp	bp, sp
jne	@@dump_loop

	mov	di, (V_STARTPOS-1) * LINE_SIZE
	add	di, X_STARTPOS - 2		; set es:[di] to print box
	push	(MSG_LEN+4)
	push	N_REGS
	call	print_box			; print box

	pop	es ds
	popa					; restore all regs

;	int	20h
	ret

dump	endp
;------------------------------------------------------
;------------------------------------------------------

;------------------------------------------------------------------------------------
