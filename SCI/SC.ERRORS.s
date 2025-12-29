
1000 *SAVE SC.ERRORS
1010 *--------------------------------
1020 *   Error Handler
1030 *--------------------------------
1040 ERROR.HANDLER
1050        AND #$1F     TRIM TO SIZE
1060        STA ERROR.CODE
1070        LDA #$0F     LEVEL
1080        STA LEVEL
1090        JSR UNHOOK.WRITE  ...IF WRITING
1100        LDA #0
1110        STA CLOSE.FLUSH.PARMS+1
1120        JSR MLI.CC   CLOSE ALL FILES
1130        BCS .1
1140        LDA #0
1150        STA LEVEL
1160        STA CLOSE.FLUSH.PARMS+1
1170        JSR MLI.CD   FLUSH
1180 .1     LDA ERROR.CODE
1190        JSR PRINT.ERROR
1200        JSR CLOSE.EXEC.FILE
1210        JSR CROUT
1220        JMP SC.SOFT
1230 *--------------------------------
1240 ERR.FILE.BUSY
1250        LDA #$14
1260        SEC
1270        RTS
1280 *--------------------------------
1290 ERROR.PRINTER
1300        JSR FIND.AND.PUT.MSG.IN.WBUF
1310        JSR BELL
1320 *---PRINT MESSAGE FROM WBUF------
1330 PRINT.CR.MESSAGE
1340        JSR CROUT
1350 PRINT.MESSAGE
1360        LDX #0
1370 .1     LDA WBUF+1,X
1380        JSR COUT
1390        INX
1400        CMP #$8D     END OF MESSAGE?
1410        BNE .1       ...NO
1420        RTS          ...YES
1430 *--------------------------------
1440 FIND.AND.PUT.MSG.IN.WBUF
1450        LDX #0
1460        CLC
1470 *---SEARCH FOR MESSAGE #---------
1480        STA WBUF
1490        TAY
1500        BEQ .5       ...FIRST MESSAGE
1510 .2     JSR SCI.GET.NEXT.NYBBLE
1520        BNE .4
1530 .3     JSR SCI.GET.NEXT.NYBBLE
1540        BEQ .3
1550        BNE .2
1560 .4     EOR #$0F
1570        BNE .2
1580        DEC WBUF
1590        BNE .2
1600 *---Put message in WBUF----------
1610 .5     LDY #0
1620        STY WBUF+80  SQUEEZED BLANK COUNT
1630 .6     STY WBUF     STORAGE INDEX
1640        LDA WBUF+80  BLANK COUNT
1650        BNE .8       ...ANOTHER BLANK
1660 .7     JSR SCI.GET.NEXT.NYBBLE
1670        LDA SCI.FIRST.TABLE,Y
1680        BNE .9       ...FREQUENT CHAR
1690        JSR SCI.GET.NEXT.NYBBLE
1700        LDA SCI.SECOND.TABLE,Y
1710        BNE .9       ...TWO NYBBLE CHAR
1720        JSR SCI.GET.NEXT.NYBBLE
1730        LDA SCI.THIRD.TABLE,Y
1740        BMI .9       ...REAL CHAR
1750        STA WBUF+80  ...BLANK COUNT
1760 .8     LDA #" "
1770        DEC WBUF+80
1780        BEQ .7       ...NO MORE BLANKS
1790 .9     LDY WBUF     STORAGE INDEX
1800        STA WBUF+1,Y
1810        INY          NEXT COLUMN
1820        EOR #$8D     END OF MESSAGE?
1830        BNE .6       ...NO
1840        RTS          ...YES
1850 *--------------------------------
1860 SCI.GET.NEXT.NYBBLE
1870        LDA SCI.MESSAGES,X
1880        BCS .1       2ND NYBBLE
1890        LSR          1ST NYBBLE
1900        LSR
1910        LSR
1920        LSR
1930        TAY
1940        SEC
1950        RTS
1960 .1     INX
1970        AND #$0F
1980        TAY
1990        CLC
2000        RTS
2010 *--------------------------------
