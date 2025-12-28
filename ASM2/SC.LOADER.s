
1000 *SAVE SC.LOADER
1010 *--------------------------------
1020 SPTR   .EQ $00
1030 DPTR   .EQ $02
1040 *--------------------------------
1050 MLI.UNIT            .EQ $BF30
1060 MLI.BITMAP          .EQ $BF58
1070 MLI.PREFIX.FLAG     .EQ $BF9A
1080 *--------------------------------
1090 MON.CROUT .EQ $FD8E
1100 SETNORM .EQ $FE84
1110 *--------------------------------
1120 *   sys file   execution
1130 *   ---------  ---------
1140 *   2000-21FF             LOADER
1150 *   2200-4AFF  8000-A8FF  S-C MACRO ASSEMBLER with 40-col driver
1160 *              A900-A9FF  additional space for longer drivers
1170 *   4B00-5FFF  AA00-BEFF  S-C ProDOS Interface
1180 *   6000-60FF  A800-A8FF  //E 80-COLUMN DRIVER
1190 *   6100-61FF  A800-A8FF  STB80 DRIVER
1200 *   6200-63FF  A800-A9FF  VIDEX VIDEOTERM DRIVER
1210 *   6400-65FF  A800-A9FF  VIDEX ULTRATERM DRIVER
1220 *   6600-71FF  D400-DFFF  ASM PARTICULAR
1230 *--------------------------------
1240 *   BLOAD SCASM          (loader and Macro and 40-col driver)
1250 *   BLOAD B.SCI          (ProDOS Interpreter)
1260 *   BLOAD B.IO.TWO.E     (//E 80-COLUMN DRIVER)
1270 *   BLOAD B.IO.STB80
1280 *   BLOAD B.IO.VIDEX
1290 *   BLOAD B.IO.ULTRA
1300 *   BSAVE SCASM.SYS,A$2000,L$4600
1310 *--------------------------------
1320        .MA MOVE
1330        LDA /]1      DESTINATION
1340        LDY /]2      SOURCE BEGINNING
1350        LDX /]3-]2+255   # PAGES
1360        JSR MOVE
1370        .EM
1380 *--------------------------------
1390 STARTUP.SC.MACRO
1400        JMP LOAD.SC
1410 *--------------------------------
1420 DRIVER.FLAG .HS 00
1430 *--------------------------------
1440 LOAD.SC
1450        JSR SELECT.DRIVER
1460        >MOVE $AA00,$4B00,$5FFF
1470        >MOVE $8000,$2200,$4AFF
1480        LDA $C083
1490        LDA $C083
1500        >MOVE $D400,$6600,$71FF
1510        LDA $C082
1520        JSR LOAD.DRIVER
1530 *--------------------------------
1540 *---GET SCREEN TO NORMAL 40------
1550 *      LDA #$15     CTRL-U, TURNS OFF 80-COLUMN
1560 *      JSR MON.COUT
1570 *      JSR SETNORM
1580 *      JSR MON.INIT
1590 *      JSR MON.HOME
1600 *---ESTABLISH RAM BITMAP---------
1610        LDX #BITMAP.SIZE-1
1620 .2     LDA MY.BITMAP,X
1630        STA MLI.BITMAP,X
1640        DEX
1650        BPL .2
1660 *---BUILD $3D0-3FF---------------
1670        LDX #5
1680 .3     LDA IMAGE.3D0,X
1690        STA $3D0,X
1700        DEX
1710        BPL .3
1720        LDX #10
1730 .4     LDA IMAGE.3F0,X
1740        STA $3F0,X
1750        DEX
1760        BPL .4
1770 *---Establish HIMEM page---------
1780        LDA #$74
1790        STA SCI.HIMEM.PAGE
1800        STA SCI.BUFFER.PAGES+2   EXEC BUFFER
1810        CLC
1820        ADC #4
1830        STA SCI.BUFFER.PAGES     BUF 0
1840        ADC #4
1850        STA SCI.BUFFER.PAGES+1   BUF 1
1860 *---SET A NULL PREFIX------------
1870        LDA #0
1880        STA MLI.PREFIX.FLAG
1890 *---SET SLOT/DRIVE DEFAULTS------
1900        LDA MLI.UNIT
1910        LSR
1920        LSR
1930        LSR
1940        LSR
1950        CMP #$08
1960        AND #$07
1970        STA SCI.SLOT
1980        LDA #1
1990        ADC #0
2000        STA SCI.DRIVE
2010 *--------------------------------
2020 IIGS   SEC
2030        JSR $FE1F
2040        BCS .2       ...NOT IIGS
2050 *--------------------------------
2060        LDY #GS.NUM-1
2070 .1     LDA GS.NEW,Y
2080        STA FAKE.MONITOR,Y
2090        DEY
2100        BPL .1
2110 *---START UP ProDOS--------------
2120 .2     JMP $8000
2130 *--------------------------------
2140 GS.NEW LDA #" "     COVER UP THE DOLLAR SIGN
2150        STA WBUF
2160        LDA WBUF-1,X LOOK FOR "HEXNUM=" COMMAND
2170        CMP #"="
2180        BEQ .1       ...YES, DON'T APPEND " Q"
2190        LDA #" "
2200        STA WBUF,X   APPEND " Q"
2210        LDA #"Q"
2220        STA WBUF+1,X
2230 .1     JMP $FF70
2240 GS.NUM .EQ *-GS.NEW
2250 *--------------------------------
2260 IMAGE.3D0
2270        JMP SCI.STARTUP    $3D0
2280        JMP SCI.STARTUP    $3D3
2290 IMAGE.3F0
2300        .DA $FA59             'BRK' VECTOR
2310        .DA SCI.STARTUP,#$BE^$A5    RESET VECTOR
2320        JMP SCI.RTS             &-VECTOR
2330        JMP SCI.RTS             Y-VECTOR
2340 *--------------------------------
2350 MY.BITMAP
2360        .HS C3.00.00.00.00.00.00.00  0000-3FFF
2370        .HS 00.00.00.00.00.00.00.00  4000-7FFF
2380        .HS FF.FF.FF.FF.FF.FF.FF.F3  8000-BFFF
2390 BITMAP.SIZE .EQ *-MY.BITMAP
2400 *--------------------------------
2410 SELECT.DRIVER
2420        LDY DRIVER.FLAG
2430        BNE .3       ...LOAD SPECIFIC DRIVER
2440        LDA $FBB3
2450        CMP #6
2460        BEQ .3       ...//E OR //C, USE //E DRIVER
2470 *---Display menu-----------------
2480        JSR MON.HOME
2490        LDY #0
2500 .1     LDA MENU,Y
2510        BEQ .2
2520        JSR MON.COUT
2530        INY
2540        BNE .1
2550 *---Get choice-------------------
2560 .2     JSR MON.RDKEY
2570        EOR #$B0
2580        BEQ .2
2590        CMP #5
2600        BCS .2
2610        TAY
2620        ORA #$B0
2630        JSR MON.COUT
2640        JSR MON.CROUT
2650 *---(Y) is selected driver-------
2660 .3     STY DRIVER.FLAG
2670        RTS
2680 *--------------------------------
2690 LOAD.DRIVER
2700        LDY DRIVER.FLAG
2710        LDA DRIVER.ADDRS,Y
2720        BEQ .4       ...40-COLUMN, RETURN NOW
2730        TAY
2740        LDA /$A800
2750        LDX #2
2760        JSR MOVE
2770 .4     RTS
2780 *--------------------------------
2790 *      MOVE (X) PAGES FROM YY00 TO AA00
2800 *--------------------------------
2810 MOVE
2820        STA DPTR+1
2830        STY SPTR+1
2840        LDY #0
2850        STY DPTR
2860        STY SPTR
2870 .1     LDA (SPTR),Y
2880        STA (DPTR),Y
2890        INY
2900        BNE .1
2910        INC SPTR+1  
2920        INC DPTR+1  
2930        DEX
2940        BNE .1
2950        RTS
2960 *--------------------------------
2970 DRIVER.ADDRS
2980        .HS 60...00...62...64...61
2990 *          //E  40   VID  ULT  STB
3000 *--------------------------------
3010 MENU
3020        .AS -/S-C MACRO ASSEMBLER 2.0 (PRODOS)/
3030        .HS 8D8D
3040        .AS -/1 -- STANDARD 40-COLUMN/
3050        .HS 8D
3060        .AS -/2 -- VIDEX VIDEOTERM/
3070        .HS 8D
3080        .AS -/3 -- VIDEX ULTRATERM/
3090        .HS 8D
3100        .AS -/4 -- STB-80/
3110        .HS 8D8D
3120        .AS -/WHICH?  /
3130        .HS 00
3140 *--------------------------------
3150        .AS /<<>>/
3160 *--------------------------------
