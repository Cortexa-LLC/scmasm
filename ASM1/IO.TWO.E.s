
1000  .LIF
1010        .TI 76,40/80 //e & //c Driver...................JULY 5, 1985............
1020 *SAVE IO.TWO.E
1030 *--------------------------------
1040 LOCATION   .EQ $8000             START OF ASSEMBLER
1050        .INB ASM2/X.DATA
1060 *--------------------------------
1070        .OR $6000                 POSITION IN SYS FILE
1080            .TF B.IO.TWO.E
1090            .PH $2800+LOCATION    POSITION WHEN RUNNING
1100 *--------------------------------
1110 *   I/O VECTORS -- 3 BYTES EACH
1120 *--------------------------------
1130 IO.INIT             JMP S.IO.INIT
1140 IO.WARM             JMP S.IO.WARM
1150 READ.KEY.WITH.CASE  JMP S.IO.RDKEY
1160 GET.HORIZ.POSN      JMP S.GET.HORIZ.POSN
1170 IO.HOME             JMP MON.HOME
1180 IO.CLREOL           JMP MON.CLREOL
1190 IO.CLREOP           JMP MON.CLREOP
1200 IO.UP               JMP MON.UP
1210 IO.DOWN             JMP MON.LF
1220 IO.LEFT             JMP S.IO.LEFT
1230 IO.RIGHT            JMP S.IO.RIGHT
1240 IO.COUT             JMP S.IO.COUT
1250 IO.PICK.SCREEN      JMP S.IO.PICK.SCREEN
1260 IO.HTABX            JMP S.IO.HTABX
1270 IO.HTAB             JMP S.IO.HTAB
1280 IO.VTAB             JMP S.IO.VTAB
1290 *---Case Toggle MUST go here-----
1300 IO.CASE.TOGGLE
1310        RTS
1320 *--------------------------------
1330 *      VARIABLE LENGTH ROUTINES
1340 *--------------------------------
1350 S.IO.INIT
1360        LDA $BF98
1370        AND #2
1380        BEQ IO.HOME
1390        LDA #$99     CTRL-Y
1400        JMP $C300
1410 *--------------------------------
1420 S.IO.HTABX
1430        PHA
1440        TXA
1450        JSR S.IO.HTAB
1460        PLA
1470        RTS
1480 *--------------------------------
1490 S.IO.HTAB
1500        BIT $C01F
1510        BPL .1
1520        STA $57B
1530        RTS
1540 .1     STA CH
1550        RTS
1560 *--------------------------------
1570 S.GET.HORIZ.POSN
1580        LDA $57B
1590        BIT $C01F
1600        BMI .1
1610        LDA CH
1620 .1     RTS
1630 *--------------------------------
1640 S.IO.WARM
1650        CLD
1660        LDX CV       SAVE CV
1670        JSR MON.INIT
1680        TXA          GET CV, FALL INTO VTAB
1690 S.IO.VTAB
1700        STA CV
1710        JMP MON.VTAB
1720 *--------------------------------
1730 S.IO.RDKEY
1740        LDA #40
1750        BIT $C01F
1760        BPL .1
1770        ASL
1780 .1     STA SCREEN.WIDTH
1790        JSR MON.RDKEY
1800        CMP #$FF
1810        BNE .2
1820        LDA #$88
1830 .2     ASL $C061    SET CARRY IF "OPEN APPLE" PRESSED
1840        ORA #$80
1850        RTS
1860 *--------------------------------
1870 S.IO.COUT
1880        CMP #$80     NORMAL OR INVERSE?
1890        BCS .2       ...NORMAL
1900        BIT $C01F    ...INVERSE; 40- OR 80-COLUMNS?
1910        BPL .2       ...40-COLUMN
1920        PHA          ...80-COLUMN
1930        LDA #$8F     SELECT INVERSE DISPLAY
1940        JSR MON.COUT
1950        PLA
1960        CMP #$20     CONTROL CHAR?
1970        BCS .1       ...NO
1980        ORA #$40     MAKE PRINTABLE CHARACTER
1990 .1     ORA #$80
2000        JSR MON.COUT
2010        LDA #$8E     SELECT NORMAL DISPLAY
2020 .2     JMP MON.COUT
2030 *--------------------------------
2040 S.IO.PICK.SCREEN
2050        BIT $C01F
2060        BMI .1
2070        LDA (BASL),Y
2080        RTS
2090 .1     TYA
2100        LSR
2110        TAY
2120        PHP
2130        SEI
2140        LDA $C055
2150        BCC .2
2160        LDA $C054
2170 .2     LDA (BASL),Y
2180        BIT $C054
2190        PLP
2200        PHA          SAVE CHAR FROM SCREEN
2210        TYA          RESTORE Y-REG
2220        ROL
2230        TAY
2240        PLA
2250        RTS
2260 *--------------------------------
2270 S.IO.RIGHT
2280        BIT $C01F    IN 80-COLUMN MODE?
2290        BMI .1       ...YES
2300        JMP MON.ADVANC
2310 .1     LDA #$9C     FORWARD SPACE
2320        .HS 2C       SKIP TWO BYTES
2330 *--------------------------------
2340 S.IO.LEFT
2350        LDA #$88     BACKSPACE
2360        JMP MON.COUT
2370 *--------------------------------
