.286
.model tiny

VIDEOSEG	equ	0b800h


.data

.code

org 100h

start	proc

	push	VIDEOSEG
	pop	es

	mov	bx, 160*5 + 80		; 5th line, center
	mov	ah, 4eh
	
next:
	in	al, 60h
	mov	es:[bx], ax
	cmp	al, 2ah			; is it left shift?
	jne	next

	int	20h

start	endp
	
end	start
