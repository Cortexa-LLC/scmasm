
1000 *SAVE X.PARAMETERS
1010 *--------------------------------
1020 *    ENTRY POINTS AND USER EXITS
1030 *--------------------------------
1040 *    HARD ENTRY
1050 HARD   JSR HARD.INIT
1060 *--------------------------------
1070 *    SOFT ENTRY
1080        JMP SOFT
1090 *--------------------------------
1100 *    USER DEFINED COMMAND
1110 USR    JMP SOFT
1120 *--------------------------------
1130 *    USER PRINT ROUTINE
1140 PRT    JMP SOFT
1150 *--------------------------------
1160 *    USER ESC-U FUNCTION
1170 USER.ESC.U
1180        JMP RDL.ERR
1190 *--------------------------------
1200 *    USER "." COMMAND
1210 USER.CMD JMP SOFT
1220 *--------------------------------
1230 *    USER OBJECT CODE STORAGE
1240 USER.OBJECT.BYTE
1250        JMP STORE.OBJECT.BYTE
1260 *--------------------------------
1270 *    USER ASSEMBLER DIRECTIVE
1280 PSUSER JMP CMNT
1290 *--------------------------------
1300 *    TAB CONTROL CHARACTER AND TAB STOPS
1310 TAB.CHAR   .DA #CHR.CTRL.I
1320 TAB.SETTINGS .DA #14,#18,#27,#32,#0
1330 *--------------------------------
1340 *    USER COMMENT CHARACTER
1350 *     (IN ESC-L FROM COLUMN 6)
1360 *--------------------------------
1370 USER.COM.DELIM .DA #CHR.DASH
1380 *--------------------------------
1390 *      COMPRESSION LOWER LIMIT
1400 *      =4 IF DESIRE COMPRESSION
1410 *      =255 IF DO NOT DESIRE COMPRESSION
1420 *--------------------------------
1430 COMPRESSION.LIMIT .HS 04
1440 *--------------------------------
1450 *      WILD CARD CHARACTER FOR SEARCH STRING
1460 *--------------------------------
1470 WILD.CARD .HS 17    CONTROL-W
1480 *--------------------------------
1490 *    OUTPUT A SINGLE CHARACTER TO SCREEN
1500 *--------------------------------
1510 MY.COUT JMP MON.COUT
1520 *--------------------------------
1530 USER.MEM.LO .DA $0000
1540 USER.MEM.HI .DA $0000
1550 *--------------------------------
1560 *   LINKAGE TO FULL SCREEN EDITOR
1570 *--------------------------------
1580 LINK.FSE
1590        JMP GNL      <<>>
1600 *--------------------------------
1610        JMP GNC.UC
1620        JMP GNNB
1630        JMP CMNT
1640        JMP ERBA
1650        JMP EMIT
1660 *--------------------------------
1670 BOTTOM.OF.SCREEN
1680        .DA #23      CHANGE TO 31 OR 47 FOR LONGER SCREENS
1690 *--------------------------------
