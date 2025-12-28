
1000 *SAVE X.DATA
1010 *--------------------------------
1020 *      PAGE ZERO VARIABLES
1030 *--------------------------------
1040 *      $00 THRU $1F RESERVED FOR USER
1050 *---Apple Monitor, mostly--------
1060 MON.WIDTH  .EQ $21
1070 CH80       .EQ $57B
1080 CH         .EQ $24
1090 CV         .EQ $25
1100 BASL       .EQ $28
1110 YSAVE      .EQ $2F
1120 ESCAPE.FLAG .EQ $30
1130 MON.MODE   .EQ $31
1140 MON.INVFLG .EQ $32
1150 MON.YSAV   .EQ $34
1160 HOOK.OUT   .EQ $36,37
1170 HOOK.IN    .EQ $38,39
1180 A0L    .EQ $3A
1190 A0H    .EQ $3B
1200 A1L    .EQ $3C
1210 A1H    .EQ $3D
1220 A2L    .EQ $3E
1230 A2H    .EQ $3F
1240 *--------------------------------
1250 *    ProDOS USES $40-4F
1260 *--------------------------------
1270 A3L    .EQ $40
1280 A3H    .EQ $41
1290 A4L    .EQ $42
1300 A4H           .EQ $43
1310 *--------------------------------
1320                     .DUMMY
1330                     .OR $50
1340 *--------------------------------
1350 *
1360 *   Following needed at all times
1370 *
1380 *--------------------------------
1390 SCREEN.WIDTH        .BS 1
1400 INFLAG              .BS 1
1410 LO.MEM              .BS 2     START OF SYMBOL TABLE
1420 EOT                 .BS 2     END OF SYMBOL TABLE
1430 PP                  .BS 2     START OF SOURCE PROGRAM
1440 HI.MEM              .BS 2     END OF SOURCE CODE
1450 *--------------------------------
1460 PAGE.NUMBER         .BS 2
1470 PAGE.LENGTH         .BS 1     =0 means no titles
1480 LINE.COUNT          .BS 1
1490 DGTCNT              .BS 1
1500 INCREMENT.VALUE     .BS 2     FOR AUTO-LINE-NUMBERING (INIT=10)
1510 CURLNO              .BS 2     NUMBER OF LAST-SUBMITTED LINE (INIT=990)
1520 PASS                .BS 1     PASS NUMBER (0=PASS 1, 1=PASS 2)
1530 CHAR.PNTR           .BS 1
1540 CURRENT.CHAR        .BS 1     CURRENT CHARACTER FROM 'GNC'
1550 CURRENT.MAJOR.LABEL .BS 2     PNTR TO CURRENT MAJOR LABEL
1560 EXP.NEW             .BS 1    NEW EXPRESSION FLAG
1570 STPNTR              .BS 2    SYMBOL TABLE WORKING POINTER
1580 TPTR                .BS 2    SYMBOL TABLE TEMP POINTER
1590 BASE.INDEX          .BS 1    used in EXPR
1600 LC.MODE             .BS 1
1610 EXP.VALUE           .BS 4
1620 EXP.VALUE64         .BS 4
1630 SYM.VALUE           .BS 4
1640 EXP.UNDEF           .BS 1    UNDEFINED TERM FLAG
1650 EMIT.COLUMN         .BS 1    KEEPS TRACK OF COLUMN FOR EMIT
1660 ORGN                .BS 4
1670 RPTCHR              .BS 1    (NML, NTKN)
1680 RPTCNT              .BS 1    (NML, NTKN)
1690 PNTR                .BS 2    SEARCH STRING PNTR
1700 INSAVE              .BS 8
1710 *--------------------------------
1720 CALL.NUM            .BS 2    CURRENT MACRO CALL NUMBER
1730 MACLBL              .BS 2
1740 CONV.CTRL           .BS 1    CONTROL FLAG INSIDE CONVERT.LINE.NUMBER
1750 MACRO.LEVEL         .BS 1
1760 PARAM.PNTR          .BS 1
1770 PARAM.CNT           .BS 1
1780 *--------------------------------
1790 PROMPT.FLAG         .BS 1    NULL, "H", OR "I"
1800 HIDE.HIMEM          .BS 2    SAVES HIMEM DURING "HIDE"
1810 CURRENT.LINE.NUMBER .BS 2
1820 LF.ALL              .BS 1    =0 TO LIST, <0 TO NOT LIST
1830 LF.MACRO            .BS 1    =0 TO LIST MACRO EXPANSIONS
1840 FLAG.SPEED          .BS 1
1850 DLIM                .BS 1   ".AS" DELIMITER, also ASM
1860 SRCP                .BS 2    POINTER TO CURRENT SOURCE LINE
1870 ENDP                .BS 2    POINTER TO END OF LINE RANGE
1880 EXP.FWDREF          .BS 1
1890 AUTOLN.FLAG         .BS 1    +=MANUAL, -=AUTO LINE NUMBERS
1900 LINE.START          .BS 2
1910 LINE.END            .BS 2
1920 *--------------------------------
1930 ZP.COMMON  .EQ *
1940 *--------------------------------
1950 *
1960 *   Variables used only during SPECIFIC commands
1970 *
1980 *--------------------------------
1990 BLKSIZ              .BS 1    used in MOVE.TEXT.UP and MOVE.TEXT.DOWN
2000 MOVE.DISTANCE       .BS 2    used in NML, COPY, and MOVE.TEXT.UP
2010 AUTO.FLAG           .BS 1    +=VERIFY, -=AUTO REPLACE
2020 CHANGE.CNT          .BS 1    # OF REPLACEMENTS IN THIS LINE
2030 ED.FCOL             .BS 1
2040 ED.FKEY             .BS 1
2050 ED.PNTR             .BS 1
2060 ED.BEGLIN           .BS 1
2070 TEXT.OPTIONS        .BS 1     used in TEXT command only
2080 REPLACE.LENGTH      .BS 1
2090 SOURCE.LENGTH       .BS 1
2100 WBUF.LENGTH         .BS 1
2110 KEY.PNTR            .BS 2    USED IN FIND, REPLACE
2120 BUF.PNTR            .BS 2    USED IN FIND, REPLACE
2130 KEY.ADDR            .BS 2    SEARCH KEY ADDRESS
2140 MATCH.END           .BS 1
2150 LC.FLAG             .BS 1    +=AS IS, -=ACCEPT BOTH CASES
2160 *--------------------------------
2170        .OR ZP.COMMON
2180 *--------------------------------
2190 *
2200 *   Variables used only during Assembly
2210 *
2220 *--------------------------------
2230 SEARCH.KEY          .BS 3    USED BY OPCODE SEARCH ROUTINE
2240 OPTBL.PNTR          .BS 2    USED BY OPCODE SEARCH ROUTINE
2250 DO.INDEX            .BS 1    DO level: =0 if empty, else 1-63
2260 DO.STACK            .BS 8    64 bits, =1 if true
2270 DO.SKIP.CNT         .BS 1    COUNTS .DO NESTS WHEN SKIPPING
2280 NYBBLE.FLAG         .BS 1    .AC DIRECTIVE
2290 BYTE                .BS 1    .AC DIRECTIVE
2300 PHASE.FLAG          .BS 1    +=NORMAL, -=IN PHASE
2310 DUMMY.FLAG          .BS 1    +=NORMAL, -=IN DUMMY SECTION
2320 TF.FLAG             .BS 1
2330 TRGT                .BS 2    TARGET ADDRESS
2340 MACSTK              .BS 2    MACRO STACK POINTER
2350 ERROR.COUNT         .BS 2
2360 *--------------------------------
2370 OBJ.BYTE            .BS 1
2380 ADDR.LENGTH         .BS 1
2390 LF.CONDITIONAL      .BS 1    =0 TO LIST FALSE SETS
2400 LF.XTRA.BYTES       .BS 1    =0 TO LIST XTRA BYTES ON XTRA LINES
2410 EMIT.MARGIN         .BS 1    COLUMN FOR LINE NUMBER TO START IN
2420 MACRO.SAVEX         .BS 1
2430 DUMMY.ORGN          .BS 4
2440 ORIGIN.SAVE         .BS 4
2450 FLAG.MA             .BS 1
2460 CALL.CNTR           .BS 2    TOTAL # OF MACRO CALLS
2470 *--------------------------------
2480 *---ONLY IN .BS DIRECTIVE--------
2490 BS.COUNT            .BS 2    # BYTES TO RESERVE
2500 *---ONLY IN .AS & .AT DIRECTIVES
2510 AS.HIBIT            .BS 1    BIT 7 VALUE FOR .AS/.AT
2520 AT.HIBIT            .BS 1    BIT 7 TOGGLE FOR LAST BYTE BIT 7
2530 *--------------------------------
2540 *
2550 *---$EB reserved for ECHO TEXTALKER software---
2560 *
2570 *---$F0-FF reserved for ASM.PARTICULAR---
2580 *
2590 *--------------------------------
2600                     .ED
2610  .PG
2620 *--------------------------------
2630 *      CHARACTER CODES
2640 *--------------------------------
2650 CHR.CTRL.I .EQ $89
2660 CHR.RETURN .EQ $8D
2670 CHR.BLANK  .EQ $A0
2680 CHR.DOLLAR .EQ $A4
2690 CHR.STAR   .EQ $AA
2700 CHR.DASH   .EQ $AD
2710 CHR.PERIOD .EQ $2E
2720 CHR.BSLASH .EQ $DC
2730 *--------------------------------
2740 *      MISCELLANEOUS SYMBOLS
2750 *--------------------------------
2760 SYMBOL     .EQ $0100    SYMBOL PACK AREA
2770 HSHTBL     .EQ $0130    HASH POINTER TABLE
2780 KBUF       .EQ $0170 - $01BF  KEY STRING
2790 WBUF       .EQ $0200    WORKING BUFFER
2800 WBUF.MAX   .EQ 248    AND ITS LENGTH
2810 PATHNAME   .EQ $2CE   (LAST 50 BYTES)
2820 *--------------------------------
2830 *      ROM-BASED ROUTINES
2840 *--------------------------------
2850 MON.PRNTAX .EQ $F941
2860 MON.PRBL2  .EQ $F94A  PRINT (X) BLANKS
2870 MON.INIT   .EQ $FB2F  TEXT MODE, FULL WINDOW
2880 MON.ADVANC .EQ $FBF4
2890 MON.BS     .EQ $FC10
2900 MON.UP     .EQ $FC1A
2910 MON.VTAB   .EQ $FC22
2920 MON.CLREOP .EQ $FC42
2930 MON.HOME   .EQ $FC58
2940 MON.LF     .EQ $FC66
2950 MON.CLREOL .EQ $FC9C
2960 MON.DELAY  .EQ $FCA8
2970 MON.RDKEY  .EQ $FD0C  READ NEXT CHAR
2980 MON.READCH .EQ $FD18
2990 MON.PHEX   .EQ $FDDA  PRINT BYTE IN HEX
3000 MON.COUT   .EQ $FDED
3010 MON.BL1    .EQ $FE00
3020 MON.SETKBD     .EQ $FE89
3030 MON.SETVID     .EQ $FE93
3040 MON.OUTPORT    .EQ $FE95  SET NEW PR#N OUTPUT
3050 MON.BELL   .EQ $FF3A  RING THE BELL
3060 MON.RTS    .EQ $FF58     ONLY AN "RTS"
3070 MNTR       .EQ $FF69     CALL-151 ENTRY INTO MONITOR
3080 MON.GETNUM .EQ $FFA7
3090 MON.TOSUB  .EQ $FFBE
3100 MON.CHRTBL .EQ $FFCC  MONITOR COMMAND CHAR TABLE
3110 *--------------------------------
3120 MON.RESET .EQ $3F2 THRU 3F4
3130 *--------------------------------
3140        .MA INCD
3150        INC ]1
3160        BNE :1
3170        INC ]1+1
3180 :1
3190        .EM
3200 *--------------------------------
3210 RDMAIN .EQ $C002
3220 RDAUX  .EQ $C003
3230 RDROM  .EQ $C082
3240 RDRAM  .EQ $C083
3250 WRMAIN .EQ $C004
3260 WRAUX  .EQ $C005
3270 AUX.CODE .EQ $DF00
3280 *--------------------------------
3290        .MA SYM
3300        .DO AUXMEM
3310        JSR ]1.]2
3320        .ELSE
3330        ]1 (]2),Y
3340        .FIN
3350        .EM
3360 *--------------------------------
