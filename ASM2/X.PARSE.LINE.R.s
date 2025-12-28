
1000 *SAVE X.PARSE.LINE.R
1010 *---------------------------------
1020 *      PARSE LINE RANGE
1030 *                          START  END       CARRY
1040 *                     (PP)   (HI.MEM)   SET
1050 *          #          #      #         CLEAR
1060 *          #1,#2      #1     #2        CLEAR
1070 *          #,              #      (HI.MEM)   CLEAR
1080 *          ,#              (PP)   #         CLEAR
1090 *---------------------------------
1100 PARSE.LINE.RANGE
1110        JSR SETUP.TEXT.POINTERS
1120        JSR GNNB.AUC  GET NEXT NON-BLANK CHAR
1130        BCS .4       EOL, RETURN WITH CARRY SET
1140        BEQ .1       COMMA, SO START AT PP
1150        JSR SCAN.LINE.NUMBER
1160        BCS .5
1170        LDA LINE.START
1180        STA SRCP
1190        LDA LINE.START+1
1200        STA SRCP+1
1210        JSR GNNB.AUC  GET NEXT NON-BLANK AFTER LINE NUMBER
1220        BCS .2       EOL, SO ONLY THIS ONE LINE
1230        BNE .5       NOT COMMA, SO ERROR
1240 .1     JSR GNNB.AUC  GET NEXT NON-BLANK AFTER COMMA
1250        BCS .3       EOL, SO GO THRU HI.MEM
1260        BEQ .3       COMMA, SAME AS EOL
1270        JSR SCAN.LINE.NUMBER
1280        BCS .5
1290 .2     LDA LINE.END
1300        STA ENDP
1310        LDA LINE.END+1
1320        STA ENDP+1
1330 .3     CLC          FLAG WE GOT AT LEAST ONE NUMBER
1340 .4     RTS
1350 .5     JMP SYNX
1360 *---------------------------------
1370 *      SCAN INPUT LINE FOR DIGIT OR PERIOD
1380 *      IF FIND DIGIT, CONVERT LINE NUMBER
1390 *                     AND SEARCH FOR IT
1400 *      IF FIND PERIOD, SEARCH FOR 
1410 *      IF NEITHER, RETURN WITH CARRY SET
1420 *---------------------------------
1430 SCAN.LINE.NUMBER
1440        CMP #'.      DOT: USE (CURLNO)
1450        BEQ .1
1460        EOR #$30
1470        CMP #10
1480        BCS .2       NOT DOT NOR DIGIT, EXIT CARRY SET
1490        JSR DECN     CONVERT THE NUMBER
1500        JSR BACKUP.CHAR.PNTR
1510        LDX #SYM.VALUE
1520        .HS 2C       SKIP OVER NEXT 2 BYTES
1530 .1     LDX #CURLNO
1540        JSR SERTXT   FIND LINE
1550        CLC          SIGNAL GOOD NUMBER
1560 .2     RTS
1570 *--------------------------------
1580 *      LOAD PP --> SRCP, HI.MEM --> ENDP
1590 *--------------------------------
1600 SETUP.TEXT.POINTERS
1610        LDA PP       ASSUME PP THRU HI.MEM
1620        STA SRCP
1630        LDA PP+1
1640        STA SRCP+1
1650        LDA HI.MEM
1660        STA ENDP
1670        LDA HI.MEM+1
1680        STA ENDP+1
1690        RTS
1700 *--------------------------------
1710 CMP.SRCP.ENDP
1720        LDA SRCP
1730        CMP ENDP
1740        LDA SRCP+1
1750        SBC ENDP+1
1760        RTS
1770 *--------------------------------
1780 *      GET NEXT NON-BLANK CHARACTER
1790 *      AND CHECK FOR A, U, OR COMMA
1800 *      SET CARRY IF A, U, OR EOL
1810 *      SET EQ IF A, U, EOL, OR COMMA
1820 *--------------------------------
1830 GNNB.AUC
1840        JSR GNNB     NEXT NON-BLANK, CONV LOWER TO UPPER
1850        BCS .1       EOL
1860        CMP #'A
1870        BEQ .1
1880        CMP #'U
1890        BEQ .1
1900        CMP #',
1910        CLC
1920        RTS
1930 .1     JSR BACKUP.CHAR.PNTR
1940        SEC
1950        RTS
