.286
.model tiny

locals	@@
VIDEOSEG	equ	0b800h		; video segment
X_STARTPOS	equ	(80d/2 - 9d/2)*2	; left border
SCRN_SIZE	equ	80d*25d*2


LINE_SIZE	equ	160d		; line length in bytes (2 bytes/symbol)
CENTER_POS	equ	80d		; center of line in bytes
VLINE		equ	0bah		; symbol that used as vertical line
HLINE		equ	0cdh		; symbol that used as horizontal line
LTOP		equ	0c9h		; left-top corner symbol
RTOP		equ	0bbh		; right-top corner symbol
LBTM		equ	0c8h		; left-bottom corner symbol
RBTM		equ	0bch		; right-bottom corner symbol
CLR_ATTR	equ	03h

NOT_DISP	equ	0
DRW_DISP	equ	1		; mode enums
SV_DISP		equ	2
RES_DISP	equ	3

V_STARTPOS	equ	5d		; for box

HK_SHOW		equ	44h		; 44h = 'f10'
HK_FOLD		equ	43h		; 43h = 'f9'

.code

org 100h

attach	proc

	push	0
	pop	es			; set es:[di] to int09 cell

	cli
	mov	di, 4*08h
	push	es:[di] es:[di+2]
	pop	tmr_oldseg tmr_oldadr
	mov	word ptr es:[di], offset disp
	mov	word ptr es:[di+2], cs	; write to the interrupt table

	mov	di, 4*09h
	push	es:[di] es:[di+2]
	pop	kb_oldseg kb_oldadr
	mov	word ptr es:[di], offset draw
	mov	word ptr es:[di+2], cs	; write to the interrupt table
	sti

	mov	ax, 3100h
	mov	dx, offset EOP
	shr	dx, 4
	inc	dx

	int	21h			; terminate & stay resident

attach	endp

include display.asm
include	dumplib.asm
include cpudump.asm

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
			db	"SS = "
			db	"DS = "
			db	"ES = "
	N_REGS		equ	($ - offset reg_msg)/MSG_LEN

	hex_dgt		db	"0123456789ABCDEF"

	drw_buf		db	4000d	dup(0)
	sv_buf		db	4000d	dup(0)

	status		db	0

	EOP		db	0		; end of program addr


end	attach
