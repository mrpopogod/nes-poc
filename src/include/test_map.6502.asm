test_map_header:
    .b $32                  ; width in 16x16 metatiles
    .b $32                  ; height in 16x16 metatiles
    .w @horizontalcodings   ; pointer to the tile codings
    .w @attributecodings    ; pointer to the attribute codings
    ; other metadata we might need would go here, like loading a specific tileset into CHR RAM or
    ; info about interactables or the encounter table
    ; also probably need the defined metatiles for this map

; Codings for our map; because each is variable length we need a lookup table
@horizontalcodings:
    .w  @h1,  @h2,  @h3,  @h4,  @h5,  @h6,  @h7,  @h8,  @h9, @h10
    .w @h11, @h12, @h13, @h14, @h15, @h16, @h17, @h18, @h19, @h20
    .w @h21, @h22, @h23, @h24, @h25, @h26, @h27, @h28, @h29, @h30
    .w @h31, @h32, @h33, @h34, @h35, @h36, @h37, @h38, @h39, @h40
    .w @h41, @h42, @h43, @h44, @h45, @h46, @h47, @h48, @h49, @h50

; Same with the attributes; since attributes are a 32x32 space we have half as many
@attributecodings:
    .w   @a1,  @a2,  @a3,  @a4,  @a5,  @a6,  @a7,  @a8,  @a9, @a10
    .w  @a11, @a12, @a13, @a14, @a15, @a16, @a17, @a18, @a19, @a20
    .w  @a21, @a22, @a23, @a24, @a25

;----- Tiles
@h1: 
    .b $32, $00, $FF
@h2: 
    .b $32, $00, $FF
@h3: 
    .b $32, $00, $FF
@h4: 
    .b $32, $00, $FF
@h5: 
    .b $32, $00, $FF
@h6: 
    .b $05, $00, $10, $01, $81, $02, $17, $01, $05, $00, $FF
@h7: 
    .b $05, $00, $81, $01, $07, $03, $81, $04, $05, $03, $81, $04, $03, $03, $81, $04, $10, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h8: 
    .b $05, $00, $82, $01, $03, $05, $04, $88, $03, $04, $03, $03, $04, $03, $03, $04, $03, $03, $81, $04, $10, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h9: 
    .b $05, $00, $83, $01, $03, $04, $03, $03, $8d, $04, $03, $04, $03, $03, $04, $03, $03, $04, $04, $03, $04, $04, $10, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h10:
    .b $05, $00, $83, $01, $03, $04, $05, $03, $84, $04, $03, $03, $04, $03, $03, $81, $04, $13, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h11:
    .b $05, $00, $82, $01, $03, $05, $04, $85, $03, $04, $03, $03, $04, $03, $03, $81, $04, $06, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h12:
    .b $05, $00, $81, $01, $09, $03, $06, $04, $06, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h13:
    .b $05, $00, $81, $01, $08, $04, $83, $03, $03, $04, $03, $03, $81, $04, $06, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h14:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h15:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h16:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h17:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h18:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h19:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h20:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h21:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h22:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h23:
    .b $05, $00, $81, $01, $07, $04, $03, $03, $81, $04, $0a, $03, $81, $04, $10, $03, $81, $01, $05, $00, $FF
@h24:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $10, $03, $81, $01, $05, $00, $FF
@h25:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $08, $04, $09, $03, $81, $01, $05, $00, $FF
@h26:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $10, $03, $81, $01, $05, $00, $FF
@h27:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h28:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h29:
    .b $05, $00, $81, $01, $0a, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h30:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h31:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h32:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h33:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h34:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h35:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h36:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h37:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h38:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h39:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h40:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h41:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h42:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h43:
    .b $05, $00, $81, $01, $05, $03, $81, $04, $04, $03, $81, $04, $0a, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h44:
    .b $05, $00, $81, $01, $15, $03, $81, $04, $0c, $03, $81, $04, $03, $03, $81, $01, $05, $00, $FF
@h45:
    .b $05, $00, $28, $01, $05, $00, $FF
@h46:
    .b $32, $00, $FF
@h47:
    .b $32, $00, $FF
@h48:
    .b $32, $00, $FF
@h49:
    .b $32, $00, $FF
@h50:
    .b $32, $00, $FF

;----- Attributes
@a1:
    .b $19, $00, $FF
@a2:
    .b $19, $00, $FF
@a3:
    .b $19, $00, $FF
@a4:
    .b $03, $00, $89, $40, $50, $50, $44, $00, $10, $44, $00, $44, $08, $00, $81, $11, $04, $00, $FF
@a5:
    .b $03, $00, $89, $44, $00, $04, $44, $00, $11, $04, $11, $05, $08, $00, $81, $11, $04, $00, $FF
@a6:
    .b $03, $00, $8b, $04, $05, $05, $04, $40, $51, $50, $11, $00, $00, $44, $06, $00, $81, $11, $04, $00, $FF
@a7:
    .b $03, $00, $04, $05, $87, $00, $11, $00, $01, $00, $00, $44, $06, $00, $81, $11, $04, $00, $FF
@a8:
    .b $08, $00, $81, $11, $04, $00, $81, $44, $06, $00, $81, $11, $04, $00, $FF
@a9:
    .b $08, $00, $81, $11, $04, $00, $81, $44, $06, $00, $81, $11, $04, $00, $FF
@a10:
    .b $08, $00, $81, $11, $04, $00, $81, $44, $06, $00, $81, $11, $04, $00, $FF
@a11:
    .b $08, $00, $81, $11, $04, $00, $81, $44, $06, $00, $81, $11, $04, $00, $FF
@a12:
    .b $03, $00, $03, $05, $83, $01, $00, $11, $04, $00, $81, $44, $0b, $00, $FF
@a13:
    .b $08, $00, $81, $11, $04, $00, $81, $44, $03, $05, $81, $01, $07, $00, $FF
@a14:
    .b $08, $00, $81, $11, $04, $00, $81, $44, $06, $00, $81, $11, $04, $00, $FF
@a15:
    .b $05, $00, $84, $40, $00, $00, $11, $04, $00, $81, $44, $06, $00, $81, $11, $04, $00, $FF
@a16:
    .b $05, $00, $84, $44, $00, $00, $11, $04, $00, $81, $44, $06, $00, $81, $11, $04, $00, $FF
@a17:
    .b $05, $00, $84, $44, $00, $00, $11, $04, $00, $81, $44, $06, $00, $81, $11, $04, $00, $FF
@a18:
    .b $05, $00, $84, $44, $00, $00, $11, $04, $00, $81, $44, $06, $00, $81, $11, $04, $00, $FF
@a19:
    .b $05, $00, $84, $44, $00, $00, $11, $04, $00, $81, $44, $06, $00, $81, $11, $04, $00, $FF
@a20:
    .b $05, $00, $84, $44, $00, $00, $11, $04, $00, $81, $44, $06, $00, $81, $11, $04, $00, $FF
@a21:
    .b $05, $00, $84, $44, $00, $00, $11, $04, $00, $81, $44, $06, $00, $81, $11, $04, $00, $FF
@a22:
    .b $05, $00, $84, $04, $00, $00, $01, $04, $00, $81, $44, $06, $00, $81, $11, $04, $00, $FF
@a23:
    .b $19, $00, $FF
@a24:
    .b $19, $00, $FF
@a25:
    .b $19, $00, $FF

; Last byte as of this commit is $85DE, so we use 1502 bytes.  Max capacity of one bank is 16k, so we've used less than a tenth.
; Looking at the entire capacity of MMC1 we've used 1/124th.  So it's a good thing we're compressing given it would be at least twice
; this size uncompressed.