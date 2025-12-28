
1000 *SAVE X.TABLES.DIREC
1010 *---------------------------------
1020        .DO 1
1030 *--------------------------------
1040 DIR.   .SE 0
1050        .MA DIR
1060        .DO "]1"=DIR.=0
1070        .DA #"]1"-$C0
1080 DIR.   .SE "]1"
1090        .FIN
1100        .DA #"]2"-$40,]3-1   .]1]2
1110        .EM
1120 *--------------------------------
1130 OPTBL.DIR
1140      >DIR A,C,DIR.AC   ASCII STRING COMPRESSED
1150      >DIR A,S,PSAS     ASCII STRING
1160      >DIR A,T,PSAT     ASCII STRING WITH LAST BYTE
1170      >DIR A,Z,PSAZ     ASCII STRING WITH ZERO END
1180      >DIR B,S,PSBS     BLOCK STORAGE
1190      >DIR D,A,PSDA     DATA
1200      >DIR D,O,PSDO     DO
1210      >DIR D,U,D.DUMMY  DUMMY
1220      >DIR E,D,D.END.DUMMY
1230      >DIR E,L,PSEL     ELSE
1240      >DIR E,N,PSEN     END OF SOURCE
1250      >DIR E,P,D.END.PHASE
1260      >DIR E,Q,PSEQ     EQUATE
1270      >DIR F,I,PSFI     FIN
1280      >DIR H,S,PSHS     HEX STRING
1290      >DIR I,N,PSIN     INCLUDE
1300      >DIR L,I,PSLI     LIST ON,/   OFF
1310      >DIR M,A,PSMA     MACRO
1320      >DIR O,P,PSOP     OPCODE TABLE SELECT
1330      >DIR O,R,PSOR     ORIGIN
1340      >DIR P,G,PSPG     PAGE EJECT
1350      >DIR P,H,D.PHASE  PHASE
1360      >DIR T,A,PSTA     TARGET ADDRESS
1370      >DIR T,F,PSTF     TARGET FILE
1380      >DIR T,I,PSTI     TITLE
1390      >DIR U,S,PSUSER   USER DIRECTIVE
1400        .HS 41       <<<TERMINATOR>>>
1410 *--------------------------------
1420        .ELSE
1430 *--------------------------------
1440 *   DIRECTIVE TABLE
1450 *--------------------------------
1460        .MA DIR
1470        .AS /]1/
1480        .DA ]2-1
1490        .EM
1500 *---------------------------------
1510 OPTBL.DIR
1520        .HS 0402      ITEM SIZE, KEY SIZE
1530        >DIR AS,PSAS     ASCII STRING
1540        >DIR AT,PSAT     ASCII STRING WITH LAST BYTE
1550        >DIR BS,PSBS     BLOCK STORAGE
1560        >DIR DA,PSDA     DATA
1570        >DIR DO,PSDO     DO
1580        >DIR DU,D.DUMMY  DUMMY
1590        >DIR ED,D.END.DUMMY
1600        >DIR EL,PSEL     ELSE
1610        >DIR EN,PSEN     END OF SOURCE
1620        >DIR EP,D.END.PHASE
1630        >DIR EQ,PSEQ     EQUATE
1640        >DIR FI,PSFI     FIN
1650        >DIR HS,PSHS     HEX STRING
1660        >DIR IN,PSIN     INCLUDE
1670        >DIR LI,PSLI     LIST ON,/   OFF
1680        >DIR MA,PSMA     MACRO
1690        >DIR OP,PSOP     OPCODE TABLE SELECT
1700        >DIR OR,PSOR     ORIGIN
1710        >DIR PG,PSPG     PAGE EJECT
1720        >DIR PH,D.PHASE  PHASE
1730        >DIR TA,PSTA     TARGET ADDRESS
1740        >DIR TF,PSTF     TARGET FILE
1750        >DIR TI,PSTI     TITLE
1760        >DIR US,PSUSER   USER DIRECTIVE
1770        .HS 00        MARK END OF TABLE
1780        .FIN
1790 *--------------------------------
