
1000 *SAVE X.DIRECTIVES.2
1010 *--------------------------------
1020 *    .IN -- INCLUDE A SOURCE FILE
1030 *--------------------------------
1040 PSIN   LDA INFLAG   SEE IF NESTED .IN
1050        BNE .4       ...YES, ERROR
1060        SEC
1070        ROR INFLAG   TURN ON FLAG (=$80)
1080        LDA #'I      PUT "I" IN PROMPT MESSAGE
1090        STA PROMPT.FLAG
1100        JSR LIST.LINE.BOTH.PASSES
1110 *---SAVE CURRENT, SET UP NEW-----
1120        LDX #1
1130 .1     LDA HI.MEM,X       SAVE CURRENT SOURCE POINTERS
1140        STA INSAVE,X
1150        LDA SRCP,X
1160        STA INSAVE+2,X
1170        LDA PP,X
1180        STA HI.MEM,X
1190   .DO AUXMEM
1200   .ELSE
1210        LDA LO.MEM,X  MAKE DOS PROTECT THE SYMBOL TABLE
1220        STA INSAVE+6,X    DURING THE LOAD
1230        LDA EOT,X
1240        STA LO.MEM,X
1250   .FIN
1260        DEX
1270        BPL .1
1280 *---CHECK FOR .INBx--------------
1290        JSR GNC.UC
1300        CMP #'B'
1310        BNE .2            ...NOT .INBx
1320        JSR GNC.UC        GET # OF BLOCKS
1330        EOR #'0'
1340        BEQ .12           ...NOT 1-9, USE 1
1350        CMP #10
1360        BCC .14           ...1-9
1370 .12    LDA #1            USE 1 BLOCK
1380 .14    ORA #$C0
1390        STA INFLAG
1400 *---LOAD THE FILE----------------
1410 .2     JSR SAVE.PATHNAME
1420        LDY #PQ.LOD  LOAD COMMAND
1430        JSR ISSUE.DOS.COMMAND
1440 *---ASSEMBLE INCLUDED STUFF------
1450        LDX #1
1460 .3     LDA PP,X          MOVE SRCP TO BEGINNING OF INCLUDED FILE
1470        STA SRCP,X
1480        STA MACSTK,X
1490   .DO AUXMEM
1500   .ELSE
1510        LDA INSAVE+6,X    RESTORE LO.MEM
1520        STA LO.MEM,X
1530   .FIN
1540        LDA SCI.IOB.RW+6,X     # BYTES ACTUALLY RECEIVED
1550        STA INSAVE+4,X
1560        DEX
1570        BPL .3
1580        LDA SCI.IOB.RW+1       REFNUM OF INB FILE
1590        STA INSAVE+6
1600        JMP ASM2      CONTINUE ASSEMBLY
1610 *---NO NESTING ALLOWED-----------
1620 .4     LDY #QNIN     "NEST .IN"
1630        JMP FIRM.ERROR
1640 *--------------------------------
1650 *    .EN -- END OF SOURCE PROGRAM
1660 *--------------------------------
1670 PSEN   JSR LIST.SOURCE.IF.LISTING
1680 ENDM
1690        BIT INFLAG    IN A ".IN"?
1700        BPL .1         NO
1710        BVC .3       ...NOT IN .INBx
1720        LDA INSAVE+6 .INBx REFNUM
1730        STA SCI.IOB.CLOSE+1
1740        LDA #$CC     Close the .INclude file
1750        JSR SCI.MLI
1760 .3     JSR RESTORE  YES, BACK TO ROOT
1770        JMP ASM2     CONTINUE ASSEMBLY
1780 *---END OF ROOT FILE-------------
1790 .1     JSR TFEND    END .TF IF DOING ONE
1800        LDA PASS     WHICH PASS?
1810        BNE .2       ...END OF PASS 2
1820        INC PASS     END OF PASS 1
1830        JMP ASM1
1840 .2     BIT LF.ALL   Are we listing?
1850        BMI ASM.END  ...no, we are finished
1860        JSR CRLF.WITH.PAGING
1870        JSR CRLF.WITH.PAGING
1880        JSR CRLF.WITH.PAGING
1890        LDY #QST     "SYMBOL TABLE"
1900        JSR QT.OUT
1910        JSR CRLF.WITH.PAGING
1920        JSR CRLF.WITH.PAGING
1930        JSR STPRNT   PRINT THE SYMBOLS
1940 *--------------------------------
1950 ASM.END
1960        JSR CRLF.WITH.PAGING
1970        LDA ERROR.COUNT
1980        STA CURRENT.LINE.NUMBER
1990        LDA ERROR.COUNT+1
2000        STA CURRENT.LINE.NUMBER+1
2010        JSR CONVERT.LINE.NUMBER.PRINT
2020        LDY #QERRCNT
2030        JSR QT.OUT
2040        JMP SOFT      END OF ASSEMBLY
2050 *--------------------------------
2060 *    RESTORE IF INSIDE AN INCLUDE
2070 *--------------------------------
2080 RESTORE
2090        LDA INFLAG
2100        BEQ .1       RETURN
2110        LDX #0       CLEAR PROMPT.FLAG
2120        STX PROMPT.FLAG
2130        STX INFLAG   CLEAR INFLAG
2140        INX          X=1
2150 .2     LDA HI.MEM,X
2160        STA PP,X
2170        STA MACSTK,X
2180        LDA INSAVE,X
2190        STA HI.MEM,X
2200        LDA INSAVE+2,X
2210        STA SRCP,X
2220        DEX
2230        BPL .2
2240 .1     RTS
2250 *--------------------------------
2260 *      SET UP TITLE LINE
2270 *--------------------------------
2280 PSTI   LDA PASS
2290        BEQ PGXIT    DO NOTHING IN PASS ONE
2300        JSR EXPR.DEFINED    GET PAGE LENGTH
2310        LDA EXP.VALUE  USE MOD 256
2320        STA PAGE.LENGTH    NON-ZERO PAGE LENGTH MEANS TITLING IS ON
2330        LDX #0       POINT AT TITLE BUFFER
2340        JSR GNC
2350        CMP #',
2360        BNE .2       NO TITLE
2370 .1     JSR GNC
2380        BCS .2       END OF TITLE
2390        STA KBUF,X
2400        INX
2410        CPX #70      MAX TITLE SIZE
2420        BCC .1
2430 .2     LDA #0       TERMINATE TITLE
2440        STA KBUF,X
2450 *---FALL INTO PSPG CODE----------
2460 *--------------------------------
2470 *    PAGE EJECT
2480 *--------------------------------
2490 PSPG   JSR FORM.FEED
2500 PGXIT  JMP ASM2
2510 *--------------------------------
2520 FORM.FEED
2530        JSR CHECK.IF.LISTING
2540        LDA #$0C      FORM FEED CHAR
2550        JSR CHO
2560       >INCD PAGE.NUMBER
2570        LDA PAGE.LENGTH
2580        CMP #3       PAGE LENGTHS LESS THAN 3 CANNOT BE TITLED
2590        BCC .1          EXIT, NOT TITLING NOW
2600        LDX #0
2610        STX LINE.COUNT
2620 .3     LDA KBUF,X   PRINT TITLE
2630        BEQ .4       END OF TITLE
2640        JSR CHO
2650        INX
2660        BNE .3       ...ALWAYS
2670 .4     LDY #PAGEQT  " PAGE "
2680        JSR QT.OUT
2690        LDA CURRENT.LINE.NUMBER   SAVE LINE #
2700        PHA
2710        LDA CURRENT.LINE.NUMBER+1
2720        PHA
2730        LDA PAGE.NUMBER           PRINT PAGE #
2740        STA CURRENT.LINE.NUMBER
2750        LDA PAGE.NUMBER+1
2760        STA CURRENT.LINE.NUMBER+1
2770        JSR CONVERT.LINE.NUMBER.PRINT
2780        JSR CRLF.WITH.PAGING
2790        PLA                       RESTORE LINE #
2800        STA CURRENT.LINE.NUMBER+1
2810        PLA
2820        STA CURRENT.LINE.NUMBER
2830 .1     RTS          RETURN
2840 *--------------------------------
2850 *      .BS -- BLOCK STORAGE
2860 *--------------------------------
2870 PSBS   JSR EXPR.DEFINED  GET # OF BYTES
2880        LDA EXP.VALUE+3
2890        ORA EXP.VALUE+2
2900        BNE RAER          VALUE >32767
2910        LDA EXP.VALUE+1
2920        BMI RAER          VALUE >32767
2930        STA BS.COUNT+1
2940        LDA EXP.VALUE
2950        STA BS.COUNT          SAVE COUNT
2960        JSR P.ORIGIN      PRINT ADDRESS
2970        JSR GNC           GET NEXT CHAR
2980        CMP #',           COMMA?
2990        BNE .1            NO, NO VALUE PRESENT
3000        JSR EXPR          GET FILL VALUE
3010        BPL .2            BRANCH IF GOOD EXPRESSION
3020 .1     JSR ZERO.EXP.VALUE    USE ZERO FOR FILL VALUE
3030 .2     SEC
3040        ROR LF.ALL     TURN OFF LISTING
3050 .3     LDA BS.COUNT          GET COUNT
3060        BNE .4            STILL MORE BYTES
3070        DEC BS.COUNT+1
3080        BMI .5            ...ALL THRU
3090 .4     DEC BS.COUNT          COUNT DOWN
3100        LDA EXP.VALUE     GET FILL VALUE
3110        JSR EMIT          AND EMIT IT
3120        JMP .3
3130 
3140 .5     ASL LF.ALL     RESTORE LISTING
3150        RTS
3160 
3170 *--------------------------------
3180 RAER   LDY #QER3    ERROR -- OUT OF RANGE
3190        JMP SOFT.ERROR
3200 
3210 *--------------------------------
3220 *      LISTING CONTROL
3230 *      .LIST ON/OFF/MON/MOFF/CON/COFF,...
3240 *--------------------------------
3250 PSLI   LDY #LI.INDEX-2
3260        JSR SET.FLAGS
3270        JMP ASM2        DON'T LIST LINE
3280 *--------------------------------
3290 *      SWITCH FLAGS ON OR OFF
3300 *--------------------------------
3310 SET.FLAGS
3320        STY YSAVE
3330 .1     LDY YSAVE
3340 .2     INY          Find letter in table
3350        INY
3360        LDA FLAG.TABLE,Y
3370        BEQ .7       ...end of table, get next letter
3380        CMP CURRENT.CHAR
3390        BNE .2       ...try next entry in table
3400 *---Found letter in table--------
3410        LDX FLAG.TABLE+1,Y
3420 .3     EOR #'N      'N' means ON
3430        BEQ .5       ...set flag to $00
3440        EOR #'F^'N   'F' means OFF
3450        BEQ .4       ...set flag to $FF
3460        EOR #',^'F   comma here is an error
3470        BEQ .9       ...oops!
3480        JSR GNC.UC   get next char from user
3490        BNE .3       ...might be N, F, or comma
3500        RTS          ...blank or end of line
3510 *---Turn flag ON or OFF----------
3520 .4     LDA #$FF     signal OFF with $FF
3530 .5     STA 0,X      store $00 or $FF in flag
3540 *---Scan to a comma or eol-------
3550 .6     JSR GNC      GET NEXT CHAR
3560        BEQ .8       ...blank or end of line
3570        CMP #','
3580        BNE .6       ...not comma yet
3590 *---Get next char from user------
3600 .7     JSR GNC.UC
3610        BCC .1       ...not end of line yet
3620 .8     RTS          RETURN TO CALLER
3630 .9     JMP ERBA
3640 *--------------------------------
3650 FLAG.TABLE
3660 LI.INDEX  .EQ *-FLAG.TABLE
3670        .DA #'N',#LF.ALL
3680        .DA #'F',#LF.ALL
3690        .DA #'M',#LF.MACRO
3700        .DA #'C',#LF.CONDITIONAL
3710        .DA #'X',#LF.XTRA.BYTES
3720        .HS 00
3730 *--------------------------------
