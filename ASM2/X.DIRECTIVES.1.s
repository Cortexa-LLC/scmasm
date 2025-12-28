
1000 *SAVE X.DIRECTIVES.1
1010 *---------------------------------
1020 *      DIRECTIVES
1030 *--------------------------------
1040 *      .DUMMY -- START DUMMY SECTION
1050 *--------------------------------
1060 D.DUMMY
1070        LDA DUMMY.FLAG    DO NOTHING IF ALREADY IN DUMMY
1080        BMI .2
1090        LDX #3
1100 .1     LDA ORGN,X
1110        STA DUMMY.ORGN,X
1120        DEX
1130        BPL .1
1140        STX DUMMY.FLAG    SET FLAG NEGATIVE
1150 .2     RTS
1160 *--------------------------------
1170 *      .ED -- END DUMMY SECTION
1180 *--------------------------------
1190 D.END.DUMMY
1200        LDA DUMMY.FLAG
1210        BPL .2       DO NOTHING IF NOT IN .DUMMY
1220        LDX #3
1230        STX DUMMY.FLAG    SET FLAG POSITIVE
1240 .1     LDA DUMMY.ORGN,X
1250        STA ORGN,X
1260        DEX
1270        BPL .1
1280 .2     RTS         RETURN TO MAIN LEVEL OF ASM
1290 *---------------------------------
1300 *      .PH -- START PHASE
1310 *--------------------------------
1320 D.PHASE
1330        JSR D.END.PHASE
1340        JSR EXPR.DEFINED  GET PHASE ORIGIN
1350        LDX #3
1360 .1     LDA ORGN,X   SAVE ORIGIN
1370        STA ORIGIN.SAVE,X
1380        LDA EXP.VALUE,X
1390        STA ORGN,X   SET PHASE ORIGIN
1400        DEX
1410        BPL .1
1420        SEC          SET FLAG TO $80
1430        ROR PHASE.FLAG
1440        RTS         RETURN TO MAIN LEVEL OF ASM
1450 *--------------------------------
1460 *      .EP -- END PHASE
1470 *--------------------------------
1480 D.END.PHASE
1490        ASL PHASE.FLAG    TEST AND CLEAR FLAG
1500        BCC .2            IT WAS ALREADY CLEAR
1510        LDX #3
1520 .1     LDA ORIGIN.SAVE,X
1530        STA ORGN,X
1540        DEX
1550        BPL .1
1560 .2     RTS
1570 *---------------------------------
1580 *   .OR -- SET ORIGIN
1590 *---------------------------------
1600 PSOR   JSR EXPR.DEFINED  GET ORIGIN VALUE
1610        LDX #3
1620 .1     LDA EXP.VALUE,X   STORE IT IN
1630        STA ORGN,X        LOCATION
1640        DEX               COUNTER
1650        BPL .1
1660        LDA DUMMY.FLAG    IF IN DUMMY SECTION, DON'T
1670        BMI RTS.1         ...IN DUMMY
1680 NEW.TARGET
1690        JSR TFEND         END .TF IF DOING ONE
1700        LDA EXP.VALUE     STORE VALUE IN
1710        STA TRGT          TARGET ADDRESS
1720        LDA EXP.VALUE+1
1730        STA TRGT+1
1740 RTS.1  RTS
1750 *---------------------------------
1760 *    .TA -- SET TARGET ADDRESS
1770 *---------------------------------
1780 PSTA   JSR EXPR.DEFINED  GET EXPR VALUE
1790        LDA EXP.VALUE+2
1800        ORA EXP.VALUE+3
1810        BEQ NEW.TARGET
1820        JMP RAER
1830 *--------------------------------
1840 *   .AT -- ASCII STRING WITH LAST BYTE FLAGGED
1850 *   .AS -- ASCII STRING WITH ALL BYTES SAME
1860 *   .AZ -- Same as .AS, but with 00 terminator byte.
1870 *--------------------------------
1880 PSAZ   JSR PSAS
1890        JMP EMIT.ZERO
1900 PSAT   LDA #$80     LAST BYTE HAS OPPOSITE BIT 7
1910        .HS 2C       ...SKIP OVER 2 BYTES
1920 PSAS   LDA #0       ALL BYTES GET SAME BIT 7
1930        STA AT.HIBIT
1940        JSR GNNB     Scan to next non-blank
1950        BCS ERBA2     END OF LINE
1960        DEC CHAR.PNTR     BACK UP
1970 .1     JSR TRY.HEX.STRING
1980        BEQ .5       ...END OF LINE
1990        LDY #0
2000        STY AS.HIBIT ...assume hibit is 0
2010        CMP #'-'      1ST NON-BLANK A MINUS?
2020        BNE .15      ...no, hibit is 0
2030        ROR AS.HIBIT ...yes, hibit is 1
2040        JSR GNC.UC
2050 .15    STA DLIM     SAVE DELIMITER
2060        JSR GNC.UC   GET NEXT CHAR
2070        BCS ERBA2    END OF LINE IS BAD NEWS
2080        CMP DLIM     CHK IF DELIMITER
2090        BEQ .4       YES, NO STRING IN BETWEEN
2100 .2     JSR GNC.UC   GET NEXT CHAR
2110        BCS ERBA2    END OF LINE IS BAD NEWS
2120        CMP DLIM     CHK IF DELIMITER
2130        BEQ .3       YES, FINISH UP AND RETURN
2140        LDA WBUF-2,Y ...NO, GET PREVIOUS CHAR
2150        ORA AS.HIBIT MERGE WITH TOP BIT
2160        JSR EMIT
2170        JMP .2       GO FOR ANOTHER ONE
2180 .3     LDA WBUF-2,Y GET PREVIOUS CHAR
2190        ORA AS.HIBIT MERGE WITH SELECTED BIT 7
2200        EOR AT.HIBIT TOGGLE BIT 7 IF IN .AT
2210        JSR EMIT     EMIT THE BYTE
2220 .4     JSR GNC      CHECK IF MORE IN LIST
2230        BEQ .5
2240        CMP #','
2250        BEQ .1
2260 .5     RTS
2270 *---------------------------------
2280 *   .HS -- HEX STRING
2290 *---------------------------------
2300 PSHS   JSR GNNB     GET NEXT NON-BLANK CHAR
2310        BCS ERBA2    END OF LINE
2320        JSR BACKUP.CHAR.PNTR
2330        JSR TRY.HEX.STRING
2340        BNE ERBA2    ...ERROR, BAD ADDRESS
2350        RTS
2360 *--------------------------------
2370 THX1   JSR HEX.DIGIT  GET NEXT HEX DIGIT
2380        BCC ERBA2    ERROR, ODD DIGITS
2390        LDA SYM.VALUE    GET CONVERTED VALUE
2400        JSR EMIT
2410 TRY.HEX.STRING
2420 .1     JSR HEX.DIGIT
2430        BCS THX1
2440        LDA CURRENT.CHAR
2450        BEQ .2       ...END OF LINE
2460        CMP #','     IF COMMA, GO GET MORE BYTES
2470        BEQ .1       ...OKAY
2480        CMP #' '     IF BLANK, VALID END OF STRING
2490 .2     RTS
2500 *--------------------------------
2510 ERBA2  JMP ERBA     ERROR: BAD ADDRESS
2520 GT255ERR LDY #QER8  VALUE > 255 ERROR
2530        .HS 2C       LONG "BIT" TO SKIP NEXT TWO BYTES
2540 NOLBLERR LDY #QER1  "NO LABEL"
2550        .HS 2C       LONG "BIT" TO SKIP NEXT TWO BYTES
2560 UNDF   LDY #QER6     "UNDEF"
2570        JMP SOFT.ERROR
2580 *---------------------------------
2590 *   .EQ -- EQUATE
2600 *---------------------------------
2610 PSEQ   LDY WBUF     SEE IF ANY LABEL
2620        CPY #$20
2630        BEQ NOLBLERR   NO LABEL ON LINE
2640        LDA STPNTR   SAVE STPNTR WHILE CALLING EXPR
2650        PHA
2660        LDA STPNTR+1
2670        PHA
2680        JSR EXPR.DEFINED  GET VALUE
2690        PLA          RESTORE STPNTR
2700        STA STPNTR+1
2710        PLA
2720        STA STPNTR
2730        LDA PASS       WHICH PASS
2740        BNE .5         PASS 2, PRINT VALUE
2750 *---PASS 1:  DEFINE VALUE--------
2760        LDY WBUF     COLUMN 1 AGAIN
2770        CPY #':      PRIVATE LABEL?
2780        BCC .4       ...LOCAL LABEL
2790        BEQ .2       ...PRIVATE LABEL
2800 *---NORMAL LABEL-----------------
2810        LDY #2
2820 .1     LDA EXP.VALUE-2,Y   REDEFINE SYMBOL
2830        >SYM STA,PNTR
2840        INY
2850        CPY #6
2860        BCC .1
2870        RTS
2880 *---PRIVATE LABEL----------------
2890 .2     LDY #0
2900 .3     LDA EXP.VALUE,Y
2910        >SYM STA,STPNTR
2920        INY
2930        CPY #4
2940        BCC .3
2950        RTS
2960 *---LOCAL LABEL------------------
2970 .4     LDY #2       COMPUTE LOCAL OFFSET
2980        SEC
2990        LDA EXP.VALUE
3000        >SYM SBC,STPNTR
3010        DEY
3020        >SYM STA,PNTR
3030        LDY #3
3040        LDA EXP.VALUE+1
3050        >SYM SBC,STPNTR
3060        BNE GT255ERR    VALUE > 255
3070        RTS         RETURN TO MAIN LEVEL OF ASM
3080 *---PASS 2:  PRINT VALUE---------
3090 .5     JMP P.EXP.VALUE.DASH
3100 *---------------------------------
3110 *   .DA -- DATA VALUE (8- OR 16-BITS)
3120 *---------------------------------
3130 PSDA   LDA #0       UNDEF FLAG FOR LINE
3140        PHA
3150 .1     JSR GNNB     GET NEXT NON-BLANK CHAR
3160        BCS ERBA2    END OF LINE
3170        STA DLIM
3180 *---Could be $$dstringd----------
3190        CMP #'$'     $$dstringd value?
3200        BNE .2       ...NO
3210        LDA WBUF,Y   Look for second $
3220        CMP #'$'
3230        BNE .25      ...NO, MUST BE SIMPLE HEX WORD
3240        JSR GNC      SKIP OVER SECOND '$'
3250        JSR PSAS     GET dstringd
3260        JMP .5
3270 *---Look for size char-----------
3280 .2     LDY #1       ASSUME 1-BYTE DATA
3290        CMP #'#'
3300        BEQ .3
3310        CMP #'/'
3320        BEQ .3
3330        LDY #3       ASSUME 3-BYTE DATA
3340        CMP #'<'     24-BIT SIGNAL
3350        BEQ .3       ...3-BYTE DATA
3360        INY          ASSUME 4-BYTE DATA
3370        CMP #'>'     32-BIT SIGNAL
3380        BEQ .3
3390 *---Size is two bytes------------
3400 .25    JSR BACKUP.CHAR.PNTR
3410        LDY #2       2-BYTE DATA
3420 *---Get expression, emit value---
3430 .3     STY ADDR.LENGTH
3440        JSR EXPR     CRACK EXPRESSION
3450        LDY DLIM     If preceded by /, shift over
3460        CPY #'/'
3470        BNE .4       ...NOT /
3480        JSR EXP.OVER.256
3490 .4     JSR EMIT.VALUE  ACCORDING TO ADDR.LENGTH
3500 *---Update UNDEF flag------------
3510        PLA          .DA'S UNDEF FLAG
3520        ORA EXP.UNDEF
3530        PHA
3540 *---Next item in list------------
3550 .5     JSR GNC.UC   LOOK FOR ANOTHER ITEM
3560        CMP #',      COMMA?
3570        BEQ .1       YES, GET ANOTHER ONE
3580        PLA          GET .DA'S UNDEF FLAG
3590        STA EXP.UNDEF     MERGED VALUE
3600        RTS          LIST LINE OR REPORT UNDEF ERROR
3610 *--------------------------------
3620 *      DO/ELSE/FIN
3630 *--------------------------------
3640 PSDO   JSR EXPR.DEFINED    GET VALUE
3650        LDX DO.INDEX        0 IF EMPTY, ELSE 1-63
3660        INX
3670        CPX #64
3680        BCC .2
3690        LDY #QERDO2  ".DO NEST TOO DEEP"
3700        JMP SOFT.ERROR
3710 .2     LDA EXP.VALUE
3720        ORA EXP.VALUE+1  TEST FOR ZERO
3730        ORA EXP.VALUE+2
3740        ORA EXP.VALUE+3
3750        BEQ .3       ZERO, FALSE
3760        SEC          NONZERO, TRUE
3770 .3     STX DO.INDEX
3780        LDX #-8
3790 .4     ROR DO.STACK+8,X
3800        INX
3810        BNE .4
3820        RTS          LIST THE LINE
3830 *--------------------------------
3840 PSEL   LDX DO.INDEX
3850        BEQ ERR.DO   ERROR, NOT BTWN .DO AND .FIN
3860        LDA DO.STACK
3870        EOR #$80     TOGGLE CURRENT LOGIC LEVEL
3880        STA DO.STACK
3890        RTS         RETURN TO MAIN LEVEL OF ASM
3900 *--------------------------------
3910 ERR.DO LDY #QERDO   "MISSING .DO"
3920        JMP SOFT.ERROR
3930 *--------------------------------
3940 PSFI   LDX DO.INDEX
3950        BEQ ERR.DO   ERROR, NOT AFTER .DO
3960        DEC DO.INDEX POP THIS DO
3970        LDX #7
3980 .1     ROL DO.STACK,X
3990        DEX
4000        BPL .1
4010        RTS         RETURN TO MAIN LEVEL OF ASM
4020 *--------------------------------
