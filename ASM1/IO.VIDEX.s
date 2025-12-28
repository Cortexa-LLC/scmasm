
1000        .TI 76,Videx Videoterm Driver.......................July 5, 1985.............
1010 *SAVE IO.VIDEX
1020 *--------------------------------
1030 LOCATION   .EQ $8000           start of assembler
1040 *--------------------------------
1050        .OR $6200               POSITION IN SYS FILE
1060            .TF B.IO.VIDEX
1070            .PH $2800+LOCATION  POSITION WHEN RUNNING
1080 *--------------------------------
1090 CH           .EQ $24
1100 CV           .EQ $25
1110 BASL         .EQ $28,29
1120 SCREEN.WIDTH .EQ $A5
1130 *--------------------------------
1140 SLOT   .EQ 3        ASSUME SLOT 3
1150 *--------------------------------
1160 VIDEX.CARD   .EQ SLOT*256+$C000
1170 VIDEX.COUT   .EQ SLOT*256+$C007
1180 VIDEX.REG    .EQ SLOT*16+$C080
1190 VIDEX.DATA   .EQ SLOT*16+$C081
1200 *--------------------------------
1210 VIDEX.BASEL .EQ $0478+SLOT
1220 VIDEX.BASEH .EQ $04F8+SLOT
1230 VIDEX.HORIZ .EQ $0578+SLOT
1240 VIDEX.CHAR  .EQ $0678+SLOT
1250 *--------------------------------
1260 F.EXEC     .EQ $BE43
1270 MON.INIT   .EQ $FB2F
1280 MON.RDKEY  .EQ $FD0C
1290 MON.COUT   .EQ $FDED
1300 *--------------------------------
1310 *   I/O VECTORS -- 3 BYTES EACH
1320 *--------------------------------
1330 IO.INIT            JMP S.IO.INIT
1340 IO.WARM            JMP S.IO.WARM
1350 READ.KEY.WITH.CASE JMP S.READ.KEY.WITH.CASE
1360 GET.HORIZ.POSN     JMP S.GET.HORIZ.POSN
1370 IO.HOME            LDA #$8C     ^L--HOME
1380                    .HS 2C
1390 IO.CLREOL          LDA #$9D     ^]--CLREOL
1400                    .HS 2C
1410 IO.CLREOP          LDA #$8B     ^K--CLREOP
1420                    .HS 2C
1430 IO.UP              LDA #$9F     ^_--UP 
1440                    .HS 2C
1450 IO.DOWN            LDA #$8A     ^J--DOWN
1460                    .HS 2C
1470 IO.LEFT            LDA #$88     ^H--LEFT
1480                    .HS 2C
1490 IO.RIGHT           LDA #$9C     ^\--RIGHT
1500                    NOP
1510 IO.COUT            JMP MON.COUT
1520 IO.PICK.SCREEN     JMP S.IO.PICK.SCREEN
1530 IO.HTABX           JMP S.IO.HTABX
1540 IO.HTAB            JMP S.IO.HTAB
1550 IO.VTAB            JMP S.IO.VTAB
1560 *---Case Toggle MUST go here-----
1570 IO.CASE.TOGGLE
1580        LDA CASEFLG
1590        EOR #$80
1600        STA CASEFLG
1610        RTS
1620 *--------------------------------
1630 *      VARIABLE LENGTH ROUTINES
1640 *--------------------------------
1650 S.IO.HTABX
1660        PHA
1670        TXA
1680        JSR S.IO.HTAB
1690        PLA
1700        RTS
1710 *--------------------------------
1720 S.GET.HORIZ.POSN
1730        LDA VIDEX.HORIZ
1740        RTS
1750 *--------------------------------
1760 S.IO.VTAB
1770        STA CV
1780        LDA VIDEX.HORIZ
1790 S.IO.HTAB
1800        PHA          SAVE HORIZ POSN
1810        LDA #$9E
1820        JSR VIDEX.COUT
1830        PLA          GET HORIZ POSN
1840        CLC
1850        ADC #$A0
1860        JSR VIDEX.COUT
1870        LDA CV
1880        ORA #$A0
1890        JMP VIDEX.COUT
1900 *--------------------------------
1910 S.IO.INIT
1920        LDA #80
1930        STA SCREEN.WIDTH
1940        STA CASEFLG  CLEAR CASEFLG (BIT7=0)
1950        LDA #$8C     CLEAR SCREEN AND START VIDEX-80
1960        JSR VIDEX.CARD
1970 INSTALL.VECTORS
1980        LDX #1
1990 .1     LDA VECTORS,X
2000        STA $36,X
2010        STA SLOT*2+$BE10,X
2020        LDA VECTORS+2,X
2030        BIT F.EXEC
2040        BMI .2
2050        STA $38,X
2060 .2     STA SLOT*2+$BE20,X
2070        DEX
2080        BPL .1
2090        RTS
2100 *--------------------------------
2110 VECTORS    .DA S.IO.COUT
2120            .DA S.IO.RDKEY
2130 *--------------------------------
2140 S.IO.WARM
2150        CLD
2160        LDX CV
2170        JSR MON.INIT
2180        STX CV
2190        JMP INSTALL.VECTORS
2200 *--------------------------------
2210 *      READ KEY WITH CASE CONTROL
2220 *--------------------------------
2230 S.READ.KEY.WITH.CASE
2240        JSR MON.RDKEY
2250        ORA #$80     REQUIRED FOR EXEC COMMAND
2260        CLC          SIGNAL NO OPEN APPLE
2270        RTS
2280 *--------------------------------
2290 S.IO.RDKEY
2300        CLD
2310        LDA #$0A     SELECT BLINKING DOUBLE UNDERLINE CURSOR
2320        STA VIDEX.REG
2330        LDA #$67
2340        STA VIDEX.DATA
2350        LDA #$0B
2360        STA VIDEX.REG
2370        LDA #$08
2380        STA VIDEX.DATA
2390 .1     LDA $C000
2400        BPL .1
2410        STA $C010
2420        PHA
2430        LDA #$0A     HIDE THE CURSOR
2440        STA VIDEX.REG
2450        LDA #$09
2460        STA VIDEX.DATA
2470        PLA
2480        CMP #$8D
2490        BNE .2
2500        JSR IO.CLREOL
2510        LDA #$8D
2520 .2     BIT CASEFLG  TEST CASE CONVERSION FLAG
2530        BPL .6       DO NOT CONVERT
2540        CMP #$B0
2550        BCC .6       DO NOT CONVERT
2560        BIT $C063    TEST PADDLE BUTTON
2570        BMI .5       NO SHIFTKEY PRESSED
2580        CMP #$B0
2590        BEQ .4
2600        CMP #$C0
2610        BNE .3
2620        LDA #$D0
2630 .3     CMP #$DB
2640        BCC .6 
2650        AND #$CF
2660        BNE .6 
2670 .4     LDA #$DD
2680 .5     ORA #$20
2690 .6     AND #$7F
2700        STA VIDEX.CHAR
2710        ORA #$80
2720        SEC
2730        RTS
2740 *--------------------------------
2750 S.IO.COUT
2760        CLD
2770        CMP #$80     NORMAL OR INVERSE?
2780        BCS .1       ...NORMAL
2790        PHA          ...80-COLUMN
2800        LDA #$8F     SELECT INVERSE DISPLAY
2810        JSR VIDEX.COUT
2820        PLA
2830        ORA #$80     MAKE PRINTABLE CHARACTER
2840        CMP #$A0
2850        BCS .2
2860        ORA #$40
2870 .2     JSR VIDEX.COUT
2880        LDA #$8E     SELECT NORMAL DISPLAY
2890 .1     JMP VIDEX.COUT
2900 *--------------------------------
2910 *   GET CHARACTER OFF CURRENT SCREEN LINE, COLUMN (Y)
2920 *--------------------------------
2930 S.IO.PICK.SCREEN
2940        STX SAVEX
2950        BIT $CFFF    TURN ON $C800 VIDEO SPACE
2960        BIT VIDEX.CARD
2970 *---CALCULATE POSITION-----------
2980        CLC
2990        TYA          COLUMN 0-79
3000        ADC VIDEX.BASEL
3010        PHA
3020        LDA #0
3030        ADC VIDEX.BASEH
3040        PHA
3050        ASL
3060        AND #$0C     USE BIT 0 AND 1 FOR PAGING
3070        TAX
3080        LDA VIDEX.REG,X
3090        PLA
3100        LSR          ODD/EVEN PAGE
3110        PLA
3120        TAX
3130 *---GET CHAR FROM WINDOW---------
3140        LDA $CC00,X
3150        BCC .1
3160        LDA $CD00,X
3170 .1     ORA #$80
3180        STA VIDEX.CHAR
3190        LDX SAVEX
3200        RTS
3210 *--------------------------------
3220 SAVEX   .BS 1
3230 CASEFLG .BS 1
3240 *--------------------------------
