
1000 *SAVE X.EDIT.LINES
1010 *--------------------------------
1020 *      EDIT ONE LINE
1030 *          TEXT OF LINE ALREADY IN WBUF
1040 *          (A1L,A1H) POINT AT LINE IN SOURCE AREA
1050 *--------------------------------
1060 EDIT.ONE.LINE
1070        LDA BOTTOM.OF.SCREEN
1080        STA ED.BEGLIN
1090        JSR IO.VTAB
1100        JSR E.BEG    Start edit 2 columns after line #
1110 .1     STX ED.PNTR
1120        JSR E.DISPLAY.LINE  Put line on screen
1130        LDX ED.PNTR  Restore PNTR in X
1140        JSR E.PROCESS.CHAR
1150        BCC .1       Not control-L, -M, or -Q
1160        JSR E.DISPLAY.LINE  ...One last time
1170        JSR CRLF
1180        JMP NML      Submit line and return
1190 *--------------------------------
1200 *      DISPLAY LINE FROM WBUF
1210 *--------------------------------
1220 E.DISPLAY.LINE
1230        LDA ED.BEGLIN
1240        JSR IO.VTAB
1250        LDA #0
1260        JSR IO.HTAB
1270        JSR SPC      One space
1280        LDX #0
1290 .1     LDA WBUF,X
1300        BEQ .4       End of line
1310        ORA #$80
1320        CMP #$A0     Control char?
1330        BCS .2       No
1340        AND #$3F     ...YES, MAKE IT INVERSE
1350 .2     PHA
1360        JSR GET.HORIZ.POSN
1370        TAY
1380        PLA
1390        INY
1400        CPY SCREEN.WIDTH
1410        BCC .3       No
1420        LDY CV       Last line on screen?
1430        CPY BOTTOM.OF.SCREEN
1440        BCC .3       No
1450        DEC ED.BEGLIN  Yes, it will scroll
1460 .3     JSR IO.COUT
1470        INX
1480        BNE .1       ...Always
1490 .4     JMP IO.CLREOP
1500 *--------------------------------
1510 *      PROCESS EDITING CHARACTER
1520 *--------------------------------
1530 E.PROCESS.CHAR
1540 EPC.1  JSR E.INPUT  Get char from keyboard
1550 EPC.2  CMP #$A0     Control char?
1560        BCC E.PROCESS.CNTRL
1570 *--------------------------------
1580 *      PUT CHARACTER INTO LINE
1590 *--------------------------------
1600 E.PUT.CHARACTER
1610        LDA WBUF,X   At end of line?
1620        BNE .1       No
1630        CPX #WBUF.MAX  Line too long?
1640        BCS .2       Yes
1650        STA WBUF+1,X Put new 
1660 .1     LDA CURRENT.CHAR
1670        STA WBUF,X
1680        INX
1690 .2     CLC
1700        RTS
1710 *--------------------------------
1720 *      PROCESS CONTROL CHAR
1730 *--------------------------------
1740 E.PROCESS.CNTRL
1750        LDY #CHARS.FOR.EDIT
1760        JMP SEARCH.CHAR.TABLES
1770 *--------------------------------
1780 E.ILLCHAR
1790        JSR MON.BELL
1800        LDX ED.PNTR  Restore X-reg
1810        JMP EPC.1
1820 *--------------------------------
1830 *      CONTROL-R:  RESTORE ORIGINAL LINE
1840 *--------------------------------
1850 E.RESTORE
1860        LDA A1L      Set line pointer back
1870        STA SRCP
1880        LDA A1H
1890        STA SRCP+1
1900        JSR GET.LINE.TO.WBUF
1910 *--------------------------------
1920 *      CONTROL-B:  BEGINNING OF LINE
1930 *--------------------------------
1940 FIND.START.OF.LINE.IN.WBUF
1950 E.BEG  LDY #0       Find 1st column after line number
1960 .1     JSR GNC2
1970        BCS .2       End of line
1980        JSR CHECK.DIGIT
1990        BCS .1       Yes
2000        INY
2010 .2     TYA          Get column # into X
2020        TAX
2030        DEX
2040        CLC
2050        RTS
2060 *--------------------------------
2070 *      CONTROL-D:  DELETE CHARACTER
2080 *--------------------------------
2090 E.DEL  LDX ED.PNTR
2100 .1     LDA WBUF,X   Are we at the end?
2110        BEQ .3       Yes
2120 .2     INX          ADVANCE PNTR
2130        LDA WBUF,X   SLIDE REST OF LINE LEFT
2140        STA WBUF-1,X   ...to delete char
2150        BNE .2       ...UNTIL END OF LINE
2160 .3     LDX ED.PNTR
2170        CLC
2180        RTS          Return with Carry clear
2190 *--------------------------------
2200 *      CONTROL-N:  END OF LINE
2210 *--------------------------------
2220 E.END  LDX ED.PNTR
2230        DEX
2240 .1     INX
2250        LDA WBUF,X   End of buffer?
2260        BNE .1       ...KEEP LOOKING
2270        CLC
2280        RTS          Carry clear
2290 *--------------------------------
2300 *      CONTROL-F:  FIND NEXT OCCURRENCE
2310 *--------------------------------
2320 E.FIND LDX ED.PNTR
2330        LDA WBUF,X   End of buffer?
2340        BEQ .3       Yes
2350        JSR E.INPUT  Get 1 char
2360        STX ED.FCOL  Save beg col
2370        STA ED.FKEY  Save key to locate
2380 .1     INX
2390        LDA WBUF,X   Text buffer
2400        BEQ .2       End of buffer
2410        ORA #$80
2420        CMP ED.FKEY  No, see if key
2430        BNE .1       No, go forward
2440        STX ED.FCOL  Save this col
2450        JSR E.INPUT  Try another key
2460        CMP ED.FKEY  Same char
2470        BEQ .1       Yes, search again
2480        STX ED.PNTR    No, exit pointing here
2490        JMP EPC.2
2500 .2     LDX ED.FCOL  Restore col
2510 .3     JSR MON.BELL Beep
2520        CLC
2530        RTS
2540 *--------------------------------
2550 *      CONTROL-H:  BACKSPACE
2560 *--------------------------------
2570 E.BKSP LDX ED.PNTR
2580        TXA          At beginning already?
2590        BEQ .1       Yes, stay there
2600        DEX          Backup
2610 .1     CLC
2620        RTS
2630 *--------------------------------
2640 *      CONTROL-O:  ALLOW INSERTION OF CONTROL CHAR
2650 *--------------------------------
2660 E.OVR  LDX ED.PNTR
2670        JSR E.INPUT  Read char
2680        JMP E.INS1   Skip control check
2690 *--------------------------------
2700 *      CONTROL-I:  INSERT CHARACTERS
2710 *--------------------------------
2720 E.INS  LDX ED.PNTR
2730        JSR E.INPUT  Read char
2740        CMP #$A0     Control char pops user out
2750        BCS E.INS1
2760        JMP E.PROCESS.CNTRL
2770 E.INS1 CPX #WBUF.MAX     End of block
2780        BEQ .1       Yes, stay there
2790        INC ED.PNTR
2800 .1     PHA          Char to insert
2810        LDA WBUF,X   Save char to move
2820        TAY
2830        PLA
2840        STA WBUF,X   Put over saved char
2850        INX
2860        TYA          Insert saved char
2870        BNE .1       If not buffer end
2880        CPX #WBUF.MAX     At end?
2890        BCC .2       Not yet
2900        LDX #WBUF.MAX     Yes
2910 .2     STA WBUF,X   Store end char
2920        JSR E.DISPLAY.LINE
2930        LDX ED.PNTR
2940        BNE E.INS    ...Always
2950 *--------------------------------
2960 *      CONTROL-Q:  QUIT, DROPPING REST OF LINE
2970 *--------------------------------
2980 E.RETQ JSR E.ZAP    Clear rest of line
2990 *--------------------------------
3000 *      CONTROL-M:  QUIT, SUBMITTING WHOLE LINE
3010 *--------------------------------
3020 E.RET  SEC
3030        RTS
3040 *--------------------------------
3050 *      CONTROL-L:  SUBMIT THIS LINE, EDIT NEXT LINE
3060 *--------------------------------
3070 E.DOWN LDA ENDP     See if at HI.MEM already
3080        CMP HI.MEM
3090        LDA ENDP+1
3100        SBC HI.MEM+1
3110        BCS .1       Yes, no need to move ENDP
3120        JSR CMP.SRCP.ENDP     End of range yet?
3130        BCC .1                ...NO
3140        CLC          Move ENDP one line
3150        LDY #0
3160        LDA (SRCP),Y Line length of next line
3170        ADC ENDP
3180        STA ENDP
3190        BCC .1
3200        INC ENDP+1
3210 .1     SEC          Signal submit line
3220        RTS
3230 *--------------------------------
3240 *      CONTROL-T:  SKIP TO NEXT TAB STOP
3250 *--------------------------------
3260 E.TAB  LDX ED.PNTR
3270 .1     JSR E.CHECK.TAB
3280        BCS E.RIT1   MOVE ONE MORE COLUMN
3290        JSR E.RIT1   Move one column right
3300        BCC .1       ...ALWAYS
3310 *--------------------------------
3320 *      CONTROL-U:  RIGHT ARROW
3330 *--------------------------------
3340 E.RIT  LDX ED.PNTR
3350 E.RIT1 LDA WBUF,X   End of buffer?
3360        BNE .1       No
3370        CPX #WBUF.MAX
3380        BCS .2
3390        STA WBUF+1,X
3400        LDA #$A0     Put a blank
3410        STA WBUF,X   To extend line
3420 .1     INX          Move ahead
3430 .2     CLC          Return
3440        RTS
3450 *--------------------------------
3460 *      CONTROL-X:  ABORT EDIT COMMAND
3470 *--------------------------------
3480 E.ABORT
3490        JSR E.DISPLAY.LINE
3500        LDA #$DC     Backslash
3510        JSR MY.COUT
3520        JMP GNL      Get next command
3530 *--------------------------------
3540 *      CONTROL-@:  CLEAR TO EOL
3550 *--------------------------------
3560 E.ZAP  LDA #0       EOL mark
3570        LDX ED.PNTR
3580        STA WBUF,X
3590        CLC
3600        RTS          Carry clear
3610 *--------------------------------
3620 *      INPUT CHAR WHERE CURSOR SHOULD BE
3630 *--------------------------------
3640 E.INPUT
3650        LDY ED.BEGLIN
3660        INX
3670        TXA
3680        DEX
3690        DEY
3700        SEC
3710 .1     INY
3720        SBC SCREEN.WIDTH
3730        BCS .1
3740        ADC SCREEN.WIDTH
3750        JSR IO.HTAB  HTAB (A)
3760        TYA
3770        JSR IO.VTAB
3780        JSR READ.KEY.WITH.CASE
3790        STA CURRENT.CHAR
3800        RTS
3810 *--------------------------------
3820 *      DETERMINE IF AT TAB STOP YET
3830 *      RETURN .EQ. IF AT A TAB STOP
3840 *             .CS. IF PAST LAST TAB STOP
3850 *             .CC. IF BEFORE A TAB STOP
3860 *--------------------------------
3870 E.CHECK.TAB
3880        TXA          Column position
3890        CLC
3900        ADC #3
3910        LDY #0
3920 .1     CMP TAB.SETTINGS,Y
3930        BCC .2
3940        BEQ .2
3950        INY
3960        CPY #5
3970        BCC .1
3980 .2     RTS
3990 *--------------------------------
4000 *      CONTROL-I -- CLEAR TO TAB STOP
4010 *--------------------------------
4020 E.TABI LDX ED.PNTR
4030        LDA #" "
4040        STA CURRENT.CHAR
4050 .1     JSR E.CHECK.TAB
4060        BCS .2       ...REACHED TAB STOP
4070        JSR E.PUT.CHARACTER
4080        BCC .1       ...ALWAYS
4090 .2     JMP E.PUT.CHARACTER One more space
4100 *--------------------------------
4110 E.TOGGLE
4120        JSR IO.CASE.TOGGLE
4130        CLC
4140        RTS
