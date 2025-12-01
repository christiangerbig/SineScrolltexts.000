; Requirement
; 68000+
; OCS+
; 1.2+


; 1 column = 1 pixel
; 16x16 pixel characters in 2 colours
; 1x sine movement
; Deleting the playfield is no longer necessary, because the character images
; are deleted by the character copy blit


; Execution time MC68000: 243 rasterlines


	MC68000


	INCDIR "include3.5:"

	INCLUDE "exec/exec.i"
	INCLUDE "exec/exec_lib.i"

	INCLUDE "dos/dos.i"
	INCLUDE "dos/dos_lib.i"
	INCLUDE "dos/dosextens.i"

	INCLUDE "graphics/gfxbase.i"
	INCLUDE "graphics/graphics_lib.i"
	INCLUDE "graphics/videocontrol.i"

	INCLUDE "intuition/intuition.i"
	INCLUDE "intuition/intuition_lib.i"

	INCLUDE "libraries/any_lib.i"

	INCLUDE "resources/cia_lib.i"

	INCLUDE "hardware/adkbits.i"
	INCLUDE "hardware/blit.i"
	INCLUDE "hardware/cia.i"
	INCLUDE "hardware/custom.i"
	INCLUDE "hardware/dmabits.i"
	INCLUDE "hardware/intbits.i"


	INCDIR "custom-includes-ocs:"


SET_SECOND_COPPERLIST		SET 1
MEASURE_RASTERTIME		SET 1


	INCLUDE "macros.i"


	INCLUDE "equals.i"

requires_030_cpu		EQU FALSE	
requires_040_cpu		EQU FALSE
requires_060_cpu		EQU FALSE
requires_fast_memory		EQU FALSE
requires_multiscan_monitor	EQU FALSE

workbench_start_enabled		EQU FALSE
screen_fader_enabled		EQU FALSE
text_output_enabled		EQU FALSE

dma_bits			EQU DMAF_BLITTER|DMAF_COPPER|DMAF_RASTER|DMAF_MASTER|DMAF_SETCLR

intena_bits			EQU INTF_SETCLR

ciaa_icr_bits			EQU CIAICRF_SETCLR
ciab_icr_bits			EQU CIAICRF_SETCLR

copcon_bits			EQU 0

pf1_x_size1			EQU 0
pf1_y_size1			EQU 0
pf1_depth1			EQU 0
pf1_x_size2			EQU 512
pf1_y_size2			EQU 256+(16*2)
pf1_depth2			EQU 1
pf1_x_size3			EQU 512
pf1_y_size3			EQU 256+(16*2)
pf1_depth3			EQU 1
pf1_colors_number		EQU 0	; 2

pf2_x_size1			EQU 0
pf2_y_size1			EQU 0
pf2_depth1			EQU 0
pf2_x_size2			EQU 0
pf2_y_size2			EQU 0
pf2_depth2			EQU 0
pf2_x_size3			EQU 0
pf2_y_size3			EQU 0
pf2_depth3			EQU 0
pf2_colors_number		EQU 0
pf_colors_number		EQU pf1_colors_number+pf2_colors_number
pf_depth			EQU pf1_depth3+pf2_depth3

pf_extra_number			EQU 1
extra_pf1_x_size		EQU 384
extra_pf1_y_size		EQU 16+(16*2)
extra_pf1_depth			EQU 1

spr_number			EQU 0
spr_x_size1			EQU 0
spr_x_size2			EQU 0
spr_depth			EQU 0
spr_colors_number		EQU 0

audio_memory_size		EQU 0

disk_memory_size		EQU 0

extra_memory_size		EQU 0

chip_memory_size		EQU 0

ciaa_ta_time			EQU 0
ciaa_tb_time			EQU 0
ciab_ta_time			EQU 0
ciab_tb_time			EQU 0
ciaa_ta_continuous_enabled	EQU FALSE
ciaa_tb_continuous_enabled	EQU FALSE
ciab_ta_continuous_enabled	EQU FALSE
ciab_tb_continuous_enabled	EQU FALSE

beam_position			EQU $136

pixel_per_line			EQU 320
visible_pixels_number		EQU 320
visible_lines_number		EQU 256
MINROW				EQU VSTART_256_LINES

