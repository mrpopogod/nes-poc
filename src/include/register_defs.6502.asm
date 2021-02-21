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
DMC_FREQ    = $4010
SND_CHN     = $4015
APU_CNTR    = $4017

  ; Controller Registers
JOY1        = $4016
JOY2        = $4017

  ; MMC1 Registers
MMC1LOAD    = $8000
MMC1CONTROL = $8000
MMC1_CHR0   = $A000
MMC1_CHR1   = $C000
MMC1_PRG    = $E000