
1000 *SAVE SC.TABLES
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
1230        >CMD 0104,DELETE
1240        >CMD 0107,EXEC
1250        >CMD 4080,IN,#
1260        >CMD 0504,LOAD
1270        >CMD 0104,LOCK
1280        >CMD 0000,NOPREFIX
1290        >CMD 0000,NOW
1300        >CMD 0000,ONLINE
1310        >CMD 2D14,OPEN
1320        >CMD 4080,PR,#
1330        >CMD 9104,PREFIX
1340        >CMD 0304,RENAME
1350        >CMD 0D04,SAVE
1360        >CMD 0104,UNLOCK
1370        >CMD 1104,VERIFY
1380        >CMD 2147,WRITE
1390        .HS 00
1400 *--------------------------------
1410 *   PARAMETER NAME TABLE
1420 *--------------------------------
1430 PARM.NAMES
1440        .AS /ABELSDFRV/
1450 NO.PARM.NAMES .EQ *-PARM.NAMES
1460 *--------------------------------
1470 *   BIT MASK FOR PARAMETERS IN PERMISSION BITS
1480 *--------------------------------
1490 *          A  B  E  L  S  D  F  R  V  @
1500 PARM.MASKS
1510        .HS 80.40.20.10.04.04.02.01.00
1520 *--------------------------------
1530 *      XXXXXXYY where yy+1= # of bytes
1540 *                   xxxxxx= offset from VAL.A
1550 *                           of last byte
1560 *--------------------------------
1570        .MA PAR
1580        .DA #VAL.]1-VAL.A+]2-1*4+]2-1
1590        .EM
1600 *--------------------------------
1610 PARM.VARIABLES
1620        >PAR A,2
1630        >PAR B,3
1640        >PAR E,2
1650        >PAR L,2
1660        >PAR S,1
1670        >PAR D,1
1680        >PAR F,2
1690        >PAR R,2
1700        >PAR V,1
1710 *--------------------------------
1720 *   FILE TYPE CODES
1730 *--------------------------------
1740        .MA FT
1750        .AS -/]1/
1760        .HS ]2
1770        .EM
1780 *--------------------------------
1790 FILE.TYPES
1800        >FT TXT,04
1810        >FT BIN,06
1820        >FT DIR,0F
1830        >FT ADB,19
1840        >FT AWP,1A
1850        >FT ASP,1B
1860        >FT PAS,EF
1870        >FT CMD,F0
1880        >FT S-C,FA   (NORMALLY "INT")
1890        >FT IVR,FB
1900        >FT BAS,FC
1910        >FT VAR,FD
1920        >FT REL,FE
1930        >FT SYS,FF
1940 LAST.FILE.TYPE .EQ *-FILE.TYPES-1
1950 *--------------------------------
1960 *   NAMES OF THE MONTHS
1970 *--------------------------------
1980 MONTH.NAMES
1990        .AS -/JFMAMJJASOND/
2000        .AS -/AEAPAUUUECOE/
2010        .AS -/NBRRYNLGPTVC/
2020 *--------------------------------
2030 NO.DATE.MSG
2040        .AS -//
2050 *--------------------------------
2060 *   MLI ERROR CODES
2070 *--------------------------------
2080 MLI.ERROR.CODES
2090        .HS 282B4041424344454647
2100        .HS 48494B4C4D4E505356
2110 *--------------------------------
2120 *   EQUIVALENT BI ERROR CODES
2130 *--------------------------------
2140 BI.ERROR.CODES
2150        .HS 0304100C0C1206068613  (86 IS A TRICK)
2160        .HS 09110D05020A140B0C08
2170 *--------------------------------
2180 MESSAGES
2190        .AC 0        INIT NYBBLE.FLAG
2200        .AC 1"ACDEFILNOPRST %"
2210        .AC 2"BGHKMUVWXY/():."
2220        .AC 3"QZ-4567890123@&"
2230 Q.BLOCKS.ABOVE .EQ 0
2240        .AC / BLOCKS SHOWN ABOVE:6%/
2250 *--------------------------------
2260 Q.DIRHDR .EQ 1
2270        .AC /TYPE   NAME2BLOCKS  MODIFIED9CREATED9ENDFILE AUXTYPE%/
2280 *--------------------------------
2290        .AC /RANGE ERROR%/
2300        .AC /NO DEVICE CONNECTED%/
2310        .AC /WRITE PROTECTED%/
2320        .AC /END OF DATA%/
2330        .AC /PATH NOT FOUND%/
2340 *--------------------------------
2350 Q.BLOCKS .EQ 7
2360        .AC / VOLUME BLOCKS USED:8FREE:8TOTAL:5%/
2370 *--------------------------------
2380        .AC "I/O ERROR%"
2390        .AC /DISK FULL%/
2400        .AC /FILE LOCKED%/
2410        .AC /INVALID PARAMETER%/
2420        .AC /NO BUFFERS AVAILABLE%/
2430        .AC /FILE TYPE MISMATCH%/
2440        .AC /PROGRAM TOO LARGE%/
2450        .AC /NOT DIRECT COMMAND%/
2460        .AC /SYNTAX ERROR%/
2470        .AC /DIRECTORY FULL%/
2480        .AC /FILE NOT OPEN%/
2490        .AC /DUPLICATE FILE NAME%/
2500        .AC /FILE BUSY%/
2510        .AC /FILE(S) STILL OPEN%/
2520 *--------------------------------
2530        .AC "%"
2540 ZZ.MESSAGES .EQ *-MESSAGES
2550 *--------------------------------
2560 FIRST.TABLE .EQ *
2570        .HS 00
2580        .AS -"ACDEFILNOPRST "
2590        .HS 8D
2600 SECOND.TABLE .EQ *
2610        .HS 00
2620        .AS -"BGHKMUVWXY/():."
2630 THIRD.TABLE .EQ *
2640        .AS -"JQZ-"
2650        .HS 05.06.07.08.09.0A.0B.0C.0D.0E.0F.10   (BLANK COUNTS+1)
2660 *--------------------------------