display_window_hstart		EQU HSTART_320_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_320_PIXEL
display_window_vstop		EQU VSTOP_256_LINES

pf1_plane_width			EQU pf1_x_size3/8
extra_pf1_plane_width		EQU extra_pf1_x_size/8
data_fetch_width		EQU pixel_per_line/8
pf1_plane_moduli		EQU (pf1_plane_width*(pf1_depth3-1))+pf1_plane_width-data_fetch_width

diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
ddfstrt_bits			EQU DDFSTRT_320_PIXEL
ddfstop_bits			EQU DDFSTOP_320_PIXEL
bplcon0_bits			EQU BPLCON0F_COLOR|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon1_bits			EQU 0
bplcon2_bits			EQU 0
color00_bits			EQU $012

cl1_hstart			EQU 0
cl1_vstart			EQU beam_position&CL_Y_WRAPPING

sine_table_length		EQU 512

; Sine-Scrolltext
ss_image_x_size			EQU 320
ss_image_plane_width		EQU ss_image_x_size/8
ss_image_depth			EQU 1
ss_origin_char_x_size		EQU 16
ss_origin_char_y_size		EQU 16

ss_text_char_x_size		EQU 16
ss_text_char_width		EQU ss_text_char_x_size/8
ss_text_char_y_size		EQU ss_origin_char_y_size
ss_text_char_depth		EQU ss_image_depth

ss_sine_char_x_size		EQU 16
ss_sine_char_width		EQU ss_sine_char_x_size/8
ss_sine_char_y_size1		EQU extra_pf1_y_size
ss_sine_char_y_size2		EQU ss_text_char_y_size
ss_sine_char_depth		EQU pf1_depth3

ss_horiz_scroll_window_x_size	EQU visible_pixels_number+(ss_text_char_x_size*2)
ss_horiz_scroll_window_width	EQU ss_horiz_scroll_window_x_size/8
ss_horiz_scroll_window_y_size	EQU ss_text_char_y_size
ss_horiz_scroll_window_depth	EQU ss_image_depth
ss_horiz_scroll_speed		EQU 2

ss_text_char_x_restart		EQU ss_horiz_scroll_window_x_size-ss_text_char_x_size
ss_text_chars_number		EQU ss_horiz_scroll_window_x_size/ss_text_char_x_size

ss_text_x_position		EQU 0
ss_text_y_position		EQU ss_text_char_y_size
ss_text_y_center		EQU (visible_lines_number-ss_text_char_y_size)/2
ss_text_y_radius		EQU (visible_lines_number-ss_text_char_y_size)/2
ss_text_y_angle_speed		EQU 2
ss_text_y_angle_step		EQU 1

ss_text_columns_x_size		EQU 1
ss_text_columns_number		EQU visible_pixels_number/ss_text_columns_x_size
ss_text_columns_per_word	EQU WORD_BITS/ss_text_columns_x_size


pf1_plane_x_offset		EQU 0
pf1_plane_y_offset		EQU ss_text_y_position


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

cl1_WAIT1			RS.L 1
cl1_WAIT2			RS.L 1
cl1_INTREQ			RS.L 1

cl1_end				RS.L 1

copperlist1_size		RS.B 0


	RSRESET

cl2_begin			RS.B 0

cl2_end				RS.L 1

copperlist2_size		RS.B 0


cl1_size1			EQU 0
cl1_size2			EQU 0
cl1_size3			EQU copperlist1_size
cl2_size1			EQU 0
cl2_size2			EQU 0
cl2_size3			EQU copperlist2_size


spr0_x_size1			EQU spr_x_size1
spr0_y_size1			EQU 0
spr1_x_size1			EQU spr_x_size1
spr1_y_size1			EQU 0
spr2_x_size1			EQU spr_x_size1
spr2_y_size1			EQU 0
spr3_x_size1			EQU spr_x_size1
spr3_y_size1			EQU 0
spr4_x_size1			EQU spr_x_size1
spr4_y_size1			EQU 0
spr5_x_size1			EQU spr_x_size1
spr5_y_size1			EQU 0
spr6_x_size1			EQU spr_x_size1
spr6_y_size1			EQU 0
spr7_x_size1			EQU spr_x_size1
spr7_y_size1			EQU 0

