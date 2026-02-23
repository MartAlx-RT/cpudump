.286
.model tiny

locals	@@
VIDEOSEG	equ	0b800h

.data
.code

org 100h

start	proc

	mov	ax, 3509h
	int	21h
	mov	old_adr, bx		; old interrupt's address
	mov	old_seg, es

	push	0
	pop	es			; set es:[di] to int09 cell
	mov	di, 4*09h

	cli
	mov	word ptr es:[di], offset @@handling
	mov	word ptr es:[di+2], cs	; write to the interrupt table
	sti

	mov	ax, 3100h
	mov	dx, offset EOP
	shr	dx, 4
	inc	dx
	int	21h			; terminate & stay resident


@@handling:
	push	ax di es

	push	VIDEOSEG
	pop	es
	mov	ah, 4eh			; pretty yellow on red
	mov	di, (80*5 + 40)*2	; at the center of the 5th line

	in	al, 60h			; input scancode
	mov	word ptr es:[di], ax	; draw it

	in	al, 61h
	or	al, 80h
	out	61h, al			; confirm receipt
	and	al, not 80h
	out	61h, al

	pop	es di ax

;--------------------------call old interrupt---------------------------------

		db	0eah		; jmp far
	old_adr	dw	0		;        :[old_adr]
	old_seg	dw	0		; old_seg:

	EOP		db	0	; end of program addr

start	endp

end	start
