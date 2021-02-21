  .target "6502"
  .format "nes"
  .setting "NESMapper", 1                   ; MMC1
  .setting "NESBatteryBackedWRAM", true     ; Support saving
  .setting "LaunchCommAND", "c:\\emulation\\fceux.exe {0}"
  .setting "DebugCommAND", "c:\\emulation\\fceux.exe {0}"
  .setting "ShowLabelsAfterCompiling", true
  .setting "ShowLocalLabelsAfterCompiling", true

  ; CONSTANTS

  ; PPU Registers
PPUCTRL     = $2000
PPUMASK     = $2001
PPUSTATUS   = $2002
OAMADDR     = $2003
OAMDATA     = $2004
PPUSCROLL   = $2005
PPUADDR     = $2006
PPUDATA     = $2007
OAMDMA      = $4014

  ; APU Registers
SQ1_VOL     = $4000
SQ1_SWEEP   = $4001
SQ1_LO      = $4002
SQ1_HI      = $4003
SQ2_VOL     = $4004
SQ2_SWEEP   = $4005
SQ2_LO      = $4006
SQ2_HI      = $4007
TRI_LINEAR  = $4008
TRI_LO      = $400A
TRI_HI      = $400B
NOISE_VOL   = $400C
NOISE_LO    = $400E
NOISE_HI    = $400F
SND_CHN     = $4015

  ; Controller Registers
JOY1        = $4016
JOY2        = $4017

  ; MMC1 Registers
MMC1LOAD    = $8000
MMC1CONTROL = $8000
MMC1_CHR0   = $A000
MMC1_CHR1   = $C000
MMC1_PRG    = $E000

  ; Variables in RAM
  .segment "RAM"
  .org $0000

  .org $0100
stack       .ds 256     ; block off the stack

  .org $0200
sprites     .ds 256     ; sprite OAM loading destination

  .org $6000
batteryram  .ds 8192    ; battery backup space - turn this into real variables

  .bank 0, 16, $8000, "NES_PRG0"

  .bank 15, 16, $C000, "NES_PRG1"   ; rename this to be whatever the last actual PRG is

; TODO: lots of actual code and other shit

  .segment "INTERRUPT_VECTORS"
  .org $FFFA
  .w NMIHandler
  .w RESET
  .w 0

  .bank 16, 8, $0000, "NES_CHR0"   ; add as many CHRs as needed - have 8kb window, but can swap high and low 4kb