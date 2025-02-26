;
; crt0.s for NES, using NROM (no mapper)
;
; Provides:
;  * Start-up code clearing RAM and VRAM
;  * Constant-cycle-time NMI handler, performing sprite DMA and VRAM writes via transfer buffer at $100
;  * 16-bit frame counter _sys_time, to support VM routines
.module crt0
.include    "global.s"

; OAM CPU page
_shadow_OAM             = 0x200
; Attribute shadow (64 bytes, leaving 56 bytes available for CPU stack)
_attribute_shadow       = 0x188
; Transfer buffer (lower half of hardware stack)
_vram_transfer_buffer   = 0x100
;
; Format of transfer buffer
;
; 0: Data length
; 1: 4 if inc-by-32, 0 if inc-by-1
; 2: PPUADDR_HI
; 3: PPUADDR_LO
; 4: ...N data bytes...
;
VRAM_HDR_SIZEOF         = 4
VRAM_HDR_LENGTH         = 0
VRAM_HDR_DIRECTION      = 1
VRAM_HDR_PPUHI          = 2
VRAM_HDR_PPULO          = 3
VRAM_MAX_BYTES          = 32
VRAM_MAX_STRIPE_SIZE    = VRAM_HDR_SIZEOF + VRAM_MAX_BYTES
; Number of 8-cycles available each frame for transfer buffer
VRAM_DELAY_CYCLES_X8    = 170

; Declare a dummy symbol for banking
; TODO: Make banking actually work
b_wait_frames = 0
.globl b_wait_frames

.macro WRITE_PALETTE_SHADOW
    lda #>0x3F00
    sta PPUADDR
    lda #<0x3F00
    sta PPUADDR
    ldx *__crt0_paletteShadow
    i = 0
.rept 8
    stx PPUDATA
    lda *(__crt0_paletteShadow+1+3*i+0)
    sta PPUDATA
    lda *(__crt0_paletteShadow+1+3*i+1)
    sta PPUDATA
    lda *(__crt0_paletteShadow+1+3*i+2)
    sta PPUDATA
    i = i + 1
.endm
.endm

.macro VRAM_BUFFER_LOCK
    clc
    ror *__crt0_drawListValid
.endm

.macro VRAM_BUFFER_UNLOCK
    sec
    ror *__crt0_drawListValid
.endm

.area ZP (PAG)
__shadow_OAM_base::                     .ds 1
__current_bank::                        .ds 1
_sys_time::                             .ds 2
_shadow_PPUCTRL::                       .ds 1
_shadow_PPUMASK::                       .ds 1
__crt0_paletteShadow::                  .ds 25
__crt0_spritePageValid:                 .ds 1
__crt0_NMI_Done:                        .ds 1
__crt0_NMI_insideNMI:                   .ds 1
__crt0_ScrollHV:                        .ds 1
__crt0_drawListValid:                   .ds 1
__crt0_drawListNumDelayCycles_x8:       .ds 1
__crt0_drawListPosW::                   .ds 1
__crt0_textPPUAddr:                     .ds 2
__crt0_NMITEMP:                         .ds 4
__crt0_textTemp:                        .ds 1
.mode::                                 .ds 1
.tmp::                                  .ds 2
_bkg_scroll_x::                         .ds 1
_bkg_scroll_y::                         .ds 1
_attribute_row_dirty::                  .ds 1
_attribute_column_dirty::               .ds 1
.crt0_textStringBegin:                  .ds 1
.crt0_forced_blanking::                 .ds 1

        ;; ****************************************

        ;; Ordering of segments for the linker
        ;; Code that really needs to be in the fixed bank
        .area CODE
        .area _CODE
        .area _HOME
        ;; Similar to _HOME
        .area _BASE
        ;;
        .area RODATA
        ;; #pragma bank 0 workaround
        .area _CODE_0
        ;; Constant data
        .area _LIT
;       ;; since _CODE_1 area base address is pre-defined in the linker from 0x4000, 
;       ;; that moves initializer code and tables out of bank 0
        .area _CODE_1
        .area _CODE_2
        .area _CODE_3
        ;; Constant data, used to init _DATA
        .area _INITIALIZER
        .area XINIT
        ;; Code, used to init _DATA
        .area _GSINIT 
        .area _GSFINAL
        ;; Uninitialised ram data
        .area DATA
        .area _DATA
        .area _BSS
        .area BSS
        ;; Initialised in ram data
        .area _INITIALIZED
        ;; For malloc
        .area _HEAP
        .area _HEAP_END

