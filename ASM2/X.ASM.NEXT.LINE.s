
1000 *SAVE X.ASM.NEXT.LINE
1010 *--------------------------------
1020 *      SET UP NEXT LINE TO ASSEMBLE
1030 *--------------------------------
1040 SETUP.NEXT.LINE
1050 .1     BIT INFLAG
1060        BVS .5            ...INSIDE .INBx
1070        LDA SRCP     CHECK IF AT END
1080        CMP HI.MEM    TOP OF SOURCE CODE
1090        LDA SRCP+1
1100        SBC HI.MEM+1
1110        BCS .7       RETURN WITH CARRY SET
1120 .5     LDA MACRO.LEVEL  IN SKELETON OR BODY?
1130        BEQ .2               BODY
1140        LDY #0       SEE IF END OF SKELETON
1150        >SYM LDA,SRCP
1160        BNE .3       NO, STILL IN SKELETON
1170        LDA (MACSTK),Y    POP SKELETON OFF MACRO STACK
1180        STA CALL.NUM+1
1190        INY
1200        LDA (MACSTK),Y
1210        STA CALL.NUM
1220        INY
1230        LDA (MACSTK),Y
1240        STA LF.ALL   Real value of listing option
1250        INY
1260        LDA (MACSTK),Y
1270        STA SRCP+1
1280        INY
1290        LDA (MACSTK),Y
1300        STA SRCP
1310        INY
1320        LDA (MACSTK),Y    (HIGH BYTE)
1330        PHA
1340        INY
1350        LDA (MACSTK),Y    (LOW BYTE)
1360        STA MACSTK
1370        PLA
1380        STA MACSTK+1
1390        DEC MACRO.LEVEL
1400        JMP .1
1410 *--------------------------------
1420 .2     JSR GET.LINE.NUMBER  BODY
1430 .3     LDX #0
1440 .4     JSR GET.NEXT.SOURCE.CHAR
1450        BEQ .6       END OF LINE
1460        STA WBUF,X    PUT INTO WORKING BUFFER
1470        INX
1480        BNE .4       ...ALWAYS
1490 .6     STA WBUF,X   PUT ZERO ON END
1500        CLC          RETURN WITH CARRY CLEAR
1510 .7     RTS
1520 *--------------------------------
1530 *      GET NEXT CHARACTER FROM SOURCE LINE
1540 *      (IF INSIDE A MACRO SKELETON, EXPAND PARAMETERS)
1550 *--------------------------------
1560 GET.NEXT.SOURCE.CHAR
1570        STX MACRO.SAVEX   MUST PRESERVE X-REGISTER
1580        LDY PARAM.PNTR
1590        BNE .1       PRESENTLY EXPANDING A PARAMETER
1600        LDA MACRO.LEVEL  IN A SKELETON?
1610        BNE .2            YES
1620        JMP NTKN          NO
1630 *--------------------------------
1640 .1     INC PARAM.PNTR
1650        LDA (MACSTK),Y
1660        BNE .8            ...NORMAL CHAR
1670        STA PARAM.PNTR    ...END OF PARAMETER
1680 .2     JSR NTKN
1690        BEQ .8       END OF LINE
1700        CMP #$7F     PARAMETER?
1710        BNE .8       NO, NORMAL CHAR
1720 *---MACRO PARAMETER--------------
1730        JSR NTKN     YES, GET PARAM #
1740        LDY #6
1750        CMP #'#      ]# RETURNS NUMBER OF PARAMETERS (0-9)
1760        BEQ .5       ...FOUND ]#
1770        SEC
1780        SBC #'1'     CHANGE "1"..."9" TO 0...8
1790        BEQ .4       ...]1
1800        TAX          ...]2 THRU ]9
1810 .3     INY
1820        LDA (MACSTK),Y  SKIP OVER A PARAMETER
1830        BNE .3
1840        DEX
1850        BNE .3
1860 .4     INY
1870        STY PARAM.PNTR
1880        BNE .1       ...ALWAYS
1890 *---NUMBER OF PARAMETERS---------
1900 .5     CLC
1910        LDA (MACSTK),Y
1920        SBC MACSTK
1930        TAY
1940        LDX #10
1950 .6     LDA (MACSTK),Y
1960        BNE .7
1970        DEX
1980        DEY
1990        CPY #7
2000        BCS .6
2010        LDX #0
2020 .7     TXA
2030        ORA #$30
2040 *--------------------------------
2050 .8     LDX MACRO.SAVEX  RESTORE X-REG
2060        CMP #0       SET "EQ" STATUS IF END OF LINE
2070        RTS
2080 *--------------------------------
