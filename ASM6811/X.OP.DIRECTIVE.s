
1000 *SAVE X.OP.DIRECTIVE
1010 *--------------------------------
1020 *   SELECT NUMBER OF BYTES OF OBJECT CODE
1030 *      TO LIST ON EACH LINE, FROM 2 TO 5
1040 *--------------------------------
1050 DIR.OP LDA PASS
1060        BEQ .1
1070        JSR EXPR     GET EXPRESSION
1080        LDA EXP.VALUE+3
1090        ORA EXP.VALUE+2
1100        ORA EXP.VALUE+1
1110        BNE .1
1120        LDA EXP.VALUE
1130        CMP #6
1140        BCS .2       ...TOO LARGE
1150        CMP #2
1160        BCC .2       ...TOO SMALL
1170        ASL
1180        ADC EXP.VALUE
1190        ADC #6
1200        STA EMIT.MARGIN
1210 .1     RTS
1220 .2     JMP ERBA
