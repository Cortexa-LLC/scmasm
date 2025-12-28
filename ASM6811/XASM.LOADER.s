
1000 *SAVE XASM.LOADER
1010 *--------------------------------
1020 SPTR   .EQ $00
1030 DPTR   .EQ $02
1040 *--------------------------------
1050 *   sys file   execution
1060 *   ---------  ---------
1070 *   2000-20FF             This loader
1080 *   2100-2BFF  D400-DEFF  S-C Cross Assembler module
1090 *--------------------------------
1100        .MA MOVE
1110        LDA /]1      DESTINATION
1120        LDY /]2      SOURCE BEGINNING
1130        LDX /]3-]2+255   # PAGES
1140        JSR MOVE
1150        .EM
1160 *--------------------------------
1170 LOAD.SC
1180        LDA $C083
1190        LDA $C083
1200        >MOVE $D400,$2100,$2BFF
1210        LDA $C082
1220 *---START UP ProDOS--------------
1230 .2     JMP $8000
1240 *--------------------------------
1250 *      MOVE (X) PAGES FROM YY00 TO AA00
1260 *--------------------------------
1270 MOVE
1280        STA DPTR+1
1290        STY SPTR+1
1300        LDY #0
1310        STY DPTR
1320        STY SPTR
1330 .1     LDA (SPTR),Y
1340        STA (DPTR),Y
1350        INY
1360        BNE .1
1370        INC SPTR+1  
1380        INC DPTR+1  
1390        DEX
1400        BNE .1
1410        RTS
1420 *--------------------------------
1430        .AS /<<>>/
1440 *--------------------------------
