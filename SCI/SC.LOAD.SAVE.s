
1000 *SAVE SC.LOAD.SAVE
1010 *--------------------------------
1020 DASH
1030        LDA GET.SET.PARMS+4      GET FILE TYPE
1040        CMP #$06          BINARY?
1050        BEQ .3            ...YES, BRUN
1060        CMP #$04          TEXT?
1070        BNE .1            ...NO, TRY SYS
1080        JMP EXEC          ...YES, EXEC
1090 *--------------------------------
1100 .1     CMP #$FF          SYS FILE?
1110        BEQ .2            ...YES, BRUN IT
1120        LDA #$0D     "FILE TYPE MISMATCH"
1130        SEC
1140        RTS
1150 *---RUN SYS FILE-----------------
1160 .2     JSR CLOSE.ALL.FILES
1170        JSR CLOSE.EXEC.FILE
1180        LDA #0
1190        STA VAL.A
1200        LDX #6       RELEASE $8000-$B7FF
1210 .4     STA BITMAP+16,X
1220        DEX
1230        BPL .4
1240        LDA #$01     RELEASE $B800-$BEFF
1250        STA BITMAP+23     B800.BFFF
1260        LDA /$2000   A$2000
1270        STA VAL.A+1
1280        LDA #$FF     T=SYS
1290        STA VAL.T
1300        LDA #$80     SIGNAL FOUND T,A, AND PATHNAME
1310        STA FBITS+1
1320        LDA #$05
1330        STA FBITS
1340 .3     JMP BRUN
1350 *--------------------------------
1360 WARM.DOS
1370        JSR CLOSE.ALL.FILES
1380        JSR CROUT
1390        JMP SC.SOFT
1400 *--------------------------------
1410 *   LOAD A SOURCE PROGRAM
1420 *--------------------------------
1430 LOAD
1440        JSR ALLOCATE.UPPER.BUFFER
1450        BCS .5
1460        LDA #$01     READ
1470        LDX #$FA     FILE TYPE
1480        JSR OPEN.A.FILE
1490        BCS .5       ...ERROR
1500 *---GET LENGTH OF FILE-----------
1510        LDA SC.INFLAG
1520        ASL
1530        BPL .1            ...NOT .INBx
1540        AND #$7F
1550        STA MISC.PARMS+3
1560        LDA #0
1570        STA MISC.PARMS+2
1580        BEQ .2            ...ALWAYS
1590 .1     JSR MLI.D1   GET LENGTH OF FILE
1600        BCS .5       ...ERROR
1610 *---FIGURE LOAD ADDRESS----------
1620 .2     SEC
1630        LDA SC.HIMEM
1640        SBC MISC.PARMS+2
1650        STA READ.WRITE.PARMS+2
1660        STA VAL.A
1670        TAX
1680        LDA SC.HIMEM+1  
1690        SBC MISC.PARMS+3
1700        STA READ.WRITE.PARMS+3
1710        STA VAL.A+1
1720        TAY
1730 *---CHECK FOR ROOM IN RAM--------
1740        BMI .6       ADDRESS>$7FFF MEANS NO ROOM
1750        TXA
1760        CMP SC.LOMEM
1770        TYA
1780        SBC SC.LOMEM+1
1790        BCC .6       ...BELOW LOMEM
1800 *---READ FILE--------------------
1810        LDA MISC.PARMS+2
1820        STA READ.WRITE.PARMS+4
1830        LDA MISC.PARMS+3
1840        STA READ.WRITE.PARMS+5
1850        JSR MLI.CA   READ THE FILE
1860        BCS .5
1870 *---CLOSE UNLESS .INBx-----------
1880        BIT SC.INFLAG
1890        BVS .4            ...IT IS .INBx
1900 .3     JSR MLI.CC   CLOSE THE FILE
1910        BCS .5
1920 *--------------------------------
1930 .4     LDX VAL.A+1
1940        LDY VAL.A
1950        STX SC.PP+1  
1960        STY SC.PP  
1970 .5     RTS
1980 .6     LDA #$0E     "PROGRAM TOO LARGE"
1990        SEC
2000        RTS
2010 *--------------------------------
2020 *   SAVE SOURCE PROGRAM ON DISK
2030 *--------------------------------
2040 SAVE
2050        BCC .1       ...FILE ALREADY HERE
2060        LDA #$FA     FILE TYPE "INT"
2070        STA VAL.T
2080        STA GET.SET.PARMS+4
2090        LDA #$C3
2100        STA GET.SET.PARMS+3
2110        LDA SC.PP     START OF PROGRAM
2120        STA CREATE.PARMS+5
2130        STA GET.SET.PARMS+5
2140        LDA SC.PP+1  
2150        STA CREATE.PARMS+6
2160        STA GET.SET.PARMS+6
2170        JSR MAKE.A.FILE   CREATE A NEW FILE
2180        BCS .2       ...ERROR
2190 .1     JSR ALLOCATE.UPPER.BUFFER
2200        BCS .2
2210        LDA #$02
2220        LDX #$FA
2230        JSR OPEN.A.FILE
2240        BCS .2       ...ERROR
2250 *---GET LENGTH-------------------
2260        SEC          GET LENGTH
2270        LDA SC.HIMEM
2280        SBC SC.PP  
2290        TAX
2300        STA MISC.PARMS+2
2310        LDA SC.HIMEM+1  
2320        SBC SC.PP+1  
2330        TAY
2340        STA MISC.PARMS+3
2350        LDA #0
2360        STA MISC.PARMS+4
2370 *---WRITE THE FILE---------------
2380        LDA SC.PP  
2390        STA READ.WRITE.PARMS+2
2400        LDA SC.PP+1  
2410        STA READ.WRITE.PARMS+3
2420        STX READ.WRITE.PARMS+4
2430        STY READ.WRITE.PARMS+5
2440        JSR MLI.CB   WRITE DATA ON FILE
2450        BCS .2       ...ERROR
2460        JSR MLI.D0   SET EOF (TRUNCATE OLD LONGER FILE)
2470        BCS .2       ...ERROR
2480        JSR MLI.CC   CLOSE THE FILE
2490        BCS .2       ...ERROR
2500 *---UPDATE FILE INFO-------------
2510        LDA SC.PP+1  
2520        LDX SC.PP  
2530        CMP GET.SET.PARMS+6
2540        BNE .3
2550        CPX GET.SET.PARMS+5
2560        CLC
2570        BNE .3
2580 .2     RTS
2590 .3     STX GET.SET.PARMS+5
2600        STA GET.SET.PARMS+6
2610        LDA #0
2620        STA GET.SET.PARMS+10
2630        STA GET.SET.PARMS+11
2640        STA GET.SET.PARMS+12
2650        STA GET.SET.PARMS+13
2660        JMP SET.FILE.INFO
2670 *--------------------------------
2680 CREATE
2690        LDX #0
2700        LDY #0       AuxType = 0000 unless specified
2710        LDA FBITS+1
2720        BPL .1       ...no A-value specified
2730        LDX VAL.A    use A-value for AuxType
2740        LDY VAL.A+1
2750 .1     STX CREATE.PARMS+5
2760        STY CREATE.PARMS+6
2770        LDA FBITS
2780        AND #$04
2790        BNE MAKE.A.FILE
2800        LDA #$0F
2810        STA VAL.T
2820  
2830 MAKE.A.FILE
2840        LDA VAL.T
2850        STA CREATE.PARMS+4
2860        LDX #$C3
2870        LDY #$01     SEEDLING
2880        CMP #$0F
2890        BNE .1    
2900        LDY #$0D     DIRECTORY
2910 .1     STX CREATE.PARMS+3 
2920        STY CREATE.PARMS+7
2930        JMP MLI.C0   CREATE
2940 *--------------------------------
2950 RENAME LDA FBITS
2960        AND #$02     PATH 2?
2970        BEQ .1       ...NO, ERROR
2980        JMP MLI.C2   RENAME
2990 .1     JMP ERR.SYNTAX
3000 *--------------------------------
3010 LOCK   JSR GET.FILE.INFO
3020        BCS RTS3
3030        LDA GET.SET.PARMS+3
3040        AND #$3C
3050        ORA #$01
3060        BNE LKUNLK   ...ALWAYS
3070 UNLOCK JSR GET.FILE.INFO
3080        BCS RTS3
3090        LDA #$C3
3100        ORA GET.SET.PARMS+3
3110 LKUNLK STA GET.SET.PARMS+3
3120        JMP SET.FILE.INFO
3130 *--------------------------------
3140 PREFIX
3150        LDX #0
3160        LDA FBITS+1
3170        AND #$04
3180        BNE .1       ...SPECIFIED S/D
3190        LDA FBITS    SEE IF SPECIFIED PATHNAME
3200        LSR
3210        BCC .3       ...NO, SO PRINT CURRENT PREFIX
3220 .1     JMP MLI.C6   SET PREFIX
3230 *---PRINT CURRENT PREFIX---------
3240 .2     LDA PATHNAME.ONE.BUFFER+1,X
3250        ORA #$80
3260        JSR COUT
3270        INX
3280 .3     CPX PATHNAME.ONE.BUFFER
3290        BCC .2
3300        JSR CROUT
3310        CLC
3320 RTS3   RTS
3330 *--------------------------------
3340 NOPREFIX
3350        LDA #0
3360        STA PATHNAME.ONE.BUFFER
3370        JMP MLI.C6   SET PREFIX
3380 *--------------------------------
3390 BSAVE
3400        BCC .2       ...EXISTING FILE
3410        LDA FBITS+1
3420        AND #$B0     A-EL
3430        CMP #$90     Require A and either E or L
3440        BCC .3       ...Neither E nor L
3450        LDA VAL.A
3460        STA CREATE.PARMS+5
3470        STA GET.SET.PARMS+5
3480        LDA VAL.A+1
3490        STA CREATE.PARMS+6
3500        STA GET.SET.PARMS+6
3510 *---T=BIN unless specified-------
3520        LDA FBITS
3530        AND #$04
3540        BNE .1       ...TYPE SPECIFIED
3550        LDA #$06     ...NO TYPE, ASSUME BINARY
3560        STA VAL.T
3570 .1     LDA VAL.T
3580        STA GET.SET.PARMS+4
3590 *--------------------------------
3600        JSR MAKE.A.FILE
3610        BCS .4
3620        JSR GET.FILE.INFO
3630        BCS .4
3640 .2     LDA #$02
3650        BNE B.COMMON ...ALWAYS
3660  
3670 .3     LDA #$06     "PATH NOT FOUND"
3680        SEC
3690 .4     RTS
3700 *--------------------------------
3710 BRUN
3720        JSR BLOAD
3730        BCS .1
3740        JSR .2
3750        CLC
3760 .1     RTS
3770 .2     JMP (READ.WRITE.PARMS+2)
3780 *--------------------------------
3790 BLOAD
3800        LDA #$01
3810 B.COMMON
3820        PHA
3830        JSR ALLOCATE.UPPER.BUFFER
3840        PLA
3850        BCS .3
3860        LDX #$06
3870        JSR OPEN.A.FILE
3880        BCS .3
3890        LDX VAL.A
3900        LDY VAL.A+1
3910        LDA FBITS+1
3920        BMI .1       ...ADDRESS SPECIFIED
3930        LDX GET.SET.PARMS+5
3940        LDY GET.SET.PARMS+6
3950        LDA FBITS    DON'T ALLOW DEFAULT ADDRESS
3960        AND #$04     ON NON-BINARY FILES
3970        BEQ .0       ...T not specified, so it is BIN
3980        LDA VAL.T    T specified, better be BIN or SYS
3990        CMP #$06     is it BIN?
4000        BEQ .0       ...yes, use AuxType value
4010        CMP #$FF     is it SYS?
4020        BNE .4       ...no, error
4030        LDX #$2000   ...type SYS, assume A$2000
4040        LDY /$2000
4050 .0     LDA FBITS+1
4060 .1     STX READ.WRITE.PARMS+2
4070        STY READ.WRITE.PARMS+3
4080        LDX VAL.L
4090        LDY VAL.L+1
4100        AND #$30
4110        BEQ .5
4120        EOR #$30
4130        BEQ .4
4140        AND #$10
4150        BEQ .7
4160        LDA VAL.E
4170        SEC
4180        SBC VAL.A
4190        TAX
4200        LDA VAL.E+1
4210        SBC VAL.A+1
4220        TAY
4230        INX
4240        BNE .2
4250        INY
4260 .2     BCS .7
4270        LDA #$02     "RANGE ERROR"
4280        SEC
4290 .3     RTS
4300 *--------------------------------
4310 .4     LDA #$0B     "INVALID PARAMETER"
4320        SEC
4330        RTS
4340 *--------------------------------
4350 .5     JSR MLI.D1   GET EOF 
4360        BCS .6
4370        LDX MISC.PARMS+2
4380        LDY MISC.PARMS+3
4390        LDA MISC.PARMS+4
4400        BEQ .7
4410        LDA #$0E     "PROGRAM TOO LARGE"
4420 .6     SEC
4430        RTS
4440 *--------------------------------
4450 .7     STX READ.WRITE.PARMS+4
4460        STY READ.WRITE.PARMS+5
4470        LDA FBITS+1
4480        AND #$40
4490        BEQ .10
4500        LDX #$02
4510 .8     LDA VAL.B,X
4520        STA MISC.PARMS+2,X
4530        DEX
4540        BPL .8
4550 .9     JSR MLI.CE   SET MARK
4560        LDX COMMAND.NUMBER
4570        BCC .10
4580        CMP #$02
4590        BNE .6
4600        CPX #CN.BSAVE
4610        BNE .6
4620        JSR MLI.D0   SET EOF
4630        BCC .9
4640        RTS
4650 *--------------------------------
4660 .10    LDX COMMAND.NUMBER
4670        CPX #CN.BSAVE
4680        BNE .12      ...NOT BSAVE
4690        JSR MLI.CB   ...BSAVE
4700        BCS .13      ...ERROR
4710 .11    JMP MLI.CC
4720 .12    JSR MLI.CA   READ
4730        BCC .11      ...GOOD, CLOSE
4740 .13    RTS
4750 *--------------------------------
