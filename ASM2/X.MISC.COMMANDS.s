
1000 *SAVE X.MISC.COMMANDS
1010 *--------------------------------
1020 HELP
1030        LDA #CMD.TBL
1040        LDX /CMD.TBL
1050        LDY #2
1060        JSR HELP.1
1070        JSR CRLF
1080        LDA SCI.TBLADR
1090        LDX SCI.TBLADR+1
1100        LDY #4
1110 *--------------------------------
1120 HELP.1
1130        STA .92+1
1140        STX .92+2
1150        STY .91+1
1160        LDY #-1      POINT TO BEGINNING
1170        LDX #10
1180        LDA #$0D
1190 .1     JSR CHO
1200        BPL .2
1210        JSR MON.PRBL2
1220        TYA
1230        CLC
1240 .91    ADC #0
1250        TAY
1260        LDX #10
1270 .2     INY
1280        DEX
1290 .92    LDA $5555,Y
1300        BNE .1
1310 .3     RTS
1320 *--------------------------------
1330 HILO   JSR EXPR.DEFINED
1340        LDA EXP.VALUE+3   MUST BE 0000XX00
1350        ORA EXP.VALUE+2
1360        ORA EXP.VALUE
1370        BNE HL.RAER
1380        LDX EXP.VALUE+1
1390        RTS
1400 *--------------------------------
1410 HIMEM  JSR HILO
1420        DEX
1430        CPX SYMBOL.BASE
1440        BCC HL.RAER       ...BELOW OR SAME AS LOMEM
1450        CPX SCI.BUFFER.PAGES+2  Start of Exec Buffer
1460        BCS HL.RAER       ABOVE EXEC BUFFER
1470        INX
1480        STX SCI.HIMEM.PAGE
1490        JMP NEW
1500 *--------------------------------
1510 HL.RAER    JMP RAER
1520 *--------------------------------
1530 LOMEM  JSR HILO
1540        CPX #8
1550        BCC HL.RAER  ...BELOW $800
1560        CPX SCI.HIMEM.PAGE
1570        BCS HL.RAER  ...ABOVE OR SAME AS HIMEM
1580        STX SYMBOL.BASE
1590        JMP NEW
1600 *--------------------------------
1610 *      SET INCREMENT VALUE FOR AUTO-LINE-NUMBERING
1620 *--------------------------------
1630 INCREMENT
1640        JSR SCAN.1.DECIMAL.NUMBER
1650        DEX          be sure there was a value
1660        BMI SYNX1    ...no, not one
1670 .1     LDA A0L,X    GET VALUE
1680        STA INCREMENT.VALUE,X
1690        DEX
1700        BPL .1
1710        RTS
1720 SYNX1  JMP SYNX
1730 *--------------------------------
1740 *      AUTO & MANUAL COMMANDS
1750 *--------------------------------
1760 AUTO   JSR SCAN.1.DECIMAL.NUMBER     GET BASE, IF ANY
1770        JSR SCAN.1.DECIMAL.NUMBER     Get increment, if any
1780        DEX          Were there any parameters?
1790        BMI .4       ...no, use current values
1800        DEX          ...yes, see if two parameters
1810        DEX
1820        BMI .2       ...no, only a starting line number
1830 .1     LDA A1L,X    ...yes, copy new increment
1840        STA INCREMENT.VALUE,X
1850        DEX
1860        BPL .1
1870 *---X=-1, form "previous" line number---
1880 .2     SEC          As written, this loop only works
1890 .3     LDA A0L+1,X       if all values are in page zero
1900        SBC INCREMENT.VALUE+1,X    because it uses negative
1910        STA CURLNO+1,X             indexing.
1920        INX
1930        BEQ .3
1940 *---Set the AUTO flag------------
1950 .4     SEC               SET FLAG
1960        .HS 90       "BCC", ALWAYS SKIP NEXT BYTE
1970 MANUAL CLC               CLEAR FLAG
1980        ROR AUTOLN.FLAG
1990        RTS
2000 *--------------------------------
2010 *
2020 *      EDIT COMMAND
2030 *
2040 *--------------------------------
2050 EDIT
2060        JSR GET.KEY.STRING
2070        JSR PARSE.LINE.RANGE
2080 .1     JSR GET.LINE.TO.WBUF
2090        BCC .2
2100        RTS          Finished with range
2110 .2     JSR FIND.KEY.IN.WBUF
2120        BCC .1       Not there
2130        JSR EDIT.ONE.LINE
2140        JMP .1
2150 *--------------------------------
2160 DATE   JSR SCAN.3.DECIMAL.NUMBERS   Day, Month, Year
2170        CPX #6
2180        BCC SYNX1    NEED ALL THREE VALUES
2190        LDA A1L      MONTH
2200        ASL
2210        ASL
2220        ASL
2230        ASL
2240        ASL          M-MMM00000
2250        ORA A0L      M-MMMDDDDD
2260        STA $BF90
2270        LDA A2L      YEAR
2280        ROL          YYYYYYYM
2290        STA $BF91
2300        RTS
2310 *--------------------------------
2320 TIME   JSR SCAN.3.DECIMAL.NUMBERS   Hour, Minute
2330        CPX #4
2340        BCC SYNX1    NEED BOTH VALUES
2350        LDA A0L      HOUR
2360        STA $BF93
2370        LDA A1L      MINUTE
2380        STA $BF92
2390        RTS
2400 *---------------------------------
2410 *      RENUMBER COMMAND
2420 *
2430 *      UP TO THREE PARAMETERS
2440 *      1:  BASE NUMBER    (DEFAULT = 1000)
2450 *      2:  INCREMENT      (DEFAULT = 10)
2460 *      3:  STARTING LINE  (DEFAULT = 0)
2470 *---------------------------------
2480 RENUMBER
2490        JSR SCAN.3.DECIMAL.NUMBERS    Base, Increment, Starting Line
2500 .1     CPX #3       COPY DEFAULTS IF ANY NEEDED
2510        BCS .2       NO MORE DEFAULTS NEEDED
2520        LDA RENDTA,X
2530        STA A0L,X
2540        INX
2550        BNE .1       ...ALWAYS
2560 .2     LDX #A2L     FIND STARTING LINE
2570        JSR SERTXT
2580 .3     LDA LINE.START      TEST IF THRU YET
2590        CMP HI.MEM
2600        LDA LINE.START+1
2610        SBC HI.MEM+1
2620        BCS .4       FINISHED
2630        LDY #0
2640        LDA (LINE.START),Y  GET LINE LENGTH
2650        PHA          SAVE FOR LATER
2660        INY
2670        LDA A0L      STORE NEW LINE NUMBER IN LINE
2680        STA (LINE.START),Y
2690        ADC A1L      ADD INCREMENT AS WE GO
2700        STA A0L
2710        INY
2720        LDA A0H      REST OF LINE NUMBER
2730        STA (LINE.START),Y
2740        ADC A1H      ADD REST OF INCREMENT
2750        BCS .5       YES, TOO BIG
2760        STA A0H      OK, AND CARRY CLEAR
2770        PLA          GET LINE SIZE
2780        ADC LINE.START      BUMP POINTER TO NEXT LINE
2790        STA LINE.START
2800        BCC .3
2810        INC LINE.START+1
2820        BNE .3       ...ALWAYS
2830 .4     RTS          FINISHED!
2840 .5     LDY #QER3   RANGE ERROR
2850        JMP HARD.ERROR
2860 RENDTA .DA 1000     DEFAULT BASE
2870        .DA #10      DEFAULT INCREMENT
2880 ***    .DA 0        DEFAULT STARTING LINE
2890 *--------------------------------
2900 *      HIDE COMMAND
2910 *--------------------------------
2920 HIDE   JSR MERGE         MERGE IF ANY PREVIOUS HIDE
2930        LDA #'H
2940        STA PROMPT.FLAG   NO, HIDE IT ALONE
2950        INX               NOW X=1
2960 .1     LDA HI.MEM,X       SAVE HI.MEM
2970        STA HIDE.HIMEM,X
2980        LDA PP,X
2990        STA HI.MEM,X
3000        DEX
3010        BPL .1
3020        RTS
3030 *--------------------------------
3040 *      MERGE COMMAND
3050 *--------------------------------
3060 MERGE  LDA PROMPT.FLAG
3070        EOR #'H
3080        BNE .1
3090        STA PROMPT.FLAG   CLEAR PROMPT CHAR
3100        LDA HIDE.HIMEM RESTORE HI.MEM
3110        STA HI.MEM
3120        LDA HIDE.HIMEM+1
3130        STA HI.MEM+1
3140 .1     RTS
3150 *--------------------------------
3160 *      NEW COMMAND
3170 *--------------------------------
3180 NEW    JSR RESTORE  RESTORE IF IN AN INCLUDE
3190        JSR MERGE
3200        JSR EMPTY.SOURCE.AREA
3210        JMP HARD
3220 *--------------------------------
3230 *      MEMORY COMMAND
3240 *      PRINT OUT BOUNDS ON SOURCE PROGRAM
3250 *      AND ON SYMBOL TABLE
3260 *--------------------------------
3270 MEMORY LDY #QSRCPRG      "SOURCE PROGRAM:  $"
3280        LDX #PP
3290        LDA #HI.MEM
3300        JSR MEM.LINE
3310        LDY #QSYMTBL       " SYMBOL TABLE:  $"
3320        LDX #LO.MEM
3330        LDA #EOT
3340 MEM.LINE
3350        PHA          SAVE SECOND VALUE PNTR
3360        TXA
3370        PHA          SAVE FIRST VALUE PNTR
3380        JSR QT.OUT
3390        PLA          GET FIRST VALUE PNTR
3400        JSR MEM.HEXVAL
3410        JSR P.DASH
3420        PLA          GET SECOND VALUE PNTR
3430 MEM.HEXVAL
3440        TAX
3450        LDA 1,X
3460        JSR MON.PHEX
3470        LDA 0,X
3480        JMP MON.PHEX
3490 *--------------------------------
3500 RST    JSR EXPR
3510        LDY EXP.VALUE
3520        LDA EXP.VALUE+1
3530 *--------------------------------
3540 SET.RESET.VECTOR
3550        STY MON.RESET
3560        STA MON.RESET+1
3570        EOR #$A5
3580        STA MON.RESET+2
3590        RTS
3600 *--------------------------------
