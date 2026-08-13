      *================================================================*
      * PROGRAM: ERRHANDL                                             *
      * PURPOSE: CENTRALISED ERROR HANDLER / LOGGER                  *
      * CALLED BY: ALL PROGRAMS ON ABNORMAL FILE STATUS              *
      * ENVIRONMENT: OS/VS COBOL - MVS 3.8J TK4-                     *
      *================================================================*
      * PARAMETERS:                                                    *
      *   01 PARM-PROG    PIC X(08)  (calling program name)           *
      *   01 PARM-FS      PIC X(02)  (file status received)           *
      *   01 PARM-KEY     PIC X(10)  (key/context info)               *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ERRHANDL.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-ERR-LINE              PIC X(79).
       01  WS-CURRENT-DATE          PIC 9(08).
       01  WS-DATE-WORK             PIC 9(06).

       LINKAGE SECTION.
       01  PARM-PROG                PIC X(08).
       01  PARM-FS                  PIC X(02).
       01  PARM-KEY                 PIC X(10).

       PROCEDURE DIVISION USING PARM-PROG PARM-FS PARM-KEY.

       0000-MAIN.
           ACCEPT WS-DATE-WORK FROM DATE
           STRING '19' DELIMITED SIZE
                  WS-DATE-WORK DELIMITED SIZE
                  INTO WS-CURRENT-DATE
           STRING
               '*** ERROR: PROG=' PARM-PROG
               ' FS=' PARM-FS
               ' KEY=' PARM-KEY
               ' DATE=' WS-CURRENT-DATE
               DELIMITED SIZE INTO WS-ERR-LINE
           DISPLAY WS-ERR-LINE
           EVALUATE PARM-FS
             WHEN '24'
               DISPLAY '    NOSPACE - DATASET MAY BE FULL'
             WHEN '30'
               DISPLAY '    PERMANENT I/O READ ERROR'
             WHEN '34'
               DISPLAY '    PERMANENT I/O WRITE ERROR'
             WHEN '35'
               DISPLAY '    FILE DOES NOT EXIST - CHECK JCL DD'
             WHEN '41'
               DISPLAY '    FILE ALREADY OPEN'
             WHEN '42'
               DISPLAY '    FILE NOT OPEN - LOGIC ERROR'
             WHEN OTHER
               DISPLAY '    UNEXPECTED FILE STATUS'
           END-EVALUATE
           GOBACK.
