
1000 *SAVE X.ASM.LINKAGE
1010 *--------------------------------
1020        .DUMMY
1030        .OR $A700
1040 SEARCH.COMPRESSED.TABLE  .BS 3
1050 GNC                      .BS 3
1060 GNC.UC                   .BS 3
1070 GNNB                     .BS 3
1080 EXPR                     .BS 10
1090 EXP1                     .BS 10
1100 ASM.ERROR                .BS 3
1110 EMIT                     .BS 10
1120 *--------------------------------
1130        .OR $F0      F0-FF is ASM private ZeroPage
1140 LEVEL.MASK               .BS 1
1150 OPBASE                   .BS 1
1160 MODE.BYTE                .BS 1
1170 FORCE.ADDR.SIZE          .BS 1
1180        .ED
1190 *--------------------------------
1200 ERR.BAD.OPCODE      .EQ 0
1210 ERR.BAD.ADDRESS     .EQ 1
1220 ERR.RANGE           .EQ 2
1230 ERR.UNDEFINED       .EQ 3
1240 *--------------------------------
1250        JMP ASM.INIT
1260        JMP ASM.LINE
1270        JMP EMIT.VALUE
1280        JMP DIR.OP
1290 *--------------------------------
1300        .AS -/FOR THE 6502, 65C02, 65R02, 65816/
1310        .HS 00
1320 *--------------------------------