.area CODEFIXED

.bndry 0x100
.identity::
_identity::
i = 0
.rept 256
.db i
i = i + 1
.endm

__crt0_NMI:
    ; Prevent NMI re-entry
    bit *__crt0_NMI_insideNMI
    bpl NotInsideNMI
    rti
NotInsideNMI:
    pha
    txa
    pha
    tya
    pha

    lda #0x80
    sta *__crt0_NMI_insideNMI

    jsr __crt0_doSpriteDMA
    jsr __crt0_NMI_doUpdateVRAM

    nop
    ; Enable screen to get normal dot crawl pattern
    lda *_shadow_PPUMASK
    sta PPUMASK

    lda *_sys_time
    clc
    adc #1
    sta *_sys_time
    lda *(_sys_time+1)
    adc #0
    sta *(_sys_time+1)

    lda #0x80
    sta __crt0_NMI_Done
    
    lda *_shadow_PPUCTRL
    ora *__crt0_ScrollHV
    sta PPUCTRL

    pla
    tay
    pla
    tax
    pla
    asl *__crt0_NMI_insideNMI
    rti

__crt0_NMI_doUpdateVRAM:
    lda *_shadow_PPUMASK
    and #(PPUMASK_SHOW_BG | PPUMASK_SHOW_SPR)
    beq __crt0_NMI_doUpdateVRAM_blanked
    ; Not manually blanked - do updates
    lda PPUSTATUS
    lda #PPUCTRL_SPR_CHR
    sta PPUCTRL
    lda #0
    sta PPUMASK
    jsr DoUpdateVRAM
    ; Set scroll address
    lda _bkg_scroll_x
    sta PPUSCROLL
    lda _bkg_scroll_y
    sta PPUSCROLL
    rts
__crt0_NMI_doUpdateVRAM_blanked:
    ; Early-out if blanked to allow main code to do VRAM address / scroll updates
    nop
    nop
    nop
    rts

.bndry 0x100
__crt0_doSpriteDMA:
    bit *__crt0_spritePageValid
    bpl __crt0_doSpriteDMA_spritePageInvalid
    lda #0                      ; +2
    sta OAMADDR                 ; +4
    lda #>_shadow_OAM           ; +2
    sta OAMDMA                  ; +512/513
    rts
__crt0_doSpriteDMA_spritePageInvalid:
    ; Delay 520 cycles to keep timing consistent
    ldx #104
__crt0_doSpriteDMA_loop:
    dex
    bne __crt0_doSpriteDMA_loop
    rts

DoUpdateVRAM:
    WRITE_PALETTE_SHADOW
    bit *__crt0_drawListValid
    bmi DoUpdateVRAM_drawListValid
DoUpdateVRAM_drawListInvalid:
    ; Delay exactly 1633 cycles to keep timing consistent
    ldx #(VRAM_DELAY_CYCLES_X8+7)
DoUpdateVRAM_invalid_loop:
    lda *__crt0_drawListNumDelayCycles_x8
    dex
    bne DoUpdateVRAM_invalid_loop
    nop
    rts
DoUpdateVRAM_drawListValid:
    jsr ProcessDrawList
    ; Delay up to 167*8-1 = 1575 cycles (value set by draw list creation code)
    ; ...plus fixed-cost of 56 cycles
    ldx *__crt0_drawListNumDelayCycles_x8
DoUpdateVRAM_valid_loop:
    stx *__crt0_drawListNumDelayCycles_x8
    dex
    bne DoUpdateVRAM_valid_loop
    lda #VRAM_DELAY_CYCLES_X8
    sta *__crt0_drawListNumDelayCycles_x8
    rts

