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

  .org $0100
stack         .ds 256     ; block off the stack

  .org $0200
spritebuffer  .ds 256     ; sprite OAM loading destination

  .org $6000
batteryram    .ds 8192    ; battery backup space - turn this into real variables

  .bank 0, 16, $8000, "NES_PRG0"

; TODO: Gonna have a bunch of different banks for data and maybe different subsystems (e.g. a menu bank)

  .bank 15, 16, $C000, "NES_PRG1"   ; rename this to be whatever the last actual PRG is

  .segment "INITIALIZATION", 15
  .org $C000
RESET:
  SEI                     ; disable IRQs
  CLD                     ; disable decimal mode
  LDX #$40
  STX APU_CNTR            ; diable APU frame IRQ
  LDX #$FF
  TXS                     ; set up stack
  INX                     ; wrap X to 0
  STX PPUCTRL             ; disable NMI
  STX PPUMASK             ; disable rendering
  STX DMC_FREQ            ; disable DMC IRQs

vblankwait1:              ; wait for a vblank
  BIT PPUSTATUS
  BPL vblankwait1

clrmem:                   ; zero out all RAM, but set the OAM segment to be offscreen
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
  BNE clrmem

vblankwait2:              ; a second vblank means PPU is ready
  BIT PPUSTATUS
  BPL vblankwait2

  LDA #%10000000          ; intensify blues
  STA PPUMASK             ; just a "it's a valid program" check

; TODO: other power-on init here, such as palettes, initial screen, ensuring the right
; bank is loaded in $8000.
; Also initialize any initial variable state

GameLoop:                 ; The main loop where we do any ongoing logic, much should be deferred
                          ; to methods in individual banks
  JMP GameLoop

NMIHandler:
  PHA
  TXA
  PHA
  TYA
  PHA                     ; Back up registers because the interrupt could have fired in the middle of something
  
  ; TODO: Code that handles graphics updates, like sprite loading and whatever
  ; is in the background buffer (don't want to do calculations here)

  PLA
  TAY
  PLA
  TAX
  PLA                     ; Restore register state before NMI triggered
  RTI

  .segment "INTERRUPT_VECTORS", 15
  .org $FFFA
  .w NMIHandler           
  .w RESET
  .w 0                    ; no external IRQ

  .bank 16, 8, $0000, "NES_CHR0"   ; add as many CHRs as needed - have 8kb window, but can swap high and low 4kb