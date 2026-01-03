; Requirements
; 68000+
; OCS+
; 1.2+


; 1 column = 2 pixel
; 16x15 pixel characters in 2 colours
; 2x sine movement
; CPU clears playfield
; Copper waits for blitter
; Beam position timing
; 64 kB aligned playfields


; Execution time MC68000: 259 rasterlines


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

copcon_bits			EQU COPCONF_CDANG

pf1_x_size1			EQU 320
pf1_y_size1			EQU 256+820
pf1_depth1			EQU 2
pf1_x_size2			EQU 320
pf1_y_size2			EQU 256+820
pf1_depth2			EQU 2
pf1_x_size3			EQU 320
pf1_y_size3			EQU 256+820
pf1_depth3			EQU 2
pf1_colors_number		EQU 0	; 4

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
extra_pf1_y_size		EQU 15
extra_pf1_depth			EQU 2

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
bplcon0_bits			EQU BPLCON0F_COLOR|(pf_depth*BPLCON0F_BPU0)
bplcon1_bits			EQU 0
bplcon2_bits			EQU 0
color00_bits			EQU $012

cl1_hstart			EQU 0
cl1_vstart			EQU $03	; avoid that the cpu operates on the cl while the copper is executing it

cl2_hstart			EQU 0
cl2_vstart			EQU beam_position&CL_Y_WRAPPING

sine_table_length		EQU 512

; Sine-Scrolltext
ss_image_x_size			EQU 320
ss_image_plane_width		EQU ss_image_x_size/8
ss_image_depth			EQU 2
ss_origin_char_x_size		EQU 16
ss_origin_char_y_size		EQU 15

ss_text_char_x_size		EQU 16
ss_text_char_width		EQU ss_text_char_x_size/8
ss_text_char_y_size		EQU ss_origin_char_y_size
ss_text_char_depth		EQU ss_image_depth

ss_sine_char_x_size		EQU 16
ss_sine_char_width		EQU ss_sine_char_x_size/8
ss_sine_char_y_size		EQU ss_text_char_y_size
ss_sine_char_depth		EQU pf1_depth3

ss_horiz_scroll_window_x_size	EQU visible_pixels_number+(ss_text_char_x_size*2)
ss_horiz_scroll_window_width	EQU ss_horiz_scroll_window_x_size/8
ss_horiz_scroll_window_y_size	EQU ss_text_char_y_size
ss_horiz_scroll_window_depth	EQU ss_image_depth
ss_horiz_scroll_speed		EQU 2

ss_text_char_x_restart		EQU ss_horiz_scroll_window_x_size-ss_text_char_x_size
ss_text_chars_number		EQU ss_horiz_scroll_window_x_size/ss_text_char_x_size

ss_text_y_radius		EQU (visible_lines_number-(ss_text_char_y_size+1))/2
ss_text_y_center		EQU (visible_lines_number-(ss_text_char_y_size+1))/2
ss_text_y_radius_angle_speed	EQU 1
ss_text_y_radius_angle_step	EQU 2
ss_text_y_angle_speed		EQU 1
ss_text_y_angle_step		EQU 1

ss_text_columns_x_size		EQU 2
ss_text_columns_per_word	EQU WORD_BITS/ss_text_columns_x_size
ss_text_columns_number		EQU visible_pixels_number/ss_text_columns_x_size


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


	RSRESET

cl1_extension1			RS.B 0

cl1_ext1_WAIT			RS.L 1
cl1_ext1_COP1LCH		RS.L 1
cl1_ext1_COP1LCL		RS.L 1
cl1_ext1_COPJMP1		RS.L 1

cl1_extension1_size		RS.B 0


; Character
	RSRESET

cl1_extension2			RS.B 0

cl1_ext2_WAITBLIT		RS.L 1
cl1_ext2_BLTCON0		RS.L 1
cl1_ext2_BLTCON1		RS.L 1
cl1_ext2_BLTAFWM		RS.L 1
cl1_ext2_BLTALWM		RS.L 1
cl1_ext2_BLTAPTH		RS.L 1
cl1_ext2_BLTAPTL		RS.L 1
cl1_ext2_BLTDPTH		RS.L 1
cl1_ext2_BLTDPTL		RS.L 1
cl1_ext2_BLTAMOD		RS.L 1
cl1_ext2_BLTDMOD		RS.L 1
cl1_ext2_noop		RS.L 1