;
; Number of cycles spent = 19 + 21 + 48*NumTransfers + 8*NumBytesTransferred
;                        = 56 + 48*NumTransfers + 8*NumBytesTransferred
;                        = 8 * (7 + 6*NumTransfers + NumBytesTransferred)
;                        = 8 * (6*NumTransfers + NumBytesTransferred + 7)
;
ProcessDrawList:
    ProcessDrawList_tempX  = __crt0_NMITEMP+2
    ProcessDrawList_addr   = __crt0_NMITEMP+0
    lda #>ProcessDrawList_UnrolledCopyLoop  ; +2
    sta *ProcessDrawList_addr+1             ; +3
    tsx                                     ; +2
    stx *ProcessDrawList_tempX              ; +3
    ldx #0xFF                               ; +2
    txs                                     ; +2
    jmp ProcessDrawList_DoOneTransfer       ; +3
    ; Total = 2 + 3 + 2 + 3 + 2 + 2 + 3 = 17 fixed-cost entry

.bndry 0x100
ProcessDrawList_UnrolledCopyLoop:
.rept 64
pla             ; +4
sta PPUDATA     ; +4
.endm
ProcessDrawList_DoOneTransfer:
    pla                                         ; +4
    beq ProcessDrawList_EndOfList               ; +2/3
    tay                                         ; +2
    ; branchaddr = 256-4*num_bytes = NOT(4*num_bytes)+1+256 = NOT(4*num_bytes)+1
    lda ProcessDrawList_NumBytesToAddress,y     ; +4
    sta *ProcessDrawList_addr                   ; +3
    pla                                         ; +4
    sta PPUCTRL                                 ; +4
    pla                                         ; +4
    sta PPUADDR                                 ; +4
    pla                                         ; +4
    sta PPUADDR                                 ; +4
    nop                                         ; +2
    nop                                         ; +2
    jmp [ProcessDrawList_addr]                  ; +5
    ; Total = 4 + 2 + 2 + 4 + 3 + 6*4 + 2 + 2 + 5 = 48 for each transfer (...+ 8*NumBytesCopied)
    ;         4 + 3 + 14 = 7 + 14 = 21 fixed-cost exit

ProcessDrawList_EndOfList:
    ldx *ProcessDrawList_tempX          ; +3
    txs                                 ; +2
    lda #0                              ; +2
    sta *__crt0_drawListPosW            ; +3
    sta *__crt0_drawListValid           ; +3
    rts                                 ; +6
    ; = 3 + 2 + 2 + 3 + 3 + 6 = 19

.bndry 0x100
ProcessDrawList_NumBytesToAddress:
i = 0
.rept 65
.db <(256-4*i)
i = i + 1
.endm

.writeNametableByte::
_writeNametableByte::
    pha
    lda #(0x20 >> 5)
    sta *__crt0_textPPUAddr+1
    tya
    asl
    rol *__crt0_textPPUAddr+1
    asl
    rol *__crt0_textPPUAddr+1
    asl
    rol *__crt0_textPPUAddr+1
    asl
    rol *__crt0_textPPUAddr+1
    asl
    rol *__crt0_textPPUAddr+1
    ora .identity,x
    sta *__crt0_textPPUAddr
    ; If we're currently in forced blanking mode, use direct writes instead of transfer buffer
    bit *.crt0_forced_blanking
    bpl 1$
    lda *__crt0_textPPUAddr+1
    sta PPUADDR
    lda *__crt0_textPPUAddr
    sta PPUADDR
    lda #0
    rol
    asl
    asl
    ora *_shadow_PPUCTRL
    sta PPUCTRL
    pla
    sta PPUDATA
    ; Increment PPU addr
    lda *__crt0_textPPUAddr
    clc
    adc #1
    sta *__crt0_textPPUAddr
    lda *(__crt0_textPPUAddr+1)
    adc #0
    sta *(__crt0_textPPUAddr+1)
    rts
