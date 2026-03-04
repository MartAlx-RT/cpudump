.286
.model tiny

locals	@@
VIDEOSEG	equ	0b800h		; video segment
X_STARTPOS	equ	(80d/2 - 9d/2)*2; left border
SCRN_DIM	equ	80d*25d


LINE_SIZE	equ	160d		; line length in bytes (2 bytes/symbol)
VLINE		equ	0bah		; symbol that used as vertical line
HLINE		equ	0cdh		; symbol that used as horizontal line
LTOP		equ	0c9h		; left-top corner symbol
RTOP		equ	0bbh		; right-top corner symbol
LBTM		equ	0c8h		; left-bottom corner symbol
RBTM		equ	0bch		; right-bottom corner symbol
CLR_ATTR	equ	03h

; enum status
NOT_DISP	equ	0		; do not display buffer
SV_DISP		equ	1		; every timer check vram and do triple bufferization
;

V_STARTPOS	equ	5d		; vertical initial position

HK_SHOW		equ	44h		; 44h = 'f10'
HK_FOLD		equ	43h		; 43h = 'f9'

.code

org 100h

attach	proc

	push	0
	pop	es

	cli
	mov	di, 4*08h			; attach int 08h
	push	es:[di] es:[di+2]
	pop	tmr_oldseg tmr_oldadr		; save old int addr
	mov	word ptr es:[di], offset disp
	mov	word ptr es:[di+2], cs		; write to the int table

	mov	di, 4*09h			; attach int 09h
	push	es:[di] es:[di+2]
	pop	kb_oldseg kb_oldadr		; save old int addr
	mov	word ptr es:[di], offset write
	mov	word ptr es:[di+2], cs		; write to the int table
	sti

	mov	ax, 3100h
	lea	dx, EOP
	shr	dx, 4
	inc	dx

	int	21h				; terminate & stay resident

attach	endp

include display.asm
include	writelib.asm
include write.asm

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
