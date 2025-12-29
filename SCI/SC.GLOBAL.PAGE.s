
1000 *SAVE SC.GLOBAL.PAGE
1010 *--------------------------------
1020             JMP WARM.DOS
1030             JMP PARSE.COMMAND
1040 SCI.USER.CMD    JMP GP.RTS   USER COMMAND PARSER
1050             JMP ERROR.HANDLER
1060 PRINT.ERROR JMP ERROR.PRINTER
1070 ERROR.CODE  .HS 00
1080 *--------------------------------
1090 OUTVEC .DA $FDF0,$C100,$C200,$C300,$C400,$C500,$C600,$C700
1100 INVEC  .DA $FD1B,$C100,$C200,$C300,$C400,$C500,$C600,$C700
1110 *--------------------------------
1120 VECOUT .HS F0FD
1130 VECIN  .HS 1BFD
1140 *--------------------------------
1150 VDOSIO .DA 0,0      SAVE HARDWARE VECTOR DURING EXEC, WRITE
1160        .DA 0,0      VSYSIO
1170 *--------------------------------
1180 D.SLOT .HS 06
1190 D.DRIV .HS 01
1200 *--------------------------------
1210 PREGA  .BS 1
1220 PREGX  .BS 1
1230 PREGY  .BS 1
1240 *--------------------------------
1250 F.TRACE             .BS 1  +=TRACE OFF, -=TRACE ON
1260 STATE               .BS 1  0=IMMD, >0=DEFERRED
1270 F.EXEC              .BS 1
1280 F.READ              .BS 1
1290 F.WRITE             .BS 1
1300 F.PREFIX            .BS 1
1310 DIR.FILE.READ.FLAG  .BS 1
1320 *--------------------------------
1330        .HS 00
1340 *--------------------------------
1350 STRINGS.SPACE.COUNT    .BS 1
1360 BUFFERED.WRITE.COUNT   .BS 1
1370 COMMAND.LINE.LENGTH    .BS 1
1380 PREVIOUS.CHAR          .BS 1
1390 OPEN.FILE.COUNT        .BS 1
1400 EXEC.FILE.CLOSING.FLAG .BS 1
1410 CATALOG.LINE.STATE     .BS 1
1420 *--------------------------------
1430 EXTERNAL.COMMAND.HANDLER .BS 2
1440 COMMAND.NAME.LENGTH      .BS 1
1450 COMMAND.NUMBER           .BS 1
1460 *--------------------------------
1470 PBITS  .HS 0000
1480 FBITS  .HS 0000
1490 VAL.A  .HS 0000
1500 VAL.B  .HS 000000
1510 VAL.E  .HS 0000
1520 VAL.L  .HS 0000
1530 VAL.S  .HS 00
1540 VAL.D  .HS 00
1550 VAL.F  .HS 0000
1560 VAL.R  .HS 0000
1570 VAL.V  .HS 00
1580 VAL.AT .HS 0000
1590 VAL.T  .HS 00
1600 VAL.LB .HS 00       PR# OR IN# VALUE
1610 *--------------------------------
1620        .DA PATHNAME.ONE.BUFFER
1630        .DA PATHNAME.TWO.BUFFER
1640 *--------------------------------
1650 MLI.CALLER
1660        STA .2
1670        STX GP.SAVEX
1680        CMP #$CF
1690        BCC .1
1700        LDA #$CE
1710 .1     TAX
1720        LDA MLI.PARM.PNTRS-$C0,X
1730        STA .3
1740        JSR GP.MLI
1750 .2     .HS 00
1760 .3     .DA *
1770        BCC .6
1780        LDX #0
1790 .4     CMP MLI.ERROR.CODES,X
1800        BEQ .5
1810        INX
1820        CPX #19
1830        BCC .4
1840 .5     LDA BI.ERROR.CODES,X 
1850 ***    SEC          (CARRY ALREADY SET)
1860 .6     LDX #*-*
1870 GP.SAVEX .EQ *-1
1880        ORA #0
1890 GP.RTS RTS
1900 *--------------------------------
1910        .HS 00       <<>>
1920 *---CREATE PARMS-----------------
1930 CREATE.PARMS
1940        .HS 07
1950        .DA PATHNAME.ONE.BUFFER
1960        .HS C3.00.0000.00.0000.0000
1970 *---GET & SET PREFIX, DESTROY----
1980 PREFIX.PARMS
1990        .HS 01
2000        .DA PATHNAME.ONE.BUFFER
2010 *---RENAME-----------------------
2020 RENAME.PARMS
2030        .HS 02
2040        .DA PATHNAME.ONE.BUFFER
2050        .DA PATHNAME.TWO.BUFFER
2060 *---GET & SET FILE INFO----------
2070 GET.SET.PARMS
2080        .HS 0A
2090        .DA PATHNAME.ONE.BUFFER
2100        .HS 00.00.0000
2110        .HS 00.0000.0000.0000.0000.0000
2120 *---MISC-------------------------
2130 MISC.PARMS
2140        .HS 02.00.0000
2150        .HS 00
2160 *---OPEN PARMS-------------------
2170 OPEN.PARMS
2180        .HS 03
2190        .DA PATHNAME.ONE.BUFFER
2200        .HS 0000.00
2210 *---SET NEWLINE PARMS------------
2220 NEWLINE.PARMS
2230        .HS 03.00.7F.0D
2240 *---READ & WRITE PARMS-----------
2250 READ.WRITE.PARMS
2260        .HS 04.00.0000.0000.0000
2270 *---CLOSE & FLUSH PARMS----------
2280 CLOSE.FLUSH.PARMS
2290        .HS 01.00
2300 *--------------------------------
2310 *   ADDRESSES OF MLI PARM LISTS FOR EACH CALL $C0-$D3
2320 *      actual address is $BExx
2330 *--------------------------------
2340 MLI.PARM.PNTRS
2350        .DA #CREATE.PARMS      $C0--CREATE
2360        .DA #PREFIX.PARMS      $C1--DESTROY
2370        .DA #RENAME.PARMS      $C2--RENAME
2380        .DA #GET.SET.PARMS     $C3--SFI
2390        .DA #GET.SET.PARMS     $C4--GFI
2400        .DA #MISC.PARMS        $C5--ONLINE
2410        .DA #PREFIX.PARMS      $C6--SPFX
2420        .DA #PREFIX.PARMS      $C7--GPFX
2430        .DA #OPEN.PARMS        $C8--OPEN
2440        .DA #NEWLINE.PARMS     $C9--NEWLINE
2450        .DA #READ.WRITE.PARMS  $CA--READ
2460        .DA #READ.WRITE.PARMS  $CB--WRITE
2470        .DA #CLOSE.FLUSH.PARMS $CC--CLOSE
2480        .DA #CLOSE.FLUSH.PARMS $CD--FLUSH
2490        .DA #MISC.PARMS        $CE--SMARK
2500 *      .DA #MISC.PARMS        $CF--GMARK
2510 *      .DA #MISC.PARMS        $D0--SEOF
2520 *      .DA #MISC.PARMS        $D1--GEOF
2530 *      .DA #MISC.PARMS        $D2--SBUF
2540 *      .DA #MISC.PARMS        $D3--GBUF
2550 *--------------------------------
2560        .AS -/++++/
2570 *--------------------------------
2580 BUFFER.BASES     .HS 78.7C      LOWER/UPPER BUFFERS
2590 EXEC.BUFFER.BASE .HS 74
2600 *--------------------------------
2610        RTS          WAS GET BUFFER
2620        NOP
2630        NOP
2640        RTS          WAS RETURN BUFFER
2650        NOP
2660        NOP
2670        .HS 74       HIMEM PAGE
2680 *--------------------------------
