
1000 *SAVE NEW.QUOTES
1010 *--------------------------------
1020 *   Y = MESSAGE NUMBER
1030 *--------------------------------
1040 QT.OUT
1050        TXA
1060        PHA
1070        LDX #0
1080        CLC
1090 *---Search for message #---------
1100 .2     JSR GET.NEXT.NYBBLE
1110        BNE .4
1120 .3     JSR GET.NEXT.NYBBLE
1130        BEQ .3
1140        BNE .2
1150 .4     EOR #$0F
1160        BNE .2
1170        DEY
1180        BNE .2
1190 *---Print the message------------
1200 .5     JSR GET.NEXT.NYBBLE
1210        TAY
1220        LDA FIRST.TABLE,Y
1230        BNE .6       ...FREQUENT CHAR
1240        JSR GET.NEXT.NYBBLE
1250        TAY
1260        LDA SECOND.TABLE,Y
1270        BNE .6       ...TWO NYBBLE CHAR
1280        JSR GET.NEXT.NYBBLE
1290        TAY
1300        LDA THIRD.TABLE,Y
1310 .6     BPL .7       ...END OF MESSAGE
1320        PHP
1330        JSR MY.COUT
1340        PLP
1350        BMI .5       ...NEXT CHAR, ALWAYS
1360 .7     PLA          ...YES
1370        TAX
1380        RTS
1390 *--------------------------------
1400 GET.NEXT.NYBBLE
1410        LDA MESSAGES,X
1420        BCS .1       2ND NYBBLE
1430        LSR          1ST NYBBLE
1440        LSR
1450        LSR
1460        LSR
1470        SEC
1480        RTS
1490 .1     INX
1500        AND #$0F
1510        CLC
1520        RTS
1530 *--------------------------------
1540 FIRST.TABLE  .HS 00
1550              .AS -/ABCDEILMNORST /
1560              .HS 7F
1570 SECOND.TABLE .HS 00
1580              .AS -/FGPUXY$.*:?52/
1590              .HS 878D
1600 THIRD.TABLE  .AS -/.HJKQVWZ>1-...../
1610 *--------------------------------
1620 MESSAGES
1630        .AC 0
1640        .AC 1/ABCDEILMNORST %/
1650        .AC 2/FGPUXY$.*:?52!#/
1660        .AC 3/HJKQVWZ>1-...../
1670 *--------------------------------
1680        .MA QT
1690 QN.    .SE QN.+1
1700 ]1 .EQ QN.
1710        .AC /]2/
1720        .EM
1730 QN.    .SE 0
1740 *--------------------------------
1750    .AC "%"      ELIMINATE QT# 0
1760    >QT QSC,"S-C MACRO ASSEMBLER %"
1770    >QT QST,"SYMBOL TABLE%"
1780    >QT QSTARS,"#***!! %"
1790    >QT QSRCPRG,"#SOURCE PROGRAM: $%"
1800    >QT QSYMTBL,"#  SYMBOL TABLE: $%"
1810    >QT QERROR," ERROR#%"
1820    >QT PAGEQT," PAGE %"
1830    >QT QREPPRMT,"#REPLACE? %"
1840    >QT QERRCNT," ERRORS IN ASSEMBLY#%"
1850    >QT QBLOADB," LOAD %"
1860    >QT QDELOR,"DELETE ORIGINAL? %"
1870    >QT QMEMPRO,"MEM PROTECT%"
1880    >QT QMEMFL,"MEM FULL%"
1890    >QT QSYNX,"SYNTAX%"
1900    >QT QER1,"NO LABEL%"
1910    >QT QER2,"BAD OPCODE%"
1920    >QT QER3,"RANGE%"
1930    >QT QER4,"EXTRA DEFINITION%"
1940    >QT QER5,"BAD ADDRESS%"
1950    >QT QER6,"UNDEF LABEL%"
1960    >QT QER7,"BAD SYMBOL%"
1970    >QT QER8,"VALUE > 255%"
1980    >QT QER9,"NO NORMAL LABEL%"
1990    >QT QNIN,"NESTED .IN%"
2000    >QT QERDO,"MISSING .DO%"
2010    >QT QERDO2,".DO NEST TOO DEEP%"
2020    >QT QSTRLNG,"KEY TOO LONG%"
2030    >QT QNONAM,"NO MACRO NAME%"
2040    >QT QREPLNG,"REPLACE TOO LONG%"
2050    >QT QERR.MACRO,"UNDEF MACRO%"
2060    .AC "%"      FLUSH LAST BYTE
2070 *--------------------------------
2080        .DO 0
2090 T
2100        LDA #1
2110        STA 0
2120 .1     LDA 0
2130        JSR $FDDA
2140        LDY 0
2150        JSR PRINT.QUOTATION
2160        JSR $FD8E
2170        INC 0
2180        LDA 0
2190        CMP #$20
2200        BCC .1
2210        RTS
2220        .FIN
