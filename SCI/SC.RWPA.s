
1000 *SAVE SC.RWPA
1010 *--------------------------------
1020 WRITE
1030        JSR GET.REFNUM.OF.OPEN.FILE
1040        BCS .1       ...NOT OPEN
1050        STA WRITE.REFNUM
1060        LDA CSWL
1070        STA VDOSIO
1080        LDA CSWH
1090        STA VDOSIO+1
1100        LDA #WRITE.TEXT.FILE
1110        STA CSWL
1120        LDA /WRITE.TEXT.FILE
1130        STA CSWH
1140        LDA #$FF
1150        STA F.WRITE
1160 .1     RTS
1170 *--------------------------------
1180 *   OUTPUT HOOK DURING A WRITE OPERATION
1190 *--------------------------------
1200 WRITE.TEXT.FILE
1210        AND #$7F     PRODOS STANDARD IS BIT7=0
1220        STA WRITE.OUTPUT.CHAR
1230        JSR SAVE.REGS
1240        LDX WRITE.REFNUM
1250        STX READ.WRITE.PARMS+1
1260        ASL          IGNORE BIT 7
1270        BEQ .2       END OF FILE
1280        LDA #WRITE.OUTPUT.CHAR
1290        STA READ.WRITE.PARMS+2
1300        LDA /WRITE.OUTPUT.CHAR
1310        STA READ.WRITE.PARMS+3
1320        LDA #1
1330        STA READ.WRITE.PARMS+4
1340        LDA #0
1350        STA READ.WRITE.PARMS+5
1360        JSR MLI.CB   WRITE
1370        BCC RESTORE.REGS
1380 *--------------------------------
1390 .1     JMP ERROR.HANDLER
1400 *--------------------------------
1410 .2     STX MISC.PARMS+1
1420        JSR MLI.CF   READ MARK
1430        BCS .1
1440        JSR MLI.D0   SET EOF
1450        BCS .1       ...ERROR
1460 *---fall into RESTORE.REGS-------
1470 *--------------------------------
1480 RESTORE.REGS
1490        LDY PREGY
1500        LDX PREGX
1510        LDA PREGA
1520        RTS
1530 *--------------------------------
1540 SAVE.REGS
1550        STA PREGA
1560        STX PREGX
1570        STY PREGY
1580        RTS
1590 *--------------------------------
