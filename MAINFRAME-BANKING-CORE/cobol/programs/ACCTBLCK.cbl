      *================================================================*
      * PROGRAM: ACCTBLCK                                             *
      * PURPOSE: ACCOUNT BLOCK AND UNBLOCK OPERATIONS                *
      * AUTHOR:  MAINFRAME-BANKING-CORE                               *
      * DATE:    2025                                                  *
      * ENVIRONMENT: OS/VS COBOL - MVS 3.8J TK4-                     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ACCTBLCK.

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

       01  WS-SUBMENU-OPT           PIC X(01).
       01  WS-INPUT-ACCT            PIC X(10).

       PROCEDURE DIVISION.

       0000-MAIN.
           MOVE 'ACCTBLCK' TO WS-PROGRAM-NAME
           OPEN I-O ACCOUNT-FILE
           IF WS-ACCT-FILE-STATUS NOT = '00'
               DISPLAY 'ACCTBLCK: FILE OPEN ERROR FS='
                        WS-ACCT-FILE-STATUS
               STOP RUN
           END-IF
           PERFORM 1000-MENU
               UNTIL WS-SUBMENU-OPT = 'X' OR 'x'
           CLOSE ACCOUNT-FILE
           GOBACK.

       1000-MENU.
           DISPLAY ' '
           DISPLAY '=== ACCOUNT BLOCKING ========================'
           DISPLAY '  B - BLOCK ACCOUNT                         '
           DISPLAY '  U - UNBLOCK ACCOUNT                       '
           DISPLAY '  X - RETURN                                '
           DISPLAY '============================================='
           DISPLAY 'OPTION: ' WITH NO ADVANCING
           ACCEPT  WS-SUBMENU-OPT
           EVALUATE WS-SUBMENU-OPT
             WHEN 'B' WHEN 'b'  PERFORM 2000-BLOCK-ACCOUNT
             WHEN 'U' WHEN 'u'  PERFORM 3000-UNBLOCK-ACCOUNT
             WHEN 'X' WHEN 'x'  CONTINUE
             WHEN OTHER  DISPLAY MSG-INVALID-OPT
           END-EVALUATE.

       2000-BLOCK-ACCOUNT.
           DISPLAY 'ACCOUNT NUMBER: ' WITH NO ADVANCING
           ACCEPT  WS-INPUT-ACCT
           MOVE WS-INPUT-ACCT TO ACCT-NBR
           READ ACCOUNT-FILE INTO ACCOUNT-RECORD
               KEY IS ACCT-NBR
           EVALUATE WS-ACCT-FILE-STATUS
             WHEN '23'  DISPLAY MSG-NOT-FOUND
             WHEN '00'
               IF ACCT-BLOCKED
                   DISPLAY 'ACCOUNT IS ALREADY BLOCKED'
               ELSE
               IF ACCT-CLOSED
                   DISPLAY MSG-ACCT-CLOSED
               ELSE
                   DISPLAY 'BLOCK REASON (30): ' WITH NO ADVANCING
                   ACCEPT  ACCT-BLOCK-REASON
                   CALL 'DATEVAL' USING WS-CURRENT-DATE
                   MOVE WS-CURRENT-DATE TO ACCT-BLOCK-DATE
                   MOVE 'B'             TO ACCT-STATUS
                   REWRITE ACCOUNT-FILE-RECORD FROM ACCOUNT-RECORD
                   IF WS-ACCT-FILE-STATUS = '00'
                       DISPLAY MSG-ACCT-BLOCKED-OK
                   ELSE
                       DISPLAY 'REWRITE ERR FS=' WS-ACCT-FILE-STATUS
                   END-IF
               END-IF
               END-IF
             WHEN OTHER
               DISPLAY 'READ ERR FS=' WS-ACCT-FILE-STATUS
           END-EVALUATE.

       3000-UNBLOCK-ACCOUNT.
           DISPLAY 'ACCOUNT NUMBER: ' WITH NO ADVANCING
           ACCEPT  WS-INPUT-ACCT
           MOVE WS-INPUT-ACCT TO ACCT-NBR
           READ ACCOUNT-FILE INTO ACCOUNT-RECORD
               KEY IS ACCT-NBR
           EVALUATE WS-ACCT-FILE-STATUS
             WHEN '23'  DISPLAY MSG-NOT-FOUND
             WHEN '00'
               IF NOT ACCT-BLOCKED
                   DISPLAY 'ACCOUNT IS NOT BLOCKED'
               ELSE
                   MOVE 'A'    TO ACCT-STATUS
                   MOVE SPACES TO ACCT-BLOCK-REASON
                   MOVE ZEROS  TO ACCT-BLOCK-DATE
                   REWRITE ACCOUNT-FILE-RECORD FROM ACCOUNT-RECORD
                   IF WS-ACCT-FILE-STATUS = '00'
                       DISPLAY MSG-ACCT-UNBLOCKED
                   ELSE
                       DISPLAY 'REWRITE ERR FS=' WS-ACCT-FILE-STATUS
                   END-IF
               END-IF
             WHEN OTHER
               DISPLAY 'READ ERR FS=' WS-ACCT-FILE-STATUS
           END-EVALUATE.