1$:
_writeNametableByteWaitForFlush:
    ldy *__crt0_drawListPosW
    tya
    ; Limit when (slightly more than) equal to 80 bytes, to avoid overrunning vblank time
    cmp #80
    bcs _writeNametableByteWaitForFlush
    VRAM_BUFFER_LOCK
    ; First check if we can append to previously added stripe
    ldy *.crt0_textStringBegin
    ; Only append if current vram buffer pointer directly follows previous stripe
    tya
    clc
    adc _vram_transfer_buffer+VRAM_HDR_LENGTH,y
    adc #VRAM_HDR_SIZEOF
    cmp *__crt0_drawListPosW
    bne 2$
    ; Only append if previous stripe was horizontal
    lda _vram_transfer_buffer+VRAM_HDR_DIRECTION,y
    bne 2$
    ; Only append if PPU address following previous stripe matches desired PPU address
    lda _vram_transfer_buffer+VRAM_HDR_PPULO,y
    clc
    adc _vram_transfer_buffer+VRAM_HDR_LENGTH,y
    sta *.tmp
    lda _vram_transfer_buffer+VRAM_HDR_PPUHI,y
    adc #0
    ; Check against textPPUAddr
    cmp *__crt0_textPPUAddr+1
    bne 2$
    lda *.tmp
    cmp *__crt0_textPPUAddr
    bne 2$
    jmp _writeNametableByte_continue
2$:
    jmp _writeNametableByte_new

_writeNametableByte_end:
    ; Increment PPU addr
    lda *__crt0_textPPUAddr
    clc
    adc #1
    sta *__crt0_textPPUAddr
    lda *(__crt0_textPPUAddr+1)
    adc #0
    sta *(__crt0_textPPUAddr+1)
    sty *__crt0_drawListPosW
    VRAM_BUFFER_UNLOCK
    ldy *__crt0_textTemp
    rts

;
; Writes a new nametable byte, effectively beginning a new stripe
;
_writeNametableByte_new:
    ldy *__crt0_drawListPosW
    sty *.crt0_textStringBegin
    ; Number of bytes
    lda #1
    sta _vram_transfer_buffer,y
    iny
    ; Horizontal mode
    lda #0
    sta _vram_transfer_buffer,y
    iny
    ; PPU hi
    lda *(__crt0_textPPUAddr+1)
    sta _vram_transfer_buffer,y
    iny
    ; PPU lo
    lda *__crt0_textPPUAddr
    sta _vram_transfer_buffer,y
    iny
    pla
    sta _vram_transfer_buffer,y
    iny
    ; zero byte at end
    lda #0
    sta _vram_transfer_buffer,y
    ; decrease total delay in NMI by 7 * 8 cycles for each individually written byte
    ;
    ; Each new write operation adds 48 cycles + 8 cycles per written byte, i.e.:
    ;  NumDelayCycles_x8 -= 6 * numberOfWriteCommands + numWrittenBytes
    ;
    ; __crt0_drawListNumDelayCycles_x8 -= 7
    lda *__crt0_drawListNumDelayCycles_x8
    sec
    sbc #7
    sta *__crt0_drawListNumDelayCycles_x8
    jmp _writeNametableByte_end

;
; Continues the previously started stripe by adding an additional byte to it
;
_writeNametableByte_continue:
    ; Increase number of bytes in header
    ldy *.crt0_textStringBegin
    lda _vram_transfer_buffer,y
    clc
    adc #1
    sta _vram_transfer_buffer,y
    ; Write new byte
    ldy *__crt0_drawListPosW
    pla
    sta _vram_transfer_buffer,y
    iny
    ; zero byte at end
    lda #0
    sta _vram_transfer_buffer,y
    ; Decrease x8 cycle delay by 1
    dec *__crt0_drawListNumDelayCycles_x8
    jmp _writeNametableByte_end

__crt0_IRQ:
    jmp __crt0_IRQ

__crt0_setPalette:
    ; Set background color to 30 (white)
    lda #0x30
    sta *__crt0_paletteShadow
    ; set all background / sprite sub-palettes to 10, 00, 1D
    lda #0x10
    ldx #0x00
    ldy #0x1D
    ;
    sta *(__crt0_paletteShadow+1)
    sta *(__crt0_paletteShadow+1+12)
    stx *(__crt0_paletteShadow+2)
    stx *(__crt0_paletteShadow+2+12)
    sty *(__crt0_paletteShadow+3)
    sty *(__crt0_paletteShadow+3+12)
    ;
    sta *(__crt0_paletteShadow+4)
    sta *(__crt0_paletteShadow+4+12)
    stx *(__crt0_paletteShadow+5)
    stx *(__crt0_paletteShadow+5+12)
    sty *(__crt0_paletteShadow+6)
    sty *(__crt0_paletteShadow+6+12)
    ;
    sta *(__crt0_paletteShadow+7)
    sta *(__crt0_paletteShadow+7+12)
    stx *(__crt0_paletteShadow+8)
    stx *(__crt0_paletteShadow+8+12)
    sty *(__crt0_paletteShadow+9)
    sty *(__crt0_paletteShadow+9+12)
    ;
    sta *(__crt0_paletteShadow+10)
    sta *(__crt0_paletteShadow+10+12)
    stx *(__crt0_paletteShadow+11)
    stx *(__crt0_paletteShadow+11+12)
    sty *(__crt0_paletteShadow+12)
    sty *(__crt0_paletteShadow+12+12)
    rts

