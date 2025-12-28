
1000 *SAVE X.ASM.VECTORS
1010 *--------------------------------
1020        .MA VEC
1030        BIT RDROM
1040        JSR ]1
1050        BIT RDRAM
1060        RTS
1070        .EM
1080 *--------------------------------
1090   JMP SEARCH.COMPRESSED.TABLE
1100   JMP GNC
1110   JMP GNC.UC
1120   JMP GNNB
1130  >VEC EXPR
1140  >VEC EXP1
1150   JMP ASM.ERROR
1160  >VEC EMIT
1170 *--------------------------------
1180 ERBA   LDY #QER5
1190        JMP SOFT.ERROR
1200 *--------------------------------
1210        .DUMMY
1220        .OR $D400
1230 D4.ASM.INIT         .BS 3
1240 D4.ASM.LINE         .BS 3
1250 D4.EMIT.VALUE       .BS 3
1260 D4.DIR.OP           .BS 3
1270 D4.VERSION
1280        .ED
1290 *--------------------------------
1300 ASM.INIT   LDA RDRAM
1310            JSR D4.ASM.INIT
1320            LDA RDROM
1330            RTS
1340 *--------------------------------
1350 ASM.PARTICULAR LDA RDRAM
1360                JSR D4.ASM.LINE
1370                LDA RDROM
1380                RTS
1390 *--------------------------------
1400 EMIT.VALUE     LDA RDRAM
1410                JSR D4.EMIT.VALUE
1420                LDA RDROM
1430                RTS
1440 *--------------------------------
1450 PSOP   LDA RDRAM
1460        JSR D4.DIR.OP
1470        LDA RDROM
1480        RTS
1490 *--------------------------------
1500 EXP.OVER.256
1510        LDA EXP.VALUE+1
1520        STA EXP.VALUE
1530        LDA EXP.VALUE+2
1540        STA EXP.VALUE+1
1550        LDA EXP.VALUE+3
1560        STA EXP.VALUE+2
1570        LDA #0
1580        STA EXP.VALUE+3
1590        RTS
1600 *--------------------------------
1610 ASM.ERROR
1620        BIT RDROM
1630        TAX          USE ERROR # FOR INDEX
1640        LDY ASM.ERROR.TABLE,X
1650        JMP SOFT.ERROR
1660 *--------------------------------
1670 ASM.ERROR.TABLE
1680        .DA #QER2    "BAD OPCODE"
1690        .DA #QER5    "BAD ADDRESS"
1700        .DA #QER3    "RANGE"
1710        .DA #QER6    "UNDEF LABEL"
1720 *--------------------------------
1730 VERSION
1740        LDY #QSC
1750        JSR QT.OUT
1760        LDY #2
1770 .1     LDA Q.VERSION,Y
1780        JSR MY.COUT
1790        DEY
1800        BPL .1
1810        LDA #$8D
1820 .2     JSR MY.COUT
1830        INY
1840        LDA RDRAM
1850        LDX D4.VERSION,Y
1860        LDA RDROM
1870        TXA
1880        BNE .2
1890        RTS
1900 *--------------------------------
