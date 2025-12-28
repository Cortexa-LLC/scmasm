
1000 *SAVE X.TABLES.65816
1010 *--------------------------------
1020 LEGAL.JUMP.MODES
1030        .HS FF.00.00.FF.FF.FF
1040        .HS FF.FF.03.02.FF.FF
1050        .HS 01.FF.02.FF.03
1060 *--------------------------------
1070 JUMP.OPCODES
1080        .HS 4C.5C.6C.7C   JMP
1090        .HS 20.22.00.FC   JSR
1100        .HS 00.00.DC.00   JML
1110        .HS 22.22.00.00   JSL
1120        .HS F4.00.00.00   PEA
1130 *--------------------------------
1140 MODE.CHARS
1150        .AS / Y,)SX,/
1160 *--------------------------------
1170 MODE.TABLE
1180        .HS 00       1 -- DIRECT
1190        .HS 40       2 -- ABSOLUTE
1200        .HS 30       3 -- DIRECT,X
1210        .HS 70       4 -- ABSOLUTE,X
1220        .HS 21       5 -- DIRECT,Y
1230        .HS 61       6 -- ABSOLUTE,Y
1240        .HS 07       7 -- (DIRECT),Y
1250        .HS 34       8 -- (DIRECT,X)
1260 *---IN 65C02, 802, 816-----------
1270        .HS 04       9 -- (DIRECT)
1280 *---IN 65802, 816----------------
1290        .HS 28       A -- ...,S
1300        .HS 2F       B -- (...,S),Y
1310 *---ONLY IN 65816----------------
1320        .HS 80       C -- LONG
1330        .HS B0       D -- LONG,X
1340        .HS 44       E -- >(DIRECT)
1350        .HS 47       F -- >(DIRECT),Y
1360 *---SPECIAL FOR JMP,JSR (A,X)----
1370        .HS 74      10 -- (ABSOLUTE,X)
1380 MODE.TABLE.SIZE .EQ *-MODE.TABLE
1390 *--------------------------------
1400 ADDR.MODE.BITS.CLASS.1
1410        .HS 08       0 -- IMMEDIATE
1420        .HS 04       1 -- DIRECT
1430        .HS 0C       2 -- ABSOLUTE
1440        .HS 14       3 -- DIRECT,X
1450        .HS 1C       4 -- ABSOLUTE,X
1460        .HS FF       5 -- DIRECT,Y  <<>>
1470        .HS 18       6 -- ABSOLUTE,Y
1480        .HS 10       7 -- (DIRECT),Y
1490        .HS 00       8 -- (DIRECT,X)
1500 *---IN 65C02, 802, 816-----------
1510        .HS 13       9 -- (DIRECT)
1520 *---IN 65802, 816----------------
1530        .HS 02       A -- ...,S
1540        .HS 12       B -- (...,S),Y
1550 *---ONLY IN 65816----------------
1560        .HS 0E       C -- LONG
1570        .HS 1E       D -- LONG,X
1580        .HS 06       E -- >(DIRECT)
1590        .HS 16       F -- >(DIRECT),Y
1600 *--------------------------------
1610 ADDR.MODE.BITS.CLASS.5
1620        .HS 00       0 -- IMMEDIATE
1630        .HS 04       1 -- DIRECT
1640        .HS 0C       2 -- ABSOLUTE
1650        .HS 14       3 -- DIRECT,X
1660        .HS 1C       4 -- ABSOLUTE,X
1670        .HS 14       5 -- DIRECT,Y
1680        .HS 1C       6 -- ABSOLUTE,Y
1690 *--------------------------------
1700 CLASS.5.MODE.MASKS
1710        .HS 80.40.20.10.08.04.02
1720 *--------------------------------
1730 FIRST.LETTER.TABLE
1740        .DA #LTR.A-OPCODE.TABLE
1750        .DA #LTR.B-OPCODE.TABLE
1760        .DA #LTR.C-OPCODE.TABLE
1770        .DA #LTR.D-OPCODE.TABLE
1780        .DA #LTR.E-OPCODE.TABLE
1790        .DA #LTR.F-OPCODE.TABLE
1800        .DA #LTR.G-OPCODE.TABLE
1810        .DA #LTR.H-OPCODE.TABLE
1820        .DA #LTR.I-OPCODE.TABLE
1830        .DA #LTR.J-OPCODE.TABLE
1840        .DA #LTR.K-OPCODE.TABLE
1850        .DA #LTR.L-OPCODE.TABLE
1860        .DA #LTR.M-OPCODE.TABLE
1870        .DA #LTR.N-OPCODE.TABLE
1880        .DA #LTR.O-OPCODE.TABLE
1890        .DA #LTR.P-OPCODE.TABLE
1900        .DA #LTR.Q-OPCODE.TABLE
1910        .DA #LTR.R-OPCODE.TABLE
1920        .DA #LTR.S-OPCODE.TABLE
1930        .DA #LTR.T-OPCODE.TABLE
1940        .DA #LTR.U-OPCODE.TABLE
1950        .DA #LTR.V-OPCODE.TABLE
1960        .DA #LTR.W-OPCODE.TABLE
1970        .DA #LTR.X-OPCODE.TABLE
1980        .DA #LTR.Y-OPCODE.TABLE
1990        .DA #LTR.Z-OPCODE.TABLE
2000 *--------------------------------
2010 *   TWO KINDS OF ENTRIES, DISTINGUISHED BY FIRST BIT:
2020 *      8-BIT ENTRIES:  FIRST BIT = 0
2030 *     24-BIT ENTRIES:  FIRST BIT = 1
2040 *
2050 *      FIRST ENTRY AT EACH LETTER IS AN 8-BIT ENTRY.
2060 *      EACH 8-BIT ENTRY IS FOLLOWED BY ONE OR MORE
2070 *      24-BIT ENTRIES.
2080 *      THE SUB-LIST OF 24-BIT ENTRIES IS TERMINATED
2090 *          BY THE NEXT 8-BIT ENTRY.
2100 *      THE LIST OF 8-BIT ENTRIES IS TERMINATED BY
2110 *          AN 8-BIT ENTRY WITH BIT 6 = 1.
2120 *
2130 *      THE VALUE OF BITS 5-0 IN AN 8-BIT ENTRY
2140 *          IS THE DIMINISHED ASCII CODE FOR THE
2150 *          SECOND LETTER OF AN OPCODE.
2160 *      THE VALUE OF BITS 5-0 OF A 24-BIT ENTRY
2170 *          IS THE DIMINISHED ASCII CODE FOR THE
2180 *          THIRD LETTER OF AN OPCODE.
2190 *                   A...Z = $81...9A
2200 *                   BLANK = $E0
2210 *                   '1'   = $F1
2220 *      THE VALUE OF THE SECOND BYTE OF A 24-BIT
2230 *          ENTRY IS AN OPCODE BASE.
2240 *      THE THIRD BYTE OF A 24-BIT ENTRY HAS TWO PARTS:
2250 *          BITS 4-1 ARE AN INDEX TO THE OP.MODE
2260 *              JUMP TABLE IN ASM.65816
2270 *          BITS 7-5 AND 0 ARE LEVEL MASK BITS.
2280 *               000XXXX0 = 6502 OPCODE
2290 *               000XXXX1 = SWEET-16
2300 *               001XXXX0 = 65C02
2310 *               010XXXX0 = ROCKWELL SPECIALS
2320 *               100XXXX0 = 65816
2330 *
2340 *          LEVEL.MASK = $00 FOR 6502
2350 *                     = $20 FOR 65C02
2360 *                     = $60 FOR ROCKWELL C02
2370 *                     = $A0 FOR 65816
2380 *--------------------------------
2390 OP..1  .SE 0
2400 OP..2  .SE 0
2410        .MA OP
2420        .DO "]1"=OP..1=0
2430 LTR.]1  .DA #"]2"-$80    bits 76 = 01
2440 OP..1  .SE "]1"
2450 OP..2  .SE "]2"
2460        .ELSE
2470        .DO "]2"=OP..2=0
2480        .DA #"]2"-$C0      bits 76 = 00
2490 OP..2  .SE "]2"
2500        .FIN
2510        .FIN
2520        .DA #"]3"^$40,#$]4,#O..]5!O..]6   bits 76 = 10 or 11
2530        .EM
2540 *--------------------------------
2550 O..65816  .EQ $80
2560 O..65R02  .EQ $40
2570 O..65C02  .EQ $20
2580 O..SWEET  .EQ $01
2590 O..       .EQ $00
2600 *--------------------------------
2610 OPCODE.TABLE
2620 LTR.F
2630 LTR.G
2640 LTR.H
2650 LTR.K
2660 LTR.Q
2670 LTR.U
2680 LTR.V
2690 LTR.Y
2700 LTR.Z  .HS 00
2710 *--------------------------------
2720        >OP A,D,C,61,COPS
2730        >OP A,D,D,A1,XN,SWEET
2740        >OP A,N,D,21,COPS
2750        >OP A,S,L,02,SHIFTS
2760        >OP B,C,C,90,REL8
2770        >OP B,C,S,B0,REL8
2780        >OP B,C," ",03,REL8,SWEET
2790        >OP B,E,Q,F0,REL8
2800        >OP B,G,E,B0,REL8
2810        >OP B,I,T,00,BITS
2820        >OP B,L,T,90,REL8
2830        >OP B,M,I,30,REL8
2840        >OP B,M," ",05,REL8,SWEET
2850        >OP B,M,1,08,REL8,SWEET
2860        >OP B,N,E,D0,REL8
2870        >OP B,N,C,02,REL8,SWEET
2880        >OP B,N,M,09,REL8,SWEET   (BNM1)
2890        >OP B,N,Z,07,REL8,SWEET
2900        >OP B,P,L,10,REL8
2910        >OP B,P," ",04,REL8,SWEET
2920        >OP B,R,A,80,REL8,65C02
2930        >OP B,R,K,00,SNGL
2940        >OP B,R,L,82,REL16,65816
2950        >OP B,R," ",01,REL8,SWEET
2960        >OP B,V,C,50,REL8
2970        >OP B,V,S,70,REL8
2980        >OP B,B,R,0F,ROCKB,65R02
2990        >OP B,B,S,8F,ROCKB,65R02
3000        >OP B,K," ",0A,SNGL,SWEET
3010        >OP B,S," ",0C,REL8,SWEET
3020        >OP B,Z," ",06,REL8,SWEET
3030        >OP C,L,C,18,SNGL
3040        >OP C,L,D,D8,SNGL
3050        >OP C,L,I,58,SNGL
3060        >OP C,L,V,B8,SNGL
3070        >OP C,M,P,C1,COPS
3080        >OP C,O,P,02,CRS,65816
3090        >OP C,P,X,04,BITS
3100        >OP C,P,Y,03,BITS
3110        >OP C,P,R,D1,XN,SWEET
3120        >OP D,E,C,C2,SHIFTS
3130        >OP D,E,X,CA,SNGL
3140        >OP D,E,Y,88,SNGL
3150        >OP D,C,R,F1,XN,SWEET
3160        >OP E,O,R,41,COPS
3170        >OP I,N,C,E2,SHIFTS
3180        >OP I,N,X,E8,SNGL
3190        >OP I,N,Y,C8,SNGL
3200        >OP I,N,R,E1,XN,SWEET
3210        >OP J,M,L,08,JUMPS,65816
3220        >OP J,M,P,00,JUMPS
3230        >OP J,S,L,0C,JUMPS,65816
3240        >OP J,S,R,04,JUMPS
3250        >OP L,D,A,A1,COPS
3260        >OP L,D,X,02,BITS
3270        >OP L,D,Y,01,BITS
3280        >OP L,D," ",23,XN,SWEET
3290        >OP L,D,D,42,XN,SWEET
3300        >OP L,S,R,42,SHIFTS
3310        >OP M,V,N,54,MOVES,65816
3320        >OP M,V,P,44,MOVES,65816
3330        >OP N,O,P,EA,SNGL
3340        >OP O,R,A,01,COPS
3350        >OP P,E,A,10,JUMPS,65816
3360        >OP P,E,I,0A,BITS,65816
3370        >OP P,E,R,62,REL16,65816
3380        >OP P,H,A,48,SNGL
3390        >OP P,H,B,8B,SNGL,65816
3400        >OP P,H,D,0B,SNGL,65816
3410        >OP P,H,K,4B,SNGL,65816
3420        >OP P,H,P,08,SNGL
3430        >OP P,H,X,DA,SNGL,65C02
3440        >OP P,H,Y,5A,SNGL,65C02
3450        >OP P,L,A,68,SNGL
3460        >OP P,L,B,AB,SNGL,65816
3470        >OP P,L,D,2B,SNGL,65816
3480        >OP P,L,P,28,SNGL
3490        >OP P,L,X,FA,SNGL,65C02
3500        >OP P,L,Y,7A,SNGL,65C02
3510        >OP P,O,P,62,POP,SWEET    (POP,POPD)
3520        >OP R,E,P,C2,CRS,65816
3530        >OP R,O,L,22,SHIFTS
3540        >OP R,O,R,62,SHIFTS
3550        >OP R,T,I,40,SNGL
3560        >OP R,T,L,6B,SNGL,65816
3570        >OP R,T,S,60,SNGL
3580        >OP R,T,N,00,SNGL,SWEET
3590        >OP R,M,B,07,ROCKC,65R02
3600        >OP R,S," ",0B,SNGL,SWEET
3610        >OP S,B,C,E1,COPS
3620        >OP S,E,C,38,SNGL
3630        >OP S,E,D,F8,SNGL
3640        >OP S,E,I,78,SNGL
3650        >OP S,E,P,E2,CRS,65816
3660        >OP S,E,T,11,SET,SWEET
3670        >OP S,T,A,81,COPS
3680        >OP S,T,P,DB,SNGL,65816
3690        >OP S,T,P,72,XN,SWEET
3700        >OP S,T,X,06,BITS
3710        >OP S,T,Y,05,BITS
3720        >OP S,T,Z,07,BITS,65C02
3730        >OP S,T," ",33,XN,SWEET
3740        >OP S,T,D,52,XN,SWEET
3750        >OP S,U,B,B1,XN,SWEET
3760        >OP S,M,B,87,ROCKC,65R02
3770        >OP T,A,X,AA,SNGL
3780        >OP T,A,Y,A8,SNGL
3790        >OP T,C,D,5B,SNGL,65816
3800        >OP T,C,S,1B,SNGL,65816
3810        >OP T,D,C,7B,SNGL,65816
3820        >OP T,R,B,09,BITS,65C02
3830        >OP T,S,B,08,BITS,65C02
3840        >OP T,S,C,3B,SNGL,65816
3850        >OP T,S,X,BA,SNGL
3860        >OP T,X,A,8A,SNGL
3870        >OP T,X,S,9A,SNGL
3880        >OP T,X,Y,9B,SNGL,65816
3890        >OP T,Y,A,98,SNGL
3900        >OP T,Y,X,BB,SNGL,65816
3910        >OP W,A,I,CB,SNGL,65816
3920        >OP W,D,M,42,SNGL,65816
3930        >OP X,B,A,EB,SNGL,65816
3940        >OP X,C,E,FB,SNGL,65816
3950        .HS 40     <<>>
3960 *--------------------------------
3970 CLASS.5.OPS
3980 *          BIT LDY LDX CPY CPX STY STX STZ
3990        .HS 20..A0..A2..C0..E0..80..82..60
4000 *
4010 *          TSB TRB PEI
4020        .HS 00..10..D0
4030 *
4040 CLASS.5.LEGAL.MODES
4050        .HS F8..F8..E6..E0..E0..70..64..78
4060        .HS 60..60..40
4070 *
4080 *      80 -- IMMEDIATE
4090 *      40 -- DIRECT
4100 *      20 -- ABSOLUTE
4110 *      10 -- DIRECT,X
4120 *      08 -- ABSOLUTE,X
4130 *      04 -- DIRECT,Y
4140 *      02 -- ABSOLUTE,Y
4150 *      01 -- <<>>
4160 *--------------------------------
