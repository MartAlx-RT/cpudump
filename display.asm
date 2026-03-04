
disp:
	pusha
	push	ds es			; push destructible registers

	cmp	cs:status, NOT_DISP
	je	@@exit

@@save:
	call	save

@@exit:
	pop	es ds
	popa				; restore registers

			db	0eah	; jmp far
	tmr_oldadr	dw	0	;        :[old_adr]
	tmr_oldseg	dw	0	; old_seg:

@@res:
	call	restore
	mov	cs:status, NOT_DISP
	jmp	@@exit



;------------------------------------------------------
;-----------------REFRESH    FUNCTION------------------
; cpy drw_buf -> vram
;-------------------EXPECTED---------------------------
; none
;-------------------RETURNS----------------------------
; none
;-------------------DESTROYS---------------------------
; ds, es, si, di, cx
;------------------------------------------------------
refresh	proc

	push	cs
	pop	ds
	lea	si, drw_buf		; ds:[si] -> drw_buf

	push	VIDEOSEG
	pop	es
	xor	di, di			; es:[di] -> vram

	cld
	mov	cx, SCRN_DIM
	rep	movsw			; cpy drw_buf to vram

	ret

refresh	endp


;------------------------------------------------------
;-----------------REMEMBER   FUNCTION------------------
; cpy vram -> sv_buf
;-------------------EXPECTED---------------------------
; none
;-------------------RETURNS----------------------------
; none
;-------------------DESTROYS---------------------------
; ds, es, si, di, cx
;------------------------------------------------------
remember	proc

	push	VIDEOSEG
	pop	ds
	xor	si, si		; ds:[si] -> vram

	push	cs
	pop	es
	lea	di, sv_buf	; es:[di] -> sv_buf

	cld
	mov	cx, SCRN_DIM
	rep	movsw		; cpy vram to sv_buf

	ret

remember	endp


;------------------------------------------------------
;-----------------RESTORE    FUNCTION------------------
; cpy vram -> sv_buf
;-------------------EXPECTED---------------------------
; none
;-------------------RETURNS----------------------------
; none
;-------------------DESTROYS---------------------------
; ds, es, si, di, cx
;------------------------------------------------------
restore	proc

	push	cs
	pop	ds
	lea	si, sv_buf	; ds:[si] -> sv_buf

	push	VIDEOSEG
	pop	es
	xor	di, di		; es:[di] -> vram

	cld
	mov	cx, SCRN_DIM
	rep	movsw		; cpy vram to sv_buf

	ret

restore	endp


;------------------------------------------------------
;-----------------SAVE       FUNCTION------------------
; does triple bufferization
;-------------------EXPECTED---------------------------
; none
;-------------------RETURNS----------------------------
; none
;-------------------DESTROYS---------------------------
; ds, es, si, di, ax, cx
;------------------------------------------------------
save	proc

	push	VIDEOSEG
	pop	es
	xor	di, di		; es:[di] -> vram

	push	cs
	pop	ds
	lea	si, drw_buf	; ds:[si] -> drw_buf

	mov	cx, SCRN_DIM

	cld
@@loop:
	repe	cmpsw

	mov	ax, word ptr cs:drw_buf[di-2]
	xchg	ax, word ptr es:[di-2]		; sv_buf <- vram, vram -> drw_buf
	xchg	ax, word ptr cs:sv_buf[di-2]

	test	cx, cx
	jnz	@@loop

@@exit:
	ret

save	endp


