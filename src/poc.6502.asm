    .target "6502"
    .format "nes"
    .setting "NESMapper", 1                   ; MMC1
    .setting "NESBatteryBackedWRAM", true     ; Support saving
    .setting "ShowLabelsAfterCompiling", true
    .setting "ShowLocalLabelsAfterCompiling", true
    .setting "LaunchCommAND", "c:\\emulation\\fceux.exe {0}"
    .setting "DebugCommAND", "c:\\emulation\\fceux.exe {0}"

    ; Constants for Registers for Readability
    .include "register_defs.6502.asm"

    ; Variables in RAM
    .segment "RAM"
    .org $0000                      ; Zero page
ptr1                    .ds 2       ; Pointer for indirect addressing
joypad1                 .ds 1       ; Button states for current frame
joypad1_old             .ds 1       ; Last frame's button states
joypad1_pressed         .ds 1       ; Current frame's off_to_on transition
sleeping                .ds 1       ; Main program sets this and then waits for NMI to clear it
random_offset           .ds 1       ; Pointer to the current offset in our random table
camera_x                .ds 1       ; X position of the camera relative to the upper left of the map
camera_y                .ds 1       ; Y position of the camera relative to the upper left of the map
player_frame            .ds 1       ; Animation frame for the player movement
button_mask             .ds 1       ; Temp holder for a button mask we want to iterate through
addend                  .ds 1       ; Temp variable when we want to add X or Y to A (STX addend)

    .org $0100                      ; The stack
stack                   .ds 256     ; block off the stack

    .org $0200                      ; Sprite buffer for OAM
spritebuffer            .ds 256     ; sprite OAM loading destination

    .org $0300                      ; Sound engine RAM
apu                     .ds 256

    .org $0400                      ; Other RAM
mmc1_interrupted        .ds 1       ; Flags whether the serial write has been interrupted; 1 is interrupted
mmc1_current_bank       .ds 1       ; What bank the main program is on so the NMI can swap back to it as necessary
mmc1_current_config     .ds 1       ; How the MMC1 is configured so the NMI can restore it if it needed to change it

    .org $6000
batteryram              .ds 8192    ; battery backup space - turn this into real variables

    .bank 0, 16, $8000, "NES_PRG0"

; This is just to see how much space this eats up
    .include "test_map.6502.asm"

; TODO: Gonna have a bunch of different banks for data and maybe different subsystems (e.g. a menu bank)

    .bank 15, 16, $C000, "NES_PRG1" ; rename this to be whatever the last actual PRG is

    .segment "FIXED_ROM", 15
    .org $C000
RESET:
    SEI                             ; Disable IRQs
    CLD                             ; Disable decimal mode
    LDX #$FF
    STX MMC1LOAD                    ; Reset the mapper to a known good state
    TXS                             ; Set up stack
    INX                             ; Wrap X to 0
    STX PPUCTRL                     ; Disable NMI
    STX PPUMASK                     ; Disable rendering
    STX DMC_FREQ                    ; Disable DMC IRQs
    LDA #%00001110                  ; Vertical mirroring, lock $C000 to last bank and switch the $8000 bank, 8k CHR since we're using CHR RAM
    JSR MMC1Configure

@vblankwait1:                       ; wait for a vblank
    BIT PPUSTATUS
    BPL @vblankwait1

@clrmem:                            ; zero out all RAM, but set the OAM segment to be offscreen
    LDA #$00
    STA $0000, X
    STA $0100, X
    STA $0300, X
    STA $0400, X
    STA $0500, X
    STA $0600, X
    STA $0700, X
    LDA #$FE
    STA spritebuffer, X
    INX
    BNE @clrmem

@vblankwait2:                       ; a second vblank means PPU is ready
    BIT PPUSTATUS
    BPL @vblankwait2

; TODO: other power-on init here, such as palettes, initial screen, ensuring the right
; bank is loaded in $8000.
; Also initialize any initial variable state

    LDA #$00
    STA player_frame

; Fixed palette load for now
LoadPalettes:
    LDA PPUSTATUS                   ; Reset the latch
    LDA #$3F
    STA PPUADDR                     ; High byte of $3F00
    LDA #$00
    STA PPUADDR                     ; Low byte of $3F00
    LDX #$00
@loop:
    LDA palette, X
    STA PPUDATA
    INX
    CPX #$20
    BNE @loop

InitialSprites:
    LDA #<playerdown0               ; Start with the player sprite facing down
    STA ptr1
    LDA #>playerdown0
    STA ptr1+1
    JSR LoadPlayerMapSprite

; Fixed CHR RAM load for now
CopyTiles:
    LDA #<testtiles_chr
    STA ptr1
    LDA #>testtiles_chr
    STA ptr1+1                      ; Get our tile data into the pointer

    LDY #$00
    STY PPUMASK                     ; Turn off rendering
    STY PPUADDR
    STY PPUADDR                     ; Nametable starts at $0000
    LDX #$20
