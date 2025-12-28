
1000 *SAVE X.DISK.OPERATI
1010 *--------------------------------
1020 SCI.TBLADR          .EQ $AA00  Address of Command Table
1030 SCI.LINBUF          .EQ $BC80
1040 SCI.STARTUP         .EQ $BE00
1050 SCI.COMMAND         .EQ $BE03
1060 SCI.ERROR           .EQ $BE09
1070 SCI.SLOT            .EQ $BE3C
1080 SCI.DRIVE           .EQ $BE3D
1090 SCI.STATE           .EQ $BE42  0=immediate, else deferred
1100 SCI.MLI             .EQ $BE70  Call MLI, (A)=operation
1110 SCI.RTS             .EQ $BE9E
1120 SCI.IOB.GETSET      .EQ $BEB4  Get/Set File Info IOB
1130 SCI.IOB.MISC        .EQ $BEC6  Misc functions IOB
1140 SCI.IOB.OPEN        .EQ $BECB  Open IOB
1150 SCI.IOB.RW          .EQ $BED5  Read/Write IOB
1160 SCI.IOB.CLOSE       .EQ $BEDD  Close IOB
1170 SCI.BUFFER.PAGES    .EQ $BEF2,3,4  Buf1, Buf2, Exec
1180 SCI.HIMEM.PAGE      .EQ $BEFB
1190 *--------------------------------
1200 *      LIST SOURCE CODE ON TEXT FILE
1210 *--------------------------------
1220 * TEXT.OPTIONS:
1230 *      TEXT    NO LINE NUMBERS
1240 *      TEXT#   WITH LINE NUMBERS
1250 *      TEXT%   WITH TAB.CHAR
1260 *--------------------------------
1270 TEXT   LDX #0       00=NO LINE NUMBERS
1280        STX TEXT.OPTIONS
1290        JSR GNNB     GET NEXT NON-BLANK CHAR
1300        CMP #'#      TEXT # MEANS WRITE LINE NUMBERS
1310        BEQ .5       USE LINE NUMBERS
1320        CMP #'%      TEXT % MEANS WRITE CONTROL-I
1330        BNE .6       NEITHER, WRITE TEXT ONLY
1340        LDA TAB.CHAR
1350        STA TEXT.OPTIONS
1360        BNE .7       ...ALWAYS
1370 .5     INC TEXT.OPTIONS
1380        BNE .7       ...ALWAYS
1390 .6     JSR BACKUP.CHAR.PNTR
1400 .7     LDA #1       INTO "DEFERRED" STATE
1410        STA SCI.STATE
1420        JSR SAVE.PATHNAME
1430        LDY #PQ.OPN
1440        JSR ISSUE.DOS.COMMAND
1450        LDY #PQ.WRT
1460        JSR ISSUE.DOS.COMMAND
1470        JSR SETUP.TEXT.POINTERS (PP --> SRCP, HIMEM --> ENDP)
1480 .1     JSR CMP.SRCP.ENDP     END OF RANGE YET?
1490        BCS .4       ...YES
1500        JSR GET.LINE.NUMBER
1510        LDA TEXT.OPTIONS
1520        BEQ .3       NO LINE #
1530        BMI .2       TAB.CHAR
1540        JSR CONVERT.LINE.NUMBER.PRINT
1550        LDA #$20     SPACE AFTER LINE #
1560 .2     JSR CHO
1570 .3     JSR NTKN
1580        BNE .2
1590        JSR CRLF
1600        JMP .1
1610 .4     LDA #0       TRUNCATE REST OF FILE
1620        JSR CHO
1630        JMP SOFT
1640 *--------------------------------
1650 *      .TF DIRECTIVE
1660 *--------------------------------
1670 *    END EXISTING .TF IF ANY
1680 *    SET .TF FLAG ON
1690 *
1700 *    PASS 1:  THAT'S ALL
1710 *
1720 *    PASS 2:  OPEN THE FILE, WITH T=BIN
1730 *             SET MARK=EOF=0
1740 *             SET STARTING ADDRESS IN FILE-INFO
1750 *             WRITE START ADDRESS AND LENGTH
1760 *--------------------------------
1770 PSTF   JSR TFEND    CLOSE EXISTING TF IF ANY
1780        SEC
1790        ROR TF.FLAG  SET FLAG ON
1800        JSR LIST.LINE.BOTH.PASSES
1810        LDA PASS     WHICH PASS?
1820        BEQ .9       ...PASS 1, EXIT NOW
1830        JSR SAVE.PATHNAME
1840        LDY #PQ.OPN
1850        JSR ISSUE.DOS.COMMAND
1860 *---Empty the file now-----------
1870        LDA #0
1880        STA SCI.IOB.MISC+2
1890        STA SCI.IOB.MISC+3
1900        STA SCI.IOB.MISC+4
1910        LDA SCI.IOB.OPEN+5  REFNUM FOR TARGET FILE
1920        STA TF.PRM   TARGET FILE REF. NUM.
1930        STA SCI.IOB.MISC+1
1940        LDA #$CE     SET MARK
1950        JSR SCI.MLI
1960        BCS JMP.PRODOS.ERR   ...ERROR 
1970        LDA #$D0     SET EOF
1980        JSR SCI.MLI
1990        BCS JMP.PRODOS.ERR   ...ERROR
2000 *---Get current file info--------
2010        LDA #10
2020        STA SCI.IOB.GETSET
2030        LDA #$C4     GET FILE INFO
2040        JSR SCI.MLI
2050        BCS JMP.PRODOS.ERR   ...ERROR
2060 *---Set proper file info---------
2070        LDA #7       change IOB for set.file.info
2080        STA SCI.IOB.GETSET
2090        LDA SCI.IOB.GETSET+4  current file type
2100        CMP #$04     is it type TXT?
2110        BEQ .9       ...yes, make no changes
2120        LDX #$2000   if type is SYS ($FF), force A=$2000
2130        LDY /$2000
2140        CMP #$FF     is it type SYS?
2150        BEQ .3       ...yes
2160        LDX ORGN     all other types, A=origin
2170        LDY ORGN+1
2180 .3     STX SCI.IOB.GETSET+5  new AuxType
2190        STY SCI.IOB.GETSET+6
2200        LDA #$C3     SET FILE INFO
2210        JSR SCI.MLI
2220        BCS JMP.PRODOS.ERR   ...ERROR
2230 .9     JMP ASM2     ...CONTINUE ASSEMBLY
2240 *--------------------------------
2250 JMP.PRODOS.ERR JMP PRODOS.ERROR
2260 *--------------------------------
2270 * OUTPUT (A) TO ALREADY OPENED DISK FILE
2280 *--------------------------------
2290 DOUT   BIT DUMMY.FLAG
2300        BMI .3       No output inside DUMMY section
2310        STA TF.BUF   Save in buffer outside zero-page
2320        STX TF.SVX
2330        LDX #4       copy parms to SCI parmblock
2340 .1     LDA TF.PRM,X
2350        STA SCI.IOB.RW+1,X
2360        DEX
2370        BPL .1       ...until all copied
2380        LDA #$CB     Write command code
2390        JSR SCI.MLI
2400        BCS JMP.PRODOS.ERR
2410        LDX TF.SVX
2420        LDA OBJ.BYTE
2430 .3     RTS
2440 *
2450 TF.SVX .BS 1
2460 TF.BUF .BS 1
2470 TF.PRM .DA #*-*,TF.BUF,1
2480 *--------------------------------
2490 * TFEND - FINISH OFF A .TF SECTION
2500 *  CALLED FROM:  .TF, .TA, .OR, .EN PROCESSORS
2510 *
2520 *  IF NOT IN .TF NOW, RETURN IMMEDIATELY
2530 *  CLEAR .TF FLAG
2540 *  PASS 1 - THAT'S ALL TO DO
2550 *  PASS 2 - CLOSE FILE
2560 *--------------------------------
2570 TFEND  ASL TF.FLAG  TEST AND CLEAR FLAG SIMULTANEOUSLY
2580        BCC .1       ...TF NOT ACTIVE, DO NOTHING
2590        LDA PASS
2600        BNE CLOSE.FILES   ...PASS 2
2610 .1     RTS
2620 *--------------------------------
2630 CLOSE.FILES
2640        LDY #PQ.CLS
2650        .HS 2C
2660 FP     LDY #PQ.FP
2670        LDA #0
2680        STA PATHNAME
2690 *--------------------------------
2700 *      ISSUE DOS COMMAND WITH FILE NAME
2710 *      (Y)=QUOTE OFFSET FOR COMMAND
2720 *
2730 *      SAVES AND RESTORES CHARACTER POINTER
2740 *      SO THAT FILE NAME CAN BE USED AGAIN.
2750 *--------------------------------
2760 ISSUE.DOS.COMMAND
2770        LDX #$7F     SAVE WBUF (0-127)
2780 .1     LDA WBUF,X
2790        STA SCI.LINBUF,X
2800        DEX
2810        BPL .1
2820 .2     INX          COPY PATHNAME INTO WBUF (5...)
2830        LDA PATHNAME,X
2840        STA WBUF+5,X
2850        BNE .2
2860        TAX          X=0
2870 .3     INX          COPY COMMAND INTO WBUF (0...)
2880        INY
2890        LDA PQTS-1,Y
2900        STA WBUF-1,X
2910        BPL .3
2920        STX SCI.STATE    ALLOW DEFERRED COMMANDS
2930        JSR PASS.CMD.TO.PRODOS
2940        LDX #$7F     RESTORE WBUF (0-127)
2950 .4     LDA SCI.LINBUF,X
2960        STA WBUF,X
2970        DEX
2980        BPL .4
2990        RTS
3000 *--------------------------------
3010 SAVE.PATHNAME
3020        LDX #0
3030 .1     CPX #49
3040        BCS .2
3050        JSR GNNB
3060        BCC .3
3070 .2     LDA #0
3080 .3     STA PATHNAME,X
3090        INX
3100        BCC .1
3110        RTS
3120 *--------------------------------
3130 PQTS   .EQ *
3140 PQ.CLS .EQ *-PQTS
3150        .AT /CLOSE/
3160 PQ.OPN .EQ *-PQTS
3170        .AT /OPEN /
3180 PQ.WRT .EQ *-PQTS
3190        .AT /WRITE/
3200 PQ.LOD .EQ *-PQTS
3210        .AT /LOAD /
3220 PQ.FP  .EQ *-PQTS
3230        .AS /-BASIC.SYSTEM/
3240        .HS 00FF
3250 *--------------------------------
