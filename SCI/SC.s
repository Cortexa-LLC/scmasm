
1000  .LIF
1010 *SAVE SC
1020        .TI 76,S-C ProDOS Interface...............July 13, 1988.................
1030 *--------------------------------
1040        .OR $4B00    BLOAD POSITION IN SYS FILE
1050        .TF B.SCI
1060        .PH $AA00
1070 *--------------------------------
1080        .INB SC.EQUATES
1090        .INB SC.COMMAND.PAR
1100        .INB SC.CATALOG
1110        .INB SC.EXEC
1120        .INB SC.ONLINE
1130        .INB SC.PR.IN
1140        .INB SC.ERRORS
1150        .INB SC.LOAD.SAVE
1160        .INB SC.OPEN.CLOSE
1170        .INB SC.RWPA
1180        .INB SC.TABLES
1190 *--------------------------------
1200 WASTE  .EQ $BD00-*
1210        .BS WASTE
1220        .INB SC.VARIABLES
1230 *--------------------------------
1240 WASTED .EQ $BE00-*
1250        .BS WASTED
1260        .INB SC.GLOBAL.PAGE
