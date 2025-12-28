
1000 *SAVE X.ASM.6811
1010 *--------------------------------
1020 ASM.INIT
1030        LDA #15
1040        STA EMIT.MARGIN
1050        RTS
1060 *--------------------------------
1070 ASM.LINE
1080        LDA SEARCH.KEY   1ST LETTER
1090        CMP #'A'
1100        BCC OPER     ...NOT A LETTER, SO BADOP
1110        CMP #'Z'+1
1120        BCS OPER     ...NOT A LETTER, SO BADOP
1130        AND #$1F     ...MAKE 01...1A
1140        TAX
1150        LDA FIRST.LETTER.TABLE-1,X
1160        BEQ OPER     ...UNUSED LETTER
1170 *---BUILD OPTBL.PNTR INTO TABLE--------
1180        ADC #OPCODE.TABLE
1190        STA OPTBL.PNTR
1200        LDY /OPCODE.TABLE
1210        BCC .1
1220        INY
1230 .1     CPX #'S'-$40  WHICH HALF OF TABLE?
1240        BCC .2       ...FIRST HALF
1250        INY          ...SECOND HALF
1260 .2     JSR SEARCH.6811.TABLE
1270 *---FOUND IT!--------------------
1280 .3     LDA (OPTBL.PNTR),Y
1290        STA OPBASE
1300        INY
1310        LDA (OPTBL.PNTR),Y
1320        TAY
1330        LDA OP.MODE+1,Y
1340        PHA
1350        LDA OP.MODE,Y
1360        PHA
1370        RTS
1380 *--------------------------------
1390 OPER   LDA #ERR.BAD.OPCODE
1400        JMP ASM.ERROR
1410 *--------------------------------
1420        .MA MODE
1430 O..]1  .EQ *-OP.MODE
1440        .DA OP.]1-1
1450        .EM
1460 *--------------------------------
1470 OP.MODE
1480        >MODE INH1       0 -- SINGLE INHERENT
1490        >MODE INH2       2 -- DOUBLE INHERENT
1500        >MODE BREL       4 -- Bxx relative branches
1510        >MODE LDA        6 -- LDA group
1520        >MODE ADD        8 -- ADD group
1530        >MODE ASL        A -- ASL group
1540        >MODE DEC        C -- DEC group
1550        >MODE CPD         CPD, CPX, CPY, LDX, LDY
1560        >MODE DIV       10 -- DIV group
1570        >MODE JMP         JMP only
1580        >MODE JSR         JSR, STD, STS
1590        >MODE PSH       14 -- PSH or PUL A-B-X-Y
1600        >MODE BCLR      16 -- BCLR, BSET
1610        >MODE XGD       1A -- XGDX, XGDY
1620        >MODE STX         STX, STY
1630        >MODE LDD         LDD, LDS
1640 *--------------------------------
1650 OP.DIV LDY OPBASE
1660        LDA MODE.DIV.TABLE,Y
1670        STA SEARCH.KEY    last letter or 4-char opcode
1680        LDA MODE.DIV.TABLE+1,Y
1690        STA OPBASE   the opcode
1700        JSR GNC.UC   get next letter
1710        CMP SEARCH.KEY
1720        BEQ EMIT.OPBASE
1730        BNE OPER    
1740 *--------------------------------
1750 OP.XGD LDA #%00001100    X,Y
1760        JSR PARSE.REST.OF.OPCODE
1770        CPY #5       WAS IT Y?
1780        BNE OP.INH1
1790 ***    BEQ OP.INH2
1800 OP.INH2
1810        JSR EMIT.PREBYTE.18
1820 OP.INH1
1830 EMIT.OPBASE
1840        LDA OPBASE
1850 EMIT.AND.CHECK.FOR.END
1860        JSR EMIT
1870        LDY CHAR.PNTR     Check next character without advancing
1880        LDA WBUF,Y        for eol or blank
1890        AND #$5F          (accepts 00 and 20)
1900        BNE .1            ...neither eol nor blank
1910        RTS               ...good
1920 .1     JMP ERBA
1930 *--------------------------------
1940 OP.LDD LDA #%11111000    allow all 5 modes
1950        .HS 2C
1960 OP.JSR LDA #%01111000    allow DIR, EXT, and indexed
1970        .HS 2C
1980 OP.JMP LDA #%00111000    allow EXT and indexed
1990        JSR GENERAL.OPERAND
2000        LDA OPBASE
2010        ORA MODE.LDA.TABLE,Y
2020        STA OPBASE
2030        TYA          check for IMM mode
2040        BNE .1       ...not IMM
2050        INC ADDR.LENGTH   change to 16-bit operand
2060 .1     JMP EMIT.PREBYTE.OP.VALUE
2070 *--------------------------------
2080 OP.ADD LDA #%01110000    allow only A, B, or D
2090        .HS 2C
2100 OP.LDA LDA #%01100000    allow only A or B
2110        JSR PARSE.REST.OF.OPCODE
2120        LDA OPBASE
2130        CPY #3       check if it was D
2140        BNE .2       ...not ADDD or SUBD
2150        DEY          make Y=2 like "B"
2160        CMP #$80     ...is it SUBD?
2170        BNE .1       ...no, it is ADDD
2180        DEY          ...yes, so make Y=1 like 'A'
2190 .1     LDA #$83
2200 .2     ORA MODE.LDA.AB.TABLE,Y
2210        STA OPBASE
2220        LDA #%11111000    ACCEPT ALL 5 MODES
2230        JSR GENERAL.OPERAND
2240        LDA OPBASE
2250        ORA MODE.LDA.TABLE,Y
2260        STA OPBASE
2270        AND #$BF
2280        CMP #$87     STA IMM IS NOT LEGAL
2290        BEQ ERBA.2
2300        CMP #$83     CHECK FOR ADDD AND SUBD IMMEDIATE
2310        BNE EMIT.PREBYTE.OP.VALUE
2320        INC ADDR.LENGTH   CHANGE TO 16-BIT OPERAND
2330        BNE EMIT.PREBYTE.OP.VALUE   ....ALWAYS
2340 ERBA.2 JMP ERBA.EMIT.TWO
2350 *--------------------------------
2360 OP.DEC LDA #%11100000    BLANK, A, OR B
2370        .HS 2C
2380 OP.ASL LDA #%11110000    BLANK, A, B, OR D
2390        JSR PARSE.REST.OF.OPCODE
2400        TYA
2410        BEQ .3
2420        CPY #3       WAS IT D?
2430        BNE .1       ...NO
2440        LDA OPBASE
2450        AND #$07     TURN 44 OR 48 INTO 04 OR 00
2460        BNE .2
2470        LDA #$05
2480        BNE .2            ...ALWAYS
2490 .1     LDA OPBASE
2500        ORA MODE.LDA.TABLE-1,Y   00 OR 10
2510 .2     JMP EMIT.AND.CHECK.FOR.END
2520 .3     LDA #%00111000    ACCEPT ONLY EXT AND INDEXED
2530        JSR GENERAL.OPERAND
2540        LDA OPBASE
2550        ORA MODE.LDA.TABLE,Y
2560        STA OPBASE
2570 EMIT.PREBYTE.OP.VALUE
2580        CPY #4       need $18 prebyte?
2590        BNE .1
2600        JSR EMIT.PREBYTE.18    ...YES
2610 .1     JMP EMIT.OP.AND.VALUE
2620 *--------------------------------
2630 EMIT.PREBYTE.18
2640        LDA #$18
2650        JMP EMIT
2660 *--------------------------------
2670 OP.PSH LDA #%01101100    A,B,X,Y
2680        JSR PARSE.REST.OF.OPCODE
2690        LDA MODE.PSH.TABLE,Y
2700        BPL .1
2710        PHA
2720        JSR EMIT.PREBYTE.18
2730        PLA
2740        AND #$7F
2750 .1     ORA OPBASE
2760        JMP EMIT.AND.CHECK.FOR.END
2770 *--------------------------------
2780 PARSE.REST.OF.OPCODE
2790        STA SEARCH.KEY+2  LEGAL MASK = bABDXY00
2800        JSR GNC.UC
2810        LDY #-1
2820 .1     INY
2830        ASL SEARCH.KEY+2  see if this char allowed
2840        BCS .2            ...yes, test for it
2850        BNE .1            ...no, but more allowed
2860        JMP OPER
2870 .2     CMP OPCODE.SUFFIX.TABLE,Y
2880        BNE .1       ...not this one, check for others
2890        RTS
2900 *--------------------------------
2910 OPCODE.SUFFIX.TABLE
2920        .AS / ABDXY/
2930 *--------------------------------
2940 OP.STX LDA #%01111000    allow DIR, EXT, and indexed
2950        .HS 2C
2960 OP.CPD LDA #%11111000    allow all 5 modes
2970        JSR GENERAL.OPERAND
2980        TYA
2990        BNE .1       ...not IMM mode
3000        INC ADDR.LENGTH   CHANGE TO 16-BIT OPERAND
3010 .1     ASL          double the mode index
3020        ADC OPBASE   Add the offset
3030        TAY
3040        LDA MODE.CPD.TABLE+1,Y
3050        STA OPBASE
3060        LDA MODE.CPD.TABLE,Y
3070        BEQ EMIT.OP.AND.VALUE
3080        JSR EMIT     emit the prebyte
3090 ***    JMP EMIT.OP.AND.VALUE
3100 EMIT.OP.AND.VALUE
3110        JSR EMIT.OPBASE
3120 EMIT.VALUE
3130 .1     LDY ADDR.LENGTH   Starts at 1-4
3140        LDA EXP.VALUE-1,Y
3150        JSR EMIT
3160        DEC ADDR.LENGTH
3170        BNE .1            get another byte
3180        RTS
3190 *--------------------------------
3200 OP.BCLR.OPER JMP OPER
3210 OP.BCLR
3220        LDY OPBASE        index to table
3230        LDA MODE.BCLR.TABLE+2,Y
3240        STA OPBASE        opcode base
3250        LDA MODE.BCLR.TABLE,Y
3260        STA SEARCH.KEY    next letter
3270        LDA MODE.BCLR.TABLE+1,Y
3280        STA SEARCH.KEY+1  letter after that
3290        JSR GNC.UC        GET 4TH LETTER
3300        CMP SEARCH.KEY
3310        BNE OP.BCLR.OPER  NOT SPELLED RIGHT
3320        JSR GNC.UC
3330        CMP SEARCH.KEY+1
3340        BNE OP.BCLR.OPER  NOT SPELLED RIGHT
3350 *---look for DIR or indexed------
3360        JSR EXPR
3370        JSR GNC
3380        CMP #','     MUST BE COMMA HERE
3390        BNE OP.BCLR.ERBA      ...BAD ADDRESS
3400        JSR GNC.UC
3410        LDY #3       Y=3 for IND,X mode
3420        CMP #'X'     MIGHT BE 'X' OR 'Y'
3430        BEQ .1       ...it is X
3440        INY          Y=4 for IND,Y mode
3450        CMP #'Y'
3460        BEQ .1       ...it is Y
3470        LDY #1       Y=1 for DIR mode
3480        DEC CHAR.PNTR     back up scanner
3490        DEC CHAR.PNTR        all the way to the comma
3500 .1     STY MODE.BYTE     remember the mode
3510        JSR CHECK.FOR.SMALL.VALUE
3520        LDA EXP.VALUE     SAVE THE VALUE
3530        STA SEARCH.KEY+1
3540 *---look for mask----------------
3550        JSR GNC           NOW NEED A COMMA
3560        CMP #','
3570        BNE OP.BCLR.ERBA           ...MISSING COMMA
3580        LDA #%10000000    ALLOW ONLY IMMEDIATE
3590        JSR GENERAL.OPERAND
3600        LDA EXP.VALUE     GET MASK
3610        STA SEARCH.KEY    SAVE MASK
3620 *---see if branching...----------
3630        LDA OPBASE
3640        AND #$04
3650        BEQ OP.BCLR.BRANCH
3660 *---Emit op & address------------
3670 OP.BCLR.EMIT
3680        LDA SEARCH.KEY+1
3690        STA EXP.VALUE
3700        LDA OPBASE
3710        LDY MODE.BYTE
3720        CPY #3       is it indexed mode?
3730        BCC .2       ...NO
3740        ORA #$0C
3750 .2     STA OPBASE
3760        JSR EMIT.PREBYTE.OP.VALUE
3770 *---Emit mask--------------------
3780        LDA SEARCH.KEY
3790        JMP EMIT
3800 *--------------------------------
3810 OP.BCLR.ERBA    JMP ERBA.EMIT.THREE
3820 *---get relative address---------
3830 OP.BCLR.BRANCH
3840        JSR GNC      REQUIRE COMMA
3850        CMP #','
3860        BNE OP.BCLR.ERBA
3870        JSR EXPR
3880        LDX #0       ...IN CASE UNDEF
3890        LDA EXP.UNDEF
3900        BMI .4       ...SKIP THE CALCULATION
3910        LDA MODE.BYTE
3920        CMP #4       set carry if IND,Y mode
3930        LDA ORGN
3940        ADC #4       4 if DIR or IND,X; 5 if IND,Y
3950        STA EXP.VALUE+2
3960        LDA ORGN+1
3970        ADC #0
3980        STA EXP.VALUE+3
3990        SEC
4000        LDA EXP.VALUE
4010        SBC EXP.VALUE+2
4020        TAY
4030        LDA EXP.VALUE+1
4040        SBC EXP.VALUE+3
4050        TAX          SAVE HI-BYTE
4060        TYA          GET LO-BYTE
4070        BPL .4
4080        INX
4090 .4     PHA          SAVE RELATIVE OFFSET
4100        TXA          SAVE MODIFIED HI-BYTE
4110        PHA
4120        JSR OP.BCLR.EMIT
4130        PLA          GET MODIFIED HI-BYTE
4140        BNE ERR.RANGE.EMIT.ONE
4150        PLA          GET RELATIVE OFFSET
4160        JMP EMIT
4170 *--------------------------------
4180 OP.BREL
4190        JSR EXPR
4200        JSR EMIT.OPBASE
4210        LDA EXP.UNDEF
4220        BMI .3       ...UNDEFINED
4230        LDY EXP.VALUE+1
4240        CLC          COMPUTE RELATIVE OFFSET
4250        LDA EXP.VALUE
4260        SBC ORGN
4270        STA EXP.VALUE
4280        BPL .2
4290        INY
4300 .2     TYA
4310        SBC ORGN+1
4320        BNE ERR.RANGE.EMIT.ONE
4330        LDA EXP.VALUE
4340 .3     JMP EMIT
4350 *--------------------------------
4360 ERR.RANGE.EMIT.TWO
4370        JSR EMIT.ZERO
4380 ERR.RANGE.EMIT.ONE
4390        JSR EMIT.ZERO
4400        LDA #ERR.RANGE
4410        JMP ASM.ERROR
4420 *--------------------------------
4430 *--------------------------------
4440 *   SEARCH COMPRESSED OPCODE TABLES
4450 *      ADDRESS OF TABLE IN Y,A
4460 *--------------------------------
4470 SEARCH.6811.TABLE
4480        STA OPTBL.PNTR
4490        STY OPTBL.PNTR+1
4500 *---Try matching 2nd letter------
4510        LDY #0
4520 .1     LDA (OPTBL.PNTR),Y      POSSIBLE MATCH
4530        ORA #$40          MAKE LIKE ASCII
4540        CMP SEARCH.KEY+1      2ND LETTER
4550        BEQ .5       ...match 2nd letter
4560 *---Scan to next 8-bit entry-----
4570        DEY          back up to compensate for iny-iny
4580        DEY
4590 .2     INY          next 24-bit entry
4600        INY
4610        INY
4620        LDA (OPTBL.PNTR),Y
4630        BMI .2       ...another 24-bit entry
4640        ASL          check if beyond our sub-group
4650        BPL .1       ...no, valid 2nd letter option
4660 .3     JMP OPER     no match in the table
4670 *---Try matching third letter----
4680 .4     INY
4690 .5     INY
4700        LDA (OPTBL.PNTR),Y
4710        BPL .3       ...no more options, not in table
4720        INY          POINT AT DATA
4730        EOR #$C0          MAKE LIKE ASCII
4740        CMP SEARCH.KEY+2      COMPARE 3RD LETTER
4750        BNE .4       ...did not match, try next entry
4760 *---Found it!--------------------
4770        RTS
4780 *--------------------------------
4790 IMMEDIATE
4800        JSR EXP1
4810        LDA DLIM
4820        CMP #'/'     #=23, /=2F, ^=5E
4830        BCC .4            ...#
4840        BEQ .3            .../
4850        JSR EXP.OVER.256  ...^
4860 .3     JSR EXP.OVER.256
4870 .4     LDY #0       SIGNAL IMMEDIATE MODE
4880        LDA SEARCH.KEY+2  SEE IF IMMED ACCEPTABLE
4890        BPL ERBA     ...NO
4900        RTS
4910 *--------------------------------
4920 ERBA.EMIT.THREE
4930        JSR EMIT.ZERO
4940 ERBA.EMIT.TWO
4950        JSR EMIT.ZERO
4960        JSR EMIT.ZERO
4970 ERBA   LDA #ERR.BAD.ADDRESS
4980        JMP ASM.ERROR
4990 EMIT.ZERO
5000        LDA #0
5010        JMP EMIT
5020 *--------------------------------
5030 *   CALL:  (A)=MASK FOR ACCEPTABLE MODES
5040 *   RETURN:
5050 *      # BYTES IN ADDRESS IN ADDR.LENGTH
5060 *      (Y) = INDEX TO ADDR.MODE.BITS
5070 *--------------------------------
5080 GENERAL.OPERAND
5090        STA SEARCH.KEY+2
5100        JSR GNNB     GET NEXT NON-BLANK
5110        BCS ERBA.EMIT.TWO     ...NO OPERAND
5120 *---PARSE PREFIX-----------------
5130        LDY #1
5140        STY ADDR.LENGTH
5150        STA DLIM
5160        CMP #'#'
5170        BEQ IMMEDIATE
5180        CMP #'/'
5190        BEQ IMMEDIATE
5200        CMP #'^'
5210        BEQ IMMEDIATE
5220        INY          Y=2
5230        CMP #'>'
5240        BEQ .1       MAKE FORCE SIZE = 2
5250        DEY          Y=1
5260        CMP #'<'
5270        BEQ .1       ...make FORCE SIZE = 1
5280        DEY          Y=0
5290        DEC CHAR.PNTR     ...no prefix, so backup
5300 .1     STY FORCE.ADDR.SIZE
5310 *---PARSE THE EXPRESSION---------
5320        JSR EXP1
5330        JSR GNC
5340        BEQ .4       ...DIRECT OR EXTENDED
5350 *---Must be ,X or ,Y-------------
5360        CMP #','
5370        BNE ERBA.1   ...INVALID SUFFIX
5380        JSR GNC.UC
5390        LDY #3       mode index for ,X
5400        CMP #'X'
5410        BEQ .2       we have ,X
5420        INY          Y=4, index for ,Y
5430        CMP #'Y'
5440        BNE ERBA.1   neither
5450 .2     LDX FORCE.ADDR.SIZE
5460        BEQ .3       ...neither < nor >
5470        CPX #1       did they use  WHICH IS ILLEGAL
5500 .3     INX          X=1, for one byte operand
5510        JSR CHECK.FOR.SMALL.VALUE
5520        JMP .6            ...GOOD
5530 *---Direct or Extended-----------
5540 .4     LDX FORCE.ADDR.SIZE
5550        LDY FORCE.ADDR.SIZE
5560        BNE .6       ...FORCED WITH < or >
5570        LDX #2       ASSUME 2-BYTE ADDRESS
5580        LDY #2       ASSUME EXT MODE
5590        LDA EXP.UNDEF
5600        BMI .6
5610        LDA EXP.VALUE+3   DO NOT ALLOW more than 16 bits
5620        ORA EXP.VALUE+2
5630        BNE ERBA.1           ...BAD ADDR
5640        LDA PASS     IGNORE FWD REF FLAG IN PASS 1
5650        BEQ .5       ...PASS 1
5660        LDA EXP.FWDREF    ...PASS 2, DEFINED
5670        BEQ .6            ...AND IS FWD REF
5680 .5     LDA EXP.VALUE+1
5690        BNE .6            ...16-BIT ADDRESS
5700        BIT SEARCH.KEY+2  SEE IF 'DIR' IS ALLOWED
5710        BVC .6            ...NO, SO LEAVE IT 'EXT'
5720        DEX               ...8-BIT ADDRESS
5730        DEY               ...DIR MODE
5740 .6     STX ADDR.LENGTH
5750        LDA SEARCH.KEY+2  ACCEPTABLE MODE BITS
5760        AND BIT.TABLE,Y
5770        BEQ ERBA.1
5780        RTS
5790 ERBA.1 JMP ERBA.EMIT.TWO    ILLEGAL
5800 *--------------------------------
5810 BIT.TABLE .HS 80.40.20.10.08
5820 *--------------------------------
5830 CHECK.FOR.SMALL.VALUE
5840        LDA EXP.UNDEF
5850        BMI .1       ...undefined, so acceptable
5860        LDA EXP.VALUE+3
5870        ORA EXP.VALUE+2
5880        ORA EXP.VALUE+1
5890        BEQ .1
5900        JMP ERBA.1
5910 .1     RTS
5920 *--------------------------------
5930 EXP.OVER.256
5940        LDA EXP.VALUE+1
5950        STA EXP.VALUE
5960        LDA EXP.VALUE+2
5970        STA EXP.VALUE+1
5980        LDA EXP.VALUE+3
5990        STA EXP.VALUE+2
6000        LDA #0
6010        STA EXP.VALUE+3
6020        RTS
6030 *--------------------------------
6040 FIRST.LETTER.TABLE
6050        .DA #LTR.A-OPCODE.TABLE
6060        .DA #LTR.B-OPCODE.TABLE
6070        .DA #LTR.C-OPCODE.TABLE
6080        .DA #LTR.D-OPCODE.TABLE
6090        .DA #LTR.E-OPCODE.TABLE
6100        .DA #LTR.F-OPCODE.TABLE
6110        .DA #LTR.G-OPCODE.TABLE
6120        .DA #LTR.H-OPCODE.TABLE
6130        .DA #LTR.I-OPCODE.TABLE
6140        .DA #LTR.J-OPCODE.TABLE
6150        .DA #LTR.K-OPCODE.TABLE
6160        .DA #LTR.L-OPCODE.TABLE
6170        .DA #LTR.M-OPCODE.TABLE
6180        .DA #LTR.N-OPCODE.TABLE
6190        .DA #LTR.O-OPCODE.TABLE
6200        .DA #LTR.P-OPCODE.TABLE
6210        .DA #LTR.Q-OPCODE.TABLE
6220        .DA #LTR.R-OPCODE.TABLE
6230        .DA #LTR.S-OPCODE.TABLE
6240        .DA #LTR.T-OPCODE.TABLE
6250        .DA #LTR.U-OPCODE.TABLE
6260        .DA #LTR.V-OPCODE.TABLE
6270        .DA #LTR.W-OPCODE.TABLE
6280        .DA #LTR.X-OPCODE.TABLE
6290        .DA #LTR.Y-OPCODE.TABLE
6300        .DA #LTR.Z-OPCODE.TABLE
6310 *--------------------------------
6320 *   The vector above points into a group in the table below,
6330 *      according to the first letter of the opcode.  Each
6340 *      first-letter-group starts with a byte having bits
6350 *      7 and 6 equal to 0 and 1, respectively.
6360 *
6370 *   The search program begins by using the opcode's first
6380 *      letter to look up an index from the vector above.
6390 *
6400 *   There are two kinds of entries, distinguished by first bit:
6410 *      8-bit entries:  first bit = 0
6420 *     24-bit entries:  first bit = 1
6430 *
6440 *   The 8-bit entries give the value of the second letter
6450 *      of the opcode names, and the 24-bit entries give
6460 *      the value of the third letter of the opcode names.
6470 *      The search program compares the opcode's second
6480 *          letter with succeeding 8-bit entries until
6490 *          it either finds a match, or finds the last
6500 *          8-bit entry in the sub-group.
6510 *
6520 *   Each 8-bit entry is followed by one or more 24-bit entries.
6530 *      The search program stops comparing an opcode's 3rd
6540 *          letter with 24-bit entries when it encounters
6550 *          the next 8-bit entry.
6560 *
6570 *   Each list of 8-bit entries begins with an 8-bit entry
6580 *      having bit 6 = 1.  Subsequent 8-bit entries under
6590 *      the same initial letter have bit 6 = 0.
6600 *
6610 *   Bits 5-0 in an 8-bit or the first byte of a 24-bit
6620 *      entry are the diminsihed ASCII code for the
6630 *      second or third letter of the opcode, respectively.
6640 *
6650 *   The value of the second byte of a 24-bit entry is
6660 *      an opcode base or an index to a mode table.
6670 *
6680 *   The value of the third byte of a 24-bit entry is a
6690 *      index to a jump table for the corresponding mode.
6700 *
6710 *--------------------------------
6720 OP..1  .SE 0
6730 OP..2  .SE 0
6740        .MA OP
6750        .DO "]1"=OP..1=0
6760 LTR.]1  .DA #"]2"-$80    bits 76 = 01
6770 OP..1  .SE "]1"
6780 OP..2  .SE "]2"
6790        .ELSE
6800        .DO "]2"=OP..2=0
6810        .DA #"]2"-$C0     bits 76 = 00
6820 OP..2  .SE "]2"
6830        .FIN
6840        .FIN
6850        .DA #"]3"-$40,#$]4,#O..]5  bits 76 = 10
6860        .EM
6870 *--------------------------------
6880 OPCODE.TABLE
6890 LTR.G
6900 LTR.H
6910 LTR.K
6920 LTR.Q
6930 LTR.U
6940 LTR.V
6950 LTR.Y
6960 LTR.Z  .HS 00
6970        >OP A,B,A,1B,INH1   1B
6980        >OP A,B,X,3A,INH1   3A
6990        >OP A,B,Y,3A,INH2   18.3A
7000        >OP A,D,C,89,LDA
7010        >OP A,D,D,8B,ADD
7020        >OP A,N,D,84,LDA
7030        >OP A,S,L,48,ASL
7040        >OP A,S,R,47,DEC
7050        >OP B,C,C,24,BREL
7060        >OP B,C,L,00,BCLR   BCLR, 00 is index
7070        >OP B,C,S,25,BREL
7080        >OP B,E,Q,27,BREL
7090        >OP B,G,E,2C,BREL
7100        >OP B,G,T,2E,BREL
7110        >OP B,H,I,22,BREL
7120        >OP B,H,S,24,BREL
7130        >OP B,I,T,85,LDA
7140        >OP B,L,E,2F,BREL
7150        >OP B,L,O,25,BREL
7160        >OP B,L,S,23,BREL
7170        >OP B,L,T,2D,BREL
7180        >OP B,M,I,2B,BREL
7190        >OP B,N,E,26,BREL
7200        >OP B,P,L,2A,BREL
7210        >OP B,R,A,20,BREL
7220        >OP B,R,C,06,BCLR   BRCLR, 06 is index
7230        >OP B,R,N,21,BREL
7240        >OP B,R,S,09,BCLR   BRSET, 09 is index
7250        >OP B,S,E,03,BCLR   BSET, 03 is index
7260        >OP B,S,R,8D,BREL
7270        >OP B,V,C,28,BREL
7280        >OP B,V,S,29,BREL
7290        >OP C,B,A,11,INH1
7300        >OP C,L,C,0C,INH1
7310        >OP C,L,I,0E,INH1
7320        >OP C,L,R,4F,DEC
7330        >OP C,L,V,0A,INH1
7340        >OP C,M,P,81,LDA
7350        >OP C,O,M,43,DEC
7360        >OP C,P,D,00,CPD   00 is index
7370        >OP C,P,X,0A,CPD   0A is index
7380        >OP C,P,Y,14,CPD   14 is index
7390        >OP D,A,A,19,INH1
7400        >OP D,E,C,4A,DEC
7410        >OP D,E,S,34,INH1
7420        >OP D,E,X,09,INH1
7430        >OP D,E,Y,09,INH2   18.09
7440        >OP E,O,R,88,LDA
7450        >OP F,D,I,00,DIV   FDIV, 00 is index
7460        >OP I,D,I,02,DIV   IDIV, 02 is index
7470        >OP I,N,C,4C,DEC
7480        >OP I,N,S,31,INH1
7490        >OP I,N,X,08,INH1
7500        >OP I,N,Y,08,INH2   18.08
7510        >OP J,M,P,4E,JMP
7520        >OP J,S,R,8D,JSR
7530        >OP L,D,A,86,LDA
7540        >OP L,D,D,CC,LDD
7550        >OP L,D,S,8E,LDD
7560        >OP L,D,X,1E,CPD   1E is index
7570        >OP L,D,Y,28,CPD   28 is index
7580        >OP L,S,L,48,ASL
7590        >OP L,S,R,44,ASL
7600        >OP M,U,L,3D,INH1
7610        >OP N,E,G,40,DEC
7620        >OP N,O,P,01,INH1
7630        >OP O,R,A,8A,LDA
7640        >OP P,S,H,04,PSH   PSHA-B-X-Y
7650        >OP P,U,L,00,PSH   PULA-B-X-Y
7660        >OP R,O,L,49,DEC
7670        >OP R,O,R,46,DEC
7680        >OP R,T,I,3B,INH1
7690        >OP R,T,S,39,INH1
7700        >OP S,B,A,10,INH1
7710        >OP S,B,C,82,LDA
7720        >OP S,E,C,0D,INH1
7730        >OP S,E,I,0F,INH1
7740        >OP S,E,V,0B,INH1
7750        >OP S,T,A,87,LDA
7760        >OP S,T,D,CD,JSR
7770        >OP S,T,O,04,DIV   STOP, 04 is index
7780        >OP S,T,S,8F,JSR
7790        >OP S,T,X,32,STX    32 is an index
7800        >OP S,T,Y,3C,STX    3C is an index
7810        >OP S,U,B,80,ADD
7820        >OP S,W,I,3F,INH1
7830        >OP T,A,B,16,INH1
7840        >OP T,A,P,06,INH1
7850        >OP T,B,A,17,INH1
7860        >OP T,E,S,06,DIV   TEST, 06 is index
7870        >OP T,P,A,07,INH1
7880        >OP T,S,T,4D,DEC
7890        >OP T,S,X,30,INH1
7900        >OP T,S,Y,30,INH2   18.30
7910        >OP T,X,S,35,INH1
7920        >OP T,Y,S,35,INH2   18.35
7930        >OP W,A,I,3E,INH1
7940        >OP X,G,D,8F,XGD   XGDX,XGDY
7950        .HS 40       <<>>
7960 *--------------------------------
7970 MODE.CPD.TABLE
7980 *           IMM    DIR    EXT   IND,X  IND,Y
7990        .HS 1A.83..1A.93..1A.83..1A.A3..CD.A3  CPD (00)
8000        .HS 00.8C..00.9C..00.BC..00.AC..CD.AC  CPX (0A)
8010        .HS 18.8C..18.9C..18.BC..1A.AC..18.AC  CPY (14)
8020        .HS 00.CE..00.DE..00.FE..00.EE..CD.EE  LDX (1E)
8030        .HS 18.CE..18.DE..18.FE..1A.EE..18.EE  LDY (28)
8040 *
8050        .HS 00.00..00.DF..00.FF..00.EF..CD.EF  STX (32)
8060        .HS 00.00..18.DF..18.FF..1A.EF..18.EF  STY (3C)
8070 *--------------------------------
8080        .MA MIX
8090        .AS /]1/
8100        .HS ]2
8110        .EM
8120 *--------------------------------
8130 MODE.BCLR.TABLE
8140        >MIX "R ",15      BCLR
8150        >MIX "T ",14      BSET
8160        >MIX "LR",13      BRCLR
8170        >MIX "ET",12      BRSET
8180 *--------------------------------
8190 MODE.DIV.TABLE
8200        >MIX V,03         FDIV
8210        >MIX V,02         IDIV
8220        >MIX P,CF         STOP
8230        >MIX T,00         TEST
8240 *--------------------------------
8250 MODE.PSH.TABLE .EQ *-1   NO ENTRY FOR BLANK
8260        .HS 32.33.00.38.B8   PSH, PUL A-B-X-Y
8270 *--------------------------------
8280 MODE.LDA.TABLE
8290        .HS 00.10.30.20.20
8300 *--------------------------------
8310 MODE.LDA.AB.TABLE .EQ *-1
8320        .HS 00.40
8330 *--------------------------------
