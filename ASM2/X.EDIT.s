
1000 *SAVE X.EDIT
1010 *--------------------------------
1020 *    SOFT INITIALIZATION
1030 *--------------------------------
1040 SOFT   LDA /$1000   START SYMBOL TABLE AT $1000
1050 SYMBOL.BASE .EQ *-1
1060        STA LO.MEM+1
1070        LDA #0
1080        STA LO.MEM
1090        STA AUTOLN.FLAG  TURN OFF AUTOMATIC LINE NUMBERS
1100        JSR IO.WARM  INIT SCREEN, CONNECT DOS
1110        JSR CLOSE.FILES
1120 *--------------------------------
1130 FAST   CLC          SET TO FAST LISTING SPEED
1140        .HS 24       (SKIP OVER SEC)
1150 SLOW   SEC          SET TO SLOW LISTING SPEED
1160        ROR FLAG.SPEED    SET/CLEAR SIGN BIT
1170 *--------------------------------
1180 *    GET NEXT LINE
1190 *--------------------------------
1200 GNL
1210        LDX #$FF     INIT STACK
1220        TXS
1230        STX PASS     PASS=-1 IF NOT ASSEMBLING
1240        INX          MAKE X=0
1250        STX SCI.STATE    GET INTO "IMMEDIATE" STATE
1260        STX RPTCNT   CLEAR REPEAT COUNT
1270        STX MACRO.LEVEL
1280        STX PARAM.PNTR
1290        STX CHAR.PNTR
1300        STX PAGE.LENGTH  TURN OFF TITLING
1310        JSR READ.LINE
1320        JSR GNC.UC.START  GET FIRST CHAR OF LINE
1330        BEQ GNL        EMPTY LINE OR 1ST CHAR IS BLANK
1340        JSR CHECK.LETTER
1350        BCC .1       NOT A LETTER
1360        JSR SEARCH.COMMAND.TABLE
1370        JMP GNL
1380 *---Test for single char cmds----
1390 .1     LDY #CHARS.FOR.COMMANDS
1400        JSR SEARCH.CHAR.TABLES
1410        JMP GNL
1420 *---" LINE, ECHO ALL CHARS-------
1430 ECHO1  JSR CHO      SEND CHARACTER
1440 ECHO.LINE
1450        JSR GNC      GET NEXT CHAR
1460        BCC ECHO1    NOT END YET
1470        RTS
1480 *--------------------------------
1490 *    SYNTAX ERROR
1500 *--------------------------------
1510 SYNX   LDY #QSYNX
1520        JMP HARD.ERROR
1530        .PG
1540 *--------------------------------
1550 *    NUMBERED LINE
1560 *--------------------------------
1570 NML    JSR GNC.START  GET FIRST CHAR
1580        JSR DECN     CONVERT LINE NUMBER
1590        LDA DGTCNT   MUST BE 1 TO 5 DIGITS
1600        BEQ SYNX
1610        LDA SYM.VALUE+2
1620        ORA SYM.VALUE+3
1630        BNE SYNX     > 65535
1640 *---Compact the numbered line----
1650        DEY          Backup to previous character
1660        JSR COMPACT.LINE
1670 *--------------------------------
1680        LDX #1       COPY IN BINARY LINE #
1690 .51    LDA SYM.VALUE,X
1700        STA CURLNO,X   SAVE HERE TOO, FOR AUTO-NUMBER
1710        STA WBUF+1,X
1720        DEX
1730        BPL .51
1740 *--------------------------------
1750 *    FIND LINE, OR PLACE WHERE IT SHOULD GO
1760 *      LINE.START --> BEGINNING OF THIS LINE
1770 *      LINE.END   --> BEGINNING OF NEXT LINE
1780 *--------------------------------
1790        LDX #SYM.VALUE   POINT AT LINE NUMBER
1800        JSR SERTXT    FIND IT IF THERE
1810        SEC          GET LENGTH OF HOLE
1820        LDA LINE.END  WILL ALWAYS BE LESS THAN 256
1830        SBC LINE.START
1840        SEC          SUBTRACT LENGTH OF NEW LINE
1850        SBC WBUF     LINE SIZE
1860        BEQ .11      SAME SIZE EXACTLY
1870        STA MOVE.DISTANCE
1880        LDA #0
1890        SBC #0
1900        STA MOVE.DISTANCE+1
1910        BCC .6       NEW LINE LONGER THAN HOLE
1920 *--------------------------------
1930 *      NEW LINE SHORTER THAN HOLE
1940 *--------------------------------
1950        CLC          COMPUTE TARGET TO MOVE UP TO
1960        LDA LINE.START
1970        ADC MOVE.DISTANCE
1980        STA A4L
1990        LDA LINE.START+1
2000        ADC MOVE.DISTANCE+1
2010        STA A4H
2020        JSR MOVE.TEXT.UP
2030        JMP .10      NOW HOLE IS RIGHT SIZE
2040 *--------------------------------
2050 *      ENLARGE HOLE TO MAKE ROOM
2060 *--------------------------------
2070 .6     CLC          (MOVE.DISTANCE) = -<#BYTES TO EXPAND>
2080        LDA PP       COMPUTE TARGET ADDRESS
2090        ADC MOVE.DISTANCE
2100        STA A4L
2110        LDA PP+1
2120        ADC MOVE.DISTANCE+1
2130        STA A4H
2140        LDA A4L       BE SURE THERE IS ROOM
2150        CMP LO.MEM
2160        LDA A4H
2170        SBC LO.MEM+1
2180        BCC MFER      NO ROOM!
2190        JSR MOVE.TEXT.DOWN
2200 *---Adjust SRCP if needed--------
2210 .10    LDA SRCP     If hole is above (SRCP),
2220        CMP LINE.END      then need to add MOVE.DISTANCE
2230        LDA SRCP+1
2240        SBC LINE.END+1
2250        BCS .11
2260        LDA SRCP
2270        ADC MOVE.DISTANCE
2280        STA SRCP
2290        LDA SRCP+1
2300        ADC MOVE.DISTANCE+1
2310        STA SRCP+1
2320 *--------------------------------
2330 *    COPY NEW LINE INTO THE HOLE
2340 *--------------------------------
2350 .11    LDX WBUF     LINE SIZE
2360        BEQ .14      NO NEW LINE TO COPY
2370        LDY #0
2380 .12    LDA LINE.END   BACK UP POINTER TO END OF HOLE
2390        BNE .13
2400        DEC LINE.END+1
2410 .13    DEC LINE.END
2420        DEX
2430        LDA WBUF,X
2440        STA (LINE.END),Y
2450        TXA
2460        BNE .12
2470 .14    RTS
2480 *--------------------------------
2490 MFER LDY #QMEMFL        MEM FULL ERROR
2500      JMP HARD.ERROR
2510 *--------------------------------
2520 COMPACT.LINE
2530        LDX #4       Start storing at WBUF+3
2540        LDA #-1      Prime RPT pump
2550        STA RPTCNT
2560 .1     STA RPTCHR
2570 .2     INY          advance input pointer
2580        INC RPTCNT   (first time makes it = 0)
2590        LDA WBUF,Y   get next char
2600        AND #$7F     be sure its low ascii
2610        CMP RPTCHR   save as previous char?
2620        BEQ .2       ...yes, just count it
2630        PHA          save new character
2640 *--------------------------------
2650        LDA RPTCNT
2660        BEQ .3
2670        JSR PROCESS.REPEAT.COUNT
2680 *--------------------------------
2690 .3     PLA          get new character
2700        BNE .1       ...not 00 terminator
2710        STA WBUF-1,X store terminator
2720        CPX #5       If only line number, make length 00
2730        BCS .4
2740        LDX #0
2750 .4     STX WBUF
2760        RTS
2770 *--------------------------------
2780 PROCESS.REPEAT.COUNT 
2790        LDA RPTCHR
2800        CMP #' '
2810        BEQ .5       ...compress blanks in special way
2820        LDA RPTCNT
2830        CMP COMPRESSION.LIMIT
2840        BCS .2       ...enough to compress to 3 bytes
2850 .1     LDA RPTCHR   spit out uncompressed chars
2860        STA WBUF-1,X
2870        INX
2880        DEC RPTCNT
2890        BNE .1
2900        RTS
2910 *---Compress $C0 cnt char--------
2920 .2     STA WBUF,X   store count
2930        LDA #$C0     Compression token
2940        STA WBUF-1,X
2950        INX
2960        INX
2970        LDA RPTCHR   repeated char
2980 .3     STA WBUF-1,X
2990        INX
3000        LDA #0
3010        STA RPTCNT
3020        RTS
3030 *---Compress blanks--------------
3040 .4     SBC #$3F     Maximum blanks in one token
3050        STA RPTCNT
3060        LDA #$BF     $3F blanks
3070        STA WBUF-1,X
3080        INX
3090 .5     LDA RPTCNT   Number of blanks left
3100        CMP #$40
3110        BCS .4       ...too many for one token
3120        ORA #$80     make into blank token + count
3130        BNE .3       ...always
3140 *--------------------------------
3150 SCAN.3.DECIMAL.NUMBERS
3160        LDX #6       FIRST CLEAR TO ZERO
3170        LDA #0
3180 .1     STA A0L-1,X
3190        DEX
3200        BNE .1
3210        JSR SCAN.1.DECIMAL.NUMBER
3220        JSR SCAN.1.DECIMAL.NUMBER
3230 ***    JMP SCAN.1.DECIMAL.NUMBER
3240 *--------------------------------
3250 SCAN.1.DECIMAL.NUMBER
3260 .1     JSR GNC
3270        BCS .2       END OF LINE
3280        EOR #$30     IS THIS A DIGIT?
3290        CMP #10
3300        BCS .1       NO
3310        TXA          SAVE X-REG
3320        PHA
3330        JSR DECN     CONVERT NUMBER
3340        PLA          RESTORE X-REG
3350        TAX
3360        LDA SYM.VALUE  STACK NUMBER
3370        STA A0L,X
3380        INX
3390        LDA SYM.VALUE+1
3400        STA A0L,X
3410        INX
3420 .2     RTS
3430 *--------------------------------
3440 *    DECIMAL NUMBER INPUT
3450 *--------------------------------
3460 DECN   JSR BACKUP.CHAR.PNTR
3470        JSR ZERO.SYM.VALUE    CLEAR ACCUMULATOR
3480        STA DGTCNT
3490 .1     JSR GNC       GET NEXT CHAR
3500        EOR #$30      CHECK IF DIGIT
3510        CMP #10
3520        BCS .5        NOT A DIGIT
3530        PHA          SAVE THE DIGIT
3540 *---ACCUMULATOR * TEN------------
3550        JSR ASL.SYM.VALUE
3560        BCS .6       OVERFLOW ERROR
3570        LDX #3
3580 .2     LDA SYM.VALUE,X   HI- TO LO-
3590        PHA
3600        DEX
3610        BPL .2       
3620 .3     JSR ASL.SYM.VALUE
3630        BCS .6       OVERFLOW ERROR
3640        INX
3650        BEQ .3       DO IT TWICE
3660        PLA
3670        ADC SYM.VALUE
3680        STA SYM.VALUE
3690        PLA
3700        ADC SYM.VALUE+1
3710        STA SYM.VALUE+1
3720        PLA
3730        ADC SYM.VALUE+2
3740        STA SYM.VALUE+2
3750        PLA
3760        ADC SYM.VALUE+3
3770        STA SYM.VALUE+3
3780        BCS .6       OVERFLOW ERROR
3790 *---ADD CURRENT DIGIT------------
3800        PLA
3810        ADC SYM.VALUE
3820        STA SYM.VALUE
3830        BCC .4
3840        INC SYM.VALUE+1
3850        BNE .4
3860        INC SYM.VALUE+2
3870        BNE .4
3880        INC SYM.VALUE+3
3890        BEQ .6       OVERFLOW ERROR
3900 .4     INC DGTCNT   COUNT THE DIGIT
3910        BNE .1       ...ALWAYS
3920 .5     RTS
3930 .6     LDY #QER3    RANGE ERROR
3940        JMP SOFT.ERROR
3950 *--------------------------------
3960 *    GET NEXT NON-BLANK CHAR
3970 *--------------------------------
3980 GNNB JSR GNC.UC    GET NEXT CHAR IN UPPER CASE
3990      BCS .1        END OF LINE
4000      BEQ GNNB      BLANK
4010 .1   RTS           RETURN
4020 *--------------------------------
4030 *      GET NEXT CHAR IN UPPER CASE
4040 *--------------------------------
4050 GNC.UC.START
4060        LDY #0
4070        STY CHAR.PNTR
4080 GNC.UC JSR GNC      GET NEXT CHAR ANY CASE
4090        BEQ .1       SPACE OR 
4100        JSR ELIMINATE.CASE    MAP LOWER CASE TO UPPER CASE
4110        STA CURRENT.CHAR
4120        CMP #$FF     CLEAR CARRY, SET .NE.
4130 .1     RTS
4140 *--------------------------------
4150 *    GET NEXT CHAR
4160 *--------------------------------
4170 GNC.START
4180        LDY #0       BEGINNING OF LINE
4190        .HS 2C       SKIP NEXT TWO BYTES
4200 GNC  LDY CHAR.PNTR
4210 GNC2 LDA WBUF,Y    GET CHAR
4220      AND #$7F
4230      STA CURRENT.CHAR
4240      BEQ .1        END OF LINE
4250      INY           BUMP POINTER
4260      STY CHAR.PNTR
4270      CMP #$20      SEE IF BLANK
4280      CLC           CARRY CLEAR SINCE NOT AT END
4290      RTS
4300 .1   LDA #$20      RETURN BLANK
4310      CMP #$20      SET CARRY AND EQUAL STATUS
4320      RTS
4330 *--------------------------------
4340 *      BACK UP CHARACTER POINTER
4350 *--------------------------------
4360 BACKUP.CHAR.PNTR
4370        PHA          SAVE A-REG
4380        LDA CURRENT.CHAR
4390        BEQ .1       DO NOT BACK OFF THE END
4400        LDA CHAR.PNTR
4410        BEQ .1       DO NOT BACK BEYOND THE BEGINNING
4420        DEC CHAR.PNTR
4430 .1     PLA
4440        RTS
4450 *--------------------------------
4460 *    GET NEXT TOKEN FROM SOURCE LINE
4470 *--------------------------------
4480 NTKN
4490        LDA RPTCNT
4500        BNE .3       IN A REPEATED CHAR LOOP
4510        JSR GNB      GET NEXT CHAR FROM SOURCE
4520        ASL          ...WEIRD WAY TO TEST SIGN BIT
4530        ROR          ...AND AS WELL AS 00
4540        BPL .4       ...NORMAL CHARACTER
4550        CMP #$C0     SEE IF BLANKS
4560        BCC .1       ...YES
4570        JSR GNBI     REPEAT TOKEN $C0 XX YY, GET XX
4580        STA RPTCNT
4590        JSR GNBI     GET YY (CHAR TO BE REPEATED)
4600        JMP .2       ...ALWAYS
4610 .1     AND #$3F     BLANK COUNT
4620        STA RPTCNT
4630        LDA #$20     BLANK
4640 .2     STA RPTCHR
4650 .3     DEC RPTCNT
4660        LDA RPTCHR
4670 .4     RTS
4680 *--------------------------------
4690 *    GET NEXT BYTE FROM SOURCE
4700 *--------------------------------
4710 GNB    LDY #0
4720 GNBI
4730   .DO AUXMEM
4740        LDA MACRO.LEVEL
4750        BEQ .0       ...NOT IN A SKELETON
4760        >SYM LDA,SRCP
4770        .HS 2C       SKIP OVER LDA (SRCP),Y
4780   .FIN
4790 .0     LDA (SRCP),Y
4800       >INCD SRCP
4810        BIT INFLAG   INSIDE BLOCKED .IN?
4820        BVC .3       ...NO
4830        PHA
4840        LDA MACRO.LEVEL
4850        BNE .25           INSIDE A SKELETON
4860        LDA INSAVE+4      REMAINING BYTES IN THIS BLOCK
4870        BNE .2            ...THERE ARE MORE
4880        ORA INSAVE+5
4890        BEQ .4            ...NO MORE IN THIS BLOCK
4900        DEC INSAVE+5
4910 .2     DEC INSAVE+4
4920 .25    PLA
4930 .3     RTS
4940 *---TRY TO READ ANOTHER BLOCK----
4950 .4     PLA
4960        LDA INSAVE+6      REFNUM OF INB FILE
4970        STA SCI.IOB.RW+1
4980        LDA PP            STARTING ADDRESS
4990        STA SRCP
5000        STA SCI.IOB.RW+2
5010        LDA PP+1
5020        STA SRCP+1
5030        STA SCI.IOB.RW+3
5040        SEC
5050        LDA HI.MEM+1       NUMBER OF PAGES
5060        SBC PP+1
5070        STA SCI.IOB.RW+5
5080        LDA #0
5090        STA SCI.IOB.RW+4
5100        LDA #$CA          READ
5110        JSR SCI.MLI
5120        BCC .5            ...NO ERRORS
5130        CMP #5            END OF DATA?
5140        BNE PRODOS.ERROR  ...ERROR
5150 .5     LDA SCI.IOB.RW+6
5160        STA INSAVE+4      # BYTES ACTUALLY READ
5170        LDA SCI.IOB.RW+7
5180        STA INSAVE+5
5190        BCC GNB           ...NOT END OF DATA
5200        LDA INSAVE+6      REFNUM
5210        STA SCI.IOB.CLOSE+1    FOR CLOSE CALL
5220        LDA #$CC
5230        JSR SCI.MLI
5240        BCS PRODOS.ERROR
5250        JSR RESTORE       END OF THE INBx FILE
5260        JMP ASM2
5270 *--------------------------------
5280 PRODOS.ERROR
5290        PHA
5300        JSR RESTORE.IF.IN.INBX
5310        PLA
5320        JMP SCI.ERROR
5330 *--------------------------------
5340 *      RETURN .CS. IF VALID CHAR
5350 *             .CC. IF INVALID CHAR
5360 *--------------------------------
5370 CHECK.DOT.DIGIT.OR.LETTER
5380        CMP #'.
5390        BEQ CHECKS.OK
5400        CMP #'_'     allow underline in symbols too
5410        BEQ CHECKS.OK
5420 CHECK.DIGIT.OR.LETTER
5430        JSR CHECK.DIGIT
5440        BCS CHECKS.OK
5450 CHECK.LETTER
5460        CMP #'A
5470        BCC CHECKS.NOT.OK
5480        CMP #'Z+1
5490        BCC CHECKS.OK
5500 CHECKS.NOT.OK
5510        CLC
5520        RTS
5530 CHECK.DIGIT
5540        CMP #'0
5550        BCC CHECKS.NOT.OK
5560        CMP #'9+1
5570        BCS CHECKS.NOT.OK
5580 CHECKS.OK
5590        SEC
5600        RTS
5610 *--------------------------------
5620 CHECK.COMMENT.CHAR
5630        CMP #'*      STAR?
5640        BEQ .1       YES
5650        CMP #';      SEMI-COLON?
5660 .1     RTS
5670  .PG
5680 *--------------------------------
5690 *    INITIALIZE FOR HARD ENTRY
5700 *--------------------------------
5710 HARD.INIT
5720        CLD
5730 *---Establish LO.MEM & HI.MEM------
5740        LDA SYMBOL.BASE   SET UP LO.MEM
5750        STA LO.MEM+1
5760        LDA SCI.HIMEM.PAGE
5770        STA HI.MEM+1
5780        LDA #0
5790        STA LO.MEM
5800        STA HI.MEM
5810 *---Init other parameters--------
5820        STA INCREMENT.VALUE+1
5830        STA PROMPT.FLAG
5840        STA INFLAG
5850        JSR STINIT     INITIALIZE SYMBOL TABLE
5860        LDA #10      SET AUTO-LINE-NUMBERING INCREMENT
5870        STA INCREMENT.VALUE
5880        LDA #990     SET AUTO-LINE-NUMBERING
5890        STA CURLNO   INITIAL VALUE
5900        LDA /990
5910        STA CURLNO+1
5920 *---Print Heading----------------
5930        JSR IO.INIT   INIT TEXT, FULL WINDOW, ETC.
5940        JSR VERSION  Print Version Number
5950 *--------------------------------
5960 EMPTY.SOURCE.AREA
5970        LDA HI.MEM
5980        STA PP       EMPTY SOURCE AREA
5990        LDA HI.MEM+1
6000        STA PP+1
6010        RTS
6020 *--------------------------------
6030 Q.VERSION
6040           .DA #VERSION.LO+"0",#".",#VERSION.HI+"0"
6050 *--------------------------------
6060        .PG
