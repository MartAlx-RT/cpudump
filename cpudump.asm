.286
.model tiny

locals	@@
VIDEOSEG	equ	0b800h
X_STARTPOS	equ	(80/2 - 9/2)*2
START_POS	equ	(25/2 - 8/2)*80*2 + X_STARTPOS


LINE_SIZE	equ	160		; line length in bytes (2 bytes/symbol)
CENTER_POS	equ	80		; center of line in bytes
VLINE		equ	0bah		; symbol that used as vertical line
HLINE		equ	0cdh		; symbol that used as horizontal line
LTOP		equ	0c9h		; left-top corner symbol
RTOP		equ	0bbh		; right-top corner symbol
LBTM		equ	0c8h		; left-bottom corner symbol
RBTM		equ	0bch		; right-bottom corner symbol
CLR_ATTR	equ	03h

V_STARTPOS	equ	5d		; for box
HOTKEY		equ	2		; key '1'

.code

org 100h

;------------------------------------------------------
;-----------------ATTACH_INT FUNCTION------------------
; set dumpbox interrupt
;-------------------EXPECTED---------------------------
; dx - number
; di - end of string for writing to
;-------------------RETURNS----------------------------
; none
;-------------------DESTROYS---------------------------
; ax, cx and input parameters
;------------------------------------------------------
attach_int	proc

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
	pusha
	push	ds es

	in	al, 60h			; input scancode
	cmp	al, HOTKEY
	jne	@@old_int
	
	call	dump

	in	al, 61h
	or	al, 80h
	out	61h, al			; confirm receipt
	and	al, not 80h
	out	61h, al

	pop	es ds
	popa
	iret



;----------------call old interrupt--------------------
@@old_int:
	pop	es ds
	popa

		db	0eah		; jmp far
	old_adr	dw	0		;        :[old_adr]
	old_seg	dw	0		; old_seg:

attach_int	endp
;------------------------------------------------------
;------------------------------------------------------



include	dumplib.asm

.data
	MSG_LEN		equ	5		; !!! HARDCODE !!! be careful
	reg_msg		db	"AX = "
			db	"CX = "
			db	"DX = "
			db	"BX = "
			db	"SP = "
			db	"BP = "
			db	"SI = "
			db	"DI = "
			db	"DS = "
			db	"ES = "
	N_REGS		equ	($ - offset reg_msg)/MSG_LEN

EOP	db	0		; end of program addr


end	attach_int