spr0_x_size2			EQU spr_x_size2
spr0_y_size2			EQU 0
spr1_x_size2			EQU spr_x_size2
spr1_y_size2			EQU 0
spr2_x_size2			EQU spr_x_size2
spr2_y_size2			EQU 0
spr3_x_size2			EQU spr_x_size2
spr3_y_size2			EQU 0
spr4_x_size2			EQU spr_x_size2
spr4_y_size2			EQU 0
spr5_x_size2			EQU spr_x_size2
spr5_y_size2			EQU 0
spr6_x_size2			EQU spr_x_size2
spr6_y_size2			EQU 0
spr7_x_size2			EQU spr_x_size2
spr7_y_size2			EQU 0


	RSRESET

	INCLUDE "main-variables.i"

save_a7				RS.L 1

; Sine-Scrolltext
ss_image			RS.L 1
ss_text_table_start		RS.W 1
ss_text_char_x_shift		RS.W 1
ss_text_y_angle			RS.W 1

variables_size			RS.B 0


	SECTION code,CODE


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; Sine-Scrolltext
	lea	ss_image_data,a0
	move.l	a0,ss_image(a3)
	moveq	#0,d0
	move.w	d0,ss_text_table_start(a3)
	move.w	d0,ss_text_char_x_shift(a3)
	move.w	d0,ss_text_y_angle(a3)

	rts


	CNOP 0,4
init_main
	bsr.s	init_colors
	bsr.s	ss_init_chars_offsets
	bsr.s	init_first_copperlist
	bra	init_second_copperlist


	CNOP 0,4
init_colors
	CPU_INIT_COLOR COLOR00,2,pf1_rgb4_color_table
	rts


; Sine-Scrolltext
	INIT_CHARS_OFFSETS.W ss


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0
	bsr.s	cl1_init_playfield_props
	bsr	cl1_init_bitplane_pointers
	bsr	cl1_init_copper_interrupt
	COP_LISTEND
	bra	cl1_set_bitplane_pointers


	COP_INIT_PLAYFIELD_REGISTERS cl1


	COP_INIT_BITPLANE_POINTERS cl1


	COP_INIT_COPINT cl1,cl1_hstart,cl1_vstart,YWRAP


	COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3


	CNOP 0,4
init_second_copperlist
	move.l	cl2_display(a3),a0
	COP_LISTEND
	rts


	CNOP 0,4
main
	bsr.s	no_sync_routines
	bra.s	beam_routines


	CNOP 0,4
no_sync_routines
	rts


	CNOP 0,4
beam_routines
	bsr	wait_copint
	bsr.s	swap_playfield1
	bsr.s	set_playfield1
	bsr.s	ss_sine_scroll
	bsr	ss_horiz_scrolltext
	bsr	ss_horiz_scroll
	RASTER_TIME
	btst	#CIAB_GAMEPORT0,CIAPRA(a4) ; LMB pressed ?
	bne.s	beam_routines
	rts


	SWAP_PLAYFIELD pf1,2


	SET_PLAYFIELD pf1,pf1_depth3,pf1_plane_x_offset,pf1_plane_y_offset


	CNOP 0,4
ss_sine_scroll
	movem.l a3-a5,-(a7)
	move.l	a7,save_a7(a3)
	bsr	ss_sine_scroll_init
	move.w	ss_text_y_angle(a3),d2	; 1st y angle
	move.w	d2,d0
	MOVEF.W (sine_table_length-1)*WORD_SIZE,d3 ; overflow 360°
	addq.w	#ss_text_y_angle_speed*WORD_SIZE,d0
	and.w	d3,d0			; remove overflow
	move.w	d0,ss_text_y_angle(a3) 
	move.w	#BC0F_SRCA|BC0F_SRCB|BC0F_DEST|NABNC|NABC|ANBNC|ANBC|ABNC|ABC,d5 ; 2nd minterm D = A+B
	lea	sine_table(pc),a0
	move.w	#ss_text_y_center,a1
	move.l	extra_pf1(a3),a2	; source
	ADDF.W	visible_pixels_number/8,a2 ; end of line
	move.l	pf1_construction2(a3),a4 ; destination
	lea	(ss_text_x_position/8)+(ss_text_y_position*extra_pf1_plane_width*extra_pf1_depth)(a2),a3 ; source2
	ADDF.W	(visible_pixels_number-ss_sine_char_x_size)/8,a4 ; end of line
	lea	(ss_text_x_position/8)+(ss_text_y_position*pf1_plane_width*pf1_depth3)(a4),a5 ; destination2
	move.w	#((ss_sine_char_y_size2*ss_sine_char_depth)<<6)|(ss_sine_char_x_size/WORD_BITS),a7 ; 2nd BLTSIZE
	moveq	#(ss_text_columns_number/WORD_BITS)-1,d7
