
1000 *SAVE SC.VARIABLES
1010 *--------------------------------
1020 ALLOCATED.BUFFER.PAGE .BS 1
1030 *--------------------------------
1040 FNLEN          .BS 1
1050 RECORD.LENGTH  .BS 2
1060 PARM.LENM1     .BS 1
1070 PARM.OFFSET    .BS 1
1080 ACCUM          .BS 3
1090 OVERFLOW       .BS 1
1100 COMMAND.ADDR   .BS 2
1110 BLOCKS         .BS 2
1120 *--------------------------------
1130 MONTH  .BS 1
1140 DAY    .BS 1
1150 YEAR   .BS 1
1160 *--------------------------------
1170 CAT.WIDTH         .BS 1
1180 ENTRY.LENGTH      .BS 1
1190 ENTRIES.PER.BLOCK .BS 1
1200 FILE.COUNT        .BS 2
1210 ENTRY.COUNTER     .BS 1
1220 *--------------------------------
1230 CAT.INDEX           .BS 1
1240 *--------------------------------
1250 FILE.REFNUMS        .BS 2
1260 FILE.BUFFER.PNTRS   .BS 2
1270 *--------------------------------
1280 EXEC.REFNUM         .BS 1
1290 EXEC.INPUT.CHAR     .BS 1
1300 *--------------------------------
1310 WRITE.REFNUM        .BS 1
1320 WRITE.OUTPUT.CHAR   .BS 1
1330 *--------------------------------
1340 PATHNAME.ONE.BUFFER .BS 1
1350 TXTBUF              .BS 65
1360 *--------------------------------
1370 *   OPEN FILE NAME BUFFERS
1380 *      3 BUFFERS, 32 BYTES EACH
1390 *      0 -- # BYTES IN FILE NAME (bits (6-0)
1400 *           Bit 7 = DIR file READ flag
1410 *      1 -- L value lsb
1420 *      2 -- L value msb
1430 *   3-31 -- file name, backwards
1440 *--------------------------------
1450 OPEN.FILE.NAME.BUFFERS
1460        .BS 32*3
1470 *--------------------------------
