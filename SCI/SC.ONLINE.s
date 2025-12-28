
1000 *SAVE SC.ONLINE
1010 *--------------------------------
1020 ONLINE LDA BUFFER.BASES
1030        STA MISC.PARMS+3
1040        LDA #0
1050        STA MISC.PARMS+2
1060        STA MISC.PARMS+1
1070        JSR MLI.C5   (Might clobber DRIVER.PTR)
1080 *---Now display the list---------
1090        LDA BUFFER.BASES
1100        STA DRIVER.PTR+1
1110        LDA #0
1120        STA DRIVER.PTR
1130 .1     PHA
1140        TAY
1150        LDA (DRIVER.PTR),Y
1160        BEQ .5            ...END OF LIST
1170        PHA
1180        LDA #"S"
1190        JSR COUT
1200        PLA
1210        PHA
1220        LSR               ISOLATE SLOT NUMBER
1230        LSR
1240        LSR
1250        LSR
1260        AND #7
1270        ORA #"0"
1280        JSR COUT          PRINT SLOT NUMBER
1290        LDA #","
1300        JSR COUT
1310        LDA #"D"
1320        JSR COUT
1330        PLA
1340        PHA
1350        ASL               SET CARRY IF DRIVE 2
1360        LDA #"1"          ASSUME DRIVE 1
1370        ADC #0            CHANGE TO 2 IF TRUE
1380        JSR COUT
1390        LDA #" "     PRINT SPACE
1400        JSR COUT
1410        PLA          get dsssllll again
1420        AND #$0F     isolate length
1430        BEQ .3       no name, show error code
1440        TAX
1450        LDA #"/"
1460 .2     JSR COUT
1470        INY          PRINT THE VOLUME OR FILE NAME
1480        LDA (DRIVER.PTR),Y
1490        ORA #$80
1500        DEX
1510        BPL .2
1520        LDA #"/"
1530        BNE .4       ...ALWAYS
1540 .3     LDA #"("
1550        JSR COUT
1560        INY
1570        LDA (DRIVER.PTR),Y    GET ERROR CODE
1580        JSR PRBYTE
1590        LDA #")"
1600 .4     JSR COUT
1610        JSR CROUT
1620 *--------------------------------
1630 .5     CLC               POINT TO NEXT VOLUME NAME
1640        PLA
1650        ADC #16
1660        BCC .1       STILL IN SAME PAGE
1670        CLC          NO ERROR!
1680        RTS
1690 *--------------------------------