ss_sine_scroll_loop1
	move.w	(a0,d2.w),d0		; sin(w)
	MULSF.W ss_text_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	add.w	a1,d0			; y' + y center
	ext.l	d0
	MULUF.L pf1_plane_width*pf1_depth3,d0,d1 ; y offset in destination1
	MOVEF.W $ff>>(8-ss_text_columns_x_size),d4 ; mask
	add.l	a4,d0			; add destinaton1 address
	WAITBLIT
	move.w	#BC0F_SRCA|BC0F_DEST|ANBNC|ANBC|ABNC|ABC,BLTCON0-DMACONR(a6) ; minterm D = A
	move.w	d4,BLTALWM-DMACONR(a6)
	move.l	a2,BLTAPT-DMACONR(a6)	; scrolltext
	move.l	d0,BLTDPT-DMACONR(a6)	; playfield write
	move.w	#((ss_sine_char_y_size1*pf1_depth3)<<6)|(ss_sine_char_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
	addq.w	#ss_text_y_angle_step*WORD_SIZE,d2
	and.w	d3,d2			; remove overflow
	subq.w	#ss_sine_char_width,a2	; next character in source1
	subq.w	#ss_sine_char_width,a4	; next character in destination1
	moveq	#(ss_text_columns_per_word-1)-1,d6
ss_sine_scroll_loop2
	move.w	(a0,d2.w),d0		; sin(w)
	MULSF.W ss_text_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	add.w	a1,d0			; y' + y center
	ext.l	d0
	MULUF.L pf1_plane_width*pf1_depth3,d0,d1 ; y offset in destination2
	IFEQ ss_text_columns_x_size-1
		MULUF.W 2,d4		; shift mask 1 bit left
	ELSE
		IFEQ ss_text_columns_x_size-2
			MULUF.W 4,d4	; shift mask 2 bits lefr
		ELSE
			lsl.w	#ss_text_columns_x_size,d4 ; shift mask n bits left
		ENDC
	ENDC
	add.l	a5,d0			; add destination2 address
	WAITBLIT
	move.w	d5,BLTCON0-DMACONR(a6)	; minterm D = A+B
	move.w	d4,BLTALWM-DMACONR(a6)
	movem.l	d0/a3,BLTBPT-DMACONR(a6) ; playfield read, scrolltext
	move.l	d0,BLTDPT-DMACONR(a6)	; playfield write
	move.w	a7,BLTSIZE-DMACONR(a6)
	addq.w	#ss_text_y_angle_step*WORD_SIZE,d2
	and.w	d3,d2			; remove overflow
	dbf	d6,ss_sine_scroll_loop2
	subq.w	#ss_sine_char_width,a3	; next character in source2
	subq.w	#ss_sine_char_width,a5	; next character in destination2
	dbf	d7,ss_sine_scroll_loop1
	move.w	#DMAF_BLITHOG,DMACON-DMACONR(a6)
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a5
	rts
	CNOP 0,4
ss_sine_scroll_init
	move.w	#DMAF_BLITHOG|DMAF_SETCLR,DMACON-DMACONR(a6)
	moveq	#0,d0
	WAITBLIT
	move.w	d0,BLTCON1-DMACONR(a6)
	moveq	#FALSE,d0
	move.w	d0,BLTAFWM-DMACONR(a6)
	move.l	#((pf1_plane_width-ss_sine_char_width)<<16)|(extra_pf1_plane_width-ss_sine_char_width),BLTBMOD-DMACONR(a6) ; B&A moduli
	move.w	#pf1_plane_width-ss_sine_char_width,BLTDMOD-DMACONR(a6)
	rts


	CNOP 0,4
