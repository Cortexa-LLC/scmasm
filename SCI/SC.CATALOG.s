
1000 *SAVE SC.CATALOG 
1010 *--------------------------------
1020 *   CATALOG COMMAND
1030 *--------------------------------
1040 CAT
1050        LDA #39
1060        .HS 2C       SKIP OVER TWO BYTES
1070 CATALOG
1080        LDA #79
1090        STA CAT.WIDTH
1100        LDA #0       CLEAR ACCUMULATED BLOCKS COUNTER
1110        STA BLOCKS
1120        STA BLOCKS+1
1130        LDA FBITS         TEST FOR TYPE AND PATHNAME
1140        AND #$05
1150        LSR               PATHNAME BIT INTO CARRY
1160        BNE .1            ...TYPE STATED
1170        STA VAL.T         SET T=0, LIST ALL TYPES
1180 .1     BCS .2            ...PATH GIVEN
1190        JSR GET.FILE.INFO        NONE STATED, GET PREFIX
1200        BCS .8            ...ERROR
1210 *---GET DIRECTORY----------------
1220 .2     JSR OPEN.READ.DIR.HEADER
1230        BCS .8            ...ERROR
1240        LDY #0       Print directory pathname
1250 .15    LDA PATHNAME.ONE.BUFFER+1,Y
1260        ORA #$80
1270        JSR COUT
1280        INY
1290        CPY PATHNAME.ONE.BUFFER
1300        BCC .15
1310        JSR CROUT
1320 *---PRINT TITLES-----------------
1330        LDA #Q.DIRHDR
1340        JSR FIND.AND.PUT.MSG.IN.WBUF
1350        JSR PRINT.CATALOG.LINE
1360 *---IF NO MORE FILES, FINISHED---
1370 .3     LDA FILE.COUNT    ANY FILES LEFT?
1380        ORA FILE.COUNT+1
1390        BEQ .7            ...NO, FINISHED
1400 *---NEXT FILE DESCRIPTION--------
1410        JSR READ.NEXT.ENTRY
1420        BCS .8            ...ERROR
1430        LDA VAL.T         CHECK IF WE LIKE THIS TYPE
1440        BEQ .4            ...WE LIKE THEM ALL
1450        CMP DIRBUF+16     FILE TYPE
1460        BNE .5            ...NO, SKIP OVER IT
1470 .4     JSR FORMAT.CAT.ENTRY
1480        JSR PRINT.CATALOG.LINE        PRINT IT
1490 *---CHECK FOR PAUSE/ABORT--------
1500 .5     JSR CHECK.KEY     SEE IF KEYPRESS
1510        BMI .3            ...NO, CONTINUE CATALOG
1520        BEQ .7            ... or , abort
1530 *--- or , so abort------
1540 .6     JSR CHECK.KEY
1550        BMI .6            WAIT FOR KEY
1560        BNE .3            ...NOT CR OR ESC, CONTINUE
1570 *--- or , abort---------
1580 .7     LDX CAT.INDEX
1590        LDA FILE.REFNUMS,X
1600        JSR CLOSE.ONE.FILE
1610        BCS .8       ...ERROR
1620        JMP FREE.BLOCKS FORMAT BLOCKS FREE ETC.
1630 .8     RTS
1640 *--------------------------------
1650 CHECK.KEY
1660        LDA $C000    SEE IF KEYSTROKE
1670        BPL .1       ...NO
1680        STA $C010    ...YES, CLEAR STROBE
1690 .1     EOR #$8D     SET .EQ. IF 
1700        BEQ .2       ...YES
1710        EOR #$8D^$9B       OR IF 
1720 .2     RTS          .MI. IF NO KEY
1730 *--------------------------------
1740 *   FORMAT BLOCKS FREE/INUSE
1750 *--------------------------------
1760 FREE.BLOCKS
1770        JSR ZERO.ACCUM
1780        JSR BLANK.WBUF
1790        LDA #Q.BLOCKS.ABOVE
1800        JSR FIND.AND.PUT.MSG.IN.WBUF
1810        LDA BLOCKS
1820        LDX BLOCKS+1
1830        LDY #24
1840        JSR CONVERT.TO.DECIMAL
1850        JSR PRINT.MESSAGE
1860 *--------------------------------
1870        LDA #PATHNAME.ONE.BUFFER+1  set up ONLINE call
1880        STA MISC.PARMS+2            to read volume name
1890        LDA /PATHNAME.ONE.BUFFER+1
1900        STA MISC.PARMS+3
1910        LDA UNIT
1920        STA MISC.PARMS+1
1930        JSR MLI.C5   ONLINE
1940        BCS .1           ...ERROR
1950 *---Setup GET FILE INFO call-----
1960        LDA PATHNAME.ONE.BUFFER+1
1970        AND #$0F
1980        TAX
1990        INX
2000        STX PATHNAME.ONE.BUFFER
2010        LDA #"/"
2020        STA PATHNAME.ONE.BUFFER+1
2030        JSR GET.FILE.INFO
2040        BCS .1           ...ERROR
2050 *---Format the bottom line-------
2060        JSR BLANK.WBUF
2070        LDA #Q.BLOCKS
2080        JSR FIND.AND.PUT.MSG.IN.WBUF
2090 *---Total Blocks in Volume-------
2100        LDA GET.SET.PARMS+5
2110        LDX GET.SET.PARMS+6
2120        LDY #51
2130        JSR CONVERT.TO.DECIMAL
2140 *---Blocks Used in Volume--------
2150        LDA GET.SET.PARMS+8
2160        LDX GET.SET.PARMS+9
2170        LDY #24
2180        JSR CONVERT.TO.DECIMAL
2190 *---Blocks Free in Volume--------
2200        LDA GET.SET.PARMS+5
2210        SEC
2220        SBC GET.SET.PARMS+8
2230        PHA
2240        LDA GET.SET.PARMS+6
2250        SBC GET.SET.PARMS+9
2260        TAX
2270        PLA
2280        LDY #37
2290        JSR CONVERT.TO.DECIMAL
2300        JSR PRINT.CATALOG.LINE
2310        CLC
2320 .1     RTS
2330 *--------------------------------
2340 *   OPEN/READ DIRECTORY HEADER
2350 *--------------------------------
2360 OPEN.READ.DIR.HEADER
2370        JSR ALLOCATE.UPPER.BUFFER
2380        STX CAT.INDEX
2390        LDX #$0F     IS STORAGE TYPE = VOL DIR?
2400        CPX GET.SET.PARMS+7
2410        BNE .1                ...NO
2420        STX GET.SET.PARMS+4   ...YES, MAKE TYPE = DIR
2430 .1     LDA #$01              FILE MUST BE READABLE
2440        JSR OPEN.DIRECTORY
2450        BCS .3       ...ERROR
2460  
2470        LDX CAT.INDEX
2480        STA FILE.REFNUMS,X
2490        LDA #DIRBUF
2500        STA READ.WRITE.PARMS+2
2510        LDA /DIRBUF
2520        STA READ.WRITE.PARMS+3
2530        LDA #$2B
2540        STA READ.WRITE.PARMS+4
2550        STA MISC.PARMS+2
2560        LDA #0
2570        STA READ.WRITE.PARMS+5
2580        JSR MLI.CA   READ
2590        BCS .3
2600        LDX #3
2610 .2     LDA DIRBUF+35,X    ENTRY LENGTH, ENTRIES/BLOCK,
2620        STA ENTRY.LENGTH,X and FILE COUNT
2630        DEX
2640        BPL .2
2650        LDA #1
2660        STA ENTRY.COUNTER
2670 .3     RTS
2680 *--------------------------------
2690 *   READ NEXT DIRECTORY ENTRY
2700 *--------------------------------
2710 READ.NEXT.ENTRY
2720 .1     LDY ENTRY.COUNTER
2730        CPY ENTRIES.PER.BLOCK
2740        BCC .2
2750 *---Skip ahead remainder bytes---
2760        LDA #4
2770        SBC MISC.PARMS+2
2780        STA READ.WRITE.PARMS+4
2790        JSR MLI.CA
2800        BCS .4       ...ERROR
2810        LDY #0
2820        LDA #4
2830        STA MISC.PARMS+2
2840 *---Read a file description------
2850 .2     INY          NEXT ENTRY
2860        STY ENTRY.COUNTER
2870        LDA ENTRY.LENGTH
2880        STA READ.WRITE.PARMS+4
2890        ADC MISC.PARMS+2
2900        STA MISC.PARMS+2
2910        JSR MLI.CA   READ
2920        BCS .4       ...ERROR
2930 *---Check if deleted file--------
2940        LDA DIRBUF
2950        AND #$F0
2960        BEQ .1       ...deleted
2970 *---Count the file---------------
2980        LDA FILE.COUNT
2990        BNE .3
3000        DEC FILE.COUNT+1
3010 .3     DEC FILE.COUNT
3020 .4     RTS
3030 *--------------------------------
3040 *   FORMAT CATALOG ENTRY LINE
3050 *--------------------------------
3060 FORMAT.CAT.ENTRY
3070        JSR BLANK.WBUF
3080        LDA DIRBUF   LENGTH OF FILENAME
3090        AND #$0F
3100        TAY
3110 .1     LDA DIRBUF,Y
3120        ORA #$80
3130        STA WBUF+7,Y
3140        DEY
3150        BNE .1
3160        STY ACCUM+2
3170 *---GET FILE TYPE----------------
3180        LDA DIRBUF+16     FILE TYPE
3190        LDX #LAST.FILE.TYPE
3200        LDY #3            POINT INTO WBUF
3210 .2     CMP FILE.TYPES,X
3220        BEQ .3            ...MATCH!
3230        DEX
3240        DEX
3250        DEX
3260        DEX
3270        BPL .2
3280        JSR CONVERT.TO.HEX
3290        JMP .6
3300 .3     DEX
3310        LDA FILE.TYPES,X
3320        JSR STUFF.WBUF.AND.BACKUP
3330        BNE .3
3340 *---SKIP IF 40-COLUMN------------
3350        BIT CAT.WIDTH
3360        BVC .7
3370 *---Display AuxType--------------
3380        LDY #"R"     Use "R=" if type TXT
3390        LDA DIRBUF+16     FILE TYPE
3400        CMP #$04
3410        BEQ .5       ...it is TXT
3420        CMP #$06     Use "A=" if type BIN
3430        BNE .6       ...not BIN, just show $xxxx
3440        LDY #"A"     ...BIN
3450 .5     STY WBUF+73
3460        LDA #"="
3470        STA WBUF+74
3480 .6     LDY #78
3490        LDA DIRBUF+31     AUXTYPE
3500        JSR CONVERT.TO.HEX
3510        LDA DIRBUF+32       "
3520        JSR CONVERT.TO.HEX
3530 *---Show file length-------------
3540        LDA DIRBUF+23     EOF MARK MSB
3550        STA ACCUM+2
3560        LDA DIRBUF+21     EOF MARK
3570        LDX DIRBUF+22      "   "
3580        LDY #70
3590        JSR CONVERT.TO.DECIMAL
3600 *---CREATION DATE/TIME-----------
3610        LDX #$18     OFFSET IN DIRBUF
3620        LDY #61      OFFSET IN WBUF
3630        JSR FORMAT.DATE.AND.TIME
3640 *---Blocks in the file-----------
3650 .7     LDY #27
3660        LDA DIRBUF+19     BLOCKS IN USE
3670        LDX DIRBUF+20       "
3680        JSR CONVERT.TO.DECIMAL
3690        CLC
3700        LDA BLOCKS
3710        ADC DIRBUF+19
3720        STA BLOCKS
3730        LDA BLOCKS+1
3740        ADC DIRBUF+20
3750        STA BLOCKS+1
3760 *---Access code------------------
3770        LDA DIRBUF+30     ACCESS
3780        AND #$C2
3790        CMP #$C2
3800        BEQ .8
3810        LDA #"*"     LOCKED
3820        STA WBUF+1
3830 *---Modified Date/Time-----------
3840 .8     LDX #$21     OFFSET IN DIRBUF
3850        LDY #44      OFFSET IN WBUF
3860 *--------------------------------
3870 *   FORMAT DATE & TIME
3880 *      --MSB--- --LSB---
3890 *      YYYYYYYM MMMDDDDD
3900 *--------------------------------
3910 FORMAT.DATE.AND.TIME
3920        LDA DIRBUF,X      MMMDDDDD
3930        AND #$1F          000DDDDD
3940        BEQ .1            ...DAY=0, NO DATE
3950        STA DAY
3960        LDA DIRBUF+1,X    YYYYYYYM
3970        LSR               0YYYYYYY
3980        STA YEAR
3990        CMP #100
4000        BCS .1            ...YEAR>99, NO DATE
4010        LDA DIRBUF+1,X    YYYYYYYM
4020        LSR               M INTO CARRY
4030        LDA DIRBUF,X      MMMDDDDD
4040        ROL               MMDDDDDM M
4050        ROL               MDDDDDMM M
4060        ROL               DDDDDMMM M
4070        ROL               DDDDMMMM
4080        AND #$0F          0000MMMM
4090        BEQ .1            ...MONTH=0, NO DATE
4100        CMP #13
4110        BCC .3            ...MONTH=1...12, GOOD
4120 *---Format -------------
4130 .1     TYA
4140        SEC
4150        SBC #6       BACK UP OVER TIME SLOT
4160        TAY
4170        LDX #8
4180 .2     LDA NO.DATE.MSG,X
4190        JSR STUFF.WBUF.AND.BACKUP
4200        DEX
4210        BPL .2
4220        RTS
4230 *---Format date, time------------
4240 .3     STA MONTH
4250        LDA DIRBUF+3,X    HOURS
4260        PHA
4270        LDA DIRBUF+2,X    MINUTES
4280        LDX #0            HIGH BYTE
4290        CMP #60           IF > 59, USE 0
4300        BCC .4            0...59
4310        TXA
4320 .4     JSR CONVERT.DECIMAL.TWO.DIGITS
4330        LDA #":"          SEPARATE WITH ":"
4340        STA WBUF+2,Y
4350        PLA               HOURS
4360        LDX #0            HIGH BYTE
4370        CMP #24           IF > 24, USE 0
4380        BCC .5            0...23
4390        TXA
4400 .5     JSR CONVERT.DECIMAL.TWO.DIGITS
4410        LDA YEAR
4420        JSR CONVERT.DECIMAL.TWO.DIGITS
4430        LDX MONTH
4440        LDA MONTH.NAMES-1+24,X
4450        JSR STUFF.WBUF.AND.BACKUP
4460        LDA MONTH.NAMES-1+12,X
4470        JSR STUFF.WBUF.AND.BACKUP
4480        LDA MONTH.NAMES-1,X
4490        JSR STUFF.WBUF.AND.BACKUP
4500        LDA #"-"
4510        STA WBUF+5,Y
4520        JSR STUFF.WBUF.AND.BACKUP
4530        LDA DAY
4540        LDX #0       HIGH BYTE
4550 *      JMP CONVERT.TO.DECIMAL
4560 *--------------------------------
4570 *   CONVERT TO DECIMAL
4580 *--------------------------------
4590 CONVERT.TO.DECIMAL
4600        STX ACCUM+1
4610        STA ACCUM
4620 .1     JSR DIVIDE.ACCUM.BY.TEN
4630        ORA #$B0
4640        JSR STUFF.WBUF.AND.BACKUP
4650        LDA ACCUM
4660        ORA ACCUM+1
4670        ORA ACCUM+2
4680        BNE .1
4690        RTS
4700 *--------------------------------
4710 *   CONVERT 2 DIGIT NUMBER
4720 *--------------------------------
4730 CONVERT.DECIMAL.TWO.DIGITS
4740        CLC
4750        ADC #100     FORCE TWO DIGITS TO PRINT
4760        JSR CONVERT.TO.DECIMAL
4770        LDA #" "     COVER UP THE "1"
4780        INY
4790 *--------------------------------
4800 STUFF.WBUF.AND.BACKUP
4810        STA WBUF+1,Y
4820        DEY
4830        RTS
4840 *--------------------------------
4850 *   CONVERT TO HEX
4860 *--------------------------------
4870 CONVERT.TO.HEX
4880        PHA
4890        AND #$0F
4900        JSR .1
4910        PLA
4920        LSR
4930        LSR
4940        LSR
4950        LSR
4960 .1     ORA #$B0
4970        CMP #$BA
4980        BCC .2
4990        ADC #6
5000 .2     JSR STUFF.WBUF.AND.BACKUP
5010        LDA #"$"
5020        STA WBUF+1,Y
5030        RTS
5040 *--------------------------------
5050 *   DIVIDE ACCUM BY TEN
5060 *--------------------------------
5070 *   DIVIDE 24-BIT VALUE IN ACCUM BY TEN
5080 *      RETURN REMAINDER IN A-REG
5090 *--------------------------------
5100 DIVIDE.ACCUM.BY.TEN
5110        LDX #24      24 BITS IN DIVIDEND
5120        LDA #0       START WITH REM=0
5130 .1     JSR SHIFT.ACCUM.LEFT
5140        ROL
5150        CMP #10
5160        BCC .2       ...STILL < 10
5170        SBC #10
5180        INC ACCUM    QUOTIENT BIT
5190 .2     DEX          NEXT BIT
5200        BNE .1
5210        RTS
5220 *--------------------------------
5230 BLANK.WBUF
5240        LDA #" "
5250        LDY #79
5260 .1     JSR STUFF.WBUF.AND.BACKUP
5270        BPL .1
5280        RTS
5290 *--------------------------------
5300 NOW    JSR GP.MLI
5310        .DA #$82,0000
5320        JSR BLANK.WBUF
5330        LDX #4
5340 .1     LDA GP.DATE-1,X
5350        STA DIRBUF-1,X
5360        DEX
5370        BNE .1
5380        LDY #15
5390        JSR FORMAT.DATE.AND.TIME
5400        LDA #20
5410        STA CAT.WIDTH
5420 ***    JMP PRINT.CATALOG.LINE
5430 *--------------------------------
5440 PRINT.CATALOG.LINE
5450        LDX CAT.WIDTH
5460        LDA #$8D
5470        STA WBUF+1,X
5480        JSR PRINT.MESSAGE
5490        CLC          because a SEC would indicate ERROR
5500        RTS
5510 *--------------------------------
