
1000 *SAVE IO.STANDARD
1010 *--------------------------------
1020 *   I/O VECTORS -- 3 BYTES EACH
1030 *--------------------------------
1040 IO.INIT               JMP S.IO.INIT
1050 IO.WARM               JMP S.IO.WARM
1060 READ.KEY.WITH.CASE    JMP S.READ.KEY.WITH.CASE
1070 GET.HORIZ.POSN        LDA CH
1080                       RTS
1090 IO.HOME               JMP MON.HOME
1100 IO.CLREOL             JMP MON.CLREOL
1110 IO.CLREOP             JMP MON.CLREOP
1120 IO.UP                 JMP MON.UP
1130 IO.DOWN               JMP MON.LF
1140 IO.LEFT               JMP MON.BS
1150 IO.RIGHT              JMP MON.ADVANC
1160 IO.COUT               JMP MON.COUT
1170 IO.PICK.SCREEN        LDA (BASL),Y
1180                       RTS
1190 IO.HTABX              STX CH
1200                       RTS
1210 IO.HTAB               STA CH
1220                       RTS
1230 IO.VTAB               JMP S.IO.VTAB
1240 IO.CASE.TOGGLE        LDA LC.MODE
1250                       EOR #$FF
1260                       STA LC.MODE
1270                       RTS
1280 *--------------------------------
1290 *      VARIABLE LENGTH ROUTINES
1300 *          (ENTERED THROUGH VECTORS)
1310 *--------------------------------
1320 S.IO.VTAB
1330        STA CV
1340        JMP MON.VTAB
1350 *--------------------------------
1360 S.IO.INIT
1370        LDA #40
1380        STA SCREEN.WIDTH
1390        JSR MON.SETKBD
1400        JSR MON.SETVID
1410        JSR MON.INIT
1420        JMP MON.HOME
1430 *--------------------------------
1440 S.IO.WARM
1450        CLD
1460        LDX CV
1470        JSR MON.INIT
1480        STX CV
1490        STX LC.MODE  POSITIVE VALUE
1500        JSR MON.VTAB
1510        RTS
1520 *--------------------------------
1530 *      READ KEY WITH CASE CONTROL
1540 *--------------------------------
1550 S.READ.KEY.WITH.CASE
1560        LDA $BE43    See if "EXEC" in progress
1570        BMI .1       ...Yes, use straight input
1580        LDA LC.MODE
1590        BMI .2       Yes, use fancy translation
1600 .1     JSR MON.RDKEY
1610        ORA #$80     Make sure it looks right
1620        CLC          SIGNAL "NO OPEN APPLE PRESSED"
1630        RTS
1640 *--------------------------------
1650 .2
1660        LDY CH       Set up cursor
1670        LDA (BASL),Y Char from screen
1680        PHA
1690        CMP #$E0     ELIMINATE CASE
1700        BCC .25
1710        AND #$DF
1720 .25    AND #$3F     Make it flash
1730        ORA #$40
1740        STA (BASL),Y
1750        PLA
1760        JSR MON.READCH
1770        BIT $C063    Shift key down?
1780        BPL .4       Yes
1790        CMP #$C0     No, lower case if letter
1800        BCC .3
1810        ORA #$20
1820        CLC          SIGNAL "NO OPEN APPLE PRESSED"
1830 .3     RTS
1840 *--------------------------------
1850 .4     CMP #$C0     Shift key down
1860        BCC .8       Not a letter key
1870        BEQ .7       Shift-P
1880        CMP #$DD     Shift-M
1890        BEQ .5       Yes
1900        CMP #$DE     Shift-N
1910        BNE .6       No
1920 .5     AND #$EF     Make capital-M or -N
1930 .6     CLC          SIGNAL "NO OPEN APPLE PRESSED"
1940        RTS
1950 *--------------------------------
1960 .7     LDA #$D0     Make capital-P
1970        CLC          SIGNAL "NO OPEN APPLE PRESSED"
1980        RTS
1990 *--------------------------------
2000 .8     CMP #$87     Look for control-shift-A thru -F
2010        BCS .10      No
2020        CMP #$81     Control-A
2030        BCC .10      No, control-P
2040        BNE .9       No, control-B thru -F
2050        LDA #$C0-$58-1    Control-shift-A = at-sign (@)
2060 .9     ADC #$58
2070 .10    CLC          SIGNAL "NO OPEN APPLE PRESSED"
2080        RTS
2090 *--------------------------------
