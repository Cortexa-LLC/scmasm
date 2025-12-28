
1000 *SAVE X.ASM.65816.2
1010 *--------------------------------
1020 LONG.INDIRECT
1030        JSR EXP1
1040        JSR GNC
1050        CMP #']'
1060        BNE ERBA.EMIT.TWO
1070        JSR GNC
1080        BEQ .1       ...[EXP]
1090        CMP #','
1100        BNE ERBA.EMIT.TWO
1110        JSR GNC.UC
1120        CMP #'Y'
1130        BNE ERBA.EMIT.TWO
1140        LDA #$47     ...[EXP],Y
1150        .HS 2C
1160 .1     LDA #$44     ...[EXP],Y
1170        STA MODE.BYTE
1180        LDA #2
1190        STA ADDR.LENGTH
1200        JMP CHECK.IF.SUFFIX.LEGAL
1210 *--------------------------------
1220 IMMEDIATE
1230        JSR GNC.UC
1240        CMP DLIM     16-BIT IMMEDIATE?
1250        BNE .1       ...NO, BACKUP
1260        LDA LEVEL.MASK    16-BIT IMMEDIATE OKAY?
1270        BPL ERBA.EMIT.TWO ...NOT AT 65816 LEVEL
1280        INC ADDR.LENGTH   ...YES, INCREASE LENGTH
1290        BNE .2            ...ALWAYS
1300 .1     DEC CHAR.PNTR
1310 .2     JSR EXP1
1320        JSR GNC
1330        BNE ERBA.EMIT.TWO    ILLEGAL
1340        LDA DLIM
1350        CMP #'/'     #=23, /=2F, ^=5E
1360        BCC .4            ...#
1370        BEQ .3            .../
1380        JSR EXP.OVER.256  ...^
1390 .3     JSR EXP.OVER.256
1400 .4     LDY #0       SIGNAL IMMEDIATE MODE
1410        STY MODE.BYTE     COPS NEEDS THIS <<<12-16-85>>>
1420        RTS
1430 *--------------------------------
1440 ERBA.EMIT.THREE
1450        JSR EMIT.ZERO
1460 ERBA.EMIT.TWO
1470        JSR EMIT.ZERO
1480        JSR EMIT.ZERO
1490 ERBA   LDA #ERR.BAD.ADDRESS
1500        JMP ASM.ERROR
1510 EMIT.ZERO LDA #0
1520           JMP EMIT
1530 *--------------------------------
1540 *   RETURN:
1550 *      # BYTES IN ADDRESS IN ADDR.LENGTH
1560 *      (Y) = INDEX TO ADDR.MODE.BITS
1570 *--------------------------------
1580 GENERAL.OPERAND
1590        JSR GNNB     GET NEXT NON-BLANK
1600        BCS ERBA.EMIT.TWO     ...NO OPERAND
1610 *---PARSE PREFIX-----------------
1620        LDY #1
1630        STY ADDR.LENGTH
1640        STA DLIM
1650        CMP #'('
1660        BEQ .3       ...indirect, must be ZP
1670        CMP #'['
1680        BEQ LONG.INDIRECT
1690        CMP #'#'
1700        BEQ IMMEDIATE
1710        CMP #'/'
1720        BEQ IMMEDIATE
1730        CMP #'^'
1740        BEQ IMMEDIATE
1750        CMP #'<'
1760        BEQ .3       MAKE FORCE SIZE = 1
1770        DEY          Y=0
1780        CMP #'>'
1790        BNE .2       ...SIZE NOT FORCED
1800        JSR GNC
1810        LDY #3       Y=3
1820        CMP DLIM     IS IT ">>"?
1830        BEQ .3       ...YES
1840        DEY          Y=2
1850        STA DLIM     CHANGE DLIM TO NEW VALUE
1860        CMP #'('     IS IT (?
1870        BEQ .3       ...YES, >(
1880 .2     DEC CHAR.PNTR     ...NO, SO BACKUP
1890 .3     STY FORCE.ADDR.SIZE
1900 *---PARSE THE EXPRESSION---------
1910        JSR EXP1
1920 *---FIGURE # OF BYTES------------
1930        LDX FORCE.ADDR.SIZE
1940        BNE .6       ...FORCED WITH <, >, OR >>
1950        LDX #2       ASSUME 2-BYTE ADDRESS
1960        LDA EXP.UNDEF
1970        BMI .6
1980        LDA PASS     IGNORE FWD REF FLAG IN PASS 1
1990        BEQ .4       ...PASS 1
2000        LDA EXP.FWDREF    ...PASS 2, DEFINED
2010        BNE .4            ...BUT NOT FWD REF
2020        LDA EXP.VALUE+3   ...FWD REF MUST BE ONLY
2030        ORA EXP.VALUE+2      16 BITS
2040        BEQ .6            ...IT FITS!
2050        BNE ERBA.1           ...ALWAYS, ERBA
2060 .4     LDA EXP.VALUE+3   DO NOT ALLOW 32-BITS
2070        BNE ERBA.1           ...BAD ADDR
2080        LDA EXP.VALUE+2
2090        BNE .5            ...3-BYTE ADDRESS
2100        DEX               X=1
2110        LDA EXP.VALUE+1
2120        BEQ .6            ...ZP
2130 .5     INX
2140 .6     STX ADDR.LENGTH
2150 *---PARSE SUFFIX-----------------
2160        DEX          MAKE 0, 1, OR 2
2170        STX MODE.BYTE
2180        LDX #6
2190 .7     JSR GNC.UC
2200 .8     CMP MODE.CHARS,X
2210        BEQ .9
2220        CLC
2230        ROL MODE.BYTE
2240        DEX
2250        BPL .8
2260        BMI ERBA.1 
2270 .9     CMP #' '     BLANK?
2280        BEQ CHECK.IF.SUFFIX.LEGAL    ...YES, END OF OPERAND
2290        CMP #')'     RIGHT PAREN?
2300        BNE .10      ...NO
2310        LDA DLIM     WAS THERE A LEFT PAREN?
2320        CMP #'('
2330        BNE ERBA.1      ...NO
2340 .10    SEC
2350        ROL MODE.BYTE
2360        DEX
2370        BPL .7
2380 ERBA.1 JMP ERBA.EMIT.TWO    ILLEGAL
2390 *--------------------------------
2400 CHECK.IF.SUFFIX.LEGAL
2410        LDY #0       SEARCH FORWARD FOR VARIOUS REASONS
2420        LDA MODE.BYTE
2430 .13    INY
2440        CPY #MODE.TABLE.SIZE+1
2450        BCS ERBA.1      ...END OF TABLE
2460        CMP MODE.TABLE-1,Y
2470        BNE .13      ...KEEP LOOKING
2480        RTS
2490 *--------------------------------
2500 SEE.IF.MODE.LEGAL.AT.LEVEL
2510        LDA LEVEL.MASK
2520        BMI .15      ...65816 LEVEL, ALL LEGAL
2530        CPY #9
2540        BCC .15      ...6502 MODES
2550        BEQ .14      ...65C02 MODE
2560        CPY #16
2570        BNE ERBA.1
2580 .14    AND #$20     AT C02 LEVEL?
2590        BEQ ERBA.1      ...NO
2600 .15    RTS
2610 *--------------------------------
2620 EXP.OVER.256
2630        LDA EXP.VALUE+1
2640        STA EXP.VALUE
2650        LDA EXP.VALUE+2
2660        STA EXP.VALUE+1
2670        LDA EXP.VALUE+3
2680        STA EXP.VALUE+2
2690        LDA #0
2700        STA EXP.VALUE+3
2710        RTS
2720   .DO ROCKWELL
2730 *--------------------------------
2740 *   ROCKWELL 65C02 EXCLUSIVES
2750 *
2760 *      RMB bit#,zp
2770 *      SMB bit#,zp
2780 *      BBR bit#,zp,reladdr
2790 *      BBS bit#,zp,reladdr
2800 *--------------------------------
2810 OP.ROCKB
2820        JSR OP.ROCKWELL
2830        JSR GNC      REQUIRE A COMMA
2840        CMP #','
2850        BNE .1       ...NO COMMA
2860        LDA EXP.VALUE
2870        PHA          SAVE ZP VALUE
2880        JSR EXP1     GET BRANCH EXPRESSION
2890        JSR EMIT.OPBASE           <<<12-16-85>>>
2900        PLA
2910        JMP OP.REL8.A
2920 .1     JMP ERBA.EMIT.THREE
2930 *--------------------------------
2940 OP.ROCKC
2950        JSR OP.ROCKWELL
2960   .FIN
2970 EMIT.OP.AND.EXP.BYTE
2980        JSR EMIT.OPBASE           <<<12-16-85>>>
2990        JMP EMIT.EXP.BYTE         <<<12-16-85>>>
3000 *--------------------------------
3010   .DO ROCKWELL
3020 OP.ROCKWELL
3030        JSR EXPR     GET BIT #
3040        JSR TEST.EXP.VALUE.ZP
3050        BNE .1       ...MUST BE SMALL NUMBER!
3060        LDA EXP.VALUE
3070        CMP #8       MUST BE 0...7
3080        BCS .1       ...TOO LARGE
3090        ASL
3100        ASL
3110        ASL
3120        ASL
3130        ORA OPBASE   MERGE INTO OPCODE
3140        STA OPBASE
3150        JSR GNC      NEED A COMMA NOW
3160        CMP #','
3170        BNE .1 
3180        JSR EXP1     GET ZP VALUE
3190        JSR TEST.EXP.VALUE.ZP
3200        BNE .1       MUST BE ZERO PAGE
3210        RTS
3220 .1     JMP ERBA.EMIT.TWO
3230 *--------------------------------
3240   .ELSE
3250 OP.ROCKB
3260 OP.ROCKC
3270        JMP BADOPERR
3280   .FIN
3290        .PG
3300   .DO SWEET.16
3310 *--------------------------------
3320 *      SWEET-16 OPCODES
3330 *--------------------------------
3340 OP.POP
3350        JSR GNC.UC   SEE WHICH: POP OR POPD
3360        BEQ OP.XN   ...POP
3370        CMP #'D'
3380        BEQ .1
3390        JMP BADOPERR
3400 .1     LDA #$A2          ...POP
3410        STA OPBASE
3420 *--------------------------------
3430 OP.XN
3440        JSR GNNB
3450        BCS SWEET.ERBA
3460        CMP #'@'
3470        BNE .1       ...NOT '@N'
3480        LDA OPBASE   ...'@N', SEE IF LEGAL
3490        AND #2
3500        BEQ SWEET.ERBA    ...NOT LEGAL WITH THIS OP
3510        LDA OPBASE        ...LEGAL, ADD $20
3520        ADC #$1F          .CS., SO 1F IS 20
3530        BNE .2       ...ALWAYS
3540 .1     DEC CHAR.PNTR     Backup character pointer
3550        LDA OPBASE
3560        LSR
3570        BCC SWEET.ERBA    'N' NOT LEGAL FOR THIS OP
3580        LDA OPBASE
3590 .2     AND #$F0     CLEAR AWAY LEGALITY FLAGS
3600        STA OPBASE
3610        JSR EXP1     GET REGISTER NUMBER
3620        JSR TEST.EXP.VALUE.ZP
3630        BNE SWEET.RAER
3640        LDA EXP.VALUE
3650        CMP #$10
3660        BCS SWEET.RAER
3670        ORA OPBASE
3680        JMP EMIT
3690 *--------------------------------
3700 SWEET.ERBA JMP ERBA
3710 SWEET.RAER JMP RAER 
3720 *--------------------------------
3730 OP.SET
3740        JSR OP.XN
3750        JSR GNC
3760        CMP #','
3770        BNE SWEET.ERBA
3780        JSR EXP1
3790        LDA #2
3800        STA ADDR.LENGTH
3810        JMP EMIT.VALUE
3820 *--------------------------------
3830   .ELSE
3840 OP.POP
3850 OP.XN
3860 OP.SET
3870        JMP BADOPERR
3880   .FIN