__crt0_waitPPU:
__crt0_waitPPU_loop:
    lda PPUSTATUS
    bpl __crt0_waitPPU_loop
    rts

__crt0_clearRAM:
    ldx #0x00
    txa
__crt0_clearRAM_loop:
    sta 0x0000,x
    ;sta 0x0100,x
    sta 0x0200,x
    sta 0x0300,x
    sta 0x0400,x
    sta 0x0500,x
    sta 0x0600,x
    sta 0x0700,x
    inx
    bne __crt0_clearRAM_loop
    rts

__crt0_clearVRAM:
    lda #0x00
    sta PPUADDR
    sta PPUADDR
    ldy #64
    ldx #0
__crt0_clearVRAM_loop:
    sta PPUDATA
    dex
    bne __crt0_clearVRAM_loop
    dey
    bne __crt0_clearVRAM_loop
    rts

.wait_vbl_done::
_wait_vbl_done::
_vsync::
    lda *_sys_time
_wait_vbl_done_waitForNextFrame_loop:
    cmp *_sys_time
    beq _wait_vbl_done_waitForNextFrame_loop
    rts

__crt0_RESET:
    ; Disable IRQs
    sei
    ; Set stack pointer
    ldx #0xff
    txs
    ; Set switchable bank to first
__crt0_RESET_bankSwitchValue:
    lda #0x00
    sta __crt0_RESET_bankSwitchValue+1
    ; Disable NMIs and rendering
    sta PPUCTRL
    sta PPUMASK
    ; Wait for PPU warm-up
    jsr __crt0_waitPPU
    jsr __crt0_waitPPU
    ; Clear RAM and VRAM
    jsr __crt0_clearRAM
    jsr __crt0_clearVRAM
    ; Hide sprites in shadow OAM, and perform OAM DMA
    ldx #0
    txa
    jsr _hide_sprites_range
    stx OAMADDR
    lda #>_shadow_OAM
    sta OAMDMA
    ; Perform initialization of DATA area
    lda #<s_XINIT
    sta ___memcpy_PARM_2
    lda #>s_XINIT
    sta ___memcpy_PARM_2+1
    lda #<l_XINIT
    sta ___memcpy_PARM_3
    lda #>l_XINIT
    sta ___memcpy_PARM_3+1
    lda #<s_DATA
    ldx #>s_DATA
    jsr ___memcpy
    ; Set palette shadow
    jsr __crt0_setPalette
    ; Initialize PPU address for printf output (start at 3rd row, 2nd column)
    lda #<0x2041
    sta *__crt0_textPPUAddr
    lda #>0x2041
    sta *(__crt0_textPPUAddr+1)
    lda #VRAM_DELAY_CYCLES_X8
    sta *__crt0_drawListNumDelayCycles_x8
    lda #0
    sta *__crt0_drawListPosW
    ; 
    lda #(PPUMASK_SHOW_BG | PPUMASK_SHOW_SPR | PPUMASK_SHOW_BG_LC | PPUMASK_SHOW_SPR_LC)
    sta *_shadow_PPUMASK
    lda #0x80
    sta *__crt0_spritePageValid
    ; enable NMI
    lda #(PPUCTRL_NMI | PPUCTRL_SPR_CHR)
    sta *_shadow_PPUCTRL
    sta PPUCTRL
    ; Call main
    jsr _main
    ; main finished - loop forever
__crt0_waitForever:
    jmp __crt0_waitForever

