      *================================================================*
      * PROGRAM: DATEVAL                                              *
      * PURPOSE: DATE UTILITY - GET CURRENT DATE / VALIDATE DATE     *
      * CALLED BY: ALL PROGRAMS NEEDING CURRENT DATE                 *
      * ENVIRONMENT: OS/VS COBOL - MVS 3.8J TK4-                     *
      *================================================================*
      * PARAMETER:                                                     *
      *   01 PARM-DATE  PIC 9(08)  (YYYYMMDD output)                  *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. DATEVAL.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-DATE-WORK.
           05  WS-YYMMDD            PIC 9(06).
           05  WS-YYMMDD-X REDEFINES WS-YYMMDD.
               10  WS-YY            PIC 9(02).
               10  WS-MM            PIC 9(02).
               10  WS-DD            PIC 9(02).
           05  WS-CENTURY           PIC 9(02).

       LINKAGE SECTION.
       01  PARM-DATE                PIC 9(08).

       PROCEDURE DIVISION USING PARM-DATE.

       0000-MAIN.
      *--- TK4-/MVS 3.8J uses CURRENT-DATE which returns YYMMDD ----*
      *--- We prefix with century 19 (safe for TK4- era dates) -----*
           ACCEPT WS-YYMMDD FROM DATE
           MOVE 19 TO WS-CENTURY
      *--- Build YYYYMMDD
           MOVE WS-CENTURY TO PARM-DATE(1:2)
           MOVE WS-YY      TO PARM-DATE(3:2)
           MOVE WS-MM      TO PARM-DATE(5:2)
           MOVE WS-DD      TO PARM-DATE(7:2)
           GOBACK.
