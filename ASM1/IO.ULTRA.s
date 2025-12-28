
1000        .TI 76,VIDEX ULTRATERM DRIVER................July 5, 1985..............
1010 *SAVE IO.ULTRA
1020 *--------------------------------
1030 LOCATION   .EQ $8000     ORIGIN OF S-C ASSEMBLER
1040 *--------------------------------
1050        .OR $6400         POSITON IN SCASM.SYSTEM SYS FILE
1060            .TF B.IO.ULTRA
1070            .PH $2800+LOCATION    POSITION WHEN RUNNING
1080 *--------------------------------
1090 *      VIDEX ULTRATERM DRIVER -- ASSUME SLOT 3
1100 SLOT   .EQ 3
1110 SKMOD  .EQ 1        SHIFT KEY MOD (=0 FOR //E VERSION)
1120 *--------------------------------
1130 *   TO MAKE THE EDIT COMMAND USE MORE THAN 24 LINES,
1140 *     CHANGE $17 TO $1F OR $2F AT $803A
1150 *--------------------------------
1160 CH           .EQ $24
1170 CV           .EQ $25
1180 BASL         .EQ $28,29
1190 SCREEN.WIDTH .EQ $A5
1200 *--------------------------------
1210 ULTRA.CARD   .EQ SLOT*256+$C000
1220 ULTRA.COUT   .EQ SLOT*256+$C007
1230 *--------------------------------
1240 ULTRA.REG    .EQ SLOT*16+$C080
1250 ULTRA.DATA   .EQ SLOT*16+$C081
1260 *--------------------------------
1270 ULTRA.HORIZ .EQ $0578+SLOT
1280 ULTRA.START .EQ $06F8+SLOT    TOP-OF-SCREEN ADDRESS / 16
1290 ULTRA.CHPG  .EQ $0678
1300 ULTRA.TEMPX .EQ $0778
1310 ULTRA.TEMPY .EQ $07F8
1320 ULTRA.FLAGS .EQ $07F8+SLOT
1330 *--------------------------------
1340 F.EXEC       .EQ $BE43
1350 MON.INIT     .EQ $FB2F
1360 MON.RDKEY    .EQ $FD0C
1370 MON.COUT     .EQ $FDED
1380 MON.INVFLG   .EQ $32
1390 *--------------------------------
1400 *   I/O VECTORS -- 3 BYTES EACH
1410 *--------------------------------
1420 IO.INIT                  JMP S.IO.INIT
1430 IO.WARM                  JMP S.IO.WARM
1440 READ.KEY.WITH.CASE       JMP S.READ.KEY.WITH.CASE
1450 GET.HORIZ.POSN           JMP S.GET.HORIZ.POSN
1460 IO.HOME                  LDA #$8C     ^L--HOME
1470                          .HS 2C
1480 IO.CLREOL                LDA #$9D     ^]--CLREOL
1490                          .HS 2C
1500 IO.CLREOP                LDA #$8B     ^K--CLREOP
1510                          .HS 2C
1520 IO.UP                    LDA #$9F     ^_--UP 
1530                          .HS 2C
1540 IO.DOWN                  LDA #$8A     ^J--DOWN
1550                          .HS 2C
1560 IO.LEFT                  LDA #$88     ^H--LEFT
1570                          .HS 2C
1580 IO.RIGHT                 LDA #$9C     ^\--RIGHT
1590                          NOP
1600 IO.COUT                  JMP MON.COUT
1610 IO.PICK.SCREEN           JMP S.IO.PICK.SCREEN
1620 IO.HTABX                 JMP S.IO.HTABX
1630 IO.HTAB                  JMP S.IO.HTAB
1640 IO.VTAB                  JMP S.IO.VTAB
1650 *---Case Toggle MUST go here-----
1660 IO.CASE.TOGGLE
1670        LDA ULTRA.FLAGS
1680        EOR #$40
1690        STA ULTRA.FLAGS
1700        RTS
1710 *--------------------------------
1720 *      VARIABLE LENGTH ROUTINES
1730 *--------------------------------
1740 S.IO.HTABX
1750        PHA
1760        TXA
1770        JSR S.IO.HTAB
1780        PLA
1790        RTS
1800 *--------------------------------
1810 S.GET.HORIZ.POSN
1820        LDA ULTRA.HORIZ
1830        RTS
1840 *--------------------------------
1850 S.IO.VTAB
1860        STA CV
1870        LDA ULTRA.HORIZ
1880 S.IO.HTAB
1890        PHA          SAVE HORIZ POSN
1900        LDA #$9E
1910        JSR ULTRA.COUT
1920        PLA          GET HORIZ POSN
1930        JSR OFFSET.COUT
1940        LDA CV
1950 OFFSET.COUT
1960        CLC          ADD $A0 OFFSET
1970        ADC #$A0
1980        JMP ULTRA.COUT
1990 *--------------------------------
2000 S.IO.INIT
2010        LDA #80
2020        STA SCREEN.WIDTH
2030        LDA #$8C     CLEAR SCREEN AND START VIDEX-80
2040        STA $C00B    SWITCH OFF //E C3 ROM
2050        STA $C006    SWITCH OFF //E C100-C7FF ROM
2060        JSR ULTRA.CARD
2070 INSTALL.VECTORS
2080        LDX #1
2090 .1     LDA VECTORS,X
2100        STA $36,X
2110        STA SLOT*2+$BE10,X
2120        LDA VECTORS+2,X
2130        BIT F.EXEC
2140        BMI .2
2150        STA $38,X
2160 .2     STA SLOT*2+$BE20,X
2170        DEX
2180        BPL .1
2190        RTS
2200 *--------------------------------
2210 VECTORS
2220        .DA S.IO.COUT
2230        .DA S.IO.RDKEY
2240 *--------------------------------
2250 S.IO.WARM
2260        CLD
2270        LDX CV
2280        JSR MON.INIT
2290        STX CV
2300        JMP INSTALL.VECTORS
2310 *--------------------------------
2320 *      READ KEY WITH CASE CONTROL
2330 *--------------------------------
2340 S.READ.KEY.WITH.CASE
2350        JSR MON.RDKEY
2360        ORA #$80     REQUIRED FOR EXEC COMMAND
2370        CLC          SIGNAL NO OPEN APPLE
2380        RTS
2390 *--------------------------------
2400 S.IO.RDKEY
2410        CLD
2420        LDA #$0A     SELECT BLINKING DOUBLE UNDERLINE CURSOR
2430        STA ULTRA.REG
2440        LDA #$67
2450        STA ULTRA.DATA
2460        LDA #$0B
2470        STA ULTRA.REG
2480        LDA #$08
2490        STA ULTRA.DATA
2500 .1     LDA $C000
2510        BPL .1
2520        STA $C010
2530        PHA
2540        LDA #$06     HIDE THE CURSOR
2550        STA ULTRA.DATA
2560        PLA
2570        CMP #$8D
2580        BNE .2
2590        JSR IO.CLREOL
2600        LDA #$8D
2610    .DO SKMOD
2620 .2     PHA          CHECK SHIFT LOCK FLAG
2630        LDA ULTRA.FLAGS
2640        ASL
2650        ASL
2660        PLA
2670        BCC .5       ...SHIFT LOCK IS ON
2680        CMP #$C0
2690        BCC .5       NOT IN ALPHA RANGE
2700        BEQ .3       ...@ IS CAPITAL P
2710        ORA #$20     ADJUST TO LOWER CASE
2720        BIT $C063    TEST SHIFT KEY (PB3)
2730        BMI .5       ...NOT PRESSED, LOWER CASE
2740        CMP #$FB
2750        BCC .4       ...NORMAL A-Z
2760 .3     EOR #$10     CHANGE @ to P, [\]^_ to KLMNO
2770 .4     AND #$DF          UPPER CASE
2780 .5     RTS
2790    .ELSE
2800 .2     RTS
2810    .FIN
2820 *--------------------------------
2830 S.IO.COUT
2840        CLD
2850        PHA
2860        STA MON.INVFLG    BIT 7 CONTROLS INV/NORM
2870        CMP #$20          CATCH INV CTRL CHARS
2880        BCS .1            ...NOT ONE
2890        ORA #$40          MAKE CTRL VISIBLE
2900 .1     JSR ULTRA.COUT
2910        LDA #$FF
2920        STA MON.INVFLG
2930        PLA
2940        RTS
2950 *--------------------------------
2960 W16TBL .DA #80/16
2970        .DA #96/16
2980        .DA #160/16
2990        .DA #80/16
3000        .DA #80/16
3010        .DA #80/16
3020        .DA #160/16
3030        .DA #128/16
3040 *--------------------------------
3050 *   GET CHARACTER OFF CURRENT SCREEN LINE, COLUMN (Y)
3060 *--------------------------------
3070 S.IO.PICK.SCREEN
3080        STY ULTRA.TEMPY
3090        STX ULTRA.TEMPX
3100        BIT $CFFF
3110        BIT ULTRA.CARD     TURN ON SCREEN             
3120 *--------------------------------
3130        LDA ULTRA.FLAGS   GET MODE (0...7)
3140        AND #$07
3150        TAY               Y = MODE INDEX (0...7)
3160 *--------------------------------
3170        LDA ULTRA.TEMPY        HORIZ. POSN
3180        CPY #$06          132 COL MODE?
3190        BNE .1            ...NOT 132 COLUMNS
3200        ADC #14           ADJUST FOR 132 COLUMN MODE
3210 .1     STA ULTRA.CHPG
3220 *--------------------------------
3230        LDX W16TBL,Y   GET WIDTH/16
3240        LDA ULTRA.START    CV*(WIDTH/16) + START
3250 .2     CLC               INCLUDE 'CLC' IN LOOP ON PURPOSE
3260        ADC CV               TO FORCE WRAP-AROUND
3270        DEX
3280        BNE .2
3290 *--------------------------------
3300        PHA
3310        LSR          *16
3320        LSR
3330        LSR
3340        LSR
3350        TAX          SAVE PAGE VALUE IN X-REG
3360        PLA
3370        ASL
3380        ASL
3390        ASL
3400        ASL
3410 *--------------------------------
3420        CLC          + CH (or CH+15 if 132 columns)
3430        ADC ULTRA.CHPG
3440        STA ULTRA.CHPG
3450        BCC .3
3460        INX          ADD CARRY TO PAGE VALUE
3470 *--------------------------------
3480 .3     TXA          GET PAGE VALUE
3490        AND #$0F
3500        ORA MODETBL,Y
3510        STA ULTRA.REG+2     
3520 *--------------------------------
3530        ASL
3540        AND #$0C
3550        TAY
3560        LDA ULTRA.REG,Y
3570        TXA          GET PAGE VALUE AGAIN
3580        LSR          SET CARRY IF IN 2ND PAGE
3590 *--------------------------------
3600        LDY ULTRA.CHPG
3610        LDA $CC00,Y
3620        BCC .4
3630        LDA $CD00,Y
3640 .4     ORA #$80     MAKE HIGH ASCII
3650        LDY ULTRA.TEMPY   RESTORE REGS 
3660        LDX ULTRA.TEMPX
3670        RTS           ALL DONE
3680 *--------------------------------
3690 MODETBL .HS 40     80X24    (VIDEOTERM EMULATION)
3700         .HS 50     96X24
3710         .HS 70    160X24
3720         .HS 50     80X24 INTERLACE
3730         .HS 50     80X32 INTERLACE
3740         .HS 50     80X48 INTERLACE
3750         .HS 70    132X24 INTERLACE
3760         .HS 70    128X32 INTERLACE
3770 *--------------------------------
