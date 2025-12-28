
1000 *SAVE SC.EQUATES
1010 *--------------------------------
1020 BASL   .EQ $28
1030 CSWL   .EQ $36
1040 CSWH   .EQ $37
1050 KSWL   .EQ $38
1060 KSWH   .EQ $39
1070 DRIVER.PTR  .EQ $3A,3B
1080 RETRY.COUNT .EQ $3C
1090 *--------------------------------
1100 SC.INFLAG  .EQ $51       $Cx if .INBx
1110 SC.LOMEM   .EQ $52,53    START OF SYMBOLS
1120 SC.EOT     .EQ $54,55    END OF SYMBOL TABLE
1130 SC.PP      .EQ $56,57    START OF SOURCE PROGRAM
1140 SC.HIMEM   .EQ $58,59    END OF SOURCE PROGRAM
1150 PASS       .EQ $63       PASS ($FF if command, 0 or 1 if assembling)
1160 *--------------------------------
1170 WBUF   .EQ $0200
1180 DIRBUF .EQ $0259
1190 PATHNAME.TWO.BUFFER .EQ $0280
1200 *--------------------------------
1210 GP.MLI      .EQ $BF00
1220 UNIT        .EQ $BF30
1230 BITMAP      .EQ $BF58
1240 GP.DATE     .EQ $BF90 ... 93
1250 LEVEL       .EQ $BF94
1260 PREFIX.FLAG .EQ $BF9A
1270 *--------------------------------
1280 KEYBOARD .EQ $C000
1290 STROBE   .EQ $C010
1300 IO.OFF   .EQ $CFFF
1310 *--------------------------------
1320 BELL       .EQ $FBE2
1330 ABORT.EXIT .EQ $FD10
1340 PRBYTE     .EQ $FDDA
1350 CROUT      .EQ $FD8E
1360 COUT       .EQ $FDED
1370 MON.SETVID .EQ $FE93
1380 *--------------------------------
1390 SC.HARD .EQ $8000
1400 SC.SOFT .EQ $8003
1410 *--------------------------------
