
1000 *SAVE X.ASM.GENERAL
1010 *--------------------------------
1020 *    ASSEMBLER MAIN DRIVER
1030 *--------------------------------
1040 ASM
1050 *      LDX #0       X=0 FROM COMMAND DISPATCHER
1060        STX PASS     SET TO PASS 1
1070        STX ERROR.COUNT
1080        STX ERROR.COUNT+1
1090 *      STX MACRO.LEVEL    ALREADY DONE IN GNL
1100 *      STX PARAM.PNTR     ALREADY DONE IN GNL
1110 *      STX PAGE.LENGTH    ALREADY DONE IN GNL
1120        STX PAGE.NUMBER
1130        STX PAGE.NUMBER+1
1140        JSR STINIT   INITIALIZE SYMBOL TABLE
1150        JSR RESTORE  IF IN INCLUDE, RESTORE
1160 *--------------------------------
1170 *      PERFORM NEXT PASS OF ASSEMBLY
1180 *--------------------------------
1190 ASM1   LDA ERROR.COUNT
1200        ORA ERROR.COUNT+1
1210        BEQ .1
1220        JMP ASM.END  PRINT # ERRORS AND ABORT ASSEMBLY
1230 .1     LDX #1       INIT 2-BYTE VARIABLES
1240 .2     LDA PP,X     POINT TO BEGINNING OF SOURCE PROGRAM
1250        STA SRCP,X
1260        STA MACSTK,X
1270        LDA #0
1280        STA CALL.CNTR,X   TOTAL # MACRO CALLS
1290        STA CALL.NUM,X    CURRENT MACRO CALL #
1300        STA ORGN+2,X      HIGH 16 OF ORIGIN
1310        DEX
1320        BPL .2
1330 *---Following = $FF--------------
1340        STX DO.STACK      SET OUTER LEVEL TRUE (=$FF)
1350        STX LF.CONDITIONAL   do not list false sets (=$FF)
1360 *---Following = $00--------------
1370        STA DUMMY.FLAG    NOT IN DUMMY SECTION
1380        STA PHASE.FLAG    NOT IN PHASE
1390        STA DO.INDEX      SET DO.STACK TO EMPTY
1400        STA LF.ALL        turn on main listing
1410        STA LF.MACRO      list macro expansions too
1420        STA LF.XTRA.BYTES list all bytes, use extra lines
1430        STA TF.FLAG       not in ".TF"
1440        STA DO.SKIP.CNT   not in ".DO"
1450        STA FLAG.MA       not in ".MA"
1460        STA NYBBLE.FLAG   .AC odd/even
1470        STA ORGN          ORIGIN = $0800
1480        STA TRGT          TARGET = $0800
1490 *---Following = $08--------------
1500        LDA #$08
1510        STA ORGN+1
1520        STA TRGT+1
1530        JSR ASM.INIT       Initialize for particular assembler
1540 *--------------------------------
1550 *    MOVE NEXT LINE INTO WORKING BUFFER
1560 *--------------------------------
1570 ASM2   LDA $C000    CHECK FOR ABORT WITHOUT
1580        CMP #CHR.RETURN   CLEARING STROBE
1590        BNE .1
1600        JMP JMP.SOFT     YES, STOP RIGHT NOW
1610 .1     LDX #$FF       INITIALIZE STACK POINTER
1620        TXS
1630        INX            MAKE X=0
1640        STX EMIT.COLUMN
1650        STX EXP.UNDEF     CLEAR UNDEFINED FLAG
1660        JSR SETUP.NEXT.LINE
1670        BCC .2       GOT A LINE
1680        JMP ENDM     NO MORE LINES, ACT LIKE .EN FOUND
1690 *---CHECK CURRENT CONDITION------
1700 .2     LDA DO.STACK      CURRENT LEVEL IN SIGN BIT
1710        BMI ASSEMBLE.ONE.LINE  TRUE, SO ASSEMBLE
1720 *--------------------------------
1730 *      SKIP TO .FIN OR .ELSE
1740 *--------------------------------
1750 SKIP.TO.FIN
1760        JSR SCAN.TO.OPCODE
1770        BCS .3
1780        LDX #DIR.QT.DO
1790        JSR DIR.SCAN.OR.FAIL
1800        BCC .1       NOT .DO
1810        INC DO.SKIP.CNT  .DO
1820        BNE .3       ...ALWAYS
1830 .1     LDY DO.SKIP.CNT
1840        BNE .2       INSIDE A NESTED .DO, IGNORE .ELSE'S
1850        JSR DIR.SCAN.OR.FAIL
1860        BCS ASSEMBLE.ONE.LINE  FOUND .ELSE
1870 .2     LDX #DIR.QT.FI
1880        JSR DIR.SCAN.OR.FAIL
1890        BCC .3       NOT .FIN
1900        LDY DO.SKIP.CNT  .FIN, SEE IF NESTED ONE
1910        BEQ ASSEMBLE.ONE.LINE  NO, ASSEMBLE THIS .FIN
1920        DEC DO.SKIP.CNT        YES, POP OFF THIS NEST
1930 .3     BIT LF.CONDITIONAL     LIST CONDITIONAL LINES?
1940        BMI ASM2               NO, SKIP IT
1950        JSR CRLF.IF.LISTING    YES, NEW LINE
1960        JMP CMNT               AND LIST IT
1970 *--------------------------------
1980 *    ANALYZE SOURCE LINE
1990 *--------------------------------
2000 ASSEMBLE.ONE.LINE
2010        JSR CRLF.IF.LISTING
2020        JSR PACK.MACRO.LINE
2030        BCS CMNT     ...only list if MACRO definition line
2040        JSR GNC.UC.START    not MACRO line, get first char
2050        BCS CMNT          ...empty line
2060        BEQ .3            ...blank, so no label
2070        JSR CHECK.COMMENT.CHAR
2080        BEQ CMNT          ...comment (* or ;)
2090        JSR LABL      PROCESS LABEL DEFINITION
2100 .3     JSR GNNB      Scan to opcode field
2110        BCS CMNT      ...none, only label on this line
2120        JSR CHECK.COMMENT.CHAR    might be a comment with no opcode
2130        BEQ CMNT     ...yes, there is a comment
2140        CMP #'>      CHECK IF MACRO OPCODE
2150        BEQ .4       ...YES
2160        CMP #'_      CHECK IF MACRO OPCODE
2170        BEQ .4       ...YES
2180        CMP #'='
2190        BEQ .5       '=' is synonym for .EQ
2200        STA SEARCH.KEY  FIRST OPCODE CHAR
2210        JSR GNC.UC
2220        STA SEARCH.KEY+1  2ND OPCODE CHAR
2230        JSR GNC.UC
2240        STA SEARCH.KEY+2  3RD OPCODE CHAR
2250        LDA SEARCH.KEY
2260        CMP #'.        IS IT A DIRECTIVE?
2270        BNE .6       NO, TRY NORMAL OPCODES
2280        LDA #OPTBL.DIR
2290        LDY /OPTBL.DIR
2300        CLC          INITIAL SEARCH
2310        JSR SEARCH.COMPRESSED.TABLE
2320        BCC OPER     ...NOT FOUND IN TABLE
2330        JSR PERFORM.DIRECTIVE
2340        JMP CMNT
2350 .4     JMP MACRO.CALL
2360 .5     JSR PSEQ     "=" is synonym for .EQ
2370        JMP CMNT
2380 .6     JSR ASM.PARTICULAR
2390 *--------------------------------
2400 CMNT   LDA EXP.UNDEF
2410        BPL .1       NO UNDEFINED EXPRESSIONS ON THIS LINE
2420        LDA PASS
2430        BEQ .1       IF WE GOT THIS FAR, OKAY IN PASS 1
2440        JMP UNDF
2450 .1     JSR LIST.SOURCE.IF.LISTING
2460        JMP ASM2      NEXT LINE
2470 *--------------------------------
2480 *--------------------------------
2490 PERFORM.DIRECTIVE
2500        INY          POINT AT HIGH BYTE OF ADDRESS
2510        LDA (OPTBL.PNTR),Y
2520        PHA
2530        DEY
2540        LDA (OPTBL.PNTR),Y
2550        PHA
2560        RTS
2570 *--------------------------------
2580 OPER   LDY #QER2    ERROR--BAD OPCODE
2590        JMP SOFT.ERROR
2600 *--------------------------------
2610 *      EMIT ONE BYTE OF OBJECT CODE
2620 *
2630 *      IF IN PASS TWO THEN
2640 *        ! IF LISTING THEN 
2650 *        ! IF IN ".TF" THEN
2660 *        !   ! 
2670 *        ! ELSE IF NOT IN DUMMY SECTION THEN
2680 *        !   !    ! IF IN PROTECTED AREA THEN
2690 *        !   !    !   ! 
2700 *        !   !    ! ELSE 
2710 *      INCREMENT ORIGIN AND ORIGIN.SAVE
2720 *      IF NOT IN DUMMY SECTION THEN INCREMENT TARGET
2730 *--------------------------------
2740 EMIT.ZERO
2750        LDA #0
2760 EMIT   LDY PASS      CHECK WHICH PASS
2770        BEQ .5        PASS 1, JUST INCREMENT LOCATION
2780        STA OBJ.BYTE  SAVE OBJECT BYTE
2790 *---LIST THE BYTE----------------
2800        JSR P.EMITTED.BYTE
2810 *---STORE THE BYTE---------------
2820        BIT DUMMY.FLAG    No output inside dummy section
2830        BMI .6            ...only increment the origin
2840        LDA OBJ.BYTE      GET OUTPUT BYTE
2850        BIT TF.FLAG  SEE IF IN ".TF"
2860        BMI .4       YES
2870        JSR USER.OBJECT.BYTE
2880        JMP .5       ...ALWAYS
2890 .4     JSR DOUT     WRITE ON TARGET FILE
2900 *---INCREMENT LOCATION-----------
2910 .5     LDA DUMMY.FLAG  IF IN DUMMY SECTION,
2920        BMI .6            THEN ONLY INCREMENT ORGN
2930        >INCD TRGT        BUMP TARGET ADDRESS
2940        >INCD ORIGIN.SAVE      AND ORIGIN OUTSIDE .PH
2950 .6     >INCD ORGN        BUMP CURRENT ORIGIN
2960        RTS
2970 *--------------------------------
2980 STORE.OBJECT.BYTE
2990        LDA TRGT+1   TARGET PAGE
3000        BNE .1       NOT PAGE ZERO
3010        LDA TRGT     ALLOW $00-$1E
3020        CMP #$1F
3030        BCC .4       SAFE
3040        BCS .3       NOT SAFE
3050 *---ALLOW $300-$3CF--------------
3060 .1     CMP #$03     IN PAGE 3?
3070        BNE .2       NO
3080        LDA TRGT     BELOW $3D0?
3090        CMP #$D0
3100        BCC .4       YES, SAFE
3110        BCS .3       NO, NOT SAFE
3120   .DO AUXMEM
3130 *---ALLOW $800-MACSTK------------
3140 .2     CMP #$08     BELOW PAGE 8?
3150        BCC .3       YES, NOT SAFE
3160        LDA TRGT
3170        CMP MACSTK
3180        LDA TRGT+1
3190        SBC MACSTK+1
3200        BCC .4       BELOW MACSTK, SAFE
3210   .ELSE
3220 *---ALLOW $800-MACLBL------------
3230 .2     CMP #$08     BELOW PAGE 8?
3240        BCC .3       YES, NOT SAFE
3250        LDA TRGT     NO, COMPARE TO MACLBL
3260        CMP MACLBL
3270        LDA TRGT+1
3280        SBC MACLBL+1
3290        BCC .4       BELOW MACLBL, SO SAFE
3300 *---ALLOW EOT-MACSTK-------------
3310        LDA EOT
3320        CMP TRGT
3330        LDA EOT+1
3340        SBC TRGT+1
3350        BCS .3       BELOW EOT, NOT SAFE
3360        LDA TRGT
3370        CMP MACSTK
3380        LDA TRGT+1
3390        SBC MACSTK+1
3400        BCC .4       BELOW MACSTK, SAFE
3410   .FIN
3420 *---NOT SAFE, CHECK USER RANGE---
3430 .3     LDA TRGT
3440        CMP USER.MEM.LO
3450        LDA TRGT+1
3460        SBC USER.MEM.LO+1
3470        BCC .5       DEFINITELY OUT OF BOUNDS
3480        LDA USER.MEM.HI
3490        CMP TRGT
3500        LDA USER.MEM.HI+1
3510        SBC TRGT+1
3520        BCC .5       DEFINITELY OUT OF BOUNDS
3530 .4     LDY #0
3540        LDA OBJ.BYTE
3550        STA (TRGT),Y
3560        RTS
3570 .5     LDY #QMEMPRO
3580        JMP FIRM.ERROR
3590 *--------------------------------
3600 *    LIST SOURCE LINE
3610 *--------------------------------
3620 LIST.SOURCE.IF.LISTING
3630        JSR CHECK.IF.LISTING
3640 LIST.SOURCE.REGARDLESS
3650        JSR P.MARGIN   PRINT BLANKS TILL MARGIN
3660 LIST.SOURCE.AT.MARGIN
3670        JSR CONVERT.LINE.NUMBER.PRINT
3680        LDY MACRO.LEVEL
3690        BEQ .2
3700        LDA #'>'
3710 .1     JSR CHO
3720        DEY
3730        BNE .1       ...UNTIL Y=0
3740 .2     LDA #' '     ...NOW Y=0
3750 .3     JSR CHO
3760        INY
3770        LDA WBUF-1,Y
3780        BNE .3
3790        RTS
3800 *--------------------------------
3810 *      PRINT CRLF IF IN PASS 2 AND IF LISTING IS ON
3820 *--------------------------------
3830 CRLF.CAUSED.FORM.FEED
3840        JSR FORM.FEED
3850 CRLF.IF.LISTING
3860        JSR CHECK.IF.LISTING
3870 CRLF.WITH.PAGING
3880        JSR CRLF
3890        INC LINE.COUNT
3900        LDA PAGE.LENGTH
3910        BEQ .1       ...NOT TITLING
3920        CMP LINE.COUNT
3930        BCC CRLF.CAUSED.FORM.FEED   ...END OF PAGE
3940 .1     RTS
3950 *--------------------------------
3960 *    PROCESS LABEL DEFINITION
3970 *--------------------------------
3980 LABL   JSR PACK     PACK AND CHECK SYMBOL
3990        BCC ERR.BS   BAD SYMBOL
4000        JSR STSRCH   SEE IF DEFINED
4010        BCC ERR.DD   YES, DOUBLE DEFINITION
4020        JMP STADD    ADD TO SYMBOL TABLE
4030 *--------------------------------
4040 ERR.DD LDY PASS     ERROR IN PASS 1
4050        BEQ ERR.DBLDF     OK IN PASS 2
4060        LDY #6       SET FLAG FOR TESTING FWD REFS
4070        >SYM LDA,STPNTR
4080        ORA #$40
4090        >SYM STA,STPNTR
4100        LDY WBUF     LOOK AT COLUMN 1
4110        CPY #':      IF PRIVATE LABEL...
4120        BEQ .2       ...THEN DON'T UPDATE C.M.LABEL
4130        LDA STPNTR   SAVE POINTER TO THIS MAJOR LABEL
4140        STA CURRENT.MAJOR.LABEL
4150        LDA STPNTR+1
4160        STA CURRENT.MAJOR.LABEL+1
4170 .2     RTS
4180 ERR.DBLDF
4190        LDY #QER4    DOUBLE DEFN
4200        .HS 2C       SKIP 2 BYTES
4210 ERR.BS LDY #QER7    BAD SYMBOL
4220        JMP SOFT.ERROR
4230 *--------------------------------
4240 *   Search Compressed Opcode Table
4250 *      If carry clear, (Y,A) = address of table
4260 *      If carry set, continue searching same table
4270 *
4280 *   Return with carry set if found, else carry clear.
4290 *      (OPTBL.PNTR),Y points at 16-bit value
4300 *                     of entry which matched.
4310 *--------------------------------
4320 SEARCH.COMPRESSED.TABLE
4330        BCS .6       ...Continue searching same table
4340        STA OPTBL.PNTR
4350        STY OPTBL.PNTR+1
4360 *---Try matching 2nd letter------
4370        LDY #0
4380 .1     LDA (OPTBL.PNTR),Y      Possible match
4390        ORA #$40                Make it ASCII
4400        CMP SEARCH.KEY+1        same as 2nd letter?
4410        BEQ .6                  ...yes, matched.
4420        BNE .3                  ...no
4430 *---Scan to next 8-bit entry-----
4440 .2     INY
4450        INY
4460 .3     INY
4470        LDA (OPTBL.PNTR),Y
4480        BMI .2       ...another 24-bit entry
4490        ASL          check if beyond our sub-group
4500        BPL .1       ...no, valid 2nd letter option
4510 .4     CLC          ...no match in table, carry clear
4520        RTS
4530 *---Try matching 3rd letter------
4540 .5     INY
4550 .6     INY
4560        LDA (OPTBL.PNTR),Y
4570        BPL .4            ...no more options, not in table
4580        INY               point at data
4590        EOR #$C0          make like ASCII
4600        CMP SEARCH.KEY+2  compare to 3rd letter
4610        BNE .5            ...did not match, try another
4620        RTS               ...found it, return carry set
4630 *--------------------------------
4640        .PG
