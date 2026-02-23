.286
.model tiny

locals	@@
VIDEOSEG	equ	0b800h

.data
	old_int		dd	19a400c1h
.code

org 100h

start	proc

	mov	ax, 3509h
	int	21h
	mov	var1, bx
	mov	var2, es

	push	0
	pop	es			; set es:[di] to int09 cell
	mov	di, 4*09h

	cli
	push	es:[di]
	push	es:[di+2]

	mov	word ptr es:[di], offset @@handling
	mov	word ptr es:[di+2], cs
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
	mov	ah, 4eh			; pretty yellow on red style
	mov	di, (80*5 + 40)*2

	in	al, 60h			; input scancode
	mov	word ptr es:[di], ax	; draw it

	in	al, 61h
	or	al, 80h
	out	61h, al			; confirm
	and	al, not 80h
	out	61h, al

	pop	es di ax

	db	0eah
	var1	dw	0
	var2	dw	0

EOP		db	0

start	endp

end	start
