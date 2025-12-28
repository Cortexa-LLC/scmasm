
1000 *SAVE SC.PR.IN
1010 *--------------------------------
1020 *      PR#slot         copy address from OUTVEC,slot to CSW
1030 *      PR#Aaddr        copy Aaddress into CSW
1040 *      PR#slot,Aaddr   copy Aaddress into OUTVEC,slot
1050 *
1060 *      IN#slot         copy address from INVEC,slot to KSW
1070 *      IN#Aaddr        copy Aaddress into KSW
1080 *      IN#slot,Aaddr   copy Aaddress into INVEC,slot
1090 *--------------------------------
1100 PR     LDA #0
1110        .HS 2C       SKIP NEXT LINE
1120 IN     LDA #2
1130        PHA          SAVE 0 OR 2
1140        ASL
1150        ASL          00 OR 08
1160        ORA VAL.LB   +SLOT
1170        ASL          *2
1180        TAX
1190        BIT FBITS    WAS SLOT PARAMETER GIVEN?
1200        BVC .1       ...NO
1210        LDA FBITS+1  ...YES, WAS A$ PARM ALSO?
1220        BMI .2       ...YES, SO UPDATE TABLE
1230        TXA          Check for "PR#0"
1240        BEQ .4       ...yes, so call MON.SETVID directly
1250        LDA OUTVEC,X ...NO, ONLY SLOT
1260        STA VAL.A    SO GET VALUE FROM TABLE
1270        LDA OUTVEC+1,X
1280        STA VAL.A+1
1290 .1     JSR CHECK.IO.DRIVER
1300        BCS .3       ...NOT VALID DRIVER
1310        PLA          POP SAVED 0 OR 2
1320        TAX
1330        LDA VAL.A    INSTALL HOOK FOR DRIVER
1340        STA CSWL,X
1350        LDA VAL.A+1
1360        STA CSWH,X
1370        RTS
1380 *---ENTER NEW VALUE IN TABLE-----
1390 .2     JSR CHECK.IO.DRIVER
1400        BCS .3       ...ERROR
1410        PLA          POP OFF SAVED 0 OR 2
1420        LDA VAL.A+1  UPDATE TABLE
1430        STA OUTVEC+1,X
1440        LDA VAL.A
1450        STA OUTVEC,X
1460        RTS
1470 .3     PLA          POP OFF SAVED 0 OR 2
1480        LDA #$03          "NO DEVICE CONNECTED"
1490        RTS
1500 *--------------------------------
1510 .4     PLA          POP OFF SAVED 0 OR 2
1520        JSR MON.SETVID
1530        CLC
1540        RTS
1550 *--------------------------------
1560 CHECK.IO.DRIVER
1570        LDA VAL.A    GET DRIVER ADDRESS INTO PNTR
1580        STA DRIVER.PTR  
1590        LDA VAL.A+1
1600        STA DRIVER.PTR+1
1610        LDY #0
1620        CMP #$C0     IS IT IN ROM AREA?
1630        BCC .3       ...NO
1640        LDA IO.OFF   ...YES, TURN OFF $C800 SPACE
1650        STY RETRY.COUNT  
1660        LDA (DRIVER.PTR),Y CHECK FOR ROM PRESENT
1670        CMP #$FF
1680        BEQ .4       ...NOT VALID ROM VALUE
1690 .1     CMP (DRIVER.PTR),Y      BETTER NOT CHANGE...
1700        BNE .4            ...WOOPS, NOT ROM
1710        DEC RETRY.COUNT  TRY IT 256 TIMES
1720        BNE .1       ...AGAIN
1730 .2     CLC          ...REALLY A DRIVER
1740        RTS
1750 *---VERIFY RAM-BASED DRIVER------
1760 .3     LDA (DRIVER.PTR),Y      GET FIRST BYTE
1770        CMP #$D8          "CLD" OPCODE?
1780        BEQ .2            ...YES, VALID DRIVER
1790 .4     SEC
1800        RTS
1810 *--------------------------------
