
1000 *SAVE SC.EXEC
1010 *--------------------------------
1020 EXEC.ERR.FILE.BUSY  JMP ERR.FILE.BUSY
1030 EXEC.ERR.MISMATCH   JMP TYPERR
1040 *--------------------------------
1050 EXEC
1060        JSR GET.REFNUM.OF.OPEN.FILE
1070        BCS .1       ...NOT CURRENTLY OPEN
1080 *---File is in use---------------
1090        BIT EXEC.FILE.CLOSING.FLAG
1100        BPL EXEC.ERR.FILE.BUSY
1110 *---Restarting same EXEC file----
1120        STA MISC.PARMS+1      REFNUM
1130        LDA #0            "REWIND" THE FILE
1140        STA MISC.PARMS+2
1150        STA MISC.PARMS+3
1160        STA MISC.PARMS+4
1170        JSR MLI.CE   SET MARK
1180        BCS CLOSE.EXEC.SAVING.ERROR
1190        BCC .2       ...ALWAYS, RESTART
1200 *--------------------------------
1210 .1     JSR CLOSE.EXEC.FILE   STOP ANY EXEC IN PROGRESS
1220        BCS .3       ...ERROR
1230 *---Check file type--------------
1240        LDA GET.SET.PARMS+4 FILE TYPE MUST BE TXT
1250        CMP #$04            TXT FILETYPE CODE
1260        BNE EXEC.ERR.MISMATCH
1270 *---Open the file----------------
1280        LDA #0
1290        STA LEVEL   LEVEL
1300        STA MISC.PARMS+2 BUFFER ADDRESS
1310        LDA EXEC.BUFFER.BASE
1320        STA MISC.PARMS+3 BUFFER ADDRESS HI
1330        STA OPEN.PARMS+4      "
1340        JSR MLI.C8   OPEN
1350        BCS .3       ...ERROR
1360        LDA OPEN.PARMS+5      REFNUM OF FILE
1370        STA EXEC.REFNUM
1380 *---Fill other param blocks------
1390 .2     LDX GET.SET.PARMS+5      RECORD LENGTH
1400        STX VAL.L
1410        LDX GET.SET.PARMS+6
1420        STX VAL.L+1
1430        LDX #2            POINT AT EXEC FILE NAME
1440        JSR SAVE.FILENAME.IN.TABLE
1450 *---Switch EXEC on now-----------
1460        LDA #$FF     MARK EXEC ACTIVE
1470        STA F.EXEC
1480        LDA KSWL
1490        STA VDOSIO+2
1500        LDA KSWH
1510        STA VDOSIO+3
1520        LDA #READ.EXEC.FILE
1530        STA KSWL
1540        LDA /READ.EXEC.FILE
1550        STA KSWH
1560        CLC
1570 .3     RTS
1580 *--------------------------------
1590 CLOSE.EXEC.SAVING.ERROR
1600        PHA          SAVE ERROR CODE
1610        JSR CLOSE.EXEC.FILE   CLOSE THE FILE
1620        PLA          GET ERROR CODE
1630        SEC          SIGNAL ERROR
1640        RTS
1650 *--------------------------------
1660 *   CLOSE EXEC FILE
1670 *--------------------------------
1680 CLOSE.EXEC.FILE
1690        CLC
1700        LDA F.EXEC
1710        BPL .1       ...NO EXEC IN PROGRESS
1720        LDA VDOSIO+2 RESTORE INPUT HOOK
1730        STA KSWL
1740        LDA VDOSIO+3
1750        STA KSWH
1760        LDA #$FF
1770        STA EXEC.FILE.CLOSING.FLAG
1780        LDX #2
1790        LDA EXEC.REFNUM
1800        JSR CLOSE.ONE.FILE   CLOSE THE FILE
1810 .1     RTS
1820 *--------------------------------
1830 *   "EXEC" INPUT HOOK
1840 *--------------------------------
1850 READ.EXEC.FILE
1860        STA (BASL),Y      STOP BLINKING ON SCREEN
1870        JSR SAVE.REGS     SAVE A,X,Y
1880 *---Check for CTRL-C Abort-------
1890        LDA KEYBOARD
1900        CMP #$83     CONTROL-C?
1910        BNE .2       ...NO
1920        JSR CLOSE.EXEC.FILE   ...YES
1930        STA STROBE
1940 *---End of Data------------------
1950 .1     JSR RESTORE.REGS
1960        JMP ABORT.EXIT
1970 *---Set up EXEC char input-------
1980 .2     LDA EXEC.REFNUM   REFNUM
1990        STA READ.WRITE.PARMS+1
2000        LDA #EXEC.INPUT.CHAR
2010        STA READ.WRITE.PARMS+2
2020        LDA /EXEC.INPUT.CHAR
2030        STA READ.WRITE.PARMS+3
2040        LDA #1       READ JUST ONE BYTE
2050        STA READ.WRITE.PARMS+4
2060        LDA #0
2070        STA READ.WRITE.PARMS+5
2080        JSR MLI.CA   READ
2090        BCS .3       ...ERROR OR END OF DATA
2100        JSR RESTORE.REGS
2110        LDA EXEC.INPUT.CHAR
2120        ORA #$80
2130        RTS
2140 *--------------------------------
2150 .3     JSR CLOSE.EXEC.SAVING.ERROR   CLOSE EXEC FILE
2160        CMP #$05     END OF DATA?
2170        BEQ .1       ...YES
2180        JMP ERROR.HANDLER
2190 *--------------------------------
