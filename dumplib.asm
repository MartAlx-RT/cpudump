
;------------------------------------------------------
;-----------------PRINT_BOX  FUNCTION------------------
; SETS ES:[DI] to (bl, bh) TO PRINT CENTERING
;-------------------EXPECTED---------------------------
; !! PASCAL CONVENTION !!
; 1st arg(word) - box width
; 2nd arg(word) - box height
; used clr_attr
;-------------------RETURNS----------------------------
; prints box with left-top at es:[di]
;-------------------DESTROYS---------------------------
; cx, ax and input parameters
;------------------------------------------------------
print_box	proc	

	push	bp
	mov	bp, sp

	mov	ah, clr_attr

	cmp	word ptr [bp+6], 0
	jz	@@terminate_print_box	; if you wanna print	empty box, go fuck yourself

	xor	cx, cx			; set counter (cx) to zero

	cld				; forward 'stosw' mode

	mov	al, LTOP		; draw left-top corner
	stosw

	mov	cx, [bp+6]
	mov	al, HLINE		; draw upper horizontal line
	rep	stosw

	mov	al, RTOP		; draw right-top corner
	stosw
	add	di, LINE_SIZE-2		; -2 because 'stosw' adds 2 to di

	mov	cx, [bp+4]
	mov	al, VLINE
@@right:				; draw right line
	stosw
	add	di, LINE_SIZE-2
loop	@@right

	std				; reverse 'stosw' mode

	mov	al, RBTM		; draw right-bottom corner
	stosw

	mov	cx, [bp+6]
	mov	al, HLINE		; draw lower horizontal line
	rep	stosw
	
	mov	al, LBTM		; draw left-bottom corner
	stosw
	sub	di, LINE_SIZE-2

	mov	cx, [bp+4]
	mov	al, VLINE
@@left:					; draw left line
	stosw
	sub	di, LINE_SIZE-2
loop	@@left

@@terminate_print_box:
	pop	bp
	ret	4

print_box	endp
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
	@@strncpy_loop:
		lodsb
		stosw						; copy to es:[di]
	loop	@@strncpy_loop

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
; ax, cx, bx, dx and input parameters
;------------------------------------------------------
itoa	proc
	mov	cx, 4			; print 4 symbols
	add	di, 6			; set di at the end of the line
	mov	ah, CLR_ATTR
	xor	bx, bx

	std

@@itoa_loop:
	mov	al, 0fh
	and	al, dl			; al = lowest nibble

	mov	bl, al
	mov	al, hex_dgt[bx]		; nibble -> digit

	stosw				; write to VRAM

	shr	dx, 4			; next nibble
loop	@@itoa_loop

	ret
itoa	endp
;------------------------------------------------------------------------------------



;------------------------------------------------------------------------------------
