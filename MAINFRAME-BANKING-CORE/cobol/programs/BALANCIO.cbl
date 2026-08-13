      *================================================================*
      * PROGRAM: BALANCIO                                             *
      * PURPOSE: BALANCE INQUIRY                                      *
      * AUTHOR:  MAINFRAME-BANKING-CORE                               *
      * DATE:    2025                                                  *
      * ENVIRONMENT: OS/VS COBOL - MVS 3.8J TK4-                     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BALANCIO.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNT-FILE
               ASSIGN TO ACCTMST
               ORGANIZATION IS INDEXED
               ACCESS MODE  IS RANDOM
               RECORD KEY   IS ACCT-NBR
               FILE STATUS  IS WS-ACCT-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  ACCOUNT-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 110 CHARACTERS.
       01  ACCOUNT-FILE-RECORD      PIC X(110).

       WORKING-STORAGE SECTION.
       COPY WRKSTORE.
       COPY FILESTCD.
       COPY MSGLIB.
       COPY ACCTLAYO.

       01  WS-BALANCE-DISP          PIC ZZZ,ZZZ,ZZZ,ZZ9.99-.
       01  WS-ANOTHER               PIC X(01).
       01  WS-SEPARATOR             PIC X(79) VALUE ALL '='.

       PROCEDURE DIVISION.

       0000-MAIN.
           MOVE 'BALANCIO' TO WS-PROGRAM-NAME
           OPEN INPUT ACCOUNT-FILE
           IF WS-ACCT-FILE-STATUS NOT = '00'
               DISPLAY 'BALANCIO: FILE OPEN ERROR FS='
                        WS-ACCT-FILE-STATUS
               STOP RUN
           END-IF
           MOVE 'Y' TO WS-ANOTHER
           PERFORM 1000-INQUIRY
               UNTIL WS-ANOTHER = 'N' OR 'n'
           CLOSE ACCOUNT-FILE
           GOBACK.

       1000-INQUIRY.
           DISPLAY ' '
           DISPLAY '=== BALANCE INQUIRY ========================='
           DISPLAY 'ACCOUNT NUMBER: ' WITH NO ADVANCING
           ACCEPT  ACCT-NBR
           READ ACCOUNT-FILE INTO ACCOUNT-RECORD
               KEY IS ACCT-NBR
           EVALUATE WS-ACCT-FILE-STATUS
             WHEN '00'
               PERFORM 1100-DISPLAY-BALANCE
             WHEN '23'
               DISPLAY MSG-NOT-FOUND
             WHEN OTHER
               DISPLAY 'READ ERROR FS=' WS-ACCT-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-ACCT-FILE-STATUS
                                     ACCT-NBR
           END-EVALUATE
           DISPLAY ' '
           DISPLAY 'ANOTHER INQUIRY? (Y/N): ' WITH NO ADVANCING
           ACCEPT  WS-ANOTHER.

       1100-DISPLAY-BALANCE.
           MOVE ACCT-BALANCE TO WS-BALANCE-DISP
           DISPLAY WS-SEPARATOR
           DISPLAY 'ACCOUNT     : ' ACCT-NBR
           DISPLAY 'TYPE        : ' ACCT-TYPE
           DISPLAY 'STATUS      : ' ACCT-STATUS
           IF ACCT-BLOCKED
               DISPLAY '*** ACCOUNT IS BLOCKED ***'
           END-IF
           IF ACCT-CLOSED
               DISPLAY '*** ACCOUNT IS CLOSED ***'
           END-IF
           DISPLAY 'BALANCE     : ' WS-BALANCE-DISP
           DISPLAY 'LAST MOVMT  : ' ACCT-LAST-MOV-DATE
           DISPLAY 'BRANCH      : ' ACCT-BRANCH-CODE
           DISPLAY WS-SEPARATOR.
