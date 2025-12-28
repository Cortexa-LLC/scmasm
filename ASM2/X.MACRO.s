
1000 *SAVE X.MACRO
1010 *--------------------------------
1020 *      .MA DIRECTIVE
1030 *--------------------------------
1040 PSMA   LDA PASS     WHICH PASS?
1050        BNE .2       PASS 2, SO SET FLAG AND IGNORE
1060        LDA #'Z+1    RIGHT BRACKET CODE
1070        STA SYMBOL+7
1080        LDA #0       CLEAR VALUE BYTES
1090        LDX #3
1100 .1     STA SYMBOL+2,X
1110        DEX
1120        BPL .1
1130        JSR GNNB     GET FIRST CHAR OF MACRO NAME
1140        LDX #1
1150        JSR PACK.NAME
1160        CPX #2       NEED AT LEAST TWO CHARS, COUNTING BRACKET
1170        BCC .3       NO MACRO NAME
1180        STX SYMBOL+6 LENGTH
1190        JSR STSRCH
1200        BCC .4       DOUBLE DEFN
1210        JSR STADD    ENTER INTO SYMBOL TABLE
1220 .2     SEC          SET "INSIDE MACRO DEFINITION" FLAG
1230        ROR FLAG.MA
1240        RTS          RETURN TO MAIN LEVEL OF ASM
1250 .3     LDY #QNONAM  NO MACRO NAME
1260        .HS 2C       SKIP NEXT TWO BYTES
1270 .4     LDY #QER4    EXTRA DEF'N
1280        JMP FIRM.ERROR
1290 *--------------------------------
1300 *      PACK MACRO LINE
1310 *--------------------------------
1320 PACK.MACRO.LINE
1330        JSR SCAN.TO.OPCODE
1340        LDX FLAG.MA  IN A MACRO DEF'N?
1350        BPL D.SET    ...NO, TRY .SE DIRECTIVE
1360        LDX PASS     WHICH PASS?
1370        BNE .10      PASS 2
1380 *---PASS 1-----------------------
1390        BCS .4       ...OPCODE IS NOT A DIRECTIVE
1400        LDX #DIR.QT.MA
1410        JSR DIR.SCAN.OR.FAIL
1420        BCC .2       NOT .MA
1430 .1     LDY #QER2    "BAD OPCODE"
1440        JMP SOFT.ERROR
1450 .2     JSR DIR.SCAN.OR.FAIL
1460        BCC .3       NOT .EM
1470        LDA #0       TERMINATE THE SKELETON
1480        STA CURRENT.MAJOR.LABEL+1  KILL POSSIBILITY OF LOCAL LABELS
1490 *                               UNTIL ANOTHER MAJOR LABEL
1500        JSR ADD.CHAR.TO.SKELETON
1510 .11    LSR FLAG.MA
1520 .12    SEC
1530        RTS
1540 *--------------------------------
1550 .3     JSR DIR.SCAN.OR.FAIL  SEE IF .IN
1560        BCS .1       YES, SO ILLEGAL!
1570 *      FALL INTO ACCEPTABLE LINE CODE
1580 *--------------------------------
1590 .4     LDY #0       BACK TO BEGINNING OF LINE
1600        BEQ .5       ...ALWAYS
1610 .55    LDX #$80     COMPRESSED BLANK TOKEN
1620 .6     INX          COUNT THE BLANK
1630        CPX #$BF     MAX BLANK COUNT?
1640        BCS .7       YES, OUTPUT TOKEN NOW
1650        JSR GNC2     GET NEXT CHARACTER
1660        BCS .7       END OF LINE
1670        BEQ .6       BLANK, SO COMPRESS IT
1680        DEY          NON-BLANK, SO BACK UP PNTR
1690 .7     TXA          COMPRESSED BLANK TOKEN
1700 .8     JSR ADD.CHAR.TO.SKELETON
1710 .5     JSR GNC2     GET NEXT CHARACTER
1720        BCS .9       END OF LINE
1730        BEQ .55      ...it is a blank
1740        CMP #']'     MACRO PARAMETER?
1750        BNE .8       ...NO
1760        TAX          save ']' in X
1770        JSR GNC2     GET PARAMETER CODE
1780        BCS .7       ...eol, add ']' and end
1790        CMP #']'
1800        BEQ .8       ...two makes one
1810        CMP #'#'
1820        BEQ .81      ...]# is valid parameter
1830        CMP #'9'+1   HOW ABOUT 1...9
1840        BCS .82      ...not a parameter
1850        CMP #'1'
1860        BCC .82      ...not a parameter
1870 .81    LDX #$7F     valid parameter
1880 .82    DEY          back up char pntr
1890        JMP .7       go add $7F or ']'
1900 *--------------------------------
1910 .9     LDA #0       TERMINATE THE LINE
1920        JSR ADD.CHAR.TO.SKELETON
1930        SEC
1940        RTS
1950 *---PASS 2-----------------------
1960 *      IF NOT ".EM", JUST LIST THE LINE
1970 .10    BCS .12      ...OPCODE IS NOT A DIRECTIVE
1980        LDX #DIR.QT.EM
1990        JSR DIR.SCAN.OR.FAIL
2000        BCC .12      NOT .EM
2010        BCS .11      ...ALWAYS
2020 *--------------------------------
2030 *      .SET DIRECTIVE
2040 *--------------------------------
2050 D.SET
2060        BCS .1            NOT A DIRECTIVE
2070        LDX #DIR.QT.SE
2080        JSR DIR.SCAN.OR.FAIL
2090        BCS .2            FOUND .SE
2100 .1     CLC
2110        RTS
2120 .2     JSR EXPR.DEFINED  GET VALUE
2130        JSR GNC.UC.START  CHECK FOR VALID LABEL
2140        BEQ .6            ...NO LABEL ERROR
2150        JSR CHECK.LETTER  MUST BE NORMAL LABEL
2160        BCC .7            ...DOES NOT START WITH A-Z
2170        JSR PACK
2180        BCC .7            ...BAD SYMBOL
2190        JSR STSRCH
2200        BCC .3            ...IN TABLE ALREADY
2210        LDA SYMBOL+7
2220        ORA #$80
2230        STA SYMBOL+7 SET THE .SE FLAG
2240        JSR STADD
2250        JMP .4
2260 .3     LDY #7       CK .SE FLAG
2270        >SYM LDA,TPTR
2280        BPL .9       DOUBLE DEF IF NOT SET!
2290        LDA TPTR     USE SAME PTR AS STADD
2300        STA PNTR
2310        LDA TPTR+1
2320        STA PNTR+1
2330        LDA PASS     HANDLE FORWARD REFERENCES
2340        BEQ .5       ...IN PASS ONE
2350        DEY          POINT AT FLAGS
2360        >SYM LDA,PNTR
2370        ORA #$40
2380        >SYM STA,PNTR
2390 .4     JSR P.EXP.VALUE.DASH     (IF LISTING)
2400 .5     LDY #2       PUT VALUE IN SYMBOL TABLE
2410 .8     LDA EXP.VALUE-2,Y
2420        >SYM STA,PNTR
2430        INY
2440        CPY #6
2450        BCC .8
2460        RTS          RETURN TO ASM WITH .CS.
2470 .6     JMP NOLBLERR
2480 .7     JMP ERR.BS
2490 .9     JMP ERR.DBLDF
2500 *--------------------------------
2510 *      ADD CHARACTER TO SKELETON
2520 *--------------------------------
2530 ADD.CHAR.TO.SKELETON
2540        PHA          SAVE CHAR
2550   .DO AUXMEM
2560        LDA EOT+1
2570        CMP /$C000
2580        BCC .1
2590        JMP MFER     MEM FULL ERROR
2600 .1     STA WRAUX
2610        LDX #0
2620        PLA
2630        STA (EOT,X)
2640        STA WRMAIN
2650   .ELSE
2660        LDA EOT
2670        CMP PP
2680        LDA EOT+1
2690        SBC PP+1
2700        BCC .1       ROOM
2710        JMP MFER     MEM FULL ERROR
2720 .1     LDX #0
2730        PLA
2740        STA (EOT,X)
2750   .FIN
2760       >INCD EOT
2770        RTS
2780 *--------------------------------
2790 *      SCAN TO OPCODE
2800 *--------------------------------
2810 SCAN.TO.OPCODE
2820        JSR GNC.START  GET FIRST CHAR
2830        BEQ .2       ...BLANK OR END
2840        JSR CHECK.COMMENT.CHAR
2850        BEQ .3       ...YES, IT IS A COMMENT
2860 .1     JSR GNC      SCAN TO A BLANK
2870        BNE .1       ...NOT BLANK YET
2880 .2     JSR GNNB     SCAN TO NON-BLANK
2890        BCS .3       ...END OF LINE
2900        CMP #'.'     DIRECTIVE?
2910        BNE .3       ...NO
2920        JSR GNC.UC      GET NEXT BYTE
2930        CLC          SIGNAL IT IS A DIRECTIVE
2940        RTS
2950 .3     SEC          SIGNAL IT IS NOT A DIRECTIVE
2960        RTS
2970 *--------------------------------
2980 *      PROCESS MACRO CALL
2990 *--------------------------------
3000 MACER1 LDY #QNONAM
3010        .HS 2C
3020 MACER2 LDY #QERR.MACRO
3030        JMP SOFT.ERROR
3040 *--------------------------------
3050 MACRO.CALL
3060        LDA #'Z+1    MACRO KEY IN SYMBOL TABLE
3070        STA SYMBOL+7
3080        LDX #1
3090        JSR GNC.UC      GET FIRST CHAR OF MACRO NAME
3100        JSR PACK.NAME
3110        CPX #2
3120        BCC MACER1   ERROR, NO NAME
3130        STX SYMBOL+6 LENGTH OF NAME
3140        JSR STSRCH
3150        BCS MACER2   ERROR, NO SUCH MACRO
3160        JSR P.ORIGIN
3170        JSR LIST.SOURCE.IF.LISTING
3180        JSR GNNB     SCAN TO PARAMETER LIST
3190        JSR BACKUP.CHAR.PNTR
3200        LDA MACSTK+1 SAVE PNTR FOR LATER
3210        PHA
3220        LDA MACSTK
3230        PHA
3240        LDX #0       PROCESS PARAMETER LIST
3250        LDA #9       FIND 9 PARAMETERS
3260        STA PARAM.CNT
3270 .1     JSR GET.ONE.PARAMETER
3280        DEC PARAM.CNT
3290        BNE .1
3300 .2     LDA WBUF-1,X
3310        JSR PUSH.MACSTK
3320        DEX
3330        BNE .2
3340        PLA          PUT OLD MACSTK PNTR ON MACRO STACK
3350        JSR PUSH.MACSTK   (LOW BYTE)
3360        PLA
3370        JSR PUSH.MACSTK   (HIGH BYTE)
3380        LDA SRCP
3390        JSR PUSH.MACSTK
3400        LDA SRCP+1
3410        JSR PUSH.MACSTK
3420        LDA LF.ALL   save current list option
3430        JSR PUSH.MACSTK
3440        LDA CALL.NUM  STACK CURRENT CALL #
3450        JSR PUSH.MACSTK
3460        LDA CALL.NUM+1
3470        JSR PUSH.MACSTK
3480        CLC          COMPUTE ADDRESS OF SKELETON
3490        LDA #7
3500        LDY #6       POINT AT LENGTH OF MACRO NAME
3510        >SYM ADC,STPNTR    NAME LENGTH+7
3520        ADC STPNTR
3530        STA SRCP
3540        LDA STPNTR+1
3550        ADC #0
3560        STA SRCP+1
3570        LDA LF.MACRO
3580        ORA LF.ALL        DON'T LIST EXPANSION IF NOT LISTING
3590        STA LF.ALL
3600        INC MACRO.LEVEL
3610       >INCD CALL.CNTR     COUNT THIS MACRO CALL
3620        LDA CALL.CNTR
3630        STA CALL.NUM
3640        LDA CALL.CNTR+1
3650        STA CALL.NUM+1
3660        JMP ASM2
3670 *--------------------------------
3680 *      PUSH A BYTE ON MACSTK
3690 *--------------------------------
3700 PUSH.MACSTK
3710        PHA          SAVE BYTE TO BE PUSHED
3720   .DO AUXMEM
3730        LDA MACSTK+1
3740        CMP /$0800
3750        BCS .1
3760   .ELSE
3770        LDA EOT
3780        CMP MACSTK
3790        LDA EOT+1
3800        SBC MACSTK+1
3810        BCC .1       STILL ROOM
3820   .FIN
3830        JMP MFER     NO ROOM
3840 .1     LDA MACSTK
3850        BNE .2
3860        DEC MACSTK+1
3870 .2     DEC MACSTK
3880        PLA          BYTE TO BE PUSHED
3890        LDY #0
3900        STA (MACSTK),Y
3910        RTS
3920 *--------------------------------
3930 *      GET ONE PARAMETER FROM MACRO CALL LINE
3940 *--------------------------------
3950 GET.ONE.PARAMETER
3960        JSR GNC
3970        BEQ .2       SPACE OR EOL, NO MORE PARAMETERS
3980        CMP #',      COMMA
3990        BEQ .3       NULL PARAMETER
4000        CMP #'"      QUOTE
4010        BEQ .4       QUOTED PARAMETER
4020 .1     STA WBUF,X   NORMAL PARAMETER
4030        INX
4040        JSR GNC
4050        BEQ .2       END OF PARAMETER
4060        CMP #',      COMMA
4070        BNE .1       MORE TO PARAMETER
4080        BEQ .3       END OF PARAMETER
4090 .2     JSR BACKUP.CHAR.PNTR
4100 .3     LDA #0
4110        STA WBUF,X
4120        INX
4130        RTS
4140 .4     JSR GNC         QUOTED PARAMETER
4150        BCS .3       END OF LINE
4160        CMP #'"
4170        BEQ .5       END OF QUOTED PARAMETER
4180 .6     STA WBUF,X
4190        INX
4200        BNE .4       ...ALWAYS
4210 .5     JSR GNC
4220        BEQ .2       END OF PARAMETER LIST
4230        CMP #',      COMMA
4240        BEQ .3
4250        BNE .6       ...ALWAYS
4260 *--------------------------------
4270 *      DIRECTIVE SCAN OR FAIL
4280 *      COMPARE NEXT TWO CHARS WITH TABLE ENTRY
4290 *      ENTER:  FIRST CHAR SET UP BY GNC.UC
4300 *              (X)=OFFSET OF TWO-BYTE ENTRY IN DIR.QTS
4310 *--------------------------------
4320 DIR.SCAN.OR.FAIL
4330        CMP DIR.QTS,X
4340        BNE .1       FAIL
4350        LDY CHAR.PNTR
4360        LDA WBUF,Y   NEXT CHAR
4370        AND #$DF     MAP LOWER CASE TO UPPER CASE
4380        CMP DIR.QTS+1,X
4390        BNE .1       FAIL
4400        JSR GNC.UC      SCAN OVER SECOND CHAR
4410        SEC          SIGNAL SUCCESS
4420        RTS
4430 .1     CLC          SIGNAL FAILURE
4440        LDA CURRENT.CHAR  RESTORE (A)
4450        INX               ADVANCE TO NEXT QUOTE
4460        INX
4470        RTS
4480 *--------------------------------
4490 DIR.QTS
4500 DIR.QT.DO .EQ *-DIR.QTS
4510        .AS /DO/
4520 DIR.QT.EL .EQ *-DIR.QTS
4530        .AS /EL/
4540 DIR.QT.FI .EQ *-DIR.QTS
4550        .AS /FI/
4560 DIR.QT.MA .EQ *-DIR.QTS
4570        .AS /MA/
4580 DIR.QT.EM .EQ *-DIR.QTS
4590        .AS /EM/
4600 DIR.QT.IN .EQ *-DIR.QTS
4610        .AS /IN/
4620 DIR.QT.SE .EQ *-DIR.QTS
4630        .AS /SE/
4640 *--------------------------------
