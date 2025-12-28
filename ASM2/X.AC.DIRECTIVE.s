
1000 *SAVE X.AC.DIRECTIVE
1010 *--------------------------------
1020 TABLE1 .EQ $BE00-48
1030 TABLE2 .EQ $BE00-32
1040 TABLE3 .EQ $BE00-16
1050 *--------------------------------
1060 DIR.AC
1070        JSR GNNB     GET NEXT NON-BLANK FOR DELIMITER
1080        BCS .8       ...ERROR
1090        STA DLIM     IN CASE IT IS A DELIMITER
1100        EOR #'0'
1110        BEQ .9       ...INITIAL STRING
1120        CMP #4
1130        BCC .10
1140 *---GET NEXT CHAR OF STRING------
1150 .2     JSR GNC      GET NEXT CHAR TO ENCODE
1160        BCS .8       ...ERROR
1170        CMP DLIM
1180        BEQ .7       ...END OF STRING
1190 *---SEARCH TABLE 1---------------
1200        LDY #15
1210 .3     CMP TABLE1,Y
1220        BEQ .6       ...FOUND IT
1230        DEY
1240        BNE .3
1250 *---SEARCH TABLE 2---------------
1260        JSR OUTPUT.NYBBLE.Y
1270        LDY #15
1280 .4     CMP TABLE2,Y
1290        BEQ .6       ...FOUND IT
1300        DEY
1310        BNE .4
1320 *---SEARCH TABLE 3---------------
1330        JSR OUTPUT.NYBBLE.Y
1340        LDY #15
1350 .5     CMP TABLE3,Y
1360        BEQ .6       ...FOUND IT
1370        DEY
1380        BNE .5
1390 *---NOT IN ANY TABLE-------------
1400        JSR OUTPUT.NYBBLE.Y
1410        PHA
1420        LSR
1430        LSR
1440        LSR
1450        LSR
1460        TAY
1470        JSR OUTPUT.NYBBLE.Y
1480        PLA
1490        AND #$0F
1500        TAY
1510 *---OUTPUT TABLE INDEX-----------
1520 .6     JSR OUTPUT.NYBBLE.Y
1530 *---NEXT CHAR--------------------
1540        JMP .2
1550 *---END OF STRING----------------
1560 .9     STA NYBBLE.FLAG
1570 .7     RTS
1580 *---ERROR------------------------
1590 .8     JMP ERBA
1600 *---READ NEW CODING TABLES-------
1610 .10    SBC #0       CHANGE TO 0,1,2
1620        ASL          *16
1630        ASL
1640        ASL
1650        ASL
1660        TAX
1670        JSR GNC
1680        BCS .7       ...NO STRING
1690        STA DLIM
1700 .11    JSR GNC      ...ALLOW LOWER CASE
1710        BCS .8       ...ERROR
1720        CMP DLIM
1730        BEQ .7       ...END OF STRING
1740        INX
1750        CPX #48
1760        BCS .8       ...GONE TOO FAR
1770        STA TABLE1,X
1780        BCC .11      ...ALWAYS
1790 *--------------------------------
1800 OUTPUT.NYBBLE.Y
1810        PHA          SAVE A-REG
1820        TYA
1830        LSR NYBBLE.FLAG
1840        BCS .1       ...IT WAS = $01
1850        ASL          ...IT WAS = $00
1860        ASL
1870        ASL
1880        ASL
1890        STA BYTE
1900        INC NYBBLE.FLAG
1910        PLA
1920        RTS
1930 .1     ORA BYTE
1940        JSR EMIT
1950        PLA
1960        RTS
1970 *--------------------------------
