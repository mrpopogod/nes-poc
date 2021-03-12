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
    .org $0000
joypad1                 .ds 1       ; Button states for current frame
joypad1_old             .ds 1       ; Last frame's button states
joypad1_pressed         .ds 1       ; Current frame's off_to_on transition
sleeping                .ds 1       ; Main program sets this and then waits for NMI to clear it
random_offset           .ds 1       ; Pointer to the current offset in our random table

    .org $0100
stack                   .ds 256     ; block off the stack

    .org $0200
spritebuffer            .ds 256     ; sprite OAM loading destination

    .org $6000
batteryram              .ds 8192    ; battery backup space - turn this into real variables

    .bank 0, 16, $8000, "NES_PRG0"

; TODO: Gonna have a bunch of different banks for data and maybe different subsystems (e.g. a menu bank)

    .bank 15, 16, $C000, "NES_PRG1" ; rename this to be whatever the last actual PRG is

    .segment "FIXED_ROM", 15
    .org $C000
RESET:
    SEI                             ; disable IRQs
    CLD                             ; disable decimal mode
    LDX #$FF
    TXS                             ; set up stack
    INX                             ; wrap X to 0
    STX PPUCTRL                     ; disable NMI
    STX PPUMASK                     ; disable rendering
    STX DMC_FREQ                    ; disable DMC IRQs

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

    LDA #%10000000                  ; intensify blues
    STA PPUMASK                     ; just a "it's a valid program" check

; TODO: other power-on init here, such as palettes, initial screen, ensuring the right
; bank is loaded in $8000.
; Also initialize any initial variable state
    LDA #$80
    STA PPUCTRL                     ; Enable NMIs

GameLoop:
    INC sleeping                    ; Go to sleep (wait for NMI).
@sleep:
    LDA sleeping
    BNE @sleep                      ; Wait for NMI to clear the sleeping flag

    JSR ReadJoypad
    ; TODO: any logic we want to handle
    ; handling the inputs
    ; preparing the drawing buffer
    JMP GameLoop

IRQHandler:
    RTI

NMIHandler:
    PHA
    TXA
    PHA
    TYA
    PHA                             ; Back up registers because the interrupt could have fired in the middle of something
  
  ; TODO: Code that handles graphics updates, like sprite loading and whatever
  ; is in the background buffer (don't want to do calculations here)

    INC random_offset               ; Pop a random number every frame
    LDA #$00
    STA sleeping                    ; Wake up the main program

    PLA
    TAY
    PLA
    TAX
    PLA                             ; Restore register state before NMI triggered
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

    .org $FFFA
    .w NMIHandler           
    .w RESET
    .w IRQHandler

    .bank 16, 8, $0000, "NES_CHR0"   ; add as many CHRs as needed - have 8kb window, but can swap high and low 4kb