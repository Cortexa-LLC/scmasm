
1000  .LIF
1010        .TI 76,S-C 68HC11 ASSEMBLER (ProDOS) 3.0               June 22, 1988     
1020 *SAVE X.ACF
1030 *--------------------------------
1040        .OR $2000
1050        .TF SCASM.68HC11
1060 *--------------------------------
1070        .INB X.DATA			Must be EXACT copy of ASM2/X.DATA
1080        .INB X.ASM.LOADER
1090        .BS $2100-*
1100        .PH $D400
1110 ZZ.START
1120        .INB X.ASM.LINKAGE
1130        .INB X.ASM.6811
1140        .INB X.OP.DIRECTIVE
1150 WASTED .EQ ZZ.START+$0B00-*
1160        .BS WASTED
1170 ZZ.END
1180 ZZ.ASMSIZE .EQ *-ZZ.START
1190        .EP
