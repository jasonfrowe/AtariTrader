   ; ---- TITLE LOGIC (Bank 2) ----

title_entry_point
   P0C1=$26: P0C2=$24: P0C3=$04
   P1C1=$C2: P1C2=$C6: P1C3=$CA
   P2C1=$04: P2C2=$08: P2C3=$0C
   P3C1=$B4: P3C2=$46: P3C3=$1C
   P4C1=$08: P4C2=$0C: P4C3=$0F
   P5C1=$34: P5C2=$86: P5C3=$0A
   P6C1=$42: P6C2=$46: P6C3=$4A
   P7C1=$C8: P7C2=$46: P7C3=$1C
   BACKGRND=$00

title_loop
title_release_wait
    if joy0fire1 || switchreset then goto title_release_wait
    clearscreen
    plotbanner title_screen_conv 7 0 46
    characterset unified_font
    plotchars 'VERSION' 1 20 11
    plotchars '*+-/<' 7 60 1
    plotchars '20260126' 1 84 11
    plotchars 'DIFFICULTY' 1 20 9
    if switchleftb then plotchars 'EASY' 5 108 9 else plotchars 'PRO ' 5 108 9
    drawscreen
    
    temp_acc = frame / 4
    P7C1 = ((12+temp_acc)&15)*16+8
    P7C2 = ((4+temp_acc)&15)*16+6
    P7C3 = ((1+temp_acc)&15)*16+12

    if joy0fire1 then goto init_game bank1
    frame = frame + 1
    if frame & 1 then gosub PlayMusic_Bank2
    goto title_loop

PlayMusic_Bank2
   asm
   lda music_active
   bne .Continue
   lda #1
   sta music_active
   lda #<Song_01_Data
   sta music_ptr_lo
   lda #>Song_01_Data
   sta music_ptr_hi
.Continue:
   lda music_ptr_lo
   sta $E2
   lda music_ptr_hi
   sta $E3
   ldy #0
.Loop:
   lda ($E2),y
   cmp #$FF
   beq .EndFrame
   cmp #$FE
   beq .EndSong
   tax
   iny
   lda ($E2),y
   sta $0450,x
   iny
   cpy #64
   bcs .EndFrame
   bne .Loop
.EndFrame:
   iny
   tya
   clc
   adc music_ptr_lo
   sta music_ptr_lo
   lda music_ptr_hi
   adc #0
   sta music_ptr_hi
   rts
.EndSong:
   lda #<Song_01_Data
   sta music_ptr_lo
   lda #>Song_01_Data
   sta music_ptr_hi
   rts
end

   asm
Song_01_Data:
   incbin "music/Song_01_30hz.bin"
end