cl1_extension2_size		RS.B 0


; Horiz scroll
	RSRESET

cl1_extension3			RS.B 0

cl1_ext3_WAITBLIT		RS.L 1
cl1_ext3_BLTCON0		RS.L 1
cl1_ext3_BLTCON1		RS.L 1
cl1_ext3_BLTAFWM		RS.L 1
cl1_ext3_BLTALWM		RS.L 1
cl1_ext3_BLTAPTH		RS.L 1
cl1_ext3_BLTAPTL		RS.L 1
cl1_ext3_BLTDPTH		RS.L 1
cl1_ext3_BLTDPTL		RS.L 1
cl1_ext3_BLTAMOD		RS.L 1
cl1_ext3_BLTDMOD		RS.L 1
cl1_ext3_noop		RS.L 1

cl1_extension3_size		RS.B 0


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

cl1_extension1_entry		RS.B cl1_extension1_size
cl1_extension2_entry		RS.B cl1_extension2_size
cl1_extension3_entry		RS.B cl1_extension3_size

cl1_COPJMP2			RS.L 1

copperlist1_size		RS.B 0


	RSRESET

cl2_extension1			RS.B 0

cl2_ext1_WAITBLIT		RS.L 1
cl2_ext1_BLTCON0		RS.L 1
cl2_ext1_BLTBPTH		RS.L 1
cl2_ext1_BLTDPTH		RS.L 1
cl2_ext1_BLTBMOD		RS.L 1
cl2_ext1_BLTAMOD		RS.L 1
cl2_ext1_BLTDMOD		RS.L 1

cl2_extension1_size		RS.B 0


	RSRESET

cl2_extension2			RS.B 0

cl2_ext2_BLTALWM		RS.L 1
cl2_ext2_BLTBPTL		RS.L 1
cl2_ext2_BLTAPTH		RS.L 1
cl2_ext2_BLTAPTL		RS.L 1
cl2_ext2_BLTDPTL		RS.L 1
cl2_ext2_noop		RS.L 1
cl2_ext2_WAITBLIT		RS.L 1

cl2_extension2_size		RS.B 0


	RSRESET

cl2_extension3			RS.B 0

cl2_ext3_COP1LCH		RS.L 1
cl2_ext3_COP1LCL		RS.L 1

cl2_extension3_size		RS.B 0


	RSRESET

cl2_begin			RS.B 0

cl2_extension1_entry		RS.B cl2_extension1_size
cl2_extension2_entry		RS.B cl2_extension2_size*ss_text_columns_number
cl2_extension3_entry		RS.B cl2_extension3_size

cl2_end				RS.L 1

copperlist2_size		RS.B 0


cl1_size1			EQU 0
cl1_size2			EQU 0
cl1_size3			EQU copperlist1_size
cl2_size1			EQU 0
cl2_size2			EQU copperlist2_size
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
ss_text_char_x_shift 		RS.W 1
ss_text_y_radius_angle		RS.W 1
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
	CPU_INIT_COLOR COLOR00,4,pf1_rgb4_color_table
	rts


; Sine-Scrolltext
	INIT_CHARS_OFFSETS.W ss


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0
	bsr.s	cl1_init_playfield_props
	bsr.s	cl1_init_bitplane_pointers
	bsr	cl1_init_copperlist_branch
	bsr	cl1_init_char_blit
	bsr	cl1_init_horiz_scroll_blit
	COP_MOVEQ 0,COPJMP2
	bsr	cl1_set_bitplane_pointers
	bra	ss_horiz_scrolltext


	COP_INIT_PLAYFIELD_REGISTERS cl1


	COP_INIT_BITPLANE_POINTERS cl1


	CNOP 0,4
cl1_init_copperlist_branch
	COP_WAIT cl1_hstart,cl1_vstart
	move.l	cl1_display(a3),d0 
	ADDF.L	cl1_extension3_entry,d0 ; skip character blit
	swap	d0
	COP_MOVE d0,COP1LCH
	swap	d0	
	COP_MOVE d0,COP1LCL
	COP_MOVEQ 0,COPJMP1
	rts


	CNOP 0,4
