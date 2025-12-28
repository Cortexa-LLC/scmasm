
1000        .TI 76,STB-80 Driver....................July 5, 1985....................
1010 *SAVE IO.STB80
1020 *--------------------------------
1030 LOCATION   .EQ $8000            START OF ASSEMBLER
1040 *--------------------------------
1050        .OR $6100                POSITON IN SYS FILE
1060            .TF B.IO.STB80
1070            .PH $2800+LOCATION   POSITION WHEN RUNNING
1080 *--------------------------------
1090 CH           .EQ $24
1100 CV           .EQ $25
1110 BASL         .EQ $28,29
1120 SCREEN.WIDTH .EQ $A5
1130 *--------------------------------
1140 SLOT       .EQ 3
1150 *--------------------------------
1160 STB.HORIZ  .EQ $05F8+SLOT
1170 STB.ESCBYT .EQ $06F8+SLOT
1180 STB.FLAGS  .EQ $0778+SLOT
1190 *--------------------------------
1200 STB.ENTRY  .EQ SLOT*256+$C000
1210 STB.RDKEY  .EQ SLOT*256+$C005
1220 STB.COUT   .EQ SLOT*256+$C019
1230 STB.SCREEN .EQ SLOT*256+$C031
1240 *--------------------------------
1250 F.EXEC     .EQ $BE43
1260 MON.INIT   .EQ $FB2F
1270 MON.RDKEY  .EQ $FD0C
1280 MON.COUT   .EQ $FDED
1290 *--------------------------------
1300 *   I/O VECTORS -- 3 BYTES EACH
1310 *--------------------------------
1320 IO.INIT             JMP S.IO.INIT
1330 IO.WARM             JMP S.IO.WARM
1340 READ.KEY.WITH.CASE  JMP S.READ.KEY.WITH.CASE
1350 GET.HORIZ.POSN      JMP S.GET.HORIZ.POSN
1360 IO.HOME             LDA #$8C     ^L--HOME
1370                     .HS 2C
1380 IO.CLREOL           LDA #$9D     ^]--CLREOL
1390                     .HS 2C
1400 IO.CLREOP           LDA #$8B     ^K--CLREOP
1410                     .HS 2C
1420 IO.UP               LDA #$9F     ^_--UP 
1430                     .HS 2C
1440 IO.DOWN             LDA #$8A     ^J--DOWN
1450                     .HS 2C
1460 IO.LEFT             LDA #$88     ^H--LEFT
1470                     .HS 2C
1480 IO.RIGHT            LDA #$9C     ^\--RIGHT
1490                     NOP
1500 IO.COUT             JMP MON.COUT
1510 IO.PICK.SCREEN      JMP S.IO.PICK.SCREEN
1520 IO.HTABX            JMP S.IO.HTABX
1530 IO.HTAB             JMP S.IO.HTAB
1540 IO.VTAB             JMP S.IO.VTAB
1550 *---Case Change MUST go here-----
1560 IO.CASE.TOGGLE
1570        LDA STB.FLAGS
1580        EOR #$40
1590        STA STB.FLAGS
1600        RTS
1610 *--------------------------------
1620 *      VARIABLE LENGTH ROUTINES
1630 *--------------------------------
1640 S.IO.HTABX
1650        PHA
1660        TXA
1670        JSR S.IO.HTAB
1680        PLA
1690        RTS
1700 *--------------------------------
1710 S.GET.HORIZ.POSN
1720        LDA STB.HORIZ
1730        RTS
1740 *--------------------------------
1750 S.IO.VTAB
1760        STA CV
1770        LDA STB.HORIZ
1780 S.IO.HTAB
1790        PHA          SAVE HORIZ POSN
1800        LDA #$9E
1810        JSR STB.COUT
1820        PLA          GET HORIZ POSN
1830        JSR OFFSET.COUT
1840        LDA CV
1850 OFFSET.COUT
1860        CLC
1870        ADC #$A0
1880        JMP STB.COUT
1890 *--------------------------------
1900 S.IO.INIT
1910        LDA #80
1920        STA SCREEN.WIDTH
1930        LDA #$8C     CLEAR SCREEN AND START STB-80
1940        JSR STB.ENTRY
1950        LDA #0
1960        STA STB.ESCBYT     DISABLE ^A AND ESC-MODE
1970        LDA #2       DISABLE "HOME" SENSING
1980        STA STB.FLAGS
1990 INSTALL.VECTORS
2000        LDX #1
2010 .1     LDA VECTORS,X
2020        STA $36,X
2030        STA SLOT*2+$BE10,X
2040        LDA VECTORS+2,X
2050        BIT F.EXEC
2060        BMI .2
2070        STA $38,X
2080 .2     STA SLOT*2+$BE20,X
2090        DEX
2100        BPL .1
2110        RTS
2120 *--------------------------------
2130 VECTORS    .DA S.IO.COUT
2140            .DA S.IO.RDKEY
2150 *--------------------------------
2160 S.IO.WARM
2170        CLD
2180        LDX CV
2190        JSR MON.INIT
2200        STX CV
2210        JMP INSTALL.VECTORS
2220 *--------------------------------
2230 *      READ KEY WITH CASE CONTROL
2240 *--------------------------------
2250 S.READ.KEY.WITH.CASE
2260        JSR MON.RDKEY
2270        ORA #$80     REQUIRED FOR EXEC FILES
2280        CLC          SIGNAL NO OPEN APPLE
2290        RTS
2300 *--------------------------------
2310 S.IO.RDKEY
2320        CLD
2330        LDA #$0A
2340        STA SLOT*16+$C080
2350        LDA #$07     SOLID DBL LINE CURSOR
2360        STA SLOT*16+$C081
2370        JSR STB.RDKEY
2380        ORA #$80     Make sure it looks right
2390        PHA
2400        LDA #$0A
2410        STA SLOT*16+$C080
2420        LDA #$20     CURSOR OFF
2430        STA SLOT*16+$C081
2440        PLA
2450        RTS
2460 *--------------------------------
2470 S.IO.COUT
2480        CLD
2490        CMP #$80     NORMAL OR INVERSE?
2500        BCS .1       ...NORMAL
2510        PHA          ...80-COLUMN
2520        LDA #$8F     SELECT INVERSE DISPLAY
2530        JSR STB.COUT
2540        PLA
2550        ORA #$80     MAKE PRINTABLE CHARACTER
2560        CMP #$A0
2570        BCS .2
2580        ORA #$40
2590 .2     JSR STB.COUT
2600        LDA #$8E     SELECT NORMAL DISPLAY
2610 .1     JMP STB.COUT
2620 *--------------------------------
2630 S.IO.PICK.SCREEN
2640        STX $481
2650        TYA
2660        STA $482
2670        JSR S.IO.HTAB
2680        JSR STB.SCREEN
2690        LDY $482
2700        LDX $481
2710        RTS
2720 *--------------------------------
