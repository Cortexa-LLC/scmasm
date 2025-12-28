
1000 *SAVE X.SYMBOL.TABLE
1010 *--------------------------------
1020 *      INITIALIZE SYMBOL TABLE
1030 *      1.  SET EOT TO BOT
1040 *      2.  CLEAR HASH POINTER TABLE
1050 *--------------------------------
1060 STINIT LDA LO.MEM    START OF SYMBOL TABLE
1070        STA EOT
1080        LDA LO.MEM+1
1090        STA EOT+1
1100        STA MACLBL+1 PRIVATE LABELS GO DOWN FROM THERE
1110        LDX #56      # BYTES IN HASH POINTER TABLE
1120        LDA #0
1130        STA MACLBL
1140        STA CURRENT.MAJOR.LABEL+1
1150 .1     STA HSHTBL-1,X
1160        DEX
1170        BNE .1
1180   .DO AUXMEM
1190        LDA RDRAM
1200        LDA RDRAM
1210        LDX #AUX.IMAGE.LEN-1
1220 .2     LDA AUX.IMAGE,X
1230        STA AUX.CODE,X
1240        DEX
1250        BPL .2
1260 BACK.TO.ROM
1270        PHA
1280        LDA RDROM
1290        PLA
1300   .FIN
1310        RTS          RETURN WITH X=0
1320 *--------------------------------
1330    .DO AUXMEM
1340 LDA.STPNTR
1350        BIT RDRAM
1360        JSR LDA.STPNTR.AUX
1370        JMP BACK.TO.ROM
1380 *
1390 ADC.STPNTR
1400        BIT RDRAM
1410        JSR ADC.STPNTR.AUX
1420        JMP BACK.TO.ROM
1430 *
1440 SBC.STPNTR
1450        BIT RDRAM
1460        JSR SBC.STPNTR.AUX
1470        JMP BACK.TO.ROM
1480 *
1490 LDA.PNTR
1500        BIT RDRAM
1510        JSR LDA.PNTR.AUX
1520        JMP BACK.TO.ROM
1530 *
1540 LDA.TPTR
1550        BIT RDRAM
1560        JSR LDA.TPTR.AUX
1570        JMP BACK.TO.ROM
1580 *
1590 LDA.SRCP
1600        BIT RDRAM
1610        JSR LDA.SRCP.AUX
1620        JMP BACK.TO.ROM
1630 *
1640 STA.PNTR
1650        STA WRAUX
1660        STA (PNTR),Y
1670        STA WRMAIN
1680        RTS
1690 STA.STPNTR
1700        STA WRAUX
1710        STA (STPNTR),Y
1720        STA WRMAIN
1730        RTS
1740 *--------------------------------
1750 AUX.IMAGE
1760 LDA.STPNTR.AUX .EQ *-AUX.IMAGE+AUX.CODE
1770        STA RDAUX
1780        LDA (STPNTR),Y
1790        STA RDMAIN
1800        RTS
1810 ADC.STPNTR.AUX .EQ *-AUX.IMAGE+AUX.CODE
1820        STA RDAUX
1830        ADC (STPNTR),Y
1840        STA RDMAIN
1850        RTS
1860 SBC.STPNTR.AUX .EQ *-AUX.IMAGE+AUX.CODE
1870        STA RDAUX
1880        SBC (STPNTR),Y
1890        STA RDMAIN
1900        RTS
1910 LDA.PNTR.AUX .EQ *-AUX.IMAGE+AUX.CODE
1920        STA RDAUX
1930        LDA (PNTR),Y
1940        STA RDMAIN
1950        RTS
1960 LDA.TPTR.AUX .EQ *-AUX.IMAGE+AUX.CODE
1970        STA RDAUX
1980        LDA (TPTR),Y
1990        STA RDMAIN
2000        RTS
2010 LDA.SRCP.AUX .EQ *-AUX.IMAGE+AUX.CODE
2020        STA RDAUX
2030        LDA (SRCP),Y
2040        STA RDMAIN
2050        RTS
2060 AUX.IMAGE.LEN .EQ *-AUX.IMAGE
2070    .FIN
2080 *--------------------------------
2090 *      A table of 28 pointers begins at $130, called HSHTBL.
2100 *      Each pointer points to the beginning of a chain of
2110 *      symbol entries.  The entries on a chain are kept
2120 *      in alphabetical order.  If a chain is empty, the
2130 *      pointer = $0000.
2140 *
2150 *      HSHTBL+$00:  Chain for target file entries
2160 *      HSHTBL+$02:  Chain for labels starting with "A"
2170 *      HSHTBL+$04:  Chain for labels starting with "B"
2180 *        - - -
2190 *      HSHTBL+$34:  Chain for labels starting with "Z"
2200 *      HSHTBL+$36:  Chain for Macro Names and Skeletons
2210 *
2220 *      Format of Target File Entry:
2230 *          0,1 -- Forward chain pointer (0=end of chain)
2240 *          2,3 -- Length of target file in bytes
2250 *          4   -- Length of code name = $02
2260 *          5,6 -- Target file code name:
2270 *                 5:  "@" = $40
2280 *                 6:  $40 + target file number ($00-$1F)
2290 *
2300 *      Format of Label Entry:
2310 *          0,1 -- Forward chain pointer (0=end of chain)
2320 *          2-5 -- Value of label
2330 *          6   -- Flags and length of label name:
2340 *                 Bits 5-0:  length of label name ($01-$20)
2350 *                 Bit    6:  =1 if forward reference
2360 *                 Bit    7:  =1 if has local labels
2370 *          7   -- First character of label name, and flag.
2380 *                 Bit 7 = 1 if label is .SEt label.
2390 *     thru 6+n -- The rest of the label name, with bit 7 = 0
2400 *
2410 *          If the label has local labels, they follow.
2420 *          Each local label occupies two bytes:
2430 *          1   -- Label number (0-99) +128
2440 *          2   -- Label value (distance from value of
2450 *                   named label)
2460 *          The local label list is terminated with a $00
2470 *                   in the label number position.
2480 *
2490 *      Format of Macro Definition Entry:
2500 *          0,1 -- Chain to next macro name
2510 *          2,3 -- $0000
2520 *          4   -- Length of macro name
2530 *          5   -- "[" + $5B
2540 *          6-n -- Rest of Macro name
2550 *          etc.-- The packed skeleton lines, each
2560 *                   terminated by $00.  A final $00
2570 *                   terminates the skeleton.
2580 *
2590 *      Private Labels are kept in a separate table.
2600 *      Each label takes 7 bytes.  Bytes 0-3 are the
2610 *      value, byte 4 is the colon number + $80,
2620 *      and bytes 5 and 6 are the macro call number.
2630 *      The Private Label table grows downward from
2640 *      MACLBL toward $0800.
2650 *
2660 *--------------------------------
2670 *      PACK SYMBOL FROM INPUT LINE
2680 *      UP TO 32 CHARACTERS PACKED AT SYMBOL+7
2690 *      AND FOLLOWING.
2700 *      # CHARS STORED IN SYMBOL+6
2710 *      RETURN CARRY CLEAR IF NO SYMBOL
2720 *      RETURN CARRY SET IF GOOD SYMBOL
2730 *--------------------------------
2740 PACK   LDX #0       POINT AT 1ST CHAR IN NAME
2750        CMP #CHR.PERIOD LOCAL SYMBOL?
2760        BEQ .1       YES
2770        CMP #':      COLON MEANS MACRO PRIVATE LABEL
2780        BNE .3       NO, NORMAL SYMBOL
2790 .1     STA SYMBOL+7 SAVE PERIOD OR COLON
2800        JSR GNC.UC   GET NEXT CHAR
2810        JSR CHECK.DIGIT
2820        BCC .4       NO, BAD SYMBOL
2830        JSR DECN     CONVERT TO BINARY
2840        LDX #0       IN CASE BAD SYMBOL...
2850        LDA DGTCNT         VALUE MUST BE < 100
2860        CMP #3            SO MUST BE 1 OR 2 DIGITS
2870        BCS .4       ...TOO MANY DIGITS, BAD SYMBOL
2880        LDA SYM.VALUE
2890        ORA #$80     BE SURE NOT 00
2900        STA SYMBOL+8 SAVE VALUE
2910        LDA CALL.NUM JUST IN CASE IT'S A
2920        STA SYMBOL+9 MACRO PRIVATE LABEL
2930        LDA CALL.NUM+1
2940        STA SYMBOL+10
2950        INX          SIGNAL GOOD SYMBOL
2960        BNE .4       ...ALWAYS
2970 *--------------------------------
2980 .3     JSR PACK.NAME
2990 .4     JSR BACKUP.CHAR.PNTR
3000        STX SYMBOL+6 SAVE LENGTH
3010        CPX #1       CARRY SET IF AT LEAST ONE CHAR
3020        LDX #0       CLEAR X AGAIN
3030        RTS
3040 *--------------------------------
3050 *      PACK A NAME INTO SYMBOL
3060 *--------------------------------
3070 PACK.NAME
3080        JSR CHECK.LETTER
3090        BCC .4       NOT A LETTER
3100 .1     CPX #32      SEE IF ALREADY 32 CHARACTERS
3110        BEQ .2       YES, IGNORE
3120        STA SYMBOL+7,X PUT CHAR IN ENTRY
3130        INX          POINT AT NEXT SLOT
3140 .2     JSR GNC.UC   GET NEXT CHAR FROM LINE
3150        JSR CHECK.DOT.DIGIT.OR.LETTER
3160        BCS .1       VALID CHAR
3170 .4     RTS          END OF NAME
3180 *--------------------------------
3190 *      SEARCH SYMBOL TABLE
3200 *      # OF CHARS STORED AT SYMBOL+6
3210 *      SYMBOL ITSELF AT SYMBOL+7 AND FOLLOWING
3220 *      JSR STSRCH
3230 *      IF FOUND: CARRY CLEAR
3240 *                (STPNTR)=ADDRESS OF ENTRY
3250 *      IF NOT FOUND: CARRY SET
3260 *                    (STPNTR)=ADDRESS OF
3270 *                    POINTER CELL WHICH
3280 *                    SHOULD POINT AT ENTRY
3290 *--------------------------------
3300 STSRCH SEC          CONVERT FIRST CHARACTER
3310        LDA SYMBOL+7 OF SYMBOL TO HASH TABLE INDEX
3320        CMP #CHR.PERIOD SEE IF LOCAL SYMBOL
3330        BEQ .8       YES
3340        CMP #':      COLON, THEN PRIVATE LABEL
3350        BNE .12      NO, NORMAL LABEL
3360        JMP SEARCH.PRIVATE.LABELS
3370 .12    SBC #$40     AT-SIGN
3380        ASL          DOUBLE INDEX, CLEAR CARRY
3390        ADC #HSHTBL
3400        STA STPNTR
3410        LDA /HSHTBL
3420        ADC #0
3430        STA STPNTR+1
3440 .1     LDY #0
3450        >SYM LDA,STPNTR GET POINTER FROM ENTRY
3460        STA TPTR
3470        INY
3480        >SYM LDA,STPNTR
3490        BEQ .4       END OF CHAIN, NOT IN TABLE
3500        STA TPTR+1
3510        LDX SYMBOL+6 # CHARS IN SYMBOL
3520        LDY #6       POINT AT LENGTH
3530        >SYM LDA,TPTR USE MINIMUM LENGTH
3540        AND #$3F     ISOLATE LENGTH
3550        CMP SYMBOL,Y
3560        INY
3570        BCS .2
3580        TAX
3590 .2     >SYM LDA,TPTR COMPARE BYTES FROM BOTH
3600        AND #$7F     ALLOW FLAG BITS IN SYMBOL
3610        CMP SYMBOL,Y
3620        BCC .3       NOT THIS ONE, BUT KEEP LOOKING
3630        BNE .4       NOT IN THIS CHAIN
3640        DEX
3650        BEQ .5       THE NAME IS THE SAME OR A SUBSET
3660        INY          NEXT BYTE PAIR
3670        BNE .2       ...ALWAYS
3680 .3     JSR .7       UPDATE POINTER, CLEAR CARRY
3690        BCC .1       ...ALWAYS
3700 .4     SEC          DID NOT FIND
3710        LDX #0       RESTORE X=0
3720        RTS
3730 .5     LDY #6       TEST LENGTHS
3740        >SYM LDA,TPTR
3750        AND #$3F     ISOLATE LENGTH
3760        CMP SYMBOL+6 # CHARS IN SYMBOL IN TABLE
3770        BEQ .6       SAME EXACTLY
3780        BCS .4       NEW SYMBOL IS SHORTER
3790        BCC .3       NEW SYMBOL IS LONGER
3800 .6     LDY #2       POINT AT VALUE
3810 .65    >SYM LDA,TPTR SET UP VALUE FOR EXPR SCAN
3820        STA SYM.VALUE-2,Y
3830        INY
3840        CPY #6
3850        BCC .65
3860 .7     LDA TPTR
3870        STA STPNTR
3880        LDA TPTR+1
3890        STA STPNTR+1
3900        CLC          SIGNAL DID FIND IT
3910        RTS
3920 *--------------------------------
3930 .8     LDA CURRENT.MAJOR.LABEL
3940        STA STPNTR
3950        LDA CURRENT.MAJOR.LABEL+1
3960        BEQ .11
3970        STA STPNTR+1
3980        CLC
3990        LDY #6       POINT AT LENGTH
4000        >SYM LDA,STPNTR GET LENGTH OF MAJOR SYMBOL
4010        BPL .4       NO LOCAL SYMBOLS YET
4020        AND #$3F     MASK TO REAL LENGTH
4030        ADC #7       POINT AT LOCALS
4040        TAY
4050 .9     >SYM LDA,STPNTR
4060        BEQ .4       END OF LOCALS, NOT FOUND
4070        CMP SYMBOL+8 COMPARE TO NAME OF LOCAL
4080        BEQ .10      FOUND IT!
4090        INY          SKIP TO NEXT LOCAL
4100        INY
4110        BNE .9       ...ALWAYS
4120 .10    INY          POINT AT VALUE OFFSET
4130        >SYM LDA,STPNTR
4140        CLC
4150        LDY #2       POINT AT MAJOR VALUE
4160        >SYM ADC,STPNTR
4170        STA SYM.VALUE
4180        INY
4190        >SYM LDA,STPNTR
4200        ADC #0
4210        STA SYM.VALUE+1
4220        INY
4230        >SYM LDA,STPNTR
4240        ADC #0
4250        STA SYM.VALUE+2
4260        INY
4270        >SYM LDA,STPNTR
4280        ADC #0
4290        STA SYM.VALUE+3
4300        CLC
4310        RTS
4320 .11    LDY #QER9     NO NORMAL LABEL YET
4330        JMP SOFT.ERROR
4340 *--------------------------------
4350 *      SEARCH PRIVATE LABEL TABLE
4360 *--------------------------------
4370 SEARCH.PRIVATE.LABELS
4380        LDA MACLBL
4390        STA STPNTR
4400        LDA MACLBL+1
4410 .1     STA STPNTR+1
4420        CMP LO.MEM+1       END OF TABLE YET?
4430        BCS .3            ...YES, NO MORE LABELS
4440        LDY #6
4450        >SYM LDA,STPNTR
4460        AND #$3F     ISOLATE FROM FLAG BITS
4470        CMP SYMBOL+10
4480        BNE .2       NO
4490        DEY
4500        >SYM LDA,STPNTR
4510        CMP SYMBOL+9
4520        BNE .2       NO
4530        DEY
4540        >SYM LDA,STPNTR
4550        CMP SYMBOL+8
4560        BEQ .4       YES, FOUND IT!
4570 .2     CLC          BUMP PNTR TO NEXT LABEL
4580        LDA STPNTR
4590        ADC #7
4600        STA STPNTR
4610        LDA STPNTR+1
4620        ADC #0
4630        BNE .1       ...ALWAYS
4640 *--------------------------------
4650 .3     SEC          SIGNAL NOT FOUND
4660        RTS
4670 *--------------------------------
4680 .4     DEY
4690 .5     >SYM LDA,STPNTR
4700        STA SYM.VALUE,Y
4710        DEY
4720        BPL .5
4730        CLC
4740        RTS
4750 *--------------------------------
4760 *      ADD SYMBOL TO TABLE
4770 *--------------------------------
4780 STADD  LDA SYMBOL+7 SEE IF LOCAL SYMBOL
4790        CMP #CHR.PERIOD
4800        BEQ .5       YES
4810        CMP #':      COLON, PRIVATE LABEL
4820        BNE .11      NO, NORMAL LABEL
4830        JMP ADD.PRIVATE.LABEL
4840 .11    LDY #1       POINT AT POINTER
4850 .1     >SYM LDA,STPNTR GET CURRENT POINTER
4860        STA SYMBOL,Y
4870        LDA EOT,Y
4880        >SYM STA,STPNTR
4890        STA PNTR,Y
4900        STA CURRENT.MAJOR.LABEL,Y
4910        LDA ORGN,Y   VALUE
4920        STA SYMBOL+2,Y
4930        LDA ORGN+2,Y
4940        STA SYMBOL+4,Y
4950        DEY
4960        BPL .1
4970        CLC          COMPUTE ENTRY SIZE
4980        LDA SYMBOL+6 FROM SYMBOL SIZE
4990        ADC #7
5000 .2     PHA          SAVE SIZE
5010        LDY EOT+1
5020        CLC
5030        ADC EOT      SEE IF ROOM FOR NEW ENTRY
5040        BCC .10
5050        INY
5060   .DO AUXMEM
5070 .10    CPY /$C000
5080        BCS .4       MEM FULL ERR
5090        STA EOT
5100   .ELSE
5110 .10    CMP MACSTK
5120        TAX          SAVE LOW BYTE
5130        TYA          GET HIGH BYTE
5140        SBC MACSTK+1
5150        BCS .4       MEM FULL ERR
5160        STX EOT
5170   .FIN
5180        STY EOT+1
5190        PLA          GET SIZE
5200        TAY
5210        DEY          CORRECT FOR INDEXING
5220 .3     LDA SYMBOL,Y
5230        >SYM STA,PNTR
5240        DEY
5250        BPL .3
5260        RTS
5270 .4     JMP MFER     MEM FULL ERR
5280 *--------------------------------
5290 .5     LDY #6       LENGTH BYTE
5300        >SYM LDA,STPNTR
5310        BMI .6       ALREADY HAVE SOME LOCAL LABELS
5320        ORA #$80     SET LOCAL FLAG
5330        >SYM STA,STPNTR
5340        BNE .8       ...ALWAYS
5350 .6     LDA EOT      BACK UP EOT
5360        BNE .7       OVER 00 TERMINATOR
5370        DEC EOT+1    OF LOCALS
5380 .7     DEC EOT
5390 .8     LDA SYMBOL+8 NAME OF LOCAL
5400        STA SYMBOL   SET UP TO ADD TO SYMBOL TABLE
5410        SEC
5420        LDY #1
5430        JSR CALC.OFFSET.BYTE
5440        JSR CALC.OFFSET.BYTE
5450        BNE .9       ERROR > 255
5460        JSR CALC.OFFSET.BYTE
5470        BNE .9       ERROR > 255
5480        JSR CALC.OFFSET.BYTE
5490        BNE .9       ERROR > 255
5500        LDA EOT
5510        STA PNTR
5520        LDA EOT+1
5530        STA PNTR+1
5540        LDA #3       SIZE IS 3 BYTES
5550        BNE .2       ...ALWAYS
5560 .9     JMP GT255ERR  VALUE > 255
5570 *--------------------------------
5580 CALC.OFFSET.BYTE
5590        INY
5600        LDA ORGN-2,Y
5610        >SYM SBC,STPNTR
5620        STA SYMBOL-1,Y
5630        RTS
5640 *--------------------------------
5650 *      ADD A PRIVATE LABEL
5660 *--------------------------------
5670 ADD.PRIVATE.LABEL
5680        SEC
5690        LDA MACLBL
5700        SBC #7
5710        STA MACLBL
5720        STA STPNTR
5730        LDA MACLBL+1
5740        SBC #0
5750        STA MACLBL+1
5760        STA STPNTR+1
5770        CMP #8       BELOW $0800?
5780        BCC .3       YES, NO MORE ROOM
5790        LDY #6       POINT AT LAST BYTE
5800 .1     LDA SYMBOL+4,Y
5810        CPY #4
5820        BCS .2
5830        LDA ORGN,Y
5840 .2     >SYM STA,STPNTR
5850        DEY
5860        BPL .1
5870        RTS
5880 .3     JMP MFER
5890 *--------------------------------