cl1_init_char_blit
	COP_WAITBLIT
	COP_MOVEQ BC0F_SRCA|BC0F_DEST|ANBNC|ANBC|ABNC|ABC,BLTCON0 ; minterm D = A
	COP_MOVEQ 0,BLTCON1
	COP_MOVEQ -1,BLTAFWM
	COP_MOVEQ -1,BLTALWM
	COP_MOVEQ 0,BLTAPTH
	COP_MOVEQ 0,BLTAPTL
	move.l	extra_pf1(a3),d0
	ADDF.L	ss_text_char_x_restart/8,d0
	swap	d0
	COP_MOVE d0,BLTDPTH		; playfield write
	swap	d0		
	COP_MOVE d0,BLTDPTL		; playfield write
	COP_MOVEQ ss_image_plane_width-ss_text_char_width,BLTAMOD
	COP_MOVEQ extra_pf1_plane_width-ss_text_char_width,BLTDMOD
	COP_MOVEQ ((ss_text_char_y_size*ss_text_char_depth)<<6)|(ss_text_char_x_size/WORD_BITS),BLTSIZE
	rts


	CNOP 0,4
cl1_init_horiz_scroll_blit
	COP_WAITBLIT
	COP_MOVEQ (-ss_horiz_scroll_speed<<12)|BC0F_SRCA|BC0F_DEST|ANBNC|ANBC|ABNC|ABC,BLTCON0 ; minterm D = A
	COP_MOVEQ 0,BLTCON1
	move.l	extra_pf1(a3),d0	; source
	move.l	d0,d1			; destination
	COP_MOVEQ -1,BLTAFWM
	addq.l	#WORD_SIZE,d0		; skip 16 pixel
	COP_MOVEQ -1,BLTALWM
	swap	d0
	COP_MOVE d0,BLTAPTH
	swap	d0		
	COP_MOVE d0,BLTAPTL
	swap	d1
	COP_MOVE d1,BLTDPTH
	swap	d1		
	COP_MOVE d1,BLTDPTL
	COP_MOVEQ extra_pf1_plane_width-ss_horiz_scroll_window_width,BLTAMOD
	COP_MOVEQ extra_pf1_plane_width-ss_horiz_scroll_window_width,BLTDMOD
	COP_MOVEQ ((ss_horiz_scroll_window_y_size*ss_horiz_scroll_window_depth)<<6)|(ss_horiz_scroll_window_x_size/WORD_BITS),BLTSIZE
	rts


	COP_SET_BITPLANE_POINTERS cl1,display,pf1_depth3


	CNOP 0,4
init_second_copperlist
	move.l	cl2_construction2(a3),a0
	bsr	cl2_init_sine_scroll_const
	bsr	cl2_init_sine_scroll_blits
	bsr	cl2_init_copperlist_branch
	COP_LISTEND
	bsr	copy_second_copperlist
	bsr	swap_second_copperlist
	bsr	set_second_copperlist
	bsr	swap_playfield1
	bsr	set_playfield1
	bsr	ss_sine_scroll
	bsr	swap_second_copperlist
	bsr	set_second_copperlist
	bsr	swap_playfield1
	bsr	set_playfield1
	bra	ss_sine_scroll


	CNOP 0,4
cl2_init_sine_scroll_const
	COP_WAITBLIT
	COP_MOVEQ BC0F_SRCA|BC0F_SRCB|BC0F_DEST|NABNC|NABC|ANBNC|ANBC|ABNC|ABC,BLTCON0 ; minterm D = A+B
	COP_MOVEQ 0,BLTBPTH
	COP_MOVEQ 0,BLTDPTH
	COP_MOVEQ pf1_plane_width-ss_text_char_width,BLTBMOD
	COP_MOVEQ extra_pf1_plane_width-ss_text_char_width,BLTAMOD
	COP_MOVEQ pf1_plane_width-ss_text_char_width,BLTDMOD
	rts


	CNOP 0,4
cl2_init_sine_scroll_blits
	move.l	extra_pf1(a3),d2	; source
	ADDF.L	visible_pixels_number/8,d2 ; end of line
	moveq	#(visible_pixels_number/WORD_BITS)-1,d7
cl2_init_sine_scroll_blits_loop1
	MOVEF.W $ff>>(8-ss_text_columns_x_size),d1 ; mask
	moveq	#ss_text_columns_per_word-1,d6