@loop:
    LDA (ptr1), Y                    ; One byte at a time
    STA PPUDATA
    INY
    BNE @loop                       ; Wait until Y wraps
    INC ptr1+1                      ; Then go to the next page
    DEX
    BNE @loop

    LDA #%10010000
    STA PPUCTRL                     ; Enable NMIs, sprites on nametable 1
    LDA #%00011000
    STA PPUMASK                     ; Enable sprites and background

GameLoop:
    INC sleeping                    ; Go to sleep (wait for NMI).
@sleep:
    LDA sleeping
    BNE @sleep                      ; Wait for NMI to clear the sleeping flag

    JSR ReadJoypad
    ; TODO: this should be gated behind the overall game state (map, battle, menu, etc)
    JSR UpdatePlayerMapSprite
    ; TODO: any logic we want to handle
    ; handling the inputs
    ; preparing the drawing buffer
    JMP GameLoop

IRQHandler:
    RTI

NMIHandler:
    PHP                             ; Back up flags; must be done first because PLA modifies flags
    PHA
    TXA
    PHA
    TYA
    PHA                             ; Back up registers because the interrupt could have fired in the middle of something
  
  ; TODO: Code that handles graphics updates, like sprite loading and whatever
  ; is in the background buffer (don't want to do calculations here)

    LDA #$00
    STA OAMADDR                     ; Set the low byte of OAM source
    LDA #$02
    STA OAMDMA                      ; Set the high byte of OAM source and trigger the copy

    LDA mmc1_current_bank           ; Example: make sure we're in bank 0
    CMP #$00
    BEQ @noswitch
    LDA #80
    STA MMC1LOAD                    ; Reset any operations in progress
    LDA #$00
    JSR MMC1NMILoadPRGBank          ; Swap to bank 0
    ; --- do something with the code in bank 0
    LDA mmc1_current_bank
    JSR MMC1NMILoadPRGBank          ; Restore the bank the main code was using
    LDA #$01
    STA mmc1_interrupted            ; Set the interrupted flag
@noswitch:

    ; Tasks to do at the end of every NMI
    INC player_frame                ; Update the animation frame counter once per frame
                                    ; TODO - should this only increment when moving?  When I have more written see how it feels
    INC random_offset               ; Pop a random number every frame
    LDA #$00
    STA sleeping                    ; Wake up the main program

    PLA
    TAY
    PLA
    TAX
    PLA                             ; Restore register state before NMI triggered
    PLP                             ; Restore flags before NMI triggered - must be done last because PLA sets flags
    RTI

; Capture the current button state and transitions
; - modifies A
ReadJoypad:
    LDA joypad1
    STA joypad1_old                 ; Save last frame's values to check for transitions

    LDA #$01
    STA JOY1
    LDA #$00
    STA JOY1                        ; Kick off the poll

    LDX #$08
@loop:
    LDA JOY1
    LSR A
    BEQ @notpressed
    INC random_offset               ; Pop every time a button is pressed - INC does not set carry if it rolls over
@notpressed:
    ROL joypad1                     ; A, B, Select, Start, Up, Down, Left, Right
    DEX
    BNE @loop

    LDA joypad1_old                 ; What was already pressed
    EOR #$FF                        ; Invert to find what wasn't pressed
    AND joypad1                     ; So figure out what was newly pressed
    STA joypad1_pressed
    RTS

; Update the player's sprite based on what's going on in map mode
; - modifies - A, Y, ptr1
; TODO: see if I can refactor this to be more offset based and save a bunch of code lines
; TODO: this will also need to account for collision; if we're against a wall don't move in that direction
UpdatePlayerMapSprite:
    LDA #%00001000                  ; Start off looking at up
    STA button_mask
@buttonloop:
    LDA joypad1
    AND button_mask
    BNE @found                      ; We found a pressed ubtton
    LSR button_mask                 ; Check the next button
    BEQ @done                       ; The mask is now 0, which means no buttons were pressed
    BCC @buttonloop                 ; Carry is always 0 except when the mask goes from 1->0, which is handled by the BEQ above
@done:
    RTS                             ; No relevant buttons pressed, nothing to do
@found:                              ; button_mask now has the button that was pressed
    LDY #$00
@offsetloop:
    LSR button_mask                 ; Each button past the first needs to add 16 to the offset
    BCS @doneoffset
    TYA
    ADC #$10                        ; We know the carry is clear if we get to this line
    TAY
    BNE @offsetloop                 ; We know the offset is at least 16 at this point (and won't wrap), so save a cycle
@doneoffset:
    LDA player_frame                ; Need to determine if we are in the second frame of our walking animation
    AND #$08
    BEQ @setptr
    TYA
    CLC                             ; Carry is definitely set; the branch that gut us here was carry set and subsequent operations don't touch it
    ADC #$08                        ; If we're in the second frame then offset by an additional 8
    TAY
@setptr:
    LDA #<playerright0              ; Start at the first address of sprite values
    CLC
    STY addend
    ADC addend                      ; Add our calculated offset
    STA ptr1
    LDA #>playerright0
    ADC #$00                        ; Don't forget to carry the one (if needed)
    STA ptr1+1
    JMP LoadPlayerMapSprite         ; Now that we know what we need to be, get it into OAM

; Loads the appropriate player sprite defined at ptr1
; Used whenever we're in map mode
; Player is always the first four sprites in OAM
; - input - ptr1
; - modifies - A, Y
LoadPlayerMapSprite:
    LDA #$70
    STA spritebuffer
    STA spritebuffer+3
    STA spritebuffer+4
    STA spritebuffer+11
    LDA #$78
    STA spritebuffer+7
    STA spritebuffer+8
    STA spritebuffer+12
    STA spritebuffer+15             ; Set up X and Y coords for the four tiles to be centered

    LDY #$00
    LDX #$01                        ; Need both X and Y because the ptr1 marches by 1 each time, while OAM is 1 and then 3
@loop:                              ; Write the actual tile and attribute data
    LDA (ptr1), Y
    STA spritebuffer, X
    INX
    INY
    LDA (ptr1), Y
    STA spritebuffer, X
    INX
    INX
    INX
    INY
    CPX #$0E
    BCC @loop                       ; the last one we want to write is 14 
    RTS

; Configure the MMC1
; - input - A
; - modifies - A
; - MMC1NMIConfigure - sub call for the NMI so it won't override the configuration the main code wants set
MMC1Configure:
    STA mmc1_current_config         ; Save our configuration in case NMI needs to change it
beginmmc1configure:
    LDA mmc1_current_config         ; If we had to loop this will restore A so we can restart
MMC1NMIConfigure:
    PHA
    LDA #$00                        ; Clear the mmc1 interrupted flag
    STA mmc1_interrupted
    PLA
    STA MMC1CONTROL
    LSR A
    STA MMC1CONTROL
    LSR A
    STA MMC1CONTROL
    LSR A
    STA MMC1CONTROL
    LSR A
    STA MMC1CONTROL
    LDA mmc1_interrupted
    BNE beginmmc1configure             ; If our serial write gets interrupted we need to start over (e.g. NMI did some bank switching)
    RTS

; Switch the PRG bank
; - input - A
; - modifies - A
; - MMC1NMILoadPRGBank - sub call for the NMI so it won't override the bank the main code wants to have set
MMC1LoadPRGBank:
    STA mmc1_current_bank           ; Save the bank we're switching to; if NMI needs to swap banks later it can use this to swap back at the end
beginmmc1loadprgbank:
    LDA mmc1_current_bank           ; If we never get interrupted a bit wasteful, but this handles restoring state if we have to retry after an NMI
MMC1NMILoadPRGBank:
    PHA
    LDA #$00                        ; Clear the mmc1 interrupted flag
    STA mmc1_interrupted
    PLA
    STA MMC1_PRG
    LSR A
    STA MMC1_PRG
    LSR A
    STA MMC1_PRG
    LSR A
    STA MMC1_PRG
    LSR A
    STA MMC1_PRG
    LDA mmc1_interrupted
    BNE beginmmc1loadprgbank           ; If our serial write gets interrupted we need to start over (e.g. NMI did some bank switching)
    RTS

    .include "random_table.6502.asm"

testtiles_chr: .incbin "test.chr"

palette:
    .byte $0F, $2D, $17, $30, $0F, $2D, $21, $30, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F    ; bg, everything but water, water, null, null
    .byte $0F, $0F, $16, $30, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F    ; sprite, main, null, null, null
    
; Sprite defs: tile, attrib 
playerright0:
    .byte $09, $40, $08, $40, $0B, $40, $0A, $40
playerright1:
    .byte $0D, $40, $0C, $40, $0F, $40, $0E, $40
playerleft0:
    .byte $08, $00, $09, $00, $0A, $00, $0B, $00
playerleft1:
    .byte $0C, $00, $0D, $00, $0E, $00, $0F, $00
playerdown0:
    .byte $00, $00, $01, $00, $02, $00, $03, $00
playerdown1
    .byte $00, $00, $01, $00, $03, $40, $02, $40
playerup0:
    .byte $04, $00, $05, $00, $06, $00, $07, $00
playerup1:
    .byte $04, $00, $05, $00, $07, $40, $06, $40

; ------ Interrupt vectors
    .org $FFFA
    .w NMIHandler           
    .w RESET
    .w IRQHandler