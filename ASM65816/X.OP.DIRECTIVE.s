
1000 *SAVE X.OP.DIRECTIVE
1010 *--------------------------------
1020 *      OPCODE TABLE SELECTION
1030 *      .OP 6502/65C02/R65C02/65816/SWEET16,...
1040 *--------------------------------
1050 DIR.OP LDA #0
1060        STA LEVEL.MASK
1070        LDA #15
1080        STA EMIT.MARGIN
1090 .1     JSR GNC.UC   GET NEXT CHARACTER
1100        BCS .5       END
1110        LDY #-2
1120 .2     INY
1130        INY
1140        LDA PSOP.TABLE,Y
1150        BEQ .1       ...END OF TABLE, TRY NEXT CHARACTER
1160        CMP CURRENT.CHAR
1170        BNE .2       ...NOT THIS ONE
1180 .3     LDA PSOP.TABLE+1,Y
1190        STA LEVEL.MASK
1200        BPL .5
1210        LDA #18
1220        STA EMIT.MARGIN
1230 .5     RTS          RETURN TO ASSEMBLER
1240 *--------------------------------
1250 PSOP.TABLE
1260        .DA #'8',#$A0     65816 = $A0
1270        .DA #'C',#$20     65C02 = $20
1280   .DO ROCKWELL
1290        .DA #'R',#$60   ROCKWELL= $60
1300   .FIN
1310   .DO SWEET.16
1320        .DA #'S',#$01   SWEET-16= $01
1330   .FIN
1340        .DA #0
1350 *--------------------------------
