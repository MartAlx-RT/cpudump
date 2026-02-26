.286
.model tiny

locals	@@
VIDEOSEG	equ	0b800h		; video segment
X_STARTPOS	equ	(80/2 - 9/2)*2	; left border


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
HOTKEY		equ	44h		; 44h = 'f10'

.code

org 100h


; attaching this interrupt
;------------------------------------------------------
attach:

	mov	ax, 3509h
	int	21h
	mov	old_adr, bx		; old interrupt's address
	mov	old_seg, es

	push	0
	pop	es			; set es:[di] to int09 cell
	mov	di, 4*09h

	cli
	mov	word ptr es:[di], offset handling
	mov	word ptr es:[di+2], cs	; write to the interrupt table
	sti

	mov	ax, 3100h
	mov	dx, offset EOP
	shr	dx, 4
	inc	dx

	int	21h			; terminate & stay resident
;------------------------------------------------------

; handling this interrupt
;------------------------------------------------------
handling:
	pusha					; push AX CX DX BX SP BP SI DI
	mov	bp, sp				; bp -> di
	add	bp, 8*2 + 2*2 - 2		; bp -> cs (next: ip ax cx dx ...)
						; -2 because sp points to actual value
	push	ss:[bp] ss:[bp-2] ds es		; push cs ip ds es

	; FINALLY: ax cx dx bx sp bp si di cs ip ds es PUSHED
	;------------------------------------------------------

	in	al, 60h				; input scancode
	cmp	al, HOTKEY
	jne	old_int				; execute old interrupt if there isn't HOTKEY
	
	jmp	dump				; will return to terminating:
	terminating:					

	in	al, 61h
	or	al, 80h
	out	61h, al				; confirm receipt
	and	al, not 80h
	out	61h, al

	mov	al, 20h				; notify dos about terminating
	out	20h, al

	pop	es ds
	add	sp, 2*2				; skip ip and cs
	popa

	iret
;------------------------------------------------------



; calling old interrupt
;------------------------------------------------------
old_int:
	pop	es ds
	add	sp, 2*2			; skip ip, cs
	popa

		db	0eah		; jmp far
	old_adr	dw	0		;        :[old_adr]
	old_seg	dw	0		; old_seg:
;------------------------------------------------------
;------------------------------------------------------

; dump function
;------------------------------------------------------
dump:

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
		add	di, X_STARTPOS		; set di to new line
		mov	cx, MSG_LEN
		call	strncpy			; si -> new reg msg, di -> end of printing
	
		add	bx, LINE_SIZE
	
		sub	bp, 2
		mov	dx, ss:[bp]		; get register value
		push	bx
		call	itoa			; print dx on the screen
		pop	bx
	
		cmp	bp, sp
	jne	@@dump_loop

	mov	di, (V_STARTPOS-1) * LINE_SIZE
	add	di, X_STARTPOS - 2		; set es:[di] to print box
	push	(MSG_LEN+4)
	push	N_REGS
	call	print_box			; print box

	jmp	terminating
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
			db	"CS = "
			db	"IP = "
			db	"DS = "
			db	"ES = "
	N_REGS		equ	($ - offset reg_msg)/MSG_LEN

	hex_dgt		db	"0123456789ABCDEF"

	EOP		db	0		; end of program addr


end	attach
