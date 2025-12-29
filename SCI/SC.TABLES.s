
1000 *SAVE SC.TABLES
1010 *--------------------------------
1020 CN.    .SE 1
1030        .MA CMD
1040 CN.    .SE CN.+1
1050 CN.]2 .EQ CN.
1060        .AT /]2]3/
1070        .DA ]2
1080        .HS ]1
1090        .EM
1100 *--------------------------------
1110 COMMAND.TABLE
1120        .AT /-/
1130        .DA DASH
1140        .HS 0104
1150        >CMD 05F4,BLOAD
1160        >CMD 01F4,BRUN
1170        >CMD 0DF4,BSAVE
1180        >CMD 0000,BYE
1190        >CMD 9504,CATALOG
1200        >CMD 9504,CAT
1210        >CMD 0100,CLOSE
1220        >CMD 0D84,CREATE

1230 *       >CMD 0104,DELETE

1240 CN.				.SE CN.+1
1250 CN.DELETE		.EQ CN.
1260 				.AT /DELETE/
1270 				.DA MLI.C1
1280 				.HS 0104

1290        >CMD 0107,EXEC
1300        >CMD 4080,IN,#
1310        >CMD 0504,LOAD
1320        >CMD 0104,LOCK
1330        >CMD 0000,NOPREFIX
1340        >CMD 0000,NOW
1350        >CMD 0000,ONLINE
1360        >CMD 2D14,OPEN
1370        >CMD 4080,PR,#
1380        >CMD 9104,PREFIX
1390        >CMD 0304,RENAME
1400        >CMD 0D04,SAVE
1410        >CMD 0104,UNLOCK
1420        >CMD 1104,VERIFY
1430        >CMD 2147,WRITE
1440        .HS 00
1450 *--------------------------------
1460 *   PARAMETER NAME TABLE
1470 *--------------------------------
1480 PARM.NAMES
1490        .AS /ABELSDFRV/
1500 NO.PARM.NAMES .EQ *-PARM.NAMES
1510 *--------------------------------
1520 *   BIT MASK FOR PARAMETERS IN PERMISSION BITS
1530 *--------------------------------
1540 *          A  B  E  L  S  D  F  R  V  @
1550 PARM.MASKS
1560        .HS 80.40.20.10.04.04.02.01.00
1570 *--------------------------------
1580 *      XXXXXXYY where yy+1= # of bytes
1590 *                   xxxxxx= offset from VAL.A
1600 *                           of last byte
1610 *--------------------------------
1620        .MA PAR
1630        .DA #VAL.]1-VAL.A+]2-1*4+]2-1
1640        .EM
1650 *--------------------------------
1660 PARM.VARIABLES
1670        >PAR A,2
1680        >PAR B,3
1690        >PAR E,2
1700        >PAR L,2
1710        >PAR S,1
1720        >PAR D,1
1730        >PAR F,2
1740        >PAR R,2
1750        >PAR V,1
1760 *--------------------------------
1770 *   FILE TYPE CODES
1780 *--------------------------------
1790        .MA FT
1800        .AS -/]1/
1810        .HS ]2
1820        .EM
1830 *--------------------------------
1840 FILE.TYPES
1850        >FT TXT,04
1860        >FT BIN,06
1870        >FT DIR,0F
1880        >FT ADB,19
1890        >FT AWP,1A
1900        >FT ASP,1B
1910        >FT PAS,EF
1920        >FT CMD,F0
1930        >FT S-C,FA   (NORMALLY "INT")
1940        >FT IVR,FB
1950        >FT BAS,FC
1960        >FT VAR,FD
1970        >FT REL,FE
1980        >FT SYS,FF
1990 LAST.FILE.TYPE .EQ *-FILE.TYPES-1
2000 *--------------------------------
2010 *   NAMES OF THE MONTHS
2020 *--------------------------------
2030 MONTH.NAMES
2040        .AS -/JFMAMJJASOND/
2050        .AS -/AEAPAUUUECOE/
2060        .AS -/NBRRYNLGPTVC/
2070 *--------------------------------
2080 NO.DATE.MSG
2090        .AS -/<NO DATE>/
2100 *--------------------------------
2110 *   MLI ERROR CODES
2120 *--------------------------------
2130 MLI.ERROR.CODES
2140        .HS 282B4041424344454647
2150        .HS 48494B4C4D4E505356
2160 *--------------------------------
2170 *   EQUIVALENT BI ERROR CODES
2180 *--------------------------------
2190 BI.ERROR.CODES
2200        .HS 0304100C0C1206068613  (86 IS A TRICK)
2210        .HS 09110D05020A140B0C08
2220 *--------------------------------
2230 SCI.MESSAGES
2240        .AC 0        INIT NYBBLE.FLAG
2250        .AC 1"ACDEFILNOPRST %"
2260        .AC 2"BGHKMUVWXY/():."
2270        .AC 3"QZ-4567890123@&"
2280 Q.BLOCKS.ABOVE .EQ 0
2290        .AC / BLOCKS SHOWN ABOVE:6%/
2300 *--------------------------------
2310 Q.DIRHDR .EQ 1
2320        .AC /TYPE   NAME2BLOCKS  MODIFIED9CREATED9ENDFILE AUXTYPE%/
2330 *--------------------------------
2340        .AC /RANGE ERROR%/
2350        .AC /NO DEVICE CONNECTED%/
2360        .AC /WRITE PROTECTED%/
2370        .AC /END OF DATA%/
2380        .AC /PATH NOT FOUND%/
2390 *--------------------------------
2400 Q.BLOCKS .EQ 7
2410        .AC / VOLUME BLOCKS USED:8FREE:8TOTAL:5%/
2420 *--------------------------------
2430        .AC "I/O ERROR%"
2440        .AC /DISK FULL%/
2450        .AC /FILE LOCKED%/
2460        .AC /INVALID PARAMETER%/
2470        .AC /NO BUFFERS AVAILABLE%/
2480        .AC /FILE TYPE MISMATCH%/
2490        .AC /PROGRAM TOO LARGE%/
2500        .AC /NOT DIRECT COMMAND%/
2510        .AC /SYNTAX ERROR%/
2520        .AC /DIRECTORY FULL%/
2530        .AC /FILE NOT OPEN%/
2540        .AC /DUPLICATE FILE NAME%/
2550        .AC /FILE BUSY%/
2560        .AC /FILE(S) STILL OPEN%/
2570 *--------------------------------
2580        .AC "%"
2590 *ZZ.MESSAGES .EQ *-MESSAGES
2600 *--------------------------------
2610 SCI.FIRST.TABLE .EQ *
2620        .HS 00
2630        .AS -"ACDEFILNOPRST "
2640        .HS 8D
2650 SCI.SECOND.TABLE .EQ *
2660        .HS 00
2670        .AS -"BGHKMUVWXY/():."
2680 SCI.THIRD.TABLE .EQ *
2690        .AS -"JQZ-"
2700        .HS 05.06.07.08.09.0A.0B.0C.0D.0E.0F.10   (BLANK COUNTS+1)
2710 *--------------------------------