.display_off::
_display_off::
    lda *_shadow_PPUMASK
    and #~(PPUMASK_SHOW_BG | PPUMASK_SHOW_SPR)
    sta *_shadow_PPUMASK
    sta PPUMASK
    ; Set forced blanking bit
    sec
    ror *.crt0_forced_blanking
    rts

.display_on::
_display_on::
    lda *_shadow_PPUMASK
    ora #(PPUMASK_SHOW_BG | PPUMASK_SHOW_SPR)
    sta *_shadow_PPUMASK
    sta PPUMASK
    ; Clear forced blanking bit
    clc
    ror *.crt0_forced_blanking
    rts

;
; Begin a horizontal stripe
;
.ppu_stripe_begin_horizontal::
    clc
    jmp .ppu_stripe_begin

;
; Begin a vertical stripe
;
.ppu_stripe_begin_vertical::
    sec
    jmp .ppu_stripe_begin

;
; Begin a stripe (carry indicates vertical stripe)
;
.ppu_stripe_begin::
    bit *.crt0_forced_blanking
    bpl 1$
    ; Direct write
    stx PPUADDR
    sta PPUADDR
    ; Set inc-by-32 bit in PPUCTRL as well
    lda #0
    rol
    asl
    asl
    lda *_shadow_PPUCTRL
    sta PPUCTRL
    rts
1$:
    ; Indirect write via transfer buffer
    sty *__crt0_textTemp
    pha
    txa
    pha
    lda #0
    rol
    asl
    asl
    pha
    ; Ensure there's at least VRAM_MAX_STRIPE_SIZE bytes remaining to write before progressing
    ; This conservative limit simplifies conditions for rest of stripe in order to write single bytes with no checks
2$:
    lda *__crt0_drawListPosW
    cmp #128-VRAM_MAX_STRIPE_SIZE
    bcs 2$
    ; Lock buffer and store current write pointer for later
    VRAM_BUFFER_LOCK
    ldy *__crt0_drawListPosW
    sty *.crt0_textStringBegin
    ; Write direction
    pla
    sta _vram_transfer_buffer+VRAM_HDR_DIRECTION,y
    ; Write address
    pla
    sta _vram_transfer_buffer+VRAM_HDR_PPUHI,y
    pla
    sta _vram_transfer_buffer+VRAM_HDR_PPULO,y
    tya
    clc
    adc #VRAM_HDR_SIZEOF
    sta *__crt0_drawListPosW
    ; __crt0_drawListNumDelayCycles_x8 -= 6 (assumes carry clear)
    lda *__crt0_drawListNumDelayCycles_x8
    sbc #5
    sta *__crt0_drawListNumDelayCycles_x8
    ldy *__crt0_textTemp
    rts

;
; End a stripe (be it direct or via transfer buffer)
;
.ppu_stripe_end::
    bit *.crt0_forced_blanking
    bpl 1$
    ; For direct writes there's nothing more to do
    rts
1$:
    sty *__crt0_textTemp
    ldy *__crt0_drawListPosW
    ; Write terminator byte
    lda #0
    sta _vram_transfer_buffer,y
    ; Write number of data bytes
    tya
    sec
    sbc *.crt0_textStringBegin
    sbc #VRAM_HDR_SIZEOF
    ldy *.crt0_textStringBegin
    sta _vram_transfer_buffer+VRAM_HDR_LENGTH,y
    lda *__crt0_drawListNumDelayCycles_x8
    sbc _vram_transfer_buffer+VRAM_HDR_LENGTH,y
    sta *__crt0_drawListNumDelayCycles_x8
    VRAM_BUFFER_UNLOCK
    ldy *__crt0_textTemp
    rts

;
; Writes a byte of an in-progress horizontal / vertical stripe (be it direct or via transfer buffer)
;
.ppu_stripe_write_byte::
    bit *.crt0_forced_blanking
    bpl 1$
    sta PPUDATA     ; Direct write
    rts
1$:
    sty *__crt0_textTemp
    ldy *__crt0_drawListPosW
    sta _vram_transfer_buffer,y
    inc *__crt0_drawListPosW
    ldy *__crt0_textTemp
    rts

; Interrupt / RESET vector table
.area VECTORS (ABS)
.org 0xfffa
.dw	__crt0_NMI
.dw	__crt0_RESET
.dw	__crt0_IRQ