ss_horiz_scrolltext
	move.w	ss_text_char_x_shift(a3),d2
	addq.w	#ss_horiz_scroll_speed,d2
	cmp.w	#ss_text_char_x_size,d2
	blt.s	ss_horiz_scrolltext_skip
	bsr.s	ss_get_new_char_image
	move.l	extra_pf1(a3),d1
	ADDF.L	(ss_text_char_x_restart/8)+(ss_text_y_position*extra_pf1_plane_width*extra_pf1_depth),d1
	WAITBLIT
	move.l	#(BC0F_SRCA|BC0F_DEST|ANBNC|ANBC|ABNC|ABC)<<16,BLTCON0-DMACONR(a6) ; minterm D = A
	moveq	#-1,d3
	move.l	d3,BLTAFWM-DMACONR(a6)
	move.l	d0,BLTAPT-DMACONR(a6)	; character image
	move.l	d1,BLTDPT-DMACONR(a6)	; playfield write
	move.l	#((ss_image_plane_width-ss_text_char_width)<<16)|(extra_pf1_plane_width-ss_text_char_width),BLTAMOD-DMACONR(a6) ; A&D moduli
	move.w	#((ss_text_char_y_size*ss_text_char_depth)<<6)|(ss_text_char_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
	moveq	#0,d2			; reset x shift
ss_horiz_scrolltext_skip
	move.w	d2,ss_text_char_x_shift(a3) 
	rts


	GET_NEW_CHAR_IMAGE.W ss


	CNOP 0,4
ss_horiz_scroll
	move.l	extra_pf1(a3),a0
	ADDF.W	(ss_text_x_position/8)+(ss_text_y_position*extra_pf1_plane_width*extra_pf1_depth),a0 ; y centering
	move.w	#DMAF_BLITHOG|DMAF_SETCLR,DMACON-DMACONR(a6)
	WAITBLIT
	move.l	#((-ss_horiz_scroll_speed<<12)|BC0F_SRCA|BC0F_DEST|ANBNC|ANBC|ABNC|ABC)<<16,BLTCON0-DMACONR(a6) ; minterm D = A
	moveq	#-1,d0
	move.l	d0,BLTAFWM-DMACONR(a6)
	move.l	a0,BLTDPT-DMACONR(a6)	; 1st line in destination
	addq.w	#WORD_SIZE,a0		; 1st line, skip 16 pixel
	move.l	a0,BLTAPT-DMACONR(a6)	; source
	move.l	#((extra_pf1_plane_width-ss_horiz_scroll_window_width)<<16)|(extra_pf1_plane_width-ss_horiz_scroll_window_width),BLTAMOD-DMACONR(a6) ; A&D moduli
	move.w	#((ss_horiz_scroll_window_y_size*ss_horiz_scroll_window_depth)<<6)|(ss_horiz_scroll_window_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
	rts


	INCLUDE "int-autovectors-handlers.i"

	CNOP 0,4
nmi_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,2
pf1_rgb4_color_table
	DC.W color00_bits
	DC.W $fff


	CNOP 0,2
sine_table
	INCLUDE "sine-table-512x16.i"


; Sine-Scrolltext
ss_ascii
	DC.B "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?-'():\/#*<> "
ss_ascii_end
	EVEN

	CNOP 0,2
ss_chars_offsets
	DS.W ss_ascii_end-ss_ascii


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"


	DC.B "$VER: "
	DC.B "1xSine-Scrolltext2 "
	DC.B "1.3 "
	DC.B "(12.5.25)",0
	EVEN


; Sine-Scrolltext
ss_text
	DC.B "SINE SCROLLTEXT WITH 1 PIXEL COLUMNS..."
	REPT ss_text_chars_number/(ss_origin_char_x_size/ss_text_char_x_size)
		DC.B " "
	ENDR
	DC.B FALSE
	EVEN


; Gfx data

; Sine-Scrolltext
ss_image_data			SECTION gfx,DATA_C
	INCBIN "Blitter:graphics/16x16x2-Lores-Font2.rawblit"

	END