cl2_init_sine_scroll_blits_loop2
	COP_MOVE d1,BLTALWM
	swap	d2
	COP_MOVEQ 0,BLTBPTL
	COP_MOVE d2,BLTAPTH		; scrolltext
	swap	d2
	COP_MOVE d2,BLTAPTL
	COP_MOVEQ 0,BLTDPTL
	COP_MOVEQ ((ss_sine_char_y_size*ss_sine_char_depth)<<6)|(ss_sine_char_x_size/WORD_BITS),BLTSIZE
	IFEQ ss_text_columns_x_size-1
		MULUF.W 2,d1		; shift mask 1 bit left
	ELSE
		IFEQ ss_text_columns_x_size-2
			MULUF.W 4,d1	; shift mask 2 bits left
		ELSE
			lsl.w	#ss_text_columns_x_size,d1 ; shift mask n bits left
		ENDC
	ENDC
	COP_WAITBLIT
	dbf	d6,cl2_init_sine_scroll_blits_loop2
	subq.l	#ss_sine_char_width,d2	; next character in source
	dbf	d7,cl2_init_sine_scroll_blits_loop1
	rts


	CNOP 0,4
cl2_init_copperlist_branch
	COP_MOVE cl1_display(a3),COP1LCH
	COP_MOVE cl1_display+WORD_SIZE(a3),COP1LCL
	rts


	COPY_COPPERLIST cl2,2


	CNOP 0,4
main
	bsr.s	no_sync_routines
	bra.s	beam_routines


	CNOP 0,4
no_sync_routines
	rts


	CNOP 0,4
beam_routines
	bsr	wait_beam_position
	bsr.s	swap_second_copperlist
	bsr.s	set_second_copperlist
	bsr.s	swap_playfield1
	bsr.s	set_playfield1
	bsr	ss_horiz_scrolltext
	bsr	ss_clear_playfield1
	bsr	ss_sine_scroll
	RASTER_TIME
	btst	#CIAB_GAMEPORT0,CIAPRA(a4) ; LMB pressed ?
	bne.s	beam_routines
	rts


	SWAP_COPPERLIST cl2,2


	SET_COPPERLIST cl2


	SWAP_PLAYFIELD pf1,3


	CNOP 0,4
set_playfield1
	move.l	pf1_display(a3),d0
	add.l	#ALIGN_64KB,d0		; 64 kByte alignment
	clr.w	d0
	moveq	#pf1_plane_width,d1
	move.l	cl1_display(a3),a0
	ADDF.W	cl1_BPL1PTH+WORD_SIZE,a0
	moveq	#pf1_depth3-1,d7
set_playfield1_loop
	swap	d0
	move.w	d0,(a0)			; BPLxPTH
	swap	d0
	move.w	d0,LONGWORD_SIZE(a0)	; BPLxPTL
	add.l	d1,d0			; next bitplane
	addq.w	#QUADWORD_SIZE,a0
	dbf	d7,set_playfield1_loop
	rts



	CNOP 0,4
ss_clear_playfield1
	movem.l a3-a6,-(a7)
	move.l	a7,save_a7(a3)
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	pf1_construction1(a3),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	d0,a7
	add.l	#pf1_plane_width*visible_lines_number*pf1_depth3,a7 ; end of playfield
	moveq	#0,d0
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6
	REPT ((pf1_plane_width*visible_lines_number*pf1_depth3)/60)
	movem.l d0-d7/a0-a6,-(a7) ; clear 60 bytes
	ENDR
	movem.l d0-d4,-(a7)		; clear remaining 20 bytes
	move.l	variables+save_a7(pc),a7
	movem.l (a7)+,a3-a6
	rts


	CNOP 0,4
ss_horiz_scrolltext
	move.w	ss_text_char_x_shift(a3),d2
	MOVEF.L cl1_extension3_entry,d3 ; jump in at vertical scroll blit
	move.l	cl1_display(a3),a2
	addq.w	#ss_horiz_scroll_speed,d2
	cmp.w	#ss_text_char_x_size,d2
	blt.s	ss_horiz_scrolltext_skip
	bsr.s	ss_get_new_char_image
	move.w	d0,cl1_extension2_entry+cl1_ext2_BLTAPTL+WORD_SIZE(a2) ; character image
	swap	d0
	move.w	d0,cl1_extension2_entry+cl1_ext2_BLTAPTH+WORD_SIZE(a2)
	moveq	#0,d2			; reset x shift
	MOVEF.L cl1_extension2_entry,d3 ; jump in at charset blit
