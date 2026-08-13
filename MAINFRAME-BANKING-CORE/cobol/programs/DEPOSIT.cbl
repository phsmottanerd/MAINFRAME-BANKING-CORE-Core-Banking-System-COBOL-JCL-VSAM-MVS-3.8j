      *================================================================*
      * PROGRAM: DEPOSIT                                              *
      * PURPOSE: DEPOSIT PROCESSING WITH BUSINESS RULES              *
      * AUTHOR:  MAINFRAME-BANKING-CORE                               *
      * DATE:    2025                                                  *
      * ENVIRONMENT: OS/VS COBOL - MVS 3.8J TK4-                     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPOSIT.

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
           SELECT TRAN-HIST-FILE
               ASSIGN TO TRANHIST
               ORGANIZATION IS INDEXED
               ACCESS MODE  IS RANDOM
               RECORD KEY   IS TRAN-KEY
               FILE STATUS  IS WS-TRAN-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  ACCOUNT-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 110 CHARACTERS.
       01  ACCOUNT-FILE-RECORD      PIC X(110).

       FD  TRAN-HIST-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 150 CHARACTERS.
       01  TRAN-HIST-RECORD         PIC X(150).

       WORKING-STORAGE SECTION.
       COPY WRKSTORE.
       COPY FILESTCD.
       COPY MSGLIB.
       COPY ACCTLAYO.
       COPY TRANLAYO.

       01  WS-DEPOSIT-AMT           PIC S9(13)V99 COMP-3.
       01  WS-DEPOSIT-AMT-INPUT     PIC X(16).
       01  WS-BALANCE-DISP          PIC ZZZ,ZZZ,ZZZ,ZZ9.99-.
       01  WS-ANOTHER               PIC X(01).

       PROCEDURE DIVISION.

       0000-MAIN.
           MOVE 'DEPOSIT ' TO WS-PROGRAM-NAME
           OPEN I-O ACCOUNT-FILE
           IF WS-ACCT-FILE-STATUS NOT = '00'
               DISPLAY 'DEPOSIT: ACCOUNT FILE OPEN ERROR FS='
                        WS-ACCT-FILE-STATUS
               STOP RUN
           END-IF
           OPEN I-O TRAN-HIST-FILE
           IF WS-TRAN-FILE-STATUS = '35'
               OPEN OUTPUT TRAN-HIST-FILE
               CLOSE TRAN-HIST-FILE
               OPEN I-O TRAN-HIST-FILE
           END-IF
           MOVE 'Y' TO WS-ANOTHER
           PERFORM 1000-DO-DEPOSIT
               UNTIL WS-ANOTHER = 'N' OR 'n'
           CLOSE ACCOUNT-FILE
           CLOSE TRAN-HIST-FILE
           GOBACK.

       1000-DO-DEPOSIT.
           MOVE 'N'    TO WS-ERROR-FLAG
           DISPLAY ' '
           DISPLAY '=== DEPOSIT ================================='
           DISPLAY 'ACCOUNT NUMBER: ' WITH NO ADVANCING
           ACCEPT  ACCT-NBR
           READ ACCOUNT-FILE INTO ACCOUNT-RECORD
               KEY IS ACCT-NBR
           EVALUATE WS-ACCT-FILE-STATUS
             WHEN '23'
               DISPLAY MSG-NOT-FOUND
               MOVE 'Y' TO WS-ERROR-FLAG
             WHEN '00'
               CONTINUE
             WHEN OTHER
               DISPLAY 'READ ERROR FS=' WS-ACCT-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-ACCT-FILE-STATUS
                                     ACCT-NBR
               MOVE 'Y' TO WS-ERROR-FLAG
           END-EVALUATE
           IF WS-ERROR-FLAG = 'Y'
               GO TO 1000-DEPOSIT-SKIP
           END-IF
           IF ACCT-BLOCKED
               DISPLAY MSG-ACCT-BLOCKED
               GO TO 1000-DEPOSIT-SKIP
           END-IF
           IF ACCT-CLOSED
               DISPLAY MSG-ACCT-CLOSED
               GO TO 1000-DEPOSIT-SKIP
           END-IF
           DISPLAY 'DEPOSIT AMOUNT: ' WITH NO ADVANCING
           ACCEPT  WS-DEPOSIT-AMT-INPUT
           MOVE FUNCTION NUMVAL(WS-DEPOSIT-AMT-INPUT)
               TO WS-DEPOSIT-AMT
           IF WS-DEPOSIT-AMT <= 0
               DISPLAY MSG-NEG-AMOUNT
               GO TO 1000-DEPOSIT-SKIP
           END-IF
           ADD WS-DEPOSIT-AMT TO ACCT-BALANCE
           CALL 'DATEVAL' USING WS-CURRENT-DATE
           MOVE WS-CURRENT-DATE TO ACCT-LAST-MOV-DATE
           REWRITE ACCOUNT-FILE-RECORD FROM ACCOUNT-RECORD
           IF WS-ACCT-FILE-STATUS NOT = '00'
               DISPLAY 'REWRITE ERROR FS=' WS-ACCT-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-ACCT-FILE-STATUS
                                     ACCT-NBR
               GO TO 1000-DEPOSIT-SKIP
           END-IF
           PERFORM 1100-WRITE-HISTORY
           MOVE ACCT-BALANCE TO WS-BALANCE-DISP
           DISPLAY MSG-OPERATION-OK
           DISPLAY 'NEW BALANCE : ' WS-BALANCE-DISP
       1000-DEPOSIT-SKIP.
           DISPLAY 'ANOTHER DEPOSIT? (Y/N): ' WITH NO ADVANCING
           ACCEPT  WS-ANOTHER.

       1100-WRITE-HISTORY.
           MOVE SPACES           TO TRANSACTION-RECORD
           MOVE ACCT-NBR         TO TRAN-ACCT-NBR
           MOVE WS-CURRENT-DATE  TO TRAN-DATE
           ADD 1 TO WS-TRAN-SEQ-CTR
           MOVE WS-TRAN-SEQ-CTR  TO TRAN-SEQ
           MOVE 'DP'             TO TRAN-TYPE
           MOVE WS-DEPOSIT-AMT   TO TRAN-AMOUNT
           MOVE 'A'              TO TRAN-STATUS
           MOVE ACCT-BALANCE     TO TRAN-BALANCE-AFTER
           MOVE 'TSO'            TO TRAN-CHANNEL
           WRITE TRAN-HIST-RECORD FROM TRANSACTION-RECORD
           IF WS-TRAN-FILE-STATUS = '22'
               ADD 1 TO WS-TRAN-SEQ-CTR
               MOVE WS-TRAN-SEQ-CTR TO TRAN-SEQ
               WRITE TRAN-HIST-RECORD FROM TRANSACTION-RECORD
           END-IF
           IF WS-TRAN-FILE-STATUS NOT = '00'
               DISPLAY 'TRAN HIST WRITE ERR FS=' WS-TRAN-FILE-STATUS
           END-IF.
