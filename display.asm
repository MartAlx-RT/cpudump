
disp:
	;cli
	pusha
	push	ds es

	push	cs
	pop	ds


	cmp	cs:status, NOT_DISP
	je	@@exit

	cmp	cs:status, SV_DISP
	je	@@cmp

	cmp	cs:status, RES_DISP
	je	@@res

	; in case DRW_DISP
	call	remember
	call	refresh
	mov	cs:status, SV_DISP

@@cmp:
	call	buf_cmp

@@exit:
	pop	es ds
	popa
	;sti
			db	0eah	; jmp far
	tmr_oldadr	dw	0	;        :[old_adr]
	tmr_oldseg	dw	0	; old_seg:

@@res:
	call	restore
	mov	cs:status, NOT_DISP
	jmp	@@exit



refresh	proc

	push	cs
	pop	ds
	lea	si, drw_buf

	push	VIDEOSEG
	pop	es
	xor	di, di

	cld
	mov	cx, SCRN_SIZE/2			; TODO think about mosw
	rep	movsw

	ret

refresh	endp


remember	proc

	push	VIDEOSEG
	pop	ds
	xor	si, si

	push	cs
	pop	es
	lea	di, sv_buf

	cld
	mov	cx, SCRN_SIZE/2
	rep	movsw

	ret

remember	endp


restore	proc

	push	cs
	pop	ds
	lea	si, sv_buf

	push	VIDEOSEG
	pop	es
	xor	di, di

	cld
	mov	cx, SCRN_SIZE/2
	rep	movsw

	ret

restore	endp


buf_cmp	proc

	push	VIDEOSEG
	pop	es
	xor	di, di

	push	cs
	pop	ds
	lea	si, drw_buf

	mov	cx, SCRN_SIZE/2

	cld
@@loop:
	repe	cmpsw
	je	@@exit

	mov	ax, word ptr cs:drw_buf[di-2]
	xchg	ax, word ptr es:[di-2]
	xchg	ax, word ptr cs:sv_buf[di-2]

	test	cx, cx
	jnz	@@loop

@@exit:
	ret

buf_cmp	endp