ss_horiz_scrolltext_skip
	move.w	d2,ss_text_char_x_shift(a3) 
	add.l	a2,d3
	move.w	d3,cl1_extension1_entry+cl1_ext1_COP1LCL+WORD_SIZE(a2)
	swap	d3
	move.w	d3,cl1_extension1_entry+cl1_ext1_COP1LCH+WORD_SIZE(a2)
	rts


	GET_NEW_CHAR_IMAGE.W ss


	CNOP 0,4
ss_sine_scroll
	movem.l a4-a5,-(a7)
	bsr	ss_sine_scroll_init
	move.w	ss_text_y_radius_angle(a3),d2 ; 1st y radius angle
	move.w	d2,d0
	MOVEF.W (sine_table_length-1)*WORD_SIZE,d5 ; overflow 360°
	addq.w	#ss_text_y_radius_angle_speed*WORD_SIZE,d0
	move.w	ss_text_y_angle(a3),d3	; 1st y angle
	and.w	d5,d0			; remove overflow
	move.w	d0,ss_text_y_radius_angle(a3) 
	move.w	d3,d0
	addq.w	#ss_text_y_angle_speed*WORD_SIZE,d0
	and.w	d5,d0			; remove overflow
	move.w	d0,ss_text_y_angle(a3) 
	lea	sine_table(pc),a0
	move.l	pf1_construction1(a3),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	d0,a1			; destination
	ADDF.W	(visible_pixels_number-ss_sine_char_x_size)/8,a1 ; end of line
	move.l	cl2_construction2(a3),a2
	ADDF.W	cl2_extension2_entry+cl2_ext2_BLTBPTL+WORD_SIZE,a2
	move.w	#ss_text_y_center,a4
	move.w	#cl2_extension2_size,a5
	moveq	#(visible_pixels_number/WORD_BITS)-1,d7
ss_sine_scroll_loop1
	moveq	#ss_text_columns_per_word-1,d6
ss_sine_scroll_loop2
	move.w	(a0,d2.w),d0		; sin(w)
	MULSF.W ss_text_y_radius*4,d0,d1 ; yr'=(yr*sin(w))/2^15
	swap	d0
	muls.w	(a0,d3.w),d0		; y'=(yr'*sin(w))/2^15
	swap	d0
	add.w	a4,d0			; y' + y center
	ext.l	d0
	MULUF.L pf1_plane_width*pf1_depth3,d0,d1 ; y offset in playfield
	add.l	a1,d0			; add destination address
	move.w	d0,(a2) 		; playfield read
	addq.w	#ss_text_y_radius_angle_step*WORD_SIZE,d2
	and.w	d5,d2			; remove overflow
	move.w	d0,cl2_ext2_BLTDPTL-cl2_ext2_BLTBPTL(a2) ; playfield write
	addq.w	#ss_text_y_angle_step*WORD_SIZE,d3
	and.w	d5,d3			; remove overflow
	add.l	a5,a2			; next blit in cl
	dbf	d6,ss_sine_scroll_loop2
	subq.w	#ss_sine_char_width,a1	; next character in destination
	dbf	d7,ss_sine_scroll_loop1
	movem.l (a7)+,a4-a5
	rts
	CNOP 0,4
ss_sine_scroll_init
	move.l	pf1_construction1(a3),d0
	add.l	#ALIGN_64KB,d0
	clr.w	d0
	move.l	cl2_construction2(a3),a0
	swap	d0
	move.w	d0,cl2_extension1_entry+cl2_ext1_BLTBPTH+WORD_SIZE(a0) ; playfield read
	move.w	d0,cl2_extension1_entry+cl2_ext1_BLTDPTH+WORD_SIZE(a0) ; playfield write
	rts


	INCLUDE "int-autovectors-handlers.i"

	CNOP 0,4
nmi_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,2
pf1_rgb4_color_table
	DC.W color00_bits,$fff,$ccc,$aaa


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
	DC.B "2xSine-Scrolltext1.2 "
	DC.B "1.0 "
	DC.B "(8.6.25)",0
	EVEN


; Sine-Scrolltext
ss_text
	DC.B "SINE SCROLLTEXT WITH 2 PIXEL COLUMNS..."
	REPT ss_text_chars_number/(ss_origin_char_x_size/ss_text_char_x_size)
	DC.B " "
	ENDR	
	DC.B FALSE
	EVEN


; Gfx data

; Sine-Scrolltext
ss_image_data			SECTION gfx,DATA_C
	INCBIN "Blitter:graphics/16x15x4-Lores-Font.rawblit"

	END
