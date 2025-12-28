
1000 *SAVE SC.COMMAND.PAR
1010 *--------------------------------
1020        .DA COMMAND.TABLE needed for HELP command
1030 *--------------------------------
1040 *   PARSE COMMAND LINE
1050 *--------------------------------
1060 PARSE.COMMAND
1070        JSR SCAN.COMMAND.TABLE
1080        BCS SYNERR2  ...SYNTAX ERROR
1090        LDA #0
1100        STA FBITS
1110        STA FBITS+1
1120        STA PATHNAME.TWO.BUFFER
1130        STA PATHNAME.ONE.BUFFER+1
1140        LDA D.SLOT
1150        STA VAL.S
1160        LDA D.DRIV
1170        STA VAL.D
1180 *---Handle special cases---------
1190        BIT PBITS         Check for PR# or IN#
1200        BVS PARSE.INPR    PR# & IN# commands
1210        BPL .1       ...not CAT(ALOG) or PREFIX
1220        JSR MLI.C7   ...CAT, CATALOG, or PREFIX
1230 *---TEST CHAR AFTER COMMAND------
1240 .1     JSR GET.NEXT.NONBLANK
1250        BNE .2       ...not comma or 
1260        BCC .5       ... already
1270        JMP GET.ANOTHER.PARM
1280 *---Get a pathname---------------
1290 .2     CMP #'/'     MUST START WITH "/" OR LETTER
1300        BEQ .3
1310        CMP #'A'
1320        BCC SYNERR2   ...SYNTAX ERROR
1330 .3     DEX          RE-SCAN THE FIRST CHAR OF PATH
1340        LDY #0
1350 .4     JSR GET.NEXT.CHAR.FROM.WBUF
1360        STA PATHNAME.ONE.BUFFER+1,Y
1370        JSR STORE.PATH.TWO.AND.TEST
1380        BCC .4
1390        DEY
1400        STY PATHNAME.ONE.BUFFER
1410        STY PATHNAME.TWO.BUFFER
1420        LDA #$01     TELL THE WORLD ABOUT IT
1430        STA FBITS
1440 *--------------------------------
1450        DEX          RE-SCAN CHAR AFTER PATHNAME
1460        JSR GET.NEXT.NONBLANK
1470        BNE SYNERR2         ...NOT COMMA OR 
1480        BCS MORE.PARMS      ...COMMA
1490 .5     JMP NO.MORE.PARMS   ...
1500 SYNERR2
1510        JMP ERR.SYNTAX
1520 *--------------------------------
1530 *   PR# or IN# commands
1540 *--------------------------------
1550 PARSE.INPR
1560        JSR GET.NEXT.NONBLANK     CHAR AFTER COMMAND
1570        BEQ SYNERR2       ...comma or 
1580        DEX          ...IN CASE IT IS "Axxx"
1590        CMP #'A'
1600        BEQ GET.ANOTHER.PARM   ...HANDLE PR#Axxx or IN#Axxx
1610        INX          RESTORE X
1620        JSR ZERO.ACCUM
1630        STY PARM.LENM1    Y=0, 1 BYTE PARM
1640        LDY #VAL.LB-VAL.A    PARM OFFSET FROM VAL.A
1650        STY PARM.OFFSET
1660        LDY #$40
1670        STY FBITS
1680        JSR CONVERT.DECIMAL.NUMBER
1690        BCS RTS4
1700        LDA VAL.LB
1710        CMP #$08
1720        BCC TEST.IF.MORE.PARMS
1730 ERR.RANGE
1740        LDA #$02
1750        SEC
1760 RTS4   RTS
1770 *--------------------------------
1780 MORE.PARMS
1790        LDA PBITS
1800        LSR          TEST BIT 0
1810        BCC SYNERR2  ...NO PATHNAME EXPECTED
1820        LSR          TEST BIT 1
1830        BCC GET.ANOTHER.PARM   ...NO PATH-TWO EXPECTED
1840 *---Get second pathname----------
1850        JSR GET.NEXT.NONBLANK
1860        BEQ SYNERR2  ...COMMA OR 
1870        DEX          RE-SCAN FIRST CHAR OF PATHNAME
1880        LDY #0
1890 .1     JSR GET.NEXT.CHAR.FROM.WBUF
1900        JSR STORE.PATH.TWO.AND.TEST
1910        BCC .1
1920        DEY
1930        STY PATHNAME.TWO.BUFFER
1940        LDA #$03     WE GOT TWO PATHNAMES, SO
1950        STA FBITS         MARK THE BITS
1960        DEX          RE-SCAN TERM. CHAR
1970 *--------------------------------
1980 TEST.IF.MORE.PARMS
1990        JSR GET.NEXT.NONBLANK
2000        BNE SYNERR2
2010        BCC NO.MORE.PARMS
2020 GET.ANOTHER.PARM
2030        JSR GET.NEXT.NONBLANK
2040        BEQ SYNERR2       ...NULL PARAMETER
2050        JSR PARSE.PARAMETER
2060        BCC TEST.IF.MORE.PARMS
2070        RTS          ...error return
2080 *--------------------------------
2090 NO.MORE.PARMS
2100        LDA VAL.S    CHECK RANGE OF S AND D
2110        BEQ ERR.RANGE
2120        CMP #$08
2130        BCS ERR.RANGE
2140        LDA VAL.D
2150        BEQ ERR.RANGE
2160        CMP #$03
2170        BCS ERR.RANGE
2180 *---CHECK IF DEFERRED COMMAND----
2190        LDA PBITS    (only OPEN and WRITE are deferred)
2200        AND #$21
2210        LSR
2220        BEQ .1       ...NOT DEFERRED
2230        LDA STATE    ...ARE WE IN DIRECT MODE?
2240        BEQ .6       ...YES, DEFERRED IS ILLEGAL
2250 *---CHECK PATHNAME---------------
2260 .1     BCC .5       ...NO PATH PERMITTED
2270        LDA PBITS+1
2280        AND #$04     S OR D OK?
2290        BEQ .5       ...NO
2300        LDA FBITS
2310        LSR          HAVE WE A PATHNAME?
2320        BCS .2       ...YES
2330        LDA PBITS    ...NO, IS PATH NEEDED
2340        AND #$90
2350        BEQ ERR.SYNTAX   ...YES
2360        BPL .5
2370 *---NEED PREFIX OR S,D-----------
2380 .2     LDA PATHNAME.ONE.BUFFER+1
2390        EOR #'/'     SLASH
2400        BEQ .3       ...EXPLICIT PREFIX
2410        LDA PREFIX.FLAG   MLI's flag
2420        BEQ .4       ...NO PREFIX IS SET
2430 .3     LDA FBITS+1  DID WE GET S,D?
2440        AND #$04
2450        BEQ .5       ...NO
2460        BCS .4       ...YES, AND THERE IS A PATHNAME
2470        LDA #0       ...YES, BUT NO PATHNAME
2480        STA PATHNAME.ONE.BUFFER
2490        STA PATHNAME.ONE.BUFFER+1
2500        LDA #$01     SIGNAL WE GOT PATHNAME AFTER ALL
2510        ORA FBITS
2520        STA FBITS
2530 .4     JSR INSERT.VOLUME.NAME
2540        BCS .7
2550 *---BRANCH TO COMMAND------------
2560 .5     CLC          SIGNAL NO ERROR
2570        LDA COMMAND.NUMBER
2580        BEQ EXTERNAL      ...USER'S COMMAND
2590        EOR #CN.PREFIX
2600        BEQ INTERNAL      ...PREFIX COMMAND
2610        LDA PBITS+1       ARE S/D VALID?
2620        AND #$04
2630        BEQ INTERNAL      ...NO
2640        LDA FBITS         ANY PATHNAME SPECIFIED?
2650        LSR
2660        BCC INTERNAL      ...NO
2670        JSR GET.FILE.INFO   ...YES
2680        BCC INTERNAL      ...NO ERROR
2690        ORA #0            ...ERROR, WAS IT "FILE NOT FOUND"?
2700        BPL .7            ...NO, REAL ERROR
2710        LDA PBITS         OKAY TO CREATE PATHNAME?
2720        AND #$08
2730        BNE INTERNAL      ...YES
2740        LDA #$06          "PATH NOT FOUND"
2750        .HS 2C
2760 .6     LDA #$0F          "NOT DIRECT COMMAND"
2770        SEC
2780 .7     RTS
2790 *--------------------------------
2800 INTERNAL   JMP (COMMAND.ADDR)
2810 EXTERNAL   JMP (EXTERNAL.COMMAND.HANDLER)
2820 *--------------------------------
2830 ERR.SYNTAX
2840        LDA #$10     SYNTAX ERROR
2850 ERRR   SEC
2860        RTS
2870 *--------------------------------
2880 *   INSERT PREFIX BEFORE PATHNAME
2890 *--------------------------------
2900 INSERT.VOLUME.NAME
2910        LDA VAL.S    BUILD UNIT # FROM SLOT,DRIVE
2920        TAY          SAVE VAL.S
2930        LSR          0000.00SS S
2940        ROR          S000.000S S
2950        ROR          SS00.0000 S
2960        ROR          SSS0.0000 0
2970        LDX VAL.D
2980        CPX #2       .CS. if 2, .CC. if 1
2990        ROR          DSSS.0000
3000        STA MISC.PARMS+1
3010        LDA #WBUF+1
3020        STA MISC.PARMS+2
3030        LDA /WBUF+1
3040        STA MISC.PARMS+3
3050        JSR MLI.C5   ONLINE -- READ VOLUME NAME
3060        BCS .4       NO SUCH SLOT AND DRIVE
3070        STX D.DRIV   UPDATE DEFAULT S AND D
3080        STY D.SLOT
3090 *--------------------------------
3100        LDA PATHNAME.ONE.BUFFER+1
3110        EOR #'/'     ALREADY HAVE VOLUME NAME?
3120        BEQ .4       ...YES, DON'T NEED ANOTHER
3130 *---ISOLATE VOLNAME LENGTH-------
3140        LDA WBUF+1   DSSSLLLL
3150        AND #$0F     0000LLLL
3160        STA WBUF+1
3170 *---MOVE PATHNAMES OVER L+2------
3180        LDY #62
3190        TYA
3200        SEC
3210        SBC WBUF+1
3220        TAX
3230 .1     LDA PATHNAME.ONE.BUFFER,X
3240        STA PATHNAME.ONE.BUFFER+2,Y
3250        LDA PATHNAME.TWO.BUFFER,X
3260        STA PATHNAME.TWO.BUFFER+2,Y
3270        DEY
3280        DEX
3290        BNE .1
3300 *---INSERT VOLUME SLASHES--------
3310        LDA #'/'
3320        STA PATHNAME.ONE.BUFFER+2,Y
3330        STA PATHNAME.ONE.BUFFER+1
3340        STA PATHNAME.TWO.BUFFER+2,Y
3350        STA PATHNAME.TWO.BUFFER+1
3360 *---COPY VOLUME NAME-------------
3370 .2     LDA WBUF+1,Y
3380        STA PATHNAME.ONE.BUFFER+1,Y
3390        STA PATHNAME.TWO.BUFFER+1,Y
3400        DEY
3410        BNE .2
3420 *---UPDATE PATH LENGTHS----------
3430        CLC
3440        LDA WBUF+1
3450        ADC #2       INCLUDE SLASHES
3460        TAY
3470        ADC PATHNAME.ONE.BUFFER
3480        CMP #64
3490 .3     BCS ERR.SYNTAX
3500        STA PATHNAME.ONE.BUFFER
3510        TYA
3520        ADC PATHNAME.TWO.BUFFER
3530        STA PATHNAME.TWO.BUFFER
3540        CMP #64
3550        BCS .3       ...BRIDGE TO SYNTAX ERROR
3560 *--------------------------------
3570 .4     RTS
3580 *--------------------------------
3590 SCAN.COMMAND.TABLE
3600        LDY #0       PNTR INTO COMMAND TABLE
3610        STY COMMAND.NUMBER
3620        DEY
3630 *---COMPARE COMMAND NAME---------
3640 .1     INC COMMAND.NUMBER
3650        LDX #0       PNTR INTO WBUF
3660 .2     INY          next byte in command table
3670        JSR GET.NEXT.NONBLANK
3680        BEQ .4       ...end of WBUF contents
3690        EOR COMMAND.TABLE,Y
3700        BEQ .2       ...same so far
3710        ASL          Might be last char
3720        BNE .4       ...No, try next command
3730 *---We found the command---------
3740        LDA COMMAND.TABLE+1,Y
3750        STA COMMAND.ADDR
3760        LDA COMMAND.TABLE+2,Y
3770        STA COMMAND.ADDR+1
3780        LDA COMMAND.TABLE+3,Y
3790        STA PBITS
3800        LDA COMMAND.TABLE+4,Y
3810        STA PBITS+1
3820        CLC
3830        RTS
3840 *---SKIP TO NEXT COMMAND---------
3850 .3     INY
3860 .4     LDA COMMAND.TABLE,Y
3870        BPL .3       ...NOT LAST CHAR YET
3880        INY          SKIP OVER ADDRESS
3890        INY
3900        INY          SKIP OVER PBITS
3910        INY
3920        LDA COMMAND.TABLE+1,Y
3930        BNE .1       ...more commands in table
3940 *---TRY EXTERNAL COMMAND---------
3950        LDA #$FF
3960        STA COMMAND.NUMBER
3970        SEC
3980        JMP USER.CMD
3990 *--------------------------------
4000 SYNERR1 JMP ERR.SYNTAX
4010 *--------------------------------
4020 PARSE.PARAMETER
4030        JSR ZERO.ACCUM
4040        LDY #NO.PARM.NAMES-1
4050 .1     CMP PARM.NAMES,Y
4060        BEQ FOUND.PARM
4070        DEY
4080        BPL .1
4090        CMP #'T'
4100        BNE SYNERR1   ...SYNTAX ERROR
4110 *---PARSE T PARAMETER------------
4120        LDA #$04
4130        AND PBITS
4140        BEQ ERR.BADPARM
4150        ORA FBITS
4160        STA FBITS
4170        LDA #0            SINGLE BLYTE
4180        STA PARM.LENM1
4190        LDA #VAL.T-VAL.A    PARM OFFSET FROM VAL.A
4200        STA PARM.OFFSET
4210        JSR GET.NEXT.NONBLANK
4220        BEQ SYNERR1
4230        CMP #'$'
4240        BEQ CONVERT.HEX.NUMBER
4250        CMP #'A'
4260        BCC CONVERT.DECIMAL.NUMBER
4270        JMP CONVERT.FILE.TYPE
4280 *--------------------------------
4290 ERR.BADPARM
4300        SEC          "INVALID PARAMETER"
4310        LDA #$0B
4320        RTS
4330 *--------------------------------
4340 FOUND.PARM
4350        LDA PARM.MASKS,Y
4360        BEQ .2
4370        AND PBITS+1
4380        BEQ ERR.BADPARM
4390        CMP #$04     IS IT S OR D
4400        BNE .1       ...NO
4410        AND FBITS+1  ...YES, DID WE ALREADY HAVE S OR D
4420        BNE .2       ...YES
4430        LDA #1       ...NO, SET D=1
4440        STA VAL.D
4450        LDA #$04
4460 .1     ORA FBITS+1
4470        STA FBITS+1
4480 .2     LDA PARM.VARIABLES,Y
4490        AND #$03
4500        STA PARM.LENM1
4510        LDA PARM.VARIABLES,Y
4520        LSR
4530        LSR
4540        STA PARM.OFFSET
4550        JSR GET.NEXT.NONBLANK
4560        BEQ GO.ERR.SYNTAX.1
4570        CMP #'$'
4580        BEQ CONVERT.HEX.NUMBER
4590 *--------------------------------
4600 CONVERT.DECIMAL.NUMBER
4610        STX COMMAND.LINE.LENGTH
4620        JSR ACCUMULATE.DECIMAL.DIGIT
4630        BCC .1
4640        BMI GO.ERR.RANGE.1
4650        BCS GO.ERR.SYNTAX.1
4660 .1     LDX COMMAND.LINE.LENGTH
4670        JSR GET.NEXT.NONBLANK
4680        BNE CONVERT.DECIMAL.NUMBER
4690        BEQ CHECK.PARAMETER.RANGE
4700 *--------------------------------
4710 CONVERT.HEX.NUMBER
4720        JSR GET.NEXT.NONBLANK
4730        BEQ GO.ERR.SYNTAX.1
4740 .1     STX COMMAND.LINE.LENGTH
4750        JSR ACCUMULATE.HEX.DIGIT
4760        BCC .2
4770        BMI GO.ERR.RANGE.1
4780        BCS GO.ERR.SYNTAX.1
4790 .2     LDX COMMAND.LINE.LENGTH
4800        JSR GET.NEXT.NONBLANK
4810        BNE .1
4820 *--------------------------------
4830 CHECK.PARAMETER.RANGE
4840        LDX #$02
4850 .1     CPX PARM.LENM1
4860        BEQ .2
4870        LDA ACCUM,X
4880        BNE GO.ERR.RANGE.1
4890        DEX
4900        BNE .1
4910 .2     LDY PARM.OFFSET
4920 .3     LDA ACCUM,X
4930        STA VAL.A,Y
4940        DEY
4950        DEX
4960        BPL .3
4970        LDX COMMAND.LINE.LENGTH
4980        CLC
4990        RTS
5000 *--------------------------------
5010 GO.ERR.SYNTAX.1 JMP ERR.SYNTAX
5020 *--------------------------------
5030 GO.ERR.RANGE.1  JMP ERR.RANGE
5040 *--------------------------------
5050 CONVERT.FILE.TYPE
5060        STA ACCUM+2       1ST LETTER
5070        LDY #2            GET 2ND AND 3RD
5080 .1     JSR GET.NEXT.NONBLANK
5090        BEQ GO.ERR.SYNTAX.1
5100        STA ACCUM-1,Y     STORE THEM BACKWARDS
5110        DEY
5120        BNE .1            ...UNTIL Y=0
5130        STX COMMAND.LINE.LENGTH  SAVE X-REG
5140 .2     LDX #2       COMPARE NEXT ENTRY
5150 .3     LDA ACCUM,X
5160        EOR FILE.TYPES,Y
5170        INY
5180        ASL          IGNORE BIT 7
5190        BNE .4       ...NOT THE SAME
5200        DEX          NEXT CHAR
5210        BPL .3
5220        LDA FILE.TYPES,Y
5230        STA VAL.T
5240        LDX COMMAND.LINE.LENGTH  RESTORE X-REG
5250        CLC
5260        RTS
5270 .4     INY
5280        DEX
5290        BPL .4
5300        CPY #LAST.FILE.TYPE
5310        BCC .2
5320        BCS GO.ERR.SYNTAX.1
5330 *--------------------------------
5340 *    GET NEXT NON-BLANK CHAR FROM WBUF
5350 *      CHAR   Z   C
5360 *        YES CLR
5370 *      COMMA YES SET
5380 *      OTHER  NO  ?
5390 *--------------------------------
5400 GET.NEXT.NONBLANK
5410 .1     JSR GET.NEXT.CHAR.FROM.WBUF
5420        CMP #' '
5430        BEQ .1       IGNORE BLANKS
5440        CMP #','
5450        BEQ .2       .CS. and .EQ.
5460        CMP #$0D     .EQ. if 
5470        CLC          .CC.
5480 .2     RTS
5490 *--------------------------------
5500 GET.NEXT.CHAR.FROM.WBUF
5510        LDA WBUF,X
5520        BNE .1       MAKE 00==8D
5530        LDA #$0D
5540 .1     AND #$7F
5550        CMP #$60     CONVERT LOWER CASE TO UPPER
5560        BCC .2
5570        AND #$5F
5580 .2     INX
5590        RTS
5600 *--------------------------------
5610 ACCUMULATE.DECIMAL.DIGIT
5620        CMP #$30
5630        BCC .1
5640        CMP #$3A
5650        BCC .2
5660 .1     SEC
5670        ORA #0
5680        RTS
5690 *--------------------------------
5700 .2     AND #$0F
5710        PHA
5720        LDA ACCUM+2
5730        CMP #$1A
5740        BCS .5
5750        LDX #$02
5760 .3     LDA ACCUM,X
5770        PHA
5780        DEX
5790        BPL .3
5800        JSR SHIFT.ACCUM.LEFT
5810        JSR SHIFT.ACCUM.LEFT
5820        LDX #0
5830        CLC
5840 .4     PLA
5850        ADC ACCUM,X
5860        STA ACCUM,X
5870        INX
5880        TXA
5890        EOR #$03
5900        BNE .4
5910        JSR SHIFT.ACCUM.LEFT
5920 .5     PLA
5930        BCS TOOBIG
5940        ADC ACCUM
5950        STA ACCUM
5960        BCC RTS1
5970        CLC
5980        INC ACCUM+1
5990        BNE RTS1
6000        INC ACCUM+2
6010        BNE RTS1
6020 TOOBIG LDA #$FF
6030        SEC
6040 RTS1   RTS
6050 *--------------------------------
6060 ACCUMULATE.HEX.DIGIT
6070        CMP #'0'
6080        BCC .1
6090        CMP #'9'+1
6100        BCC .3
6110        CMP #'A'
6120        BCC .1
6130        CMP #'F'+1
6140        BCC .2
6150 .1     SEC
6160        ORA #0
6170        RTS
6180 .2     SBC #$06
6190 .3     AND #$0F
6200        LDX #$03
6210 .4     JSR SHIFT.ACCUM.LEFT
6220        BCS TOOBIG
6230        DEX
6240        BPL .4
6250        ORA ACCUM
6260        STA ACCUM
6270        RTS
6280 *--------------------------------
6290 SHIFT.ACCUM.LEFT
6300        ASL ACCUM
6310        ROL ACCUM+1
6320        ROL ACCUM+2
6330        RTS
6340 *--------------------------------
6350 ZERO.ACCUM
6360        LDY #0
6370        STY ACCUM
6380        STY ACCUM+1
6390        STY ACCUM+2
6400        RTS
6410 *--------------------------------
6420 *      RETURN .CC. IF NOT END OF PATHNAME YET
6430 *        ELSE .CS.
6440 *--------------------------------
6450 STORE.PATH.TWO.AND.TEST
6460        STA PATHNAME.TWO.BUFFER+1,Y
6470        INY
6480        CMP #','
6490        BEQ .1
6500        CMP #' '
6510        BEQ .1
6520        CMP #$0D
6530        BEQ .1
6540        CPY #65
6550 .1     RTS
6560 *--------------------------------
