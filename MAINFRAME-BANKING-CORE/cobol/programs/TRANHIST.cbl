      *================================================================*
      * PROGRAM: TRANHIST                                             *
      * PURPOSE: TRANSACTION HISTORY INQUIRY - SEQUENTIAL BY ACCOUNT *
      * AUTHOR:  MAINFRAME-BANKING-CORE                               *
      * DATE:    2025                                                  *
      * ENVIRONMENT: OS/VS COBOL - MVS 3.8J TK4-                     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TRANHIST.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TRAN-HIST-FILE
               ASSIGN TO TRANHIST
               ORGANIZATION IS INDEXED
               ACCESS MODE  IS DYNAMIC
               RECORD KEY   IS TRAN-KEY
               FILE STATUS  IS WS-TRAN-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  TRAN-HIST-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 150 CHARACTERS.
       01  TRAN-HIST-RECORD         PIC X(150).

       WORKING-STORAGE SECTION.
       COPY WRKSTORE.
       COPY FILESTCD.
       COPY MSGLIB.
       COPY TRANLAYO.

       01  WS-INPUT-ACCT            PIC X(10).
       01  WS-TRAN-COUNT            PIC 9(06) VALUE 0.
       01  WS-AMOUNT-DISP           PIC ZZZ,ZZZ,ZZZ,ZZ9.99-.
       01  WS-ANOTHER               PIC X(01).
       01  WS-SEPARATOR             PIC X(79) VALUE ALL '-'.

       PROCEDURE DIVISION.

       0000-MAIN.
           MOVE 'TRANHIST' TO WS-PROGRAM-NAME
           OPEN INPUT TRAN-HIST-FILE
           IF WS-TRAN-FILE-STATUS NOT = '00'
               DISPLAY 'TRANHIST: FILE OPEN ERROR FS='
                        WS-TRAN-FILE-STATUS
               STOP RUN
           END-IF
           MOVE 'Y' TO WS-ANOTHER
           PERFORM 1000-DO-INQUIRY
               UNTIL WS-ANOTHER = 'N' OR 'n'
           CLOSE TRAN-HIST-FILE
           GOBACK.

       1000-DO-INQUIRY.
           MOVE ZEROS TO WS-TRAN-COUNT
           MOVE 'N'   TO WS-EOF-FLAG
           DISPLAY ' '
           DISPLAY '=== TRANSACTION HISTORY ====================='
           DISPLAY 'ACCOUNT NUMBER: ' WITH NO ADVANCING
           ACCEPT  WS-INPUT-ACCT
           MOVE WS-INPUT-ACCT   TO TRAN-ACCT-NBR
           MOVE ZEROS           TO TRAN-DATE
           MOVE ZEROS           TO TRAN-SEQ
           START TRAN-HIST-FILE KEY >= TRAN-KEY
           EVALUATE WS-TRAN-FILE-STATUS
             WHEN '00'
               PERFORM 1100-READ-LOOP
                   UNTIL WS-EOF = 'Y'
             WHEN '23'
               DISPLAY MSG-NO-MOVEMENT
             WHEN OTHER
               DISPLAY 'START ERROR FS=' WS-TRAN-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-TRAN-FILE-STATUS
                                     WS-INPUT-ACCT
           END-EVALUATE
           IF WS-TRAN-COUNT = 0
               DISPLAY MSG-NO-MOVEMENT
           ELSE
               DISPLAY WS-SEPARATOR
               DISPLAY 'TOTAL RECORDS: ' WS-TRAN-COUNT
           END-IF
           DISPLAY 'ANOTHER INQUIRY? (Y/N): ' WITH NO ADVANCING
           ACCEPT  WS-ANOTHER.

       1100-READ-LOOP.
           READ TRAN-HIST-FILE NEXT INTO TRANSACTION-RECORD
           EVALUATE WS-TRAN-FILE-STATUS
             WHEN '10'
               MOVE 'Y' TO WS-EOF-FLAG
             WHEN '00'
               IF TRAN-ACCT-NBR = WS-INPUT-ACCT
                   PERFORM 1200-DISPLAY-TRAN
                   ADD 1 TO WS-TRAN-COUNT
               ELSE
                   MOVE 'Y' TO WS-EOF-FLAG
               END-IF
             WHEN OTHER
               DISPLAY 'READ ERR FS=' WS-TRAN-FILE-STATUS
               MOVE 'Y' TO WS-EOF-FLAG
           END-EVALUATE.

       1200-DISPLAY-TRAN.
           MOVE TRAN-AMOUNT TO WS-AMOUNT-DISP
           DISPLAY WS-SEPARATOR
           DISPLAY 'DATE: ' TRAN-DATE '  SEQ: ' TRAN-SEQ
                   '  TYPE: ' TRAN-TYPE '  STATUS: ' TRAN-STATUS
           DISPLAY 'AMOUNT  : ' WS-AMOUNT-DISP
           DISPLAY 'REJECT  : ' TRAN-REJECT-CODE
                   '  ' TRAN-REJECT-DESC
           IF TRAN-TRANSFER
               DISPLAY 'TARGET  : ' TRAN-TARGET-ACCT
               DISPLAY 'SOURCE  : ' TRAN-SOURCE-ACCT
           END-IF
           DISPLAY 'CHANNEL : ' TRAN-CHANNEL
                   '  OPERATOR: ' TRAN-OPERATOR.
