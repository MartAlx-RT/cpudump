
;------------------------------------------------------
;-----------------PRINT_BOX  FUNCTION------------------
; SETS ES:[DI] to (bl, bh) TO PRINT CENTERING
;-------------------EXPECTED---------------------------
; !! PASCAL CONVENTION !!
; 1st arg(word) - box width
; 2nd arg(word) - box height
; used CLR_ATTR
;-------------------RETURNS----------------------------
; prints box with left-top at es:[di]
;-------------------DESTROYS---------------------------
; cx, ax and input parameters
;------------------------------------------------------
print_box	proc	

	push	bp
	mov	bp, sp

	mov	ah, CLR_ATTR

	cmp	word ptr ss:[bp+6], 0
	jz	@@exit			; if you wanna print empty box, go fuck yourself

	xor	cx, cx			; set counter (cx) to zero

	cld				; forward 'stosw' mode

	mov	al, LTOP		; draw left-top corner
	stosw

	mov	cx, ss:[bp+6]
	mov	al, HLINE		; draw upper horizontal line
	rep	stosw

	mov	al, RTOP		; draw right-top corner
	stosw
	add	di, LINE_SIZE-2		; -2 because 'stosw' adds 2 to di

	mov	cx, ss:[bp+4]
	mov	al, VLINE
@@right:				; draw right line
	stosw
	add	di, LINE_SIZE-2
loop	@@right

	std				; reverse 'stosw' mode

	mov	al, RBTM		; draw right-bottom corner
	stosw

	mov	cx, ss:[bp+6]
	mov	al, HLINE		; draw lower horizontal line
	rep	stosw

	mov	al, LBTM		; draw left-bottom corner
	stosw
	sub	di, LINE_SIZE-2

	mov	cx, ss:[bp+4]
	mov	al, VLINE
@@left:					; draw left line
	stosw
	sub	di, LINE_SIZE-2
loop	@@left

@@exit:
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
	jz	@@exit		; length = 0 => exit

	cld
	@@loop:
		lodsb
		stosw		; copy to es:[di]
	loop	@@loop

	@@exit:
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
; ax, cx, bx, and input parameters
;------------------------------------------------------
itoa	proc

	mov	cx, 4		; print 4 symbols
	mov	ah, CLR_ATTR
	xor	bx, bx

	cld
@@loop:
	rol	dx, 4
	mov	al, 0fh
	and	al, dl

	mov	bl, al
	mov	al, cs:hex_dgt[bx]
	stosw

loop	@@loop

	ret

itoa	endp
;------------------------------------------------------------------------------------



;------------------------------------------------------------------------------------
